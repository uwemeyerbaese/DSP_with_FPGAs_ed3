-- This is a generic DLMS FIR filter generator 
-- It uses W1 bit data/coefficients bits
LIBRARY lpm;                   -- Using predefined packages
USE lpm.lpm_components.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY fir6dlms IS                      ------> Interface
  GENERIC (W1 : INTEGER := 8; -- Input bit width
           W2 : INTEGER := 16;-- Multiplier bit width 2*W1
           L  : INTEGER := 2; -- Filter length 
           Delay  : INTEGER := 3 -- Pipeline Delay 
           );
  PORT ( clk    : IN STD_LOGIC;
         x_in   : IN  STD_LOGIC_VECTOR(W1-1 DOWNTO 0);
         d_in   : IN  STD_LOGIC_VECTOR(W1-1 DOWNTO 0);
        e_out, y_out : OUT STD_LOGIC_VECTOR(W2-1 DOWNTO 0);
    f0_out, f1_out  : OUT STD_LOGIC_VECTOR(W1-1 DOWNTO 0));
END fir6dlms;

ARCHITECTURE fpga OF fir6dlms IS

  SUBTYPE N1BIT IS STD_LOGIC_VECTOR(W1-1 DOWNTO 0);
  SUBTYPE N2BIT IS STD_LOGIC_VECTOR(W2-1 DOWNTO 0);
  TYPE ARRAY_N1BITF IS ARRAY (0 TO L-1) OF N1BIT;
  TYPE ARRAY_N1BITX IS ARRAY (0 TO Delay+L-1) OF N1BIT;
  TYPE ARRAY_N1BITD IS ARRAY (0 TO Delay) OF N1BIT ;
  TYPE ARRAY_N1BIT IS ARRAY (0 TO L-1) OF N1BIT;
  TYPE ARRAY_N2BIT IS ARRAY (0 TO L-1) OF N2BIT;

  SIGNAL  xemu0, xemu1       :  N1BIT;
  SIGNAL  emu     :  N1BIT;
  SIGNAL  y, sxty :  N2BIT;

  SIGNAL  e, sxtd  :  N2BIT;
  SIGNAL  f        :  ARRAY_N1BITF; -- Coefficient array 
  SIGNAL  x        :  ARRAY_N1BITX; -- Data array 
  SIGNAL  d        :  ARRAY_N1BITD; -- Reference array 
  SIGNAL  p, xemu  :  ARRAY_N2BIT;  -- Product array 
                                          
BEGIN

  dsxt: PROCESS (d)  -- make d a 16 bit number
  BEGIN
    sxtd(7 DOWNTO 0) <= d(Delay);
    FOR k IN 15 DOWNTO 8 LOOP
      sxtd(k) <= d(3)(7);
    END LOOP;
  END PROCESS;

  Store: PROCESS   ------> Store these data or coefficients
  BEGIN
    WAIT UNTIL clk = '1';  
      d(0) <= d_in;   -- Shift register for desired data
      d(1) <= d(0);
      d(2) <= d(1);
      d(3) <= d(2);
      x(0) <= x_in;   -- Shift register for data          
      x(1) <= x(0);
      x(2) <= x(1);
      x(3) <= x(2);
      x(4) <= x(3);
      f(0) <= f(0) + xemu(0)(15 DOWNTO 8); -- implicit 
      f(1) <= f(1) + xemu(1)(15 DOWNTO 8); -- divide by 2
  END PROCESS Store;
 
  MulGen1: FOR I IN 0 TO L-1 GENERATE 
  FIR: lpm_mult             -- Multiply p(i) = f(i) * x(i);
        GENERIC MAP ( LPM_WIDTHA => W1, LPM_WIDTHB => W1, 
                      LPM_REPRESENTATION => "SIGNED", 
                      LPM_PIPELINE => Delay,                      
                      LPM_WIDTHP => W2, 
                      LPM_WIDTHS => W2)  
        PORT MAP ( dataa => x(I), datab => f(I),                      
                             result => p(I), clock => clk);
        END GENERATE;

  y <= p(0) + p(1);  -- Computer ADF output

  ysxt: PROCESS (y) -- scale y by 128 because x is fraction
  BEGIN
    sxty(8 DOWNTO 0) <= y(15 DOWNTO 7);
    FOR k IN 15 DOWNTO 9 LOOP
      sxty(k) <= y(y'high);
    END LOOP;
  END PROCESS;

  e <= sxtd - sxty;        -- e*mu divide by 2 and 2
  emu <= e(8 DOWNTO 1);    -- from xemu makes mu=1/4                            

  MulGen2: FOR I IN 0 TO L-1 GENERATE 
  FUPDATE: lpm_mult       -- Multiply xemu(i) = emu * x(i);
        GENERIC MAP ( LPM_WIDTHA => W1, LPM_WIDTHB => W1, 
                      LPM_REPRESENTATION => "SIGNED", 
                      LPM_PIPELINE => Delay,                      
                      LPM_WIDTHP => W2, 
                      LPM_WIDTHS => W2)  
        PORT MAP ( dataa => x(I+Delay), datab => emu, 
                          result => xemu(I), clock => clk);
        END GENERATE;

    y_out <= sxty;    -- Monitor some test signals
    e_out <= e;
    f0_out <= f(0);
    f1_out <= f(1);

END fpga;

