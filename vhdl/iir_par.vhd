PACKAGE n_bit_int IS          -- User-defined type
  SUBTYPE BITS15 IS INTEGER RANGE -2**14 TO 2**14-1;
END n_bit_int;

LIBRARY work;
USE work.n_bit_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY iir_par IS                      ------> Interface
  PORT ( clk, reset : IN  STD_LOGIC;
         x_in     : IN  BITS15;
         x_e, x_o, y_e, y_o : OUT BITS15;
         clk2     : OUT STD_LOGIC;
         y_out    : OUT BITS15);
END iir_par;

ARCHITECTURE fpga OF iir_par IS

  TYPE STATE_TYPE IS (even, odd);
  SIGNAL  state                     : STATE_TYPE;
  SIGNAL  x_even, xd_even           : BITS15 := 0;
  SIGNAL  x_odd, xd_odd, x_wait     : BITS15 := 0;
  SIGNAL  y_even, y_odd, y_wait, y  : BITS15 := 0;  
  SIGNAL  sum_x_even, sum_x_odd     : BITS15 := 0;
  SIGNAL  clk_div2                  : STD_LOGIC;

BEGIN
 
  Multiplex: PROCESS (reset, clk) --> Split x into even and
  BEGIN             -- odd samples; recombine y at clk rate
    IF reset = '1' THEN               -- asynchronous reset
      state <= even;
    ELSIF rising_edge(clk) THEN    
    CASE state IS
      WHEN even =>   
         x_even <= x_in; 
         x_odd <= x_wait;
         clk_div2 <= '1';
         y <= y_wait;
         state <= odd;
      WHEN odd => 
         x_wait <= x_in;
         y <= y_odd;
         y_wait <= y_even;
         clk_div2 <= '0';
         state <= even;
      END CASE;
      END IF;
  END PROCESS Multiplex;

  y_out <= y;
  clk2  <= clk_div2;
  x_e <= x_even; -- Monitor some extra test signals
  x_o <= x_odd;
  y_e <= y_even;
  y_o <= y_odd;

  Arithmetic: PROCESS
  BEGIN
    WAIT UNTIL clk_div2 = '0';  
    xd_even <= x_even;
    sum_x_even <= (xd_even * 2 + xd_even) /4 + x_odd;
    y_even <= (y_even * 8 + y_even )/16 + sum_x_even;
    xd_odd <= x_odd;
    sum_x_odd <= (xd_odd * 2 + xd_odd) /4 + xd_even;
    y_odd  <= (y_odd * 8 + y_odd) / 16 + sum_x_odd;
  END PROCESS Arithmetic;
  
END fpga;
