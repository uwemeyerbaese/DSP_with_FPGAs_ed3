-- Title: T-RISC stack machine 
-- Description: This is the top control path/FSM of the 
-- T-RISC, with a single three-phase clock cycle design
-- It has a stack machine/0-address-type instruction word
-- The stack has only four words.

LIBRARY lpm; USE lpm.lpm_components.ALL;

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_arith.ALL;
USE ieee.STD_LOGIC_signed.ALL;

ENTITY trisc0 IS 
 GENERIC (WA : INTEGER := 7; -- Address bit width -1
          WD : INTEGER := 7); -- Data bit width -1
 PORT(reset, clk : IN  STD_LOGIC;
      jc_OUT     : OUT BOOLEAN;
      me_ena     : OUT STD_LOGIC;
      iport      : IN  STD_LOGIC_VECTOR(WD DOWNTO 0);
      oport      : OUT STD_LOGIC_VECTOR(WD DOWNTO 0);
      s0_OUT, s1_OUT, dmd_IN, dmd_OUT : OUT 
                             STD_LOGIC_VECTOR(WD DOWNTO 0);
      pc_OUT, dma_OUT, dma_IN : OUT 
                             STD_LOGIC_VECTOR(WA DOWNTO 0);
      ir_imm     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      op_code    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END;

ARCHITECTURE fpga OF trisc0 IS

  TYPE state_type IS (ifetch, load, store, incpc);
  SIGNAL state    : state_type;
  SIGNAL op   : STD_LOGIC_VECTOR(3 DOWNTO 0);   
  SIGNAL imm, s0, s1, s2, s3, dmd 
                           : STD_LOGIC_VECTOR(wd DOWNTO 0);
  SIGNAL pc, dma : STD_LOGIC_VECTOR(wa DOWNTO 0);
  SIGNAL pmd, ir   : STD_LOGIC_VECTOR(11 DOWNTO 0);
  SIGNAL eq, ne, mem_ena, not_clk : STD_LOGIC;
  SIGNAL jc       :  boolean;

-- OP Code of instructions:
  CONSTANT add   : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"0";
  CONSTANT neg   : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"1";
  CONSTANT sub   : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"2";
  CONSTANT opand : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"3";
  CONSTANT opor  : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"4";
  CONSTANT inv   : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"5";
  CONSTANT mul   : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"6";
  CONSTANT pop   : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"7";
  CONSTANT pushi : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"8";
  CONSTANT push  : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"9";
  CONSTANT scan  : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"A";
  CONSTANT print : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"B";
  CONSTANT cne   : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"C";
  CONSTANT ceq   : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"D";
  CONSTANT cjp   : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"E";
  CONSTANT jmp   : STD_LOGIC_VECTOR(3 DOWNTO 0) := X"F";

BEGIN

  FSM: PROCESS (op, clk, reset) -- FSM of processor
  BEGIN -- store in register ? 
      CASE op IS -- always store except Branch
        WHEN pop    => mem_ena <= '1';
        WHEN OTHERS => mem_ena <= '0';
      END CASE;
      IF reset = '1' THEN
        pc <= (OTHERS => '0');
      ELSIF FALLING_EDGE(clk) THEN
        IF ((op=cjp) AND NOT jc ) OR  (op=jmp) THEN
          pc <= imm;
        ELSE 
          pc <= pc + "00000001"; 
        END IF;
      END IF;
      IF reset = '1' THEN
        jc <= false;
      ELSIF rising_edge(clk) THEN
        jc <= (op=ceq AND s0=s1) OR (op=cne AND s0/=s1);
      END IF;
  END PROCESS FSM;

  -- Mapping of the instruction, i.e., decode instruction
  op   <= ir(11 DOWNTO 8);   -- Operation code
  dma  <= ir(7 DOWNTO 0);    -- Data memory address
  imm  <= ir(7 DOWNTO 0);    -- Immidiate operand

  prog_rom: lpm_rom
  GENERIC MAP ( lpm_width => 12,                 
                lpm_widthad => 8,
                lpm_outdata => "registered",
                lpm_address_control => "unregistered",
                lpm_file => "TRISC0FAC.MIF")
  PORT MAP ( outclock => clk, address => pc, q => pmd);
  not_clk <= NOT clk;

  data_ram: lpm_ram_dq
  GENERIC MAP ( lpm_width => 8,                 
                lpm_widthad => 8,
                lpm_indata => "registered",
                lpm_outdata => "unregistered",
                lpm_address_control => "registered")                       
  PORT MAP ( data => s0, we => mem_ena, inclock => not_clk,
               address => dma, q => dmd);

  ALU: PROCESS (op, clk)
  VARIABLE temp: STD_LOGIC_VECTOR(2*WD+1 DOWNTO 0);
  BEGIN
    IF rising_edge(clk) THEN
      CASE op IS
        WHEN add    =>   s0  <= s0 + s1;
        WHEN neg    =>   s0  <= -s0;
        WHEN sub    =>   s0  <= s1 - s0;
        WHEN opand  =>   s0  <= s0 AND s1;
        WHEN opor   =>   s0  <= s0 OR s1;
        WHEN inv    =>   s0  <= NOT s0; 
        WHEN mul    =>   temp  := s0 * s1;
                         s0  <= temp(WD DOWNTO 0);
        WHEN pop    =>   s0  <= s1;
        WHEN pushi  =>   s0  <= imm;
        WHEN push   =>   s0  <= dmd;
        WHEN scan   =>   s0 <= iport;
        WHEN print  =>   oport <= s0; s0<=s1;
        WHEN OTHERS =>   s0 <= (OTHERS => '0');
      END CASE;
      CASE op IS    -- Specify the stack operations
        WHEN pushi | push | scan => s3<=s2; s2<=s1; s1<=s0;
                                               -- Push type
        WHEN cjp | jmp | inv | neg => NULL;   
                                   -- Do nothing for branch
        WHEN OTHERS =>   s1<=s2; s2<=s3; s3<=(OTHERS=>'0');
                                          -- Pop all others
      END CASE;
    END IF;
  END PROCESS ALU;

  -- Extra test pins:
  dmd_OUT <= dmd; dma_OUT <= dma; -- Data memory I/O
  dma_IN <= dma; dmd_IN  <= s0;
  pc_OUT <= pc; ir <= pmd; ir_imm <= imm; op_code <= op;  
                                                 -- Program
  jc_OUT <= jc; me_ena <= mem_ena; -- Control signals
  s0_OUT <= s0; s1_OUT <= s1;     -- Two top stack elements

END fpga;
