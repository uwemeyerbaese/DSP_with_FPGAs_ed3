-- This is a generic FIR filter generator 
-- It uses W1 bit data/coefficients bits
LIBRARY lpm;                     -- Using predefined packages
USE lpm.lpm_components.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY fir_gen IS                      ------> Interface
  GENERIC (W1 : INTEGER := 9; -- Input bit width
           W2 : INTEGER := 18;-- Multiplier bit width 2*W1
           W3 : INTEGER := 19;-- Adder width = W2+log2(L)-1
           W4 : INTEGER := 11;-- Output bit width
           L  : INTEGER := 4; -- Filter length 
        Mpipe : INTEGER := 3-- Pipeline steps of multiplier
           );
  PORT ( clk    : IN STD_LOGIC;
         Load_x : IN  STD_LOGIC;
         x_in   : IN  STD_LOGIC_VECTOR(W1-1 DOWNTO 0);
         c_in   : IN  STD_LOGIC_VECTOR(W1-1 DOWNTO 0);
         y_out  : OUT STD_LOGIC_VECTOR(W4-1 DOWNTO 0));
END fir_gen;

ARCHITECTURE fpga OF fir_gen IS

  SUBTYPE N1BIT IS STD_LOGIC_VECTOR(W1-1 DOWNTO 0);
  SUBTYPE N2BIT IS STD_LOGIC_VECTOR(W2-1 DOWNTO 0);
  SUBTYPE N3BIT IS STD_LOGIC_VECTOR(W3-1 DOWNTO 0);
  TYPE ARRAY_N1BIT IS ARRAY (0 TO L-1) OF N1BIT;
  TYPE ARRAY_N2BIT IS ARRAY (0 TO L-1) OF N2BIT;
  TYPE ARRAY_N3BIT IS ARRAY (0 TO L-1) OF N3BIT;

  SIGNAL  x  :  N1BIT;
  SIGNAL  y  :  N3BIT;
  SIGNAL  c  :  ARRAY_N1BIT; -- Coefficient array 
  SIGNAL  p  :  ARRAY_N2BIT; -- Product array 
  SIGNAL  a  :  ARRAY_N3BIT; -- Adder array 
                                                        
BEGIN

  Load: PROCESS            ------> Load data or coefficient
  BEGIN
    WAIT UNTIL clk = '1';  
    IF (Load_x = '0') THEN
      c(L-1) <= c_in;      -- Store coefficient in register
      FOR I IN L-2 DOWNTO 0 LOOP  -- Coefficients shift one
        c(I) <= c(I+1);
      END LOOP;
    ELSE
      x <= x_in;           -- Get one data sample at a time
    END IF;
  END PROCESS Load;


  SOP: PROCESS (clk)        ------> Compute sum-of-products
  BEGIN
    IF clk'event and (clk = '1') THEN
    FOR I IN 0 TO L-2  LOOP      -- Compute the transposed
      a(I) <= (p(I)(W2-1) & p(I)) + a(I+1); -- filter adds
    END LOOP;
    a(L-1) <= p(L-1)(W2-1) & p(L-1);     -- First TAP has 
    END IF;                              -- only a register
    y <= a(0);
  END PROCESS SOP;

  -- Instantiate L pipelined multiplier 
  MulGen: FOR I IN 0 TO L-1 GENERATE 
  Muls: lpm_mult               -- Multiply p(i) = c(i) * x;
        GENERIC MAP ( LPM_WIDTHA => W1, LPM_WIDTHB => W1, 
                      LPM_PIPELINE => Mpipe,
                      LPM_REPRESENTATION => "SIGNED", 
                      LPM_WIDTHP => W2, 
                      LPM_WIDTHS => W2)  
        PORT MAP ( clock => clk, dataa => x, 
                   datab => c(I), result => p(I));
        END GENERATE;

  y_out <= y(W3-1 DOWNTO W3-W4);  

END fpga;

