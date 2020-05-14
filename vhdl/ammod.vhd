PACKAGE nine_bit_int IS    -- User-defined types
  SUBTYPE NINE_BIT IS INTEGER RANGE -256 TO 255;
  TYPE ARRAY_NINE_BIT IS ARRAY (0 TO 3) OF NINE_BIT;
END nine_bit_int;

LIBRARY work;
USE work.nine_bit_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY ammod IS                      ------> Interface
       PORT (clk               : IN  STD_LOGIC;
             r_in , phi_in     : IN  NINE_BIT;
             x_out, y_out, eps : OUT NINE_BIT);
END ammod;

ARCHITECTURE fpga OF ammod IS

BEGIN
 
  PROCESS                   ------> Behavioral Style 
    VARIABLE x, y, z : ARRAY_NINE_BIT := (0,0,0,0);  
  BEGIN                           -- Tapped delay lines
  WAIT UNTIL clk = '1';    -- Compute last value first 
    x_out <= x(3);         -- in sequential statements !!
    eps   <= z(3);
    y_out <= y(3);

    IF z(2) >= 0 THEN                 -- Rotate 14 degrees
      x(3) := x(2) - y(2) /4;
      y(3) := y(2) + x(2) /4;
      z(3) := z(2) - 14;
    ELSE
      x(3) := x(2) + y(2) /4;
      y(3) := y(2) - x(2) /4;
      z(3) := z(2) + 14;
    END IF;

    IF z(1) >= 0 THEN                 -- Rotate 26 degrees
      x(2) := x(1) - y(1) /2;
      y(2) := y(1) + x(1) /2;
      z(2) := z(1) - 26;
    ELSE
      x(2) := x(1) + y(1) /2;
      y(2) := y(1) - x(1) /2;
      z(2) := z(1) + 26;
    END IF;

    IF z(0) >= 0 THEN                -- Rotate  45 degrees
      x(1) := x(0) - y(0);
      y(1) := y(0) + x(0);
      z(1) := z(0) - 45;
    ELSE
      x(1) := x(0) + y(0);
      y(1) := y(0) - x(0);
      z(1) := z(0) + 45;
    END IF;

    IF phi_in > 90    THEN     -- Test for |phi_in| > 90 
      x(0) := 0;               -- Rotate 90 degrees
      y(0) := r_in;            -- Input in register 0
      z(0) := phi_in - 90;
    ELSIF phi_in < -90 THEN
      x(0) := 0;
      y(0) := - r_in;
      z(0) := phi_in + 90;
    ELSE
      x(0) := r_in;
      y(0) := 0;
      z(0) := phi_in;
    END IF;
  END PROCESS;
  
END fpga;