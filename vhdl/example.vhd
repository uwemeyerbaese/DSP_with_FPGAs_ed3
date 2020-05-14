PACKAGE eight_bit_int IS    -- User-defined type
  SUBTYPE BYTE IS INTEGER RANGE -128 TO 127;
END eight_bit_int;

LIBRARY work;
USE work.eight_bit_int.ALL;

LIBRARY lpm;                   -- Using predefined packages
USE lpm.lpm_components.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY example IS                         ------> Interface
  GENERIC (WIDTH : INTEGER := 8);   -- Bit width 
  PORT (clk  :  IN STD_LOGIC;
        a, b :  IN BYTE;
        op1  :  IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
        sum  :  OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
        d    :  OUT BYTE);
END example;

ARCHITECTURE fpga OF example IS

  SIGNAL  c, s        :  BYTE;       -- Auxiliary variables
  SIGNAL  op2, op3    :  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  
BEGIN

  -- Conversion int -> logic vector
  op2 <= CONV_STD_LOGIC_VECTOR(b,8);   

  add1: lpm_add_sub         ------> Component instantiation
    GENERIC MAP (LPM_WIDTH => WIDTH,
                 LPM_REPRESENTATION => "SIGNED",
                 LPM_DIRECTION => "ADD")  
    PORT MAP (dataa => op1, 
              datab => op2,
              result => op3);
  reg1: lpm_ff
    GENERIC MAP (LPM_WIDTH => WIDTH )  
    PORT MAP (data => op3, 
              q => sum,
              clock => clk);

  c <= a  + b ;                 ------> Data flow style
 
  p1: PROCESS                   ------> Behavioral style 
  BEGIN
    WAIT UNTIL clk = '1';
    s <= c + s;           ----> Signal assignment statement
  END PROCESS p1;
  d <= s;

END fpga;