-- Restoring Division
LIBRARY ieee;               -- Using predefined packages
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY div_res IS                      ------> Interface
  GENERIC(WN : INTEGER := 8;
          WD : INTEGER := 6;
          PO2WND : INTEGER := 8192; -- 2**(WN+WD)
          PO2WN1 : INTEGER := 128;  -- 2**(WN-1)
          PO2WN : INTEGER := 255);  -- 2**WN-1
  PORT ( clk, reset     : IN  STD_LOGIC;
         n_in    : IN  STD_LOGIC_VECTOR(WN-1 DOWNTO 0); 
         d_in    : IN  STD_LOGIC_VECTOR(WD-1 DOWNTO 0);
         r_out   : OUT STD_LOGIC_VECTOR(WD-1 DOWNTO 0);
         q_out   : OUT STD_LOGIC_VECTOR(WN-1 DOWNTO 0));
END div_res;

ARCHITECTURE flex OF div_res IS

  SUBTYPE TWOWORDS IS INTEGER RANGE -1 TO PO2WND-1;
  SUBTYPE WORD IS INTEGER RANGE 0 TO PO2WN;

  TYPE STATE_TYPE IS (s0, s1, s2, s3);
  SIGNAL s : STATE_TYPE;

BEGIN
-- Bit width:  WN         WD           WN            WD
--         Numerator / Denominator = Quotient and Remainder
-- OR:       Numerator = Quotient * Denominator + Remainder

  States: PROCESS(reset, clk)-- Divider in behavioral style
    VARIABLE  r, d : TWOWORDS :=0;  -- N+D bit width
    VARIABLE  q : WORD;
    VARIABLE count  : INTEGER RANGE 0 TO WN;
  BEGIN
    IF reset = '1' THEN               -- asynchronous reset
      s <= s0;
    ELSIF rising_edge(clk) THEN  
    CASE s IS
      WHEN s0 =>          -- Initialization step 
        s <= s1;
        count := 0;
        q := 0;           -- Reset quotient register
        d := PO2WN1  * CONV_INTEGER(d_in); -- Load denom.        
        r := CONV_INTEGER(n_in); -- Remainder = numerator
      WHEN s1 =>          -- Processing step
          r := r - d;     -- Subtract denominator
          s <= s2;
      WHEN s2 =>          -- Restoring step
        IF r < 0 THEN     
          r := r + d;     -- Restore previous remainder
          q := q * 2;     -- LSB = 0 and SLL
        ELSE
          q := 2 * q + 1; -- LSB = 1 and SLL
        END IF;
        count := count + 1;
        d := d / 2;
        IF count = WN THEN -- Division ready ?
          s <= s3;
        ELSE
          s <= s1;
        END IF;
      WHEN s3 =>                   -- Output of result
        q_out <= CONV_STD_LOGIC_VECTOR(q, WN); 
        r_out <= CONV_STD_LOGIC_VECTOR(r, WD); 
        s <= s0;               -- Start next division
    END CASE;
    END IF;
  END PROCESS States;
  
END flex;
