PACKAGE n_bit_int IS             -- User-defined type
  SUBTYPE BITS15 IS INTEGER RANGE -2**14 TO 2**14-1;
END n_bit_int;

LIBRARY work;
USE work.n_bit_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY iir_pipe IS
  PORT ( x_in  : IN   BITS15;   -- Input
         y_out : OUT  BITS15;   -- Result
         clk   : IN   STD_LOGIC);
END iir_pipe;

ARCHITECTURE fpga OF iir_pipe IS

  SIGNAL  x, x3, sx, y, y9 : BITS15 := 0;
            
BEGIN

  PROCESS  -- Use FFs for input, output and pipeline stages
  BEGIN
    WAIT UNTIL clk = '1';
    x   <= x_in;
    x3  <= x / 2 + x / 4;   -- Compute x*3/4
    sx <=  x + x3; -- Sum of x element i.e. output FIR part
    y9  <= y / 2 + y / 16;  -- Compute y*9/16
    y   <= sx + y9;         -- Compute output
  END PROCESS;

  y_out <= y ;    -- Connect register y to output pins
  
END fpga;
