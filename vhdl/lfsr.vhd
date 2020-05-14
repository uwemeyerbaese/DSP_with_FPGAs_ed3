LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY lfsr IS                      ------> Interface
  PORT ( clk : IN  STD_LOGIC;
         y   : OUT STD_LOGIC_VECTOR(6 DOWNTO 1));
END lfsr;

ARCHITECTURE fpga OF lfsr IS

  SIGNAL  ff  :   STD_LOGIC_VECTOR(6 DOWNTO 1) 
                                        := (OTHERS => '0');  
BEGIN

  PROCESS          -- Implement length 6 LFSR with xnor
  BEGIN
    WAIT UNTIL clk = '1';
    ff(1) <= NOT (ff(5) XOR ff(6));
    FOR I IN 6 DOWNTO 2 LOOP    -- Tapped delay line: 
      ff(I) <= ff(I-1);         -- shift one 
    END LOOP;
  END PROCESS ;

  PROCESS (ff)
  BEGIN              -- Connect to I/O cell
    FOR k IN 1 TO 6 LOOP
      y(k) <= ff(k); 
    END LOOP;
  END PROCESS;
  
END fpga;
