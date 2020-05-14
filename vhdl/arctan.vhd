PACKAGE n_bits_int IS          -- User-defined types
  SUBTYPE BITS9 IS INTEGER RANGE -2**8 TO 2**8-1;
  TYPE ARRAY_BITS9_4 IS ARRAY (1 TO 5) of BITS9;
END n_bits_int;

LIBRARY work;
USE work.n_bits_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY arctan IS                          ------> Interface
  PORT (clk      : IN  STD_LOGIC;
        x_in     : IN  BITS9;
        d_o      : OUT ARRAY_BITS9_4;
        f_out    : OUT BITS9);
END arctan;

ARCHITECTURE fpga OF arctan IS

  SIGNAL x,f,d1,d2,d3,d4,d5 : BITS9; -- Auxilary signals
  SIGNAL d : ARRAY_BITS9_4 := (0,0,0,0,0);-- Auxilary array
  -- Chebychev coefficients for 8-bit precision: 
  CONSTANT c1 : BITS9 := 212;
  CONSTANT c3 : BITS9 := -12;
  CONSTANT c5 : BITS9 := 1;

BEGIN

  STORE: PROCESS    ------> I/O store in register 
  BEGIN                    
    WAIT UNTIL clk = '1';
    x <= x_in;
    f_out <= f;
  END PROCESS;

  --> Compute sum-of-products:
  SOP: PROCESS (x,d) 
  BEGIN
-- Clenshaw's recurrence formula
  d(5) <= c5; 
  d(4) <= x * d(5) / 128;
  d(3) <= x * d(4) / 128 - d(5) + c3;
  d(2) <= x * d(3) / 128 - d(4);
  d(1) <= x * d(2) / 128 - d(3) + c1;
  f  <= x * d(1) / 256 - d(2); -- last step is different
  END PROCESS SOP;
  
  d_o <= d;     -- Provide some test signals as outputs

END fpga;
