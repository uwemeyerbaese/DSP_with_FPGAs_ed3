PACKAGE n_bit_int IS               -- User-defined type
  SUBTYPE BITS15 IS INTEGER RANGE -2**14 TO 2**14-1;
END n_bit_int;

LIBRARY work;
USE work.n_bit_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY iir IS
  PORT (x_in  : IN  BITS15;     -- Input
        y_out : OUT BITS15;     -- Result
        clk   : IN  STD_LOGIC);
END iir;

ARCHITECTURE fpga OF iir IS

  SIGNAL x, y : BITS15 := 0;
 
BEGIN

  PROCESS     -- Use FF for input and recursive part
  BEGIN
    WAIT UNTIL clk = '1';
    x  <= x_in;
    y  <= x + y / 4 + y / 2;
  end process;

  y_out <= y;           -- Connect y to output pins
  
END fpga;
