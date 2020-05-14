LIBRARY ieee;               -- Using predefined packages
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY dasign IS                      ------> Interface
       PORT (clk, reset : IN STD_LOGIC;
             x_in0, x_in1, x_in2 
                        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
             lut  : out INTEGER RANGE -2 TO 4;
             y    : OUT INTEGER RANGE -64 TO 63);
END dasign;

ARCHITECTURE fpga OF dasign IS

  COMPONENT case3s      -- User-defined components
    PORT ( table_in : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); 
          table_out : OUT INTEGER RANGE -2 TO 4);
  END COMPONENT;

  TYPE STATE_TYPE IS (s0, s1);
  SIGNAL state      : STATE_TYPE;
  SIGNAL table_in   : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL x0, x1, x2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL table_out  : INTEGER RANGE -2 TO 4;
  
BEGIN

  table_in(0) <= x0(0);
  table_in(1) <= x1(0);
  table_in(2) <= x2(0);

  PROCESS (reset, clk)       ------> DA in behavioral style
    VARIABLE  p : INTEGER RANGE -64 TO 63:= 0; -- Temp. reg.
    VARIABLE count : INTEGER RANGE 0 TO 4; -- Counts the 
  BEGIN                                    -- shifts
    IF reset = '1' THEN               -- asynchronous reset
      state <= s0;
    ELSIF rising_edge(clk) THEN  
    CASE state IS
      WHEN s0 =>        -- Initialization step 
        state <= s1;
        count := 0;
        p := 0;           
        x0 <= x_in0;
        x1 <= x_in1;
        x2 <= x_in2;
      WHEN s1 =>          -- Processing step
        IF count = 4 THEN -- Is sum of product done?
          y <= p;      -- Output of result to y and
          state <= s0; -- start next sum of product
        ELSE
          IF count = 3 THEN           -- Subtract for last 
          p := p / 2 - table_out * 8; -- accumulator step
          ELSE                         
          p := p / 2 + table_out * 8;  -- Accumulation for
          END IF;                      -- all other steps
            FOR k IN 0 TO 2 LOOP    -- Shift bits
              x0(k) <= x0(k+1);
              x1(k) <= x1(k+1);
              x2(k) <= x2(k+1);
            END LOOP;
          count := count + 1;
          state <= s1;
        END IF;
    END CASE;
    END IF;
  END PROCESS;

  LC_Table0: case3s
    PORT MAP(table_in => table_in, table_out => table_out);
  lut <= table_out; -- Extra test signal

END fpga;
