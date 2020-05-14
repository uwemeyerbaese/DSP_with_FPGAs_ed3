-- Desciption: This is a W x L bit register file.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY reg_file IS
  GENERIC(W : INTEGER := 7; -- Bit width-1
          N : INTEGER := 15); -- Number of regs-1
  PORT ( clk, reg_ena : IN std_logic;
         data  : IN STD_LOGIC_VECTOR(W DOWNTO 0);
         rd, rs, rt : IN integer RANGE 0 TO 15;
         s, t : OUT STD_LOGIC_VECTOR(W DOWNTO 0));
END;

ARCHITECTURE fpga OF reg_file IS

  SUBTYPE bitw IS STD_LOGIC_VECTOR(W DOWNTO 0);
  TYPE SLV_NxW IS ARRAY (0 TO N) OF bitw;
  SIGNAL r : SLV_NxW;

BEGIN

  MUX: PROCESS   -- Input mux inferring registers
  BEGIN
    WAIT UNTIL clk = '1';
    IF reg_ena = '1' AND rd > 0 THEN
      r(rd) <= data;
    END IF;
  END PROCESS MUX;

  DEMUX: PROCESS (r, rs, rt) --  2 output demux 
  BEGIN                      --  without registers
    IF rs > 0 THEN -- First source
      s <= r(rs);
    ELSE
      s <= (OTHERS => '0');
    END IF;
    IF rt > 0 THEN -- Second source
      t <= r(rt);
    ELSE
      t <= (OTHERS => '0');
    END IF;
  END PROCESS DEMUX;
                 
END fpga;