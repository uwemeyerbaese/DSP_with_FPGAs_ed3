LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY cic3s32 IS     
  PORT ( clk, reset  : IN STD_LOGIC;
         x_in        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         clk2        : OUT STD_LOGIC;
        y_out        : OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
END cic3s32;

ARCHITECTURE fpga OF cic3s32 IS

  SUBTYPE word26 IS STD_LOGIC_VECTOR(25 DOWNTO 0);
  SUBTYPE word21 IS STD_LOGIC_VECTOR(20 DOWNTO 0);
  SUBTYPE word16 IS STD_LOGIC_VECTOR(15 DOWNTO 0);
  SUBTYPE word14 IS STD_LOGIC_VECTOR(13 DOWNTO 0);
  SUBTYPE word13 IS STD_LOGIC_VECTOR(12 DOWNTO 0);
  SUBTYPE word12 IS STD_LOGIC_VECTOR(11 DOWNTO 0);

  TYPE    STATE_TYPE IS (hold, sample);
  SIGNAL  state      : STATE_TYPE ;
  SIGNAL  count      : INTEGER RANGE 0 TO 31;
  SIGNAL  x          : STD_LOGIC_VECTOR(7 DOWNTO 0)
                    := (OTHERS => '0'); -- Registered input
  SIGNAL  sxtx  : STD_LOGIC_VECTOR(25 DOWNTO 0);  
                                     -- Sign extended input
  SIGNAL  i0  : word26 := (OTHERS => '0');   -- I section 0
  SIGNAL  i1  : word21 := (OTHERS => '0');   -- I section 1
  SIGNAL  i2  : word16 := (OTHERS => '0');   -- I section 2
  SIGNAL  i2d1, i2d2, c1, c0 : word14 := (OTHERS => '0');  
                                    -- I and COMB section 0
  SIGNAL  c1d1, c1d2, c2 : word13 := (OTHERS=>'0');--COMB 1
  SIGNAL  c2d1, c2d2, c3 : word12 := (OTHERS=>'0');--COMB 2
      
BEGIN

  FSM: PROCESS (reset, clk)
  BEGIN
    IF reset = '1' THEN               -- Asynchronous reset
      state <= hold; 
      count <= 0;      
      clk2  <= '0';
    ELSIF rising_edge(clk) THEN  
      IF count = 31 THEN
        count <= 0;
        state <= sample;
        clk2  <= '1'; 
      ELSE
        count <= count + 1;
        state <= hold;
        clk2  <= '0';
      END IF;
    END IF;
  END PROCESS FSM;

  Sxt : PROCESS (x)
  BEGIN
    sxtx(7 DOWNTO 0) <= x;
    FOR k IN 25 DOWNTO 8 LOOP
      sxtx(k) <= x(x'high);
    END LOOP;
  END PROCESS Sxt;

  Int: PROCESS 
  BEGIN
  WAIT 
    UNTIL clk = '1';
      x   <= x_in;
      i0  <= i0 + x;        
      i1  <= i1 + i0(25 DOWNTO 5);  -- i.e., i0/32      
      i2  <= i2 + i1(20 DOWNTO 5);  -- i.e., i1/32
  END PROCESS Int;

  Comb: PROCESS 
  BEGIN
    WAIT UNTIL clk = '1';
    IF state = sample THEN
      c0   <= i2(15 DOWNTO 2);   -- i.e., i2/4
      i2d1 <= c0;
      i2d2 <= i2d1;
      c1   <= c0 - i2d2;
      c1d1 <= c1(13 DOWNTO 1);   -- i.e., c1/2
      c1d2 <= c1d1;
      c2   <= c1(13 DOWNTO 1) - c1d2; 
      c2d1 <= c2(12 DOWNTO 1);    -- i.e., c2/2
      c2d2 <= c2d1;
      c3   <= c2(12 DOWNTO 1) - c2d2;
    END IF;
  END PROCESS Comb;

  y_out <= c3(11 DOWNTO 2);    -- i.e., c3/4

END fpga;