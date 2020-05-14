LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY lfsr6s3 IS                      ------> Interface
  PORT ( clk : IN  STD_LOGIC;
         y   : OUT STD_LOGIC_VECTOR(6 DOWNTO 1));
END lfsr6s3;

ARCHITECTURE fpga OF lfsr6s3 IS

  SIGNAL ff : STD_LOGIC_VECTOR(6 DOWNTO 1) := (OTHERS => '0');  
  
BEGIN

  PROCESS   -- Implement three step length-6 LFSR with xnor
  BEGIN
    WAIT UNTIL clk = '1';
    ff(6) <= ff(3);
    ff(5) <= ff(2);
    ff(4) <= ff(1);
    ff(3) <= NOT (ff(5) XOR ff(6));
    ff(2) <= NOT (ff(4) XOR ff(5));
    ff(1) <= NOT (ff(3) XOR ff(4));
  END PROCESS ;

  PROCESS (ff)
  BEGIN              -- Connect to I/O cell
    FOR k IN 1 TO 6 LOOP
      y(k) <= ff(k); 
    END LOOP;
  END PROCESS;
  
END fpga;
