PACKAGE eight_bit_int IS    -- User-defined types
  SUBTYPE BYTE IS INTEGER RANGE -128 TO 127;
  TYPE ARRAY_BYTE IS ARRAY (0 TO 3) OF BYTE;
END eight_bit_int;

LIBRARY work;
USE work.eight_bit_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY cordic IS                      ------> Interface
       PORT (clk         : IN  STD_LOGIC;
             x_in , y_in : IN  BYTE;
             r, phi, eps : OUT BYTE);
END cordic;

ARCHITECTURE fpga OF cordic IS
  SIGNAL  x, y, z : ARRAY_BYTE:= (0,0,0,0); 
BEGIN                                    -- Array of Bytes
 
  PROCESS                ------> Behavioral Style 
  BEGIN
    WAIT UNTIL clk = '1'; -- Compute last value first in
    r <= x(3);            -- sequential VHDL statements !!
    phi <= z(3);
    eps <= y(3);

    IF y(2) >= 0 THEN            -- Rotate 14 degrees
      x(3) <= x(2) + y(2) /4;
      y(3) <= y(2) - x(2) /4;
      z(3) <= z(2) + 14;
    ELSE
      x(3) <= x(2) - y(2) /4;
      y(3) <= y(2) + x(2) /4;
      z(3) <= z(2) - 14;
    END IF;

    IF y(1) >= 0 THEN            -- Rotate 26 degrees
      x(2) <= x(1) + y(1) /2;
      y(2) <= y(1) - x(1) /2;
      z(2) <= z(1) + 26;
    ELSE
      x(2) <= x(1) - y(1) /2;
      y(2) <= y(1) + x(1) /2;
      z(2) <= z(1) - 26;
    END IF;

    IF y(0) >= 0 THEN            -- Rotate  45 degrees
      x(1) <= x(0) + y(0);
      y(1) <= y(0) - x(0);
      z(1) <= z(0) + 45;
    ELSE
      x(1) <= x(0) - y(0);
      y(1) <= y(0) + x(0);
      z(1) <= z(0) - 45;
    END IF;

-- Test for x_in < 0 rotate 0,+90, or -90 degrees
    IF x_in >= 0 THEN 
      x(0) <= x_in;       -- Input in register 0
      y(0) <= y_in;
      z(0) <= 0;
    ELSIF y_in >= 0 THEN
      x(0) <= y_in;
      y(0) <= - x_in;
      z(0) <= 90;
    ELSE
      x(0) <= - y_in;
      y(0) <= x_in;
      z(0) <= -90;
    END IF;
  END PROCESS;
  
END fpga;
