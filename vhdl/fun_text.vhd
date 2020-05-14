--  A 32-bit function generator using accumulator and ROM

LIBRARY lpm;
USE lpm.lpm_components.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY fun_text IS
  GENERIC ( WIDTH   : INTEGER := 32);    -- Bit width
  PORT ( M        : IN  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
         sin, acc : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         clk      : IN  STD_LOGIC); 
END fun_text;

ARCHITECTURE fpga OF fun_text IS

  SIGNAL s, acc32 : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL msbs     : STD_LOGIC_VECTOR(7 DOWNTO 0);
                                       -- Auxiliary vectors
BEGIN

  add1: lpm_add_sub             -- Add M to acc32
    GENERIC MAP ( LPM_WIDTH => WIDTH,
                  LPM_REPRESENTATION => "SIGNED",
                  LPM_DIRECTION => "ADD",
                  LPM_PIPELINE => 0)                
    PORT MAP ( dataa => M, 
               datab => acc32,
               result => s );
    
  reg1: lpm_ff                  -- Save accu
    GENERIC MAP ( LPM_WIDTH => WIDTH)  
    PORT MAP ( data => s, 
               q => acc32,
               clock => clk);
    
  select1: PROCESS (acc32)
             VARIABLE i : INTEGER;
           BEGIN
             FOR i IN 7 DOWNTO 0 LOOP
               msbs(i) <= acc32(31-7+i);
             END LOOP;
           END PROCESS select1;
           
  acc <= msbs;

  rom1: lpm_rom
    GENERIC MAP ( LPM_WIDTH => 8,
                  LPM_WIDTHAD => 8,
                  LPM_FILE => "sine.mif")
    PORT MAP ( address => msbs, 
               inclock => clk,
               outclock => clk,
               q => sin);
            
END fpga;
