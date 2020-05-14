PACKAGE n_bits_int IS          -- User-defined types
  SUBTYPE BITS9 IS INTEGER RANGE -2**8 TO 2**8-1;
  SUBTYPE BITS18 IS INTEGER RANGE -2**17 TO 2**17-1;
  TYPE ARRAY_BITS18_6 IS ARRAY (0 TO 5) of BITS18;
END n_bits_int;

LIBRARY work;
USE work.n_bits_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY ln IS                          ------> Interface
  GENERIC (N : INTEGER := 5);-- Number of coeffcients-1 
  PORT (clk      : IN  STD_LOGIC;
        x_in     : IN  BITS18;
        f_out    : OUT BITS18);
END ln;

ARCHITECTURE fpga OF ln IS

  SIGNAL x, f : BITS18:= 0; -- Auxilary wire
-- Polynomial coefficients for 16-bit precision: 
-- f(x) = (1  + 65481 x -32093 x^2 + 18601 x^3 
--                      -8517 x^4 + 1954 x^5)/65536
  CONSTANT p : ARRAY_BITS18_6 := 
         (1,65481,-32093,18601,-8517,1954);
  SIGNAL s : ARRAY_BITS18_6 ;
 
BEGIN

  STORE: PROCESS    ------> I/O store in register 
  BEGIN                    
    WAIT UNTIL clk = '1';
    x <= x_in;
    f_out <= f;
  END PROCESS;

  --> Compute sum-of-products:
  SOP: PROCESS (x,s) 
  VARIABLE slv : STD_LOGIC_VECTOR(35 DOWNTO 0);
  BEGIN
-- Polynomial Approximation from Chebyshev coeffiecients
  s(N) <= p(N);
  FOR K IN N-1 DOWNTO 0 LOOP
    slv := CONV_STD_LOGIC_VECTOR(x,18) 
                        * CONV_STD_LOGIC_VECTOR(s(K+1),18);
    s(K) <= CONV_INTEGER(slv(33 downto 16)) + p(K); 
  END LOOP;   -- x*s/65536 problem 32 bits
  f  <= s(0);             -- make visiable outside
  END PROCESS SOP;
  
END fpga;
