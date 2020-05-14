-- Convergence division after Anderson, Earle, Goldschmidt, 
LIBRARY ieee;                                   -- and Powers
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY div_aegp IS                      ------> Interface
  GENERIC(WN : INTEGER := 9; -- 8 bit plus one integer bit
          WD : INTEGER := 9; 
          STEPS : INTEGER := 2;
          TWO : INTEGER := 512; -- 2**(WN+1)
          PO2WN  : INTEGER := 256;  -- 2**(WN-1)
          PO2WN2 : INTEGER := 1023);  -- 2**(WN+1)-1
  PORT ( clk, reset : IN  STD_LOGIC;
         n_in       : IN  STD_LOGIC_VECTOR(WN-1 DOWNTO 0); 
         d_in       : IN  STD_LOGIC_VECTOR(WD-1 DOWNTO 0);
         q_out      : OUT STD_LOGIC_VECTOR(WD-1 DOWNTO 0));
END div_aegp;

ARCHITECTURE fpga OF div_aegp IS

  SUBTYPE WORD IS INTEGER RANGE 0 TO PO2WN2;

  TYPE STATE_TYPE IS (s0, s1, s2);
  SIGNAL state    : STATE_TYPE;

BEGIN
-- Bit width:  WN         WD        WN             WD
--         Numerator / Denominator = Quotient and Remainder
-- OR:       Numerator = Quotient * Denominator + Remainder

  States: PROCESS(reset, clk)-- Divider in behavioral style
    VARIABLE  x, t, f : WORD:=0; -- WN+1 bits
    VARIABLE count  : INTEGER RANGE 0 TO STEPS;
  BEGIN
    IF reset = '1' THEN               -- asynchronous reset
      state <= s0;
    ELSIF rising_edge(clk) THEN    
    CASE state IS
      WHEN s0 =>              -- Initialization step 
        state <= s1;
        count := 0;
        t := CONV_INTEGER(d_in); -- Load denominator
        x := CONV_INTEGER(n_in); -- Load numerator
      WHEN s1 =>          -- Processing step
        f := TWO - t;
        x := x * f / PO2WN;
        t := t * f / PO2WN;
        count := count + 1;
        IF count = STEPS THEN -- Division ready ?
          state <= s2;
        ELSE
          state <= s1;
        END IF;
      WHEN s2 =>                   -- Output of results
        q_out <= CONV_STD_LOGIC_VECTOR(x, WN); 
        state <= s0;               -- start next division
    END CASE;
    END IF;
  END PROCESS States;
  
END fpga;
