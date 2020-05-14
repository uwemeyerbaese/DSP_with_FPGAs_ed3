PACKAGE eight_bit_int IS    -- User-defined types
  SUBTYPE BYTE IS INTEGER RANGE -128 TO 127;
  TYPE ARRAY_BYTE IS ARRAY (0 TO 3) OF BYTE;
END eight_bit_int;

LIBRARY work;
USE work.eight_bit_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY fir_srg IS                         ------> Interface
  PORT (clk   :   IN  STD_LOGIC;
        x     :   IN  BYTE;
        y     :   OUT BYTE);
END fir_srg;

ARCHITECTURE flex OF fir_srg IS

  SIGNAL tap : ARRAY_BYTE := (0,0,0,0);  
                               -- Tapped delay line of bytes
BEGIN

  p1: PROCESS             ------> Behavioral style 
  BEGIN
    WAIT UNTIL clk = '1';
  -- Compute output y with the filter coefficients weight.
  -- The coefficients are [-1  3.75  3.75  -1]. 
  -- Division for Altera VHDL is only allowed for 
  -- powers-of-two values!
    y <= 2 * tap(1) + tap(1) + tap(1) / 2 + tap(1) / 4 
         + 2 * tap(2) + tap(2) + tap(2) / 2 + tap(2) / 4 
         - tap(3) - tap(0);
    FOR I IN 3 DOWNTO 1 LOOP 
      tap(I) <= tap(I-1); -- Tapped delay line: shift one
    END LOOP;
    tap(0) <= x;                -- Input in register 0
  END PROCESS;

END flex;
