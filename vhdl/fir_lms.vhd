-- This is a generic LMS FIR filter generator 
-- It uses W1 bit data/coefficients bits
LIBRARY lpm;                   -- Using predefined packages
USE lpm.lpm_components.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY fir_lms IS                      ------> Interface
  GENERIC (W1 : INTEGER := 8;  -- Input bit width
           W2 : INTEGER := 16; -- Multiplier bit width 2*W1
           L  : INTEGER := 2   -- Filter length 
           );
      PORT ( clk    : IN  STD_LOGIC;
             x_in   : IN  STD_LOGIC_VECTOR(W1-1 DOWNTO 0);
             d_in   : IN  STD_LOGIC_VECTOR(W1-1 DOWNTO 0);
       e_out, y_out : OUT STD_LOGIC_VECTOR(W2-1 DOWNTO 0);
    f0_out, f1_out  : OUT STD_LOGIC_VECTOR(W1-1 DOWNTO 0));
END fir_lms;

ARCHITECTURE fpga OF fir_lms IS

  SUBTYPE N1BIT IS STD_LOGIC_VECTOR(W1-1 DOWNTO 0);
  SUBTYPE N2BIT IS STD_LOGIC_VECTOR(W2-1 DOWNTO 0);
  TYPE ARRAY_N1BIT IS ARRAY (0 TO L-1) OF N1BIT;
  TYPE ARRAY_N2BIT IS ARRAY (0 TO L-1) OF N2BIT;

  SIGNAL  d       :  N1BIT;
  SIGNAL  emu     :  N1BIT;
  SIGNAL  y, sxty :  N2BIT;

  SIGNAL  e, sxtd  :  N2BIT;
  SIGNAL  x, f     :  ARRAY_N1BIT; -- Coeff/Data arrays
  SIGNAL  p, xemu  :  ARRAY_N2BIT; -- Product arrays 
                                                        
BEGIN

  dsxt: PROCESS (d)  -- 16 bit signed extension for input d
  BEGIN
    sxtd(7 DOWNTO 0) <= d;
    FOR k IN 15 DOWNTO 8 LOOP
      sxtd(k) <= d(d'high);
    END LOOP;
  END PROCESS;

  Store: PROCESS   ------> Store these data or coefficients
  BEGIN
    WAIT UNTIL clk = '1';  
      d    <= d_in;
      x(0) <= x_in;           
      x(1) <= x(0);
      f(0) <= f(0) + xemu(0)(15 DOWNTO 8); -- implicit 
      f(1) <= f(1) + xemu(1)(15 DOWNTO 8); -- divide by 2
  END PROCESS Store;
 
  MulGen1: FOR I IN 0 TO L-1 GENERATE 
  FIR: lpm_mult             -- Multiply p(i) = f(i) * x(i);
        GENERIC MAP ( LPM_WIDTHA => W1, LPM_WIDTHB => W1, 
                      LPM_REPRESENTATION => "SIGNED", 
                      LPM_WIDTHP => W2, 
                      LPM_WIDTHS => W2)  
        PORT MAP ( dataa => x(I), datab => f(I), 
                                           result => p(I));
        END GENERATE;

  y <= p(0) + p(1);  -- Compute ADF output

  ysxt: PROCESS (y) -- Scale y by 128 because x is fraction
  BEGIN
    sxty(8 DOWNTO 0) <= y(15 DOWNTO 7);
    FOR k IN 15 DOWNTO 9 LOOP
      sxty(k) <= y(y'high);
    END LOOP;
  END PROCESS;

  e <= sxtd - sxty;
  emu <= e(8 DOWNTO 1);    -- e*mu divide by 2 and 
                           -- 2 from xemu makes mu=1/4
  MulGen2: FOR I IN 0 TO L-1 GENERATE 
  FUPDATE: lpm_mult       -- Multiply xemu(i) = emu * x(i);
        GENERIC MAP ( LPM_WIDTHA => W1, LPM_WIDTHB => W1, 
                      LPM_REPRESENTATION => "SIGNED", 
                      LPM_WIDTHP => W2, 
                      LPM_WIDTHS => W2)  
        PORT MAP ( dataa => x(I), datab => emu,
                                        result => xemu(I));
        END GENERATE;

    y_out  <= sxty;    -- Monitor some test signals
    e_out  <= e;
    f0_out <= f(0);
    f1_out <= f(1);

END fpga;

