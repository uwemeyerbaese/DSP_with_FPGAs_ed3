LIBRARY ieee;               -- Using predefined packages
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY dapara IS                      ------> Interface
       PORT (clk  : IN STD_LOGIC;
             x_in : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
             y    : OUT INTEGER RANGE -46 TO 44);
END dapara;

ARCHITECTURE fpga OF dapara IS
  TYPE ARRAY4x3 IS ARRAY (0 TO 3) 
                         OF STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL x : ARRAY4x3;
  TYPE IARRAY IS ARRAY (0 TO 3) OF INTEGER RANGE -2 TO 4;
  SIGNAL h : IARRAY;
  SIGNAL s0 : INTEGER RANGE -6 TO 12;
  SIGNAL s1 : INTEGER RANGE -10 TO 8;
  SIGNAL t0, t1, t2, t3 : INTEGER RANGE -2 TO 4;
  COMPONENT case3s
    PORT ( table_in   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
           table_out  : OUT INTEGER RANGE -2 TO 4);
  END COMPONENT;

BEGIN

  PROCESS                    ------> DA in behavioral style
  BEGIN
    WAIT UNTIL clk = '1';  
    FOR l IN 0 TO 3 LOOP  -- For all four vectors
      FOR k IN 0 TO 1 LOOP  -- shift all bits
        x(l)(k) <= x(l)(k+1);
      END LOOP;
    END LOOP;
    FOR k IN 0 TO 3 LOOP  -- Load x_in in the 
      x(k)(2) <= x_in(k); -- MSBs of the registers
    END LOOP;
    y <= h(0) + 2 * h(1) + 4 * h(2) - 8 * h(3);
-- Pipeline register and adder tree 
--  t0 <= h(0); t1 <= h(1); t2 <= h(2); t3 <= h(3); 
--  s0 <= t0 + 2 * t1; s1 <= t2 - 2 * t3; 
--  y <= s0 + 4 * s1;
  END PROCESS;

  LC_Tables: FOR k IN 0 TO 3 GENERATE -- One table for each
  LC_Table: case3s                    -- bit in x_in   
             PORT MAP(table_in => x(k), table_out => h(k));
  END GENERATE;  

END fpga;
