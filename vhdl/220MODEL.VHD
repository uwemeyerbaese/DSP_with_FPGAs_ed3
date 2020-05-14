--------------------------------------------------------------------------
--   This VHDL file was developed by Altera Corporation.  It may be freely
-- copied and/or distributed at no cost.  Any persons using this file for
-- any purpose do so at their own risk, and are responsible for the results
-- of such use.  Altera Corporation does not guarantee that this file is
-- complete, correct, or fit for any particular purpose.  NO WARRANTY OF
-- ANY KIND IS EXPRESSED OR IMPLIED.  This notice must accompany any copy
-- of this file.
--
--------------------------------------------------------------------------
-- LPM Synthesizable Models (Support string type generic)
--------------------------------------------------------------------------
-- Version 1.7 (lpm 220)      Date 07/13/99
--
-- 1. Changed LPM_RAM_IO so that it can be used to simulate both
--    MP2/Quartus behaviour and LPM220-compliant behaviour.
-- 
--------------------------------------------------------------------------
-- Version 1.6 (lpm 220)      Date 06/15/99
--
-- 1. Fixed LPM_ADD_SUB sign extension problem and subtraction bug.
-- 2. Fixed LPM_COUNTER to use LPM_MODULUS value.
-- 3. Added CIN and COUT port, and discarded EQ port in LPM_COUNTER to
--    comply with the specfication.
-- 4. Included LPM_RAM_DP, LPM_RAM_DQ, LPM_RAM_IO, LPM_ROM, LPM_FIFO, and
--    LPM_FIFO_DC; they are all initialized to 0's.
--------------------------------------------------------------------------
-- Version 1.5 (lpm 220)      Date 05/10/99
--
-- Changed LPM_MODULUS from string type to integer.
--------------------------------------------------------------------------
-- Version 1.4 (lpm 220)      Date 02/05/99
-- 
-- 1. Added LPM_DIVIDE module.
-- 2. Added CLKEN port to LPM_MUX, LPM_DECODE, LPM_ADD_SUB, LPM_MULT
--    and LPM_COMPARE
-- 3. Replaced the constants holding string with the actual string.
--------------------------------------------------------------------------
-- Version 1.3    Date 07/30/96
--
-- Modification History
--
-- 1. Changed the DEFAULT value to "UNUSED" for LPM_SVALUE, LPM_AVALUE,
-- LPM_MODULUS, and LPM_NUMWORDS, LPM_HINT,LPM_STRENGTH, LPM_DIRECTION,
-- and LPM_PVALUE
--
-- 2. Added the two dimentional port components (AND, OR, XOR, and MUX).
--------------------------------------------------------------------------
-- Excluded Functions:
--
--   LPM_FSM and LPM_TTABLE
--
--------------------------------------------------------------------------
-- Assumptions:
--
-- 1. All ports and signal types are std_logic or std_logic_vector
--    from IEEE 1164 package.
-- 2. Synopsys std_logic_arith, std_logic_unsigned, and std_logic_signed
--    package are assumed to be accessible from IEEE library.
-- 3. lpm_component_package must be accessible from library work.
-- 4. LPM_SVALUE, LPM_AVALUE, LPM_MODULUS, and LPM_NUMWORDS, LPM_HINT,
--    LPM_STRENGTH, LPM_DIRECTION, and LPM_PVALUE  default value is
--    string "UNUSED".
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_CONSTANT is
	generic (LPM_WIDTH : positive;
			 LPM_CVALUE : natural;
			 LPM_STRENGTH : string := "UNUSED";
			 LPM_TYPE : string := "LPM_CONSTANT";
			 LPM_HINT : string := "UNUSED");
	port (RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_CONSTANT;

architecture LPM_SYN of LPM_CONSTANT is
begin

	RESULT <= conv_std_logic_vector(LPM_CVALUE, LPM_WIDTH);

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_INV is
	generic (LPM_WIDTH : positive;
			 LPM_TYPE : string := "LPM_INV";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_INV;

architecture LPM_SYN of LPM_INV is
begin

 RESULT <= not DATA;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_AND is
	generic (LPM_WIDTH : positive;
			 LPM_SIZE : positive;
			 LPM_TYPE : string := "LPM_AND";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0, LPM_WIDTH-1 downto 0); 
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0)); 
end LPM_AND;

architecture LPM_SYN of LPM_AND is

signal RESULT_INT : std_logic_2d(LPM_SIZE-1 downto 0,LPM_WIDTH-1 downto 0);

begin

L1: for i in 0 to LPM_WIDTH-1 generate
		RESULT_INT(0,i) <= DATA(0,i);
L2:     for j in 0 to LPM_SIZE-2 generate
			RESULT_INT(j+1,i) <=  RESULT_INT(j,i) and DATA(j+1,i);
L3:         if j = LPM_SIZE-2 generate
				RESULT(i) <= RESULT_INT(LPM_SIZE-1,i);
			end generate L3;
		end generate L2;
	end generate L1;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_OR is
	generic (LPM_WIDTH : positive; 
			 LPM_SIZE : positive; 
			 LPM_TYPE : string := "LPM_OR";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0, LPM_WIDTH-1 downto 0); 
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0)); 
end LPM_OR;

architecture LPM_SYN of LPM_OR is

signal RESULT_INT : std_logic_2d(LPM_SIZE-1 downto 0,LPM_WIDTH-1 downto 0);

begin

L1: for i in 0 to LPM_WIDTH-1 generate
		RESULT_INT(0,i) <= DATA(0,i);
L2:     for j in 0 to LPM_SIZE-2 generate
			RESULT_INT(j+1,i) <=  RESULT_INT(j,i) or DATA(j+1,i);
L3:         if j = LPM_SIZE-2 generate
				RESULT(i) <= RESULT_INT(LPM_SIZE-1,i);
			end generate L3;
		end generate L2;
	end generate L1;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_XOR is
	generic (LPM_WIDTH : positive; 
			 LPM_SIZE : positive; 
			 LPM_TYPE : string := "LPM_XOR";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0, LPM_WIDTH-1 downto 0); 
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0)); 
end LPM_XOR;

architecture LPM_SYN of LPM_XOR is

signal RESULT_INT : std_logic_2d(LPM_SIZE-1 downto 0,LPM_WIDTH-1 downto 0);

begin

L1: for i in 0 to LPM_WIDTH-1 generate
		RESULT_INT(0,i) <= DATA(0,i);
L2:     for j in 0 to LPM_SIZE-2 generate
			RESULT_INT(j+1,i) <=  RESULT_INT(j,i) xor DATA(j+1,i);
L3:         if j = LPM_SIZE-2 generate
				RESULT(i) <= RESULT_INT(LPM_SIZE-1,i);
			end generate L3;
		end generate L2;
	end generate L1;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_BUSTRI is
	generic (LPM_WIDTH : positive;
			 LPM_TYPE : string := "LPM_BUSTRI";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  ENABLEDT : in std_logic := '0';
		  ENABLETR : in std_logic := '0';
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
		  TRIDATA : inout std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_BUSTRI;

architecture LPM_SYN of LPM_BUSTRI is
begin

	process(DATA, TRIDATA, ENABLETR, ENABLEDT)
	begin
		if ENABLEDT = '0' and ENABLETR = '1' then
			RESULT <= TRIDATA;
			TRIDATA <= (OTHERS => 'Z');
		elsif ENABLEDT = '1' and ENABLETR = '0' then
			RESULT <= (OTHERS => 'Z');
			TRIDATA <= DATA;
		elsif ENABLEDT = '1' and ENABLETR = '1' then
			RESULT <= DATA;
			TRIDATA <= DATA;
		else
			RESULT <= (OTHERS => 'Z');
			TRIDATA <= (OTHERS => 'Z');
		end if;
	end process;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_MUX is
	generic (LPM_WIDTH : positive; 
			 LPM_SIZE : positive; 
			 LPM_WIDTHS : positive; 
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE : string := "LPM_MUX";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0, LPM_WIDTH-1 downto 0);
		  ACLR : in std_logic := '0';
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  SEL : in std_logic_vector(LPM_WIDTHS-1 downto 0); 
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_MUX;

architecture LPM_SYN of LPM_MUX is

type t_resulttmp IS ARRAY (0 to LPM_PIPELINE) of std_logic_vector(LPM_WIDTH-1 downto 0);

begin

	process (ACLR, CLOCK, SEL, DATA)
	variable resulttmp : t_resulttmp;
	variable ISEL : integer;
	begin
		if LPM_PIPELINE >= 0 then
			ISEL := conv_integer(SEL);

			for i in 0 to LPM_WIDTH-1 loop
				resulttmp(LPM_PIPELINE)(i) := DATA(ISEL,i);
			end loop;

			if LPM_PIPELINE > 0 then
				if ACLR = '1' then
					for i in 0 to LPM_PIPELINE loop
						resulttmp(i) := (OTHERS => '0');
					end loop;
				elsif CLOCK'event and CLOCK = '1' and CLKEN = '1'  then
					resulttmp(0 to LPM_PIPELINE - 1) := resulttmp(1 to LPM_PIPELINE);
				end if;
			end if;

			RESULT <= resulttmp(0);
		end if;
	end process;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;


entity LPM_DECODE is
	generic (LPM_WIDTH : positive;
			 LPM_DECODES : positive;
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE : string := "LPM_DECODE";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  ACLR : in std_logic := '0';
		  ENABLE : in std_logic := '1';
		  EQ : out std_logic_vector(LPM_DECODES-1 downto 0));
end LPM_DECODE;

architecture LPM_SYN of LPM_DECODE is

type t_eqtmp IS ARRAY (0 to LPM_PIPELINE) of std_logic_vector(LPM_DECODES-1 downto 0);

begin

	process(ACLR, CLOCK, DATA, ENABLE)
	variable eqtmp : t_eqtmp;
	begin

		if LPM_PIPELINE >= 0 then
			for i in 0 to LPM_DECODES-1 loop
				if conv_integer(DATA) = i then
					if ENABLE = '1' then
						eqtmp(LPM_PIPELINE)(i) := '1';
					else
						eqtmp(LPM_PIPELINE)(i) := '0';
					end if;
				else
					eqtmp(LPM_PIPELINE)(i) := '0';
				end if;
			end loop;

			if LPM_PIPELINE > 0 then
				if ACLR = '1' then
					for i in 0 to LPM_PIPELINE loop
						eqtmp(i) := (OTHERS => '0');
					end loop;
				elsif CLOCK'event and CLOCK = '1' and CLKEN = '1' then
					eqtmp(0 to LPM_PIPELINE - 1) := eqtmp(1 to LPM_PIPELINE);
				end if;
			end if;
		end if;

		EQ <= eqtmp(0);
	end process;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_CLSHIFT is
	generic (LPM_WIDTH : positive;
			 LPM_WIDTHDIST : positive;
			 LPM_SHIFTTYPE : string := "LOGICAL";
			 LPM_TYPE : string := "LPM_CLSHIFT";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0); 
		  DISTANCE : in STD_LOGIC_VECTOR(LPM_WIDTHDIST-1 downto 0); 
		  DIRECTION : in STD_LOGIC := '0';
		  RESULT : out STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0);
		  UNDERFLOW : out STD_LOGIC;
		  OVERFLOW : out STD_LOGIC);
end LPM_CLSHIFT;

architecture LPM_SYN of LPM_CLSHIFT is

signal IRESULT : std_logic_vector(LPM_WIDTH-1 downto 0);
signal TMPDATA : std_logic_vector(LPM_WIDTHDIST downto 1);

begin

	process(DATA, DISTANCE, DIRECTION)
	begin
		TMPDATA <= (OTHERS => '0');
		if LPM_SHIFTTYPE = "ARITHMETIC" then
			if DIRECTION = '0' then
				IRESULT <= conv_std_logic_vector((conv_integer(DATA) * (2**LPM_WIDTHDIST)), LPM_WIDTH);
			else
				IRESULT <= conv_std_logic_vector((conv_integer(DATA) / (2**LPM_WIDTHDIST)), LPM_WIDTH);
			end if;
		elsif LPM_SHIFTTYPE = "ROTATE" then
			if DIRECTION = '0' then
				IRESULT <= (DATA(LPM_WIDTH-LPM_WIDTHDIST-1 downto 0) &
							DATA(LPM_WIDTH-1 downto LPM_WIDTH-LPM_WIDTHDIST));
			else
				IRESULT <= (DATA(LPM_WIDTHDIST-1 downto 0) &
				DATA(LPM_WIDTH-1 downto LPM_WIDTHDIST));
			end if;
		else
			if DIRECTION =  '1' then
				IRESULT <= (DATA(LPM_WIDTH-LPM_WIDTHDIST-1 downto 0) & TMPDATA);
			else
				IRESULT(LPM_WIDTH-LPM_WIDTHDIST-1 downto 0) <= DATA(LPM_WIDTH-1 downto LPM_WIDTHDIST);
					IRESULT(LPM_WIDTH-1 downto LPM_WIDTH-LPM_WIDTHDIST) <= (OTHERS => '0');
			end if;
		end if;
	end process;

	process(IRESULT)
	begin
		if LPM_SHIFTTYPE = "LOGICAL" or LPM_SHIFTTYPE = "ROTATE" then
			if IRESULT > 2 ** (LPM_WIDTH) then
				OVERFLOW <= '1';
			else
				OVERFLOW <= '0';
			end if;

			if IRESULT = 0 then
				UNDERFLOW <= '1';
			else
				UNDERFLOW <= '0';
			end if;
		else
			OVERFLOW <= '0';
			UNDERFLOW <= '0';
		end if;
	end process;

	RESULT <= IRESULT;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use work.LPM_COMPONENTS.all;

entity LPM_ADD_SUB_SIGNED is
	generic (LPM_WIDTH : positive;
			 LPM_DIRECTION : string := "UNUSED";
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE : string := "LPM_ADD_SUB";
			 LPM_HINT : string := "UNUSED");
	port (DATAA : in std_logic_vector(LPM_WIDTH downto 1);
		  DATAB : in std_logic_vector(LPM_WIDTH downto 1);
		  ACLR : in std_logic := '0';
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  CIN : in std_logic := '0';
		  ADD_SUB : in std_logic := '1';
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
		  COUT : out std_logic;
		  OVERFLOW : out std_logic);
end LPM_ADD_SUB_SIGNED;

architecture LPM_SYN of LPM_ADD_SUB_SIGNED is

signal A, B : std_logic_vector(LPM_WIDTH downto 0);
type t_resulttmp IS ARRAY (0 to LPM_PIPELINE) of std_logic_vector(LPM_WIDTH downto 0);

begin

	A <= (DATAA(LPM_WIDTH) & DATAA);
	B <= (DATAB(LPM_WIDTH) & DATAB);

	process(ACLR, CLOCK, A, B, CIN, ADD_SUB)
	variable resulttmp : t_resulttmp;
	variable couttmp : std_logic_vector(0 to LPM_PIPELINE);
	variable overflowtmp : std_logic_vector(0 to LPM_PIPELINE);
	begin

		if LPM_PIPELINE >= 0 then
			if LPM_DIRECTION = "ADD" or
			   (LPM_DIRECTION /= "SUB" and ADD_SUB = '1') then

				resulttmp(LPM_PIPELINE) := A + B + CIN;
				couttmp(LPM_PIPELINE) := resulttmp(LPM_PIPELINE)(LPM_WIDTH)
											xor DATAA(LPM_WIDTH)
											xor DATAB(LPM_WIDTH);
			else
				resulttmp(LPM_PIPELINE) := A - B + CIN - 1;
				couttmp(LPM_PIPELINE) := not resulttmp(LPM_PIPELINE)(LPM_WIDTH)
											xor DATAA(LPM_WIDTH)
											xor DATAB(LPM_WIDTH);
			end if;

			if (resulttmp(LPM_PIPELINE) > (2 ** (LPM_WIDTH-1)) -1) or
			   (resulttmp(LPM_PIPELINE) < -2 ** (LPM_WIDTH-1)) then

				overflowtmp(LPM_PIPELINE) := '1';
			else
				overflowtmp(LPM_PIPELINE) := '0';
			end if;

			if LPM_PIPELINE > 0 then
				if ACLR = '1' then
					overflowtmp := (OTHERS => '0');
					couttmp := (OTHERS => '0');
					for i in 0 to LPM_PIPELINE loop
						resulttmp(i) := (OTHERS => '0');
					end loop;
				elsif CLOCK'event and CLOCK = '1' and CLKEN = '1' then
					overflowtmp(0 to LPM_PIPELINE - 1) := overflowtmp(1 to LPM_PIPELINE);
					couttmp(0 to LPM_PIPELINE - 1) := couttmp(1 to LPM_PIPELINE);
					resulttmp(0 to LPM_PIPELINE - 1) := resulttmp(1 to LPM_PIPELINE);
				end if;
			end if;

			COUT <= couttmp(0);
			OVERFLOW <= overflowtmp(0);
			RESULT <= resulttmp(0)(LPM_WIDTH-1 downto 0);
		end if;
	end process;

end LPM_SYN;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_ADD_SUB_UNSIGNED is
	generic (LPM_WIDTH : positive;
			 LPM_DIRECTION : string := "UNUSED";
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE : string := "LPM_ADD_SUB";
			 LPM_HINT : string := "UNUSED");
	port (DATAA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  DATAB : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  ACLR : in std_logic := '0';
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  CIN : in std_logic := '0';
		  ADD_SUB : in std_logic := '1';
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
		  COUT : out std_logic;
		  OVERFLOW : out std_logic);
end LPM_ADD_SUB_UNSIGNED;

architecture LPM_SYN of LPM_ADD_SUB_UNSIGNED is
signal A, B : std_logic_vector(LPM_WIDTH downto 0);
type t_resulttmp IS ARRAY (0 to LPM_PIPELINE) of std_logic_vector(LPM_WIDTH downto 0);

begin

	A <= ('0' & DATAA);
	B <= ('0' & DATAB);

	process(ACLR, CLOCK, A, B, CIN, ADD_SUB)
	variable resulttmp : t_resulttmp;
	variable couttmp : std_logic_vector(0 to LPM_PIPELINE);
	variable overflowtmp : std_logic_vector(0 to LPM_PIPELINE);
	begin

		if LPM_PIPELINE >= 0 then
			if LPM_DIRECTION = "ADD" or
			   (LPM_DIRECTION /= "SUB" and ADD_SUB = '1') then

				resulttmp(LPM_PIPELINE) := A + B + CIN;
				couttmp(LPM_PIPELINE) := resulttmp(LPM_PIPELINE)(LPM_WIDTH);
			else
				resulttmp(LPM_PIPELINE) := A - B + CIN - 1;
				couttmp(LPM_PIPELINE) := not resulttmp(LPM_PIPELINE)(LPM_WIDTH);
			end if;

			overflowtmp(LPM_PIPELINE) := resulttmp(LPM_PIPELINE)(LPM_WIDTH);

			if LPM_PIPELINE > 0 then
				if ACLR = '1' then
					overflowtmp := (OTHERS => '0');
					couttmp := (OTHERS => '0');
					for i in 0 to LPM_PIPELINE loop
						resulttmp(i) := (OTHERS => '0');
					end loop;
				elsif CLOCK'event and CLOCK = '1' and CLKEN = '1' then
					overflowtmp(0 to LPM_PIPELINE - 1) := overflowtmp(1 to LPM_PIPELINE);
					couttmp(0 to LPM_PIPELINE - 1) := couttmp(1 to LPM_PIPELINE);
					resulttmp(0 to LPM_PIPELINE - 1) := resulttmp(1 to LPM_PIPELINE);
				end if;
			end if;

			COUT <= couttmp(0);
			OVERFLOW <= overflowtmp(0);
			RESULT <= resulttmp(0)(LPM_WIDTH-1 downto 0);
		end if;
	end process;

end LPM_SYN;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_ADD_SUB is
	generic (LPM_WIDTH : positive;
			 LPM_DIRECTION : string := "UNUSED";
			 LPM_REPRESENTATION: string := "SIGNED";
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE : string := "LPM_ADD_SUB";
			 LPM_HINT : string := "UNUSED");
	port (DATAA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  DATAB : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  ACLR : in std_logic := '0';
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  CIN : in std_logic := '0';
		  ADD_SUB : in std_logic := '1';
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
		  COUT : out std_logic;
		  OVERFLOW : out std_logic);
end LPM_ADD_SUB;

architecture LPM_SYN of LPM_ADD_SUB is

	component LPM_ADD_SUB_SIGNED
			generic (LPM_WIDTH : positive;
					 LPM_DIRECTION : string := "UNUSED";
					 LPM_PIPELINE : integer := 0;
					 LPM_TYPE : string := "LPM_ADD_SUB";
					 LPM_HINT : string := "UNUSED");
			port (DATAA : in std_logic_vector(LPM_WIDTH downto 1);
				  DATAB : in std_logic_vector(LPM_WIDTH downto 1);
				  ACLR : in std_logic := '0';
				  CLOCK : in std_logic := '0';
				  CLKEN : in std_logic := '1';
				  CIN : in std_logic := '0';
				  ADD_SUB : in std_logic := '1';
				  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
				  COUT : out std_logic;
				  OVERFLOW : out std_logic);
	end component;

	component LPM_ADD_SUB_UNSIGNED
			generic (LPM_WIDTH : positive;
					 LPM_DIRECTION : string := "UNUSED";
					 LPM_PIPELINE : integer := 0;
					 LPM_TYPE : string := "LPM_ADD_SUB";
					 LPM_HINT : string := "UNUSED");
			port (DATAA : in std_logic_vector(LPM_WIDTH-1 downto 0);
				  DATAB : in std_logic_vector(LPM_WIDTH-1 downto 0);
				  ACLR : in std_logic := '0';
				  CLOCK : in std_logic := '0';
				  CLKEN : in std_logic := '1';
				  CIN : in std_logic := '0';
				  ADD_SUB : in std_logic := '1';
				  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
				  COUT : out std_logic;
				  OVERFLOW : out std_logic);
	end component;


begin

L1: if LPM_REPRESENTATION = "UNSIGNED" generate

U:  LPM_ADD_SUB_UNSIGNED
	generic map (LPM_WIDTH => LPM_WIDTH, LPM_DIRECTION => LPM_DIRECTION,
				 LPM_PIPELINE => LPM_PIPELINE, LPM_TYPE => LPM_TYPE,
				 LPM_HINT => LPM_HINT)
	port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR, CLOCK => CLOCK,
			  CIN => CIN, ADD_SUB => ADD_SUB, RESULT => RESULT, COUT => COUT,
			  OVERFLOW => OVERFLOW, CLKEN => CLKEN);
	end generate;

L2: if LPM_REPRESENTATION = "SIGNED" generate

V:  LPM_ADD_SUB_SIGNED
	generic map (LPM_WIDTH => LPM_WIDTH, LPM_DIRECTION => LPM_DIRECTION,
				 LPM_PIPELINE => LPM_PIPELINE, LPM_TYPE => LPM_TYPE,
				 LPM_HINT => LPM_HINT)
	port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR, CLOCK => CLOCK,
			  CIN => CIN, ADD_SUB => ADD_SUB, RESULT => RESULT, COUT => COUT,
			  OVERFLOW => OVERFLOW, CLKEN => CLKEN);
	end generate;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use work.LPM_COMPONENTS.all;

entity LPM_COMPARE_SIGNED is
	generic (LPM_WIDTH : positive;
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE: string := "LPM_COMPARE";
			 LPM_HINT : string := "UNUSED");
	port (DATAA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  DATAB : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  ACLR : in std_logic := '0';
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  AGB : out std_logic;
		  AGEB : out std_logic;
		  AEB : out std_logic;
		  ANEB : out std_logic;
		  ALB : out std_logic;
		  ALEB : out std_logic);
end LPM_COMPARE_SIGNED;

architecture LPM_SYN of LPM_COMPARE_SIGNED is
begin

	process(ACLR, CLOCK, DATAA, DATAB)
	variable agbtmp : std_logic_vector (0 to LPM_PIPELINE);
	variable agebtmp : std_logic_vector (0 to LPM_PIPELINE);
	variable aebtmp : std_logic_vector (0 to LPM_PIPELINE);
	variable anebtmp : std_logic_vector (0 to LPM_PIPELINE);
	variable albtmp : std_logic_vector (0 to LPM_PIPELINE);
	variable alebtmp : std_logic_vector (0 to LPM_PIPELINE);

	begin
		if LPM_PIPELINE >= 0 then
			if DATAA > DATAB then
				agbtmp(LPM_PIPELINE) := '1';
				agebtmp(LPM_PIPELINE) := '1';
				anebtmp(LPM_PIPELINE) := '1';
				aebtmp(LPM_PIPELINE) := '0';
				albtmp(LPM_PIPELINE) := '0';
				alebtmp(LPM_PIPELINE) := '0';
			elsif DATAA = DATAB then
				agbtmp(LPM_PIPELINE) := '0';
				agebtmp(LPM_PIPELINE) := '1';
				anebtmp(LPM_PIPELINE) := '0';
				aebtmp(LPM_PIPELINE) := '1';
				albtmp(LPM_PIPELINE) := '0';
				alebtmp(LPM_PIPELINE) := '1';
			else
				agbtmp(LPM_PIPELINE) := '0';
				agebtmp(LPM_PIPELINE) := '0';
				anebtmp(LPM_PIPELINE) := '1';
				aebtmp(LPM_PIPELINE) := '0';
				albtmp(LPM_PIPELINE) := '1';
				alebtmp(LPM_PIPELINE) := '1';
			end if;

			if LPM_PIPELINE > 0 then
				if ACLR = '1' then
					for i in 0 to LPM_PIPELINE loop
						agbtmp(i) := '0';
						agebtmp(i) := '0';
						anebtmp(i) := '0';
						aebtmp(i) := '0';
						albtmp(i) := '0';
						alebtmp(i) := '0';
					end loop;
				elsif CLOCK'event and CLOCK = '1' and CLKEN = '1' then
					agbtmp(0 to LPM_PIPELINE-1) :=  agbtmp(1 to LPM_PIPELINE);
					agebtmp(0 to LPM_PIPELINE-1) := agebtmp(1 to LPM_PIPELINE) ;
					anebtmp(0 to LPM_PIPELINE-1) := anebtmp(1 to LPM_PIPELINE);
					aebtmp(0 to LPM_PIPELINE-1) := aebtmp(1 to LPM_PIPELINE);
					albtmp(0 to LPM_PIPELINE-1) := albtmp(1 to LPM_PIPELINE);
					alebtmp(0 to LPM_PIPELINE-1) := alebtmp(1 to LPM_PIPELINE);
				end if;
			end if;
		end if;

		AGB <= agbtmp(0);
		AGEB <= agebtmp(0);
		ANEB <= anebtmp(0);
		AEB <= aebtmp(0);
		ALB <= albtmp(0);
		ALEB <= alebtmp(0);
	end process;

end LPM_SYN;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_COMPARE_UNSIGNED is
	generic (LPM_WIDTH : positive;
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE: string := "LPM_COMPARE";
			 LPM_HINT : string := "UNUSED");
	port (DATAA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  DATAB : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  ACLR : in std_logic := '0';
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  AGB : out std_logic;
		  AGEB : out std_logic;
		  AEB : out std_logic;
		  ANEB : out std_logic;
		  ALB : out std_logic;
		  ALEB : out std_logic);
end LPM_COMPARE_UNSIGNED;

architecture LPM_SYN of LPM_COMPARE_UNSIGNED is
begin

	process(ACLR, CLOCK, DATAA, DATAB)
	variable agbtmp : std_logic_vector (0 to LPM_PIPELINE);
	variable agebtmp : std_logic_vector (0 to LPM_PIPELINE);
	variable aebtmp : std_logic_vector (0 to LPM_PIPELINE);
	variable anebtmp : std_logic_vector (0 to LPM_PIPELINE);
	variable albtmp : std_logic_vector (0 to LPM_PIPELINE);
	variable alebtmp : std_logic_vector (0 to LPM_PIPELINE);

	begin
		if LPM_PIPELINE >= 0 then
			if DATAA > DATAB then
				agbtmp(LPM_PIPELINE) := '1';
				agebtmp(LPM_PIPELINE) := '1';
				anebtmp(LPM_PIPELINE) := '1';
				aebtmp(LPM_PIPELINE) := '0';
				albtmp(LPM_PIPELINE) := '0';
				alebtmp(LPM_PIPELINE) := '0';
			elsif DATAA = DATAB then
				agbtmp(LPM_PIPELINE) := '0';
				agebtmp(LPM_PIPELINE) := '1';
				anebtmp(LPM_PIPELINE) := '0';
				aebtmp(LPM_PIPELINE) := '1';
				albtmp(LPM_PIPELINE) := '0';
				alebtmp(LPM_PIPELINE) := '1';
			else
				agbtmp(LPM_PIPELINE) := '0';
				agebtmp(LPM_PIPELINE) := '0';
				anebtmp(LPM_PIPELINE) := '1';
				aebtmp(LPM_PIPELINE) := '0';
				albtmp(LPM_PIPELINE) := '1';
				alebtmp(LPM_PIPELINE) := '1';
			end if;

			if LPM_PIPELINE > 0 then
				if ACLR = '1' then
					for i in 0 to LPM_PIPELINE loop
						agbtmp(i) := '0';
						agebtmp(i) := '0';
						anebtmp(i) := '0';
						aebtmp(i) := '0';
						albtmp(i) := '0';
						alebtmp(i) := '0';
					end loop;
				elsif CLOCK'event and CLOCK = '1' and CLKEN = '1' then
					agbtmp(0 to LPM_PIPELINE-1) :=  agbtmp(1 to LPM_PIPELINE);
					agebtmp(0 to LPM_PIPELINE-1) := agebtmp(1 to LPM_PIPELINE) ;
					anebtmp(0 to LPM_PIPELINE-1) := anebtmp(1 to LPM_PIPELINE);
					aebtmp(0 to LPM_PIPELINE-1) := aebtmp(1 to LPM_PIPELINE);
					albtmp(0 to LPM_PIPELINE-1) := albtmp(1 to LPM_PIPELINE);
					alebtmp(0 to LPM_PIPELINE-1) := alebtmp(1 to LPM_PIPELINE);
				end if;
			end if;
		end if;

		AGB <= agbtmp(0);
		AGEB <= agebtmp(0);
		ANEB <= anebtmp(0);
		AEB <= aebtmp(0);
		ALB <= albtmp(0);
		ALEB <= alebtmp(0);
	end process;

end LPM_SYN;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_COMPARE is
	generic (LPM_WIDTH : positive;
			 LPM_REPRESENTATION : string := "UNSIGNED";
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE: string := "LPM_COMPARE";
			 LPM_HINT : string := "UNUSED");
	port (DATAA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  DATAB : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  ACLR : in std_logic := '0';
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  AGB : out std_logic;
		  AGEB : out std_logic;
		  AEB : out std_logic;
		  ANEB : out std_logic;
		  ALB : out std_logic;
		  ALEB : out std_logic);
end LPM_COMPARE;

architecture LPM_SYN of LPM_COMPARE is

	component LPM_COMPARE_SIGNED
		generic (LPM_WIDTH : positive;
				 LPM_PIPELINE : integer := 0;
				 LPM_TYPE: string := "LPM_COMPARE";
				 LPM_HINT : string := "UNUSED");
		port (DATAA : in std_logic_vector(LPM_WIDTH-1 downto 0);
			  DATAB : in std_logic_vector(LPM_WIDTH-1 downto 0);
			  ACLR : in std_logic := '0';
			  CLOCK : in std_logic := '0';
			  CLKEN : in std_logic := '1';
			  AGB : out std_logic;
			  AGEB : out std_logic;
			  AEB : out std_logic;
			  ANEB : out std_logic;
			  ALB : out std_logic;
			  ALEB : out std_logic);
	end component;

	component LPM_COMPARE_UNSIGNED
		generic (LPM_WIDTH : positive;
				 LPM_PIPELINE : integer := 0;
				 LPM_TYPE: string := "LPM_COMPARE";
				 LPM_HINT : string := "UNUSED");
		port (DATAA : in std_logic_vector(LPM_WIDTH-1 downto 0);
			  DATAB : in std_logic_vector(LPM_WIDTH-1 downto 0);
			  ACLR : in std_logic := '0';
			  CLOCK : in std_logic := '0';
			  CLKEN : in std_logic := '1';
			  AGB : out std_logic;
			  AGEB : out std_logic;
			  AEB : out std_logic;
			  ANEB : out std_logic;
			  ALB : out std_logic;
			  ALEB : out std_logic);
	end component;

begin

L1: if LPM_REPRESENTATION = "UNSIGNED" generate

U1: LPM_COMPARE_UNSIGNED
	generic map (LPM_WIDTH => LPM_WIDTH, LPM_PIPELINE => LPM_PIPELINE,
				 LPM_TYPE => LPM_TYPE, LPM_HINT => LPM_HINT)
	port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR,
			  CLOCK => CLOCK, AGB => AGB, AGEB => AGEB, CLKEN => CLKEN,
			  AEB => AEB, ANEB => ANEB, ALB => ALB, ALEB => ALEB);
	end generate;

L2: if LPM_REPRESENTATION = "SIGNED" generate

U2: LPM_COMPARE_SIGNED
	generic map (LPM_WIDTH => LPM_WIDTH, LPM_PIPELINE => LPM_PIPELINE,
				 LPM_TYPE => LPM_TYPE, LPM_HINT => LPM_HINT)
	port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR,
			  CLOCK => CLOCK, AGB => AGB, AGEB => AGEB, CLKEN => CLKEN,
			  AEB => AEB, ANEB => ANEB, ALB => ALB, ALEB => ALEB);
	end generate;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use work.LPM_COMPONENTS.all;

entity LPM_MULT_SIGNED is
	generic (LPM_WIDTHA : positive;
			 LPM_WIDTHB : positive;
			 --LPM_WIDTHS : positive;
			 LPM_WIDTHS : natural := 0;
			 LPM_WIDTHP : positive;
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE: string := "LPM_MULT";
			 LPM_HINT : string := "UNUSED");
	port (DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
		  DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
		  ACLR : in std_logic := '0';
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  SUM : in std_logic_vector(LPM_WIDTHS-1 downto 0) := (OTHERS => '0');
		  RESULT : out std_logic_vector(LPM_WIDTHP-1 downto 0));
end LPM_MULT_SIGNED;

architecture LPM_SYN of LPM_MULT_SIGNED is

signal FP : std_logic_vector(LPM_WIDTHS-1 downto 0);
type t_resulttmp IS ARRAY (0 to LPM_PIPELINE) of std_logic_vector(LPM_WIDTHP-1 downto 0);

begin

	process (CLOCK, ACLR, DATAA, DATAB, SUM)
	variable resulttmp : t_resulttmp;
	begin
		if LPM_PIPELINE >= 0 then
			if LPM_WIDTHP >= LPM_WIDTHS then
				resulttmp(LPM_PIPELINE) := (DATAA * DATAB) + SUM;
			else
				FP <= (DATAA * DATAB) + SUM;
				resulttmp(LPM_PIPELINE) := FP(LPM_WIDTHS-1 downto LPM_WIDTHS-LPM_WIDTHP);
			end if;

			if LPM_PIPELINE > 0 then
				if ACLR = '1' then
					for i in 0 to LPM_PIPELINE loop
						resulttmp(i) := (OTHERS => '0');
					end loop;
				elsif CLOCK'event and CLOCK = '1' and CLKEN = '1' then
					resulttmp(0 to LPM_PIPELINE - 1) := resulttmp(1 to LPM_PIPELINE);
				end if;
			end if;
		end if;

		RESULT <= resulttmp(0);
	end process;

end LPM_SYN;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_MULT_UNSIGNED is
	generic (LPM_WIDTHA : positive;
			 LPM_WIDTHB : positive;
			 --LPM_WIDTHS : positive;
			 LPM_WIDTHS : natural := 0;
			 LPM_WIDTHP : positive;
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE: string := "LPM_MULT";
			 LPM_HINT : string := "UNUSED");
	port (DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
		  DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
		  ACLR : in std_logic := '0';
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  SUM : in std_logic_vector(LPM_WIDTHS-1 downto 0) := (OTHERS => '0');
		  RESULT : out std_logic_vector(LPM_WIDTHP-1 downto 0));
end LPM_MULT_UNSIGNED;

architecture LPM_SYN of LPM_MULT_UNSIGNED is

signal FP : std_logic_vector(LPM_WIDTHS-1 downto 0);
type t_resulttmp IS ARRAY (0 to LPM_PIPELINE) of std_logic_vector(LPM_WIDTHP-1 downto 0);

begin

	process (CLOCK, ACLR, DATAA, DATAB, SUM)
	variable resulttmp : t_resulttmp;
	begin
		if LPM_PIPELINE >= 0 then
			if LPM_WIDTHP >= LPM_WIDTHS then
				resulttmp(LPM_PIPELINE) := (DATAA * DATAB) + SUM;
			else
				FP <= (DATAA * DATAB) + SUM;
				resulttmp(LPM_PIPELINE) := FP(LPM_WIDTHS-1 downto LPM_WIDTHS-LPM_WIDTHP);
			end if;

			if LPM_PIPELINE > 0 then
				if ACLR = '1' then
					for i in 0 to LPM_PIPELINE loop
						resulttmp(i) := (OTHERS => '0');
					end loop;
				elsif CLOCK'event and CLOCK = '1' and CLKEN = '1' then
					resulttmp(0 to LPM_PIPELINE - 1) := resulttmp(1 to LPM_PIPELINE);
				end if;
			end if;
		end if;

		RESULT <= resulttmp(0);
	end process;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_MULT is
	generic (LPM_WIDTHA : positive;
			 LPM_WIDTHB : positive;
			 --LPM_WIDTHS : positive;
			 LPM_WIDTHS : natural := 0;
			 LPM_WIDTHP : positive;
			 LPM_REPRESENTATION : string := "UNSIGNED";
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE: string := "LPM_MULT";
			 LPM_HINT : string := "UNUSED");
	port (DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
		  DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
		  ACLR : in std_logic := '0';
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  SUM : in std_logic_vector(LPM_WIDTHS-1 downto 0) := (OTHERS => '0');
		  RESULT : out std_logic_vector(LPM_WIDTHP-1 downto 0));
end LPM_MULT;

architecture LPM_SYN of LPM_MULT is

	component LPM_MULT_UNSIGNED
		generic (LPM_WIDTHA : positive;
				 LPM_WIDTHB : positive;
				 --LPM_WIDTHS : positive;
				 LPM_WIDTHS : natural := 0;
				 LPM_WIDTHP : positive;
				 LPM_PIPELINE : integer := 0;
				 LPM_TYPE: string := "LPM_MULT";
				 LPM_HINT : string := "UNUSED");
		port (DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
			  DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
			  ACLR : in std_logic := '0';
			  CLOCK : in std_logic := '0';
			  CLKEN : in std_logic := '1';
			  SUM : in std_logic_vector(LPM_WIDTHS-1 downto 0) := (OTHERS => '0');
			  RESULT : out std_logic_vector(LPM_WIDTHP-1 downto 0));
	end component;

	component LPM_MULT_SIGNED
		generic (LPM_WIDTHA : positive;
				 LPM_WIDTHB : positive;
				 --LPM_WIDTHS : positive;
				 LPM_WIDTHS : natural := 0;
				 LPM_WIDTHP : positive;
				 LPM_PIPELINE : integer := 0;
				 LPM_TYPE: string := "LPM_MULT";
				 LPM_HINT : string := "UNUSED");
		port (DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
			  DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
			  ACLR : in std_logic := '0';
			  CLOCK : in std_logic := '0';
			  CLKEN : in std_logic := '1';
			  SUM : in std_logic_vector(LPM_WIDTHS-1 downto 0) := (OTHERS => '0');
			  RESULT : out std_logic_vector(LPM_WIDTHP-1 downto 0));
	end component;

begin

L1: if LPM_REPRESENTATION = "UNSIGNED" generate

U1: LPM_MULT_UNSIGNED
	generic map (LPM_WIDTHA => LPM_WIDTHA,
				 LPM_WIDTHB => LPM_WIDTHB, LPM_WIDTHS => LPM_WIDTHS,
				 LPM_WIDTHP => LPM_WIDTHP, LPM_PIPELINE => LPM_PIPELINE,
				 LPM_TYPE => LPM_TYPE, LPM_HINT => LPM_HINT)
	port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR, CLKEN => CLKEN,
			  SUM => SUM, CLOCK => CLOCK, RESULT => RESULT);
	end generate;

L2: if LPM_REPRESENTATION = "SIGNED" generate

U1: LPM_MULT_SIGNED
	generic map (LPM_WIDTHA => LPM_WIDTHA,
				 LPM_WIDTHB => LPM_WIDTHB, LPM_WIDTHS => LPM_WIDTHS,
				 LPM_WIDTHP => LPM_WIDTHP, LPM_PIPELINE => LPM_PIPELINE,
				 LPM_TYPE => LPM_TYPE, LPM_HINT => LPM_HINT)
	port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR, CLKEN => CLKEN,
			  SUM => SUM, CLOCK => CLOCK, RESULT => RESULT);
	end generate;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.LPM_COMPONENTS.all;

entity LPM_DIVIDE is
	generic (LPM_WIDTHN : positive;
			 LPM_WIDTHD : positive;
			 --LPM_WIDTHQ : positive;
			 --LPM_WIDTHR : positive;
			 LPM_NREPRESENTATION : string := "UNSIGNED";
			 LPM_DREPRESENTATION : string := "UNSIGNED";
			 LPM_PIPELINE : integer := 0;
			 LPM_TYPE : string := "LPM_DIVIDE";
			 LPM_HINT : string := "UNUSED");
	port (NUMER : in std_logic_vector(LPM_WIDTHN-1 downto 0);
		  DENOM : in std_logic_vector(LPM_WIDTHD-1 downto 0);
		  ACLR : in std_logic := '0';
		  CLOCK : in std_logic := '0';
		  CLKEN : in std_logic := '1';
		  QUOTIENT : out std_logic_vector(LPM_WIDTHN-1 downto 0);
		  REMAIN : out std_logic_vector(LPM_WIDTHD-1 downto 0));
end LPM_DIVIDE;

architecture behave of lpm_divide is

type qpipeline is array (0 to lpm_pipeline) of std_logic_vector(LPM_WIDTHN-1 downto 0);
type rpipeline is array (0 to lpm_pipeline) of std_logic_vector(LPM_WIDTHD-1 downto 0);

begin

	process (aclr, clock, numer, denom)
	variable tmp_quotient : qpipeline;
	variable tmp_remain : rpipeline;
	variable int_numer, int_denom, int_quotient, int_remain : integer := 0;
	variable signed_quotient : signed(LPM_WIDTHN-1 downto 0);
	variable unsigned_quotient : unsigned(LPM_WIDTHN-1 downto 0);
	begin
		if (lpm_nrepresentation = "UNSIGNED" ) then
			int_numer := conv_integer(unsigned(numer));
		else -- signed
			int_numer := conv_integer(signed(numer));
		end if;
		if (lpm_drepresentation = "UNSIGNED" ) then
			int_denom := conv_integer(unsigned(denom));
		else -- signed
			int_denom := conv_integer(signed(denom));
		end if;
		if int_denom = 0 then
			int_quotient := 0;
			int_remain := 0;
		else
			int_quotient := int_numer mod int_denom;
			int_remain := int_numer rem int_denom;
		end if;
		signed_quotient := conv_signed(int_quotient, LPM_WIDTHN);
		unsigned_quotient := conv_unsigned(int_quotient, LPM_WIDTHN);

		tmp_remain(lpm_pipeline) := conv_std_logic_vector(int_Remain, LPM_WIDTHD);
		if ((lpm_nrepresentation = "UNSIGNED") and (lpm_drepresentation = "UNSIGNED")) then
			tmp_quotient(lpm_pipeline) := conv_std_logic_vector(unsigned_quotient, LPM_WIDTHN);
		else
			tmp_quotient(lpm_pipeline) := conv_std_logic_vector(signed_quotient, LPM_WIDTHN);
		end if;
	  
		if lpm_pipeline > 0 then
			if aclr = '1' then
				for i in 0 to lpm_pipeline loop
					tmp_quotient(i) := (OTHERS => '0');
					tmp_remain(i) := (OTHERS => '0');
				end loop;
			elsif clock'event and clock = '1' then
				if clken = '1' then
					tmp_quotient(0 to lpm_pipeline-1) := tmp_quotient(1 to lpm_pipeline);
					tmp_remain(0 to lpm_pipeline-1) := tmp_remain(1 to lpm_pipeline);
				end if;
			end if;
		end if;
		
		quotient <= tmp_quotient(0);
		remain <= tmp_remain(0);
	end process;

end behave;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use work.LPM_COMPONENTS.all;

entity LPM_ABS is
	generic (LPM_WIDTH : positive;
			 LPM_TYPE: string := "LPM_ABS";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
		  OVERFLOW : out std_logic);
end LPM_ABS;

architecture LPM_SYN of LPM_ABS is
begin

	process(DATA)
	begin
		if (DATA = -2 ** (LPM_WIDTH-1)) then
			OVERFLOW <= '1';
			RESULT <= (OTHERS => 'X');
		elsif DATA < 0 then
			RESULT <= 0 - DATA;
			OVERFLOW <= '0';
		else
			RESULT <= DATA;
			OVERFLOW <= '0';
		end if;
	end process;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_COUNTER is
	generic (LPM_WIDTH : positive;
			 LPM_MODULUS: natural := 0;
			 LPM_DIRECTION : string := "UNUSED";
			 LPM_AVALUE : string := "UNUSED";
			 LPM_SVALUE : string := "UNUSED";
			 LPM_PVALUE : string := "UNUSED";
			 LPM_TYPE: string := "LPM_COUNTER";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0):= (OTHERS => '0');
		  CLOCK : in std_logic ;
		  CLK_EN : in std_logic := '1';
		  CNT_EN : in std_logic := '1';
		  UPDOWN : in std_logic := '1';
		  SLOAD : in std_logic := '0';
		  SSET : in std_logic := '0';
		  SCLR : in std_logic := '0';
		  ALOAD : in std_logic := '0';
		  ASET : in std_logic := '0';
		  ACLR : in std_logic := '0';
		  CIN : in std_logic := '0';
		  COUT : out std_logic := '0';
		  --EQ : out std_logic_vector(15 downto 0);
		  Q : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_COUNTER;

architecture LPM_SYN of LPM_COUNTER is

signal COUNT : std_logic_vector(LPM_WIDTH-1 downto 0);
signal INIT : std_logic := '0';

begin

	Counter: process (CLOCK, ACLR, ASET, ALOAD, DATA, INIT)
	variable IAVALUE, ISVALUE : integer;
	variable IMODULUS : integer;
	variable dir_tmp : integer;
	begin
		-- INITIALIZE TO PVALUE --
		if INIT = '0' then
			if LPM_PVALUE /= "UNUSED" then
				COUNT <= conv_std_logic_vector(str_to_int(LPM_PVALUE), LPM_WIDTH);
			else
				COUNT <= (OTHERS => '0');
			end if;
			INIT <= '1';
		else
			-- SETUP VARIABLES --
			IAVALUE := str_to_int(LPM_AVALUE);
			ISVALUE := str_to_int(LPM_SVALUE);
			if LPM_MODULUS = 0 then
				IMODULUS := 2 ** LPM_WIDTH;
			else
				IMODULUS := LPM_MODULUS;
			end if;

			if ACLR =  '1' then
				COUNT <= (OTHERS => '0');
			elsif ASET = '1' then
				if LPM_AVALUE = "UNUSED" then
					COUNT <= (OTHERS => '1');
				else
					COUNT <= conv_std_logic_vector(IAVALUE, LPM_WIDTH);
				end if;
			elsif ALOAD = '1' then
				COUNT <= DATA;
			elsif CLOCK'event and CLOCK = '1' then
				if CLK_EN = '1' then
					if SCLR = '1' then
						COUNT <= (OTHERS => '0');
					elsif SSET = '1' then
						if LPM_SVALUE = "UNUSED" then
							COUNT <= (OTHERS => '1');
						else
							COUNT <= conv_std_logic_vector(ISVALUE, LPM_WIDTH);
						end if;
					elsif SLOAD = '1' then
						COUNT <= DATA;
					elsif CNT_EN = '1' then
						if LPM_DIRECTION = "UNUSED" then
							if UPDOWN = '0' then
								dir_tmp := 0;   -- decrease
							else
								dir_tmp := 1;   -- increase
							end if;
						elsif LPM_DIRECTION = "UP" then
							dir_tmp := 1;       -- increase
						elsif LPM_DIRECTION = "DOWN" then
							dir_tmp := 0;       -- decrease
						else
							dir_tmp := 1;       -- Anything other than legal values.
						end if;

						if dir_tmp = 1 then
							-- INCREMENT --
							if COUNT + 1 >= IMODULUS then
								COUNT <= conv_std_logic_vector(CIN, LPM_WIDTH);
							elsif COUNT + 2 >= IMODULUS then
								if CIN = '1' then
									COUNT <= conv_std_logic_vector(0, LPM_WIDTH);
								else
									COUNT <= conv_std_logic_vector(IMODULUS-1, LPM_WIDTH);
								end if;
							else
								COUNT <= COUNT + 1 + CIN;
							end if;
						else
							-- DECREMENT --
							if COUNT = 0 then
								if CIN = '1' then
									COUNT <= conv_std_logic_vector(IMODULUS-2, LPM_WIDTH);
								else
									COUNT <= conv_std_logic_vector(IMODULUS-1, LPM_WIDTH);
								end if;
							elsif COUNT = 1 then
								if CIN = '1' then
									COUNT <= conv_std_logic_vector(IMODULUS-1, LPM_WIDTH);
								else
									COUNT <= conv_std_logic_vector(0, LPM_WIDTH);
								end if;
							else
								COUNT <= COUNT - 1 - CIN;
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process Counter;


	--Decode: process (COUNT)
	--variable IMODULUS : integer;
	--begin
	--    EQ <= (OTHERS => '0');
	--    if LPM_MODULUS = 0 then
	--        IMODULUS := 2 ** LPM_WIDTH;
	--    else
	--        IMODULUS := LPM_MODULUS;
	--    end if;
	--
	--    if COUNT = IMODULUS - 1 then
	--        EQ(0) <= '1';
	--    end if;
	--end process Decode;

	CarryOut: process (COUNT, CIN)
	variable IMODULUS : integer;
	variable dir_tmp : integer;
	begin
		if INIT = '1' then
			-- SETUP VARIABLES --
			if LPM_MODULUS = 0 then
				IMODULUS := 2 ** LPM_WIDTH;
			else
				IMODULUS := LPM_MODULUS;
			end if;
			if LPM_DIRECTION = "UNUSED" then
				if UPDOWN = '0' then
					dir_tmp := 0;   -- decrease
				else
					dir_tmp := 1;   -- increase
				end if;
			elsif LPM_DIRECTION = "UP" then
				dir_tmp := 1;       -- increase
			elsif LPM_DIRECTION = "DOWN" then
				dir_tmp := 0;       -- decrease
			else
				dir_tmp := 1;       -- Anything other than legal values.
			end if;

			COUT <= '0';
			if CIN = '1' then
				if (dir_tmp = 1 and COUNT >= IMODULUS - 2)
				   or (dir_tmp = 0 and COUNT <= 1) then
					COUT <= '1';
				end if;
			else
				if (dir_tmp = 1 and COUNT >= IMODULUS - 1)
				   or (dir_tmp = 0 and COUNT = 0) then
					COUT <= '1';
				end if;
			end if;
		end if;
	end process CarryOut;

	Q <= COUNT;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.LPM_COMPONENTS.all;

entity LPM_LATCH is
	generic (LPM_WIDTH : positive;
			 LPM_AVALUE : string := "UNUSED";
			 LPM_PVALUE : string := "UNUSED";
			 LPM_TYPE: string := "LPM_LATCH";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  GATE : in std_logic;
		  ASET : in std_logic := '0';
		  ACLR : in std_logic := '0';
		  Q : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_LATCH;

architecture LPM_SYN of LPM_LATCH is
begin

	process (DATA, GATE, ACLR, ASET)
	variable IAVALUE : integer;
	begin
		if ACLR =  '1' then
			Q <= (OTHERS => '0');
		elsif ASET = '1' then
			if LPM_AVALUE = "UNUSED" then
				Q <= (OTHERS => '1');
			else
				IAVALUE := str_to_int(LPM_AVALUE);
				Q <= conv_std_logic_vector(IAVALUE, LPM_WIDTH);
			end if;
		elsif GATE = '1' then
			Q <= DATA;
		end if;
	end process;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.LPM_COMPONENTS.all;

entity LPM_FF is
	generic (LPM_WIDTH : positive;
			 LPM_AVALUE : string := "UNUSED";
			 LPM_SVALUE : string := "UNUSED";
			 LPM_PVALUE : string := "UNUSED";
			 LPM_FFTYPE: string := "DFF";
			 LPM_TYPE: string := "LPM_FF";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  CLOCK : in std_logic;
		  ENABLE : in std_logic := '1';
		  SLOAD : in std_logic := '0';
		  SCLR : in std_logic := '0';
		  SSET : in std_logic := '0';
		  ALOAD : in std_logic := '0';
		  ACLR : in std_logic := '0';
		  ASET : in std_logic := '0';
		  Q : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_FF;

architecture LPM_SYN of LPM_FF is

signal IQ : std_logic_vector(LPM_WIDTH-1 downto 0);

begin

	process (DATA, CLOCK, ACLR, ASET, ALOAD)
	variable IAVALUE, ISVALUE : integer;
	begin
		if ACLR =  '1' then
			IQ <= (OTHERS => '0');
		elsif ASET = '1' then
			if LPM_AVALUE = "UNUSED" then
				IQ <= (OTHERS => '1');
			else
				IAVALUE := str_to_int(LPM_AVALUE);
				IQ <= conv_std_logic_vector(IAVALUE, LPM_WIDTH);
			end if;
		elsif ALOAD = '1' then
			if LPM_FFTYPE = "TFF" then
				IQ <= DATA;
			end if;
		elsif CLOCK'event and CLOCK = '1' then
			if ENABLE = '1' then
				if SCLR = '1' then
					IQ <= (OTHERS => '0');
				elsif SSET = '1' then
					if LPM_SVALUE = "UNUSED" then
						IQ <= (OTHERS => '1');
					else
						ISVALUE := str_to_int(LPM_SVALUE);
						IQ <= conv_std_logic_vector(ISVALUE, LPM_WIDTH);
					end if;
				elsif  SLOAD = '1' then
					if LPM_FFTYPE = "TFF" then
						IQ <= DATA;
					end if;
				else
					if LPM_FFTYPE = "TFF" then
						for i in 0 to LPM_WIDTH-1 loop
							if DATA(i) = '1' then
								IQ(i) <= not IQ(i);
							end if;
						end loop;
					else
						IQ <= DATA;
					end if;
				end if;
			end if;
		end if;
	end process;

	Q <= IQ;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.LPM_COMPONENTS.all;

entity LPM_SHIFTREG is
	generic (LPM_WIDTH : positive;
			 LPM_AVALUE : string := "UNUSED";
			 LPM_SVALUE : string := "UNUSED";
			 LPM_PVALUE : string := "UNUSED";
			 LPM_DIRECTION: string := "UNUSED";
			 LPM_TYPE: string := "L_SHIFTREG";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0) := (OTHERS => '0');
		  CLOCK : in std_logic;
		  ENABLE : in std_logic := '1';
		  SHIFTIN : in std_logic := '1';
		  LOAD : in std_logic := '0';
		  SCLR : in std_logic := '0';
		  SSET : in std_logic := '0';
		  ACLR : in std_logic := '0';
		  ASET : in std_logic := '0';
		  Q : out std_logic_vector(LPM_WIDTH-1 downto 0);
		  SHIFTOUT : out std_logic);
end LPM_SHIFTREG;

architecture LPM_SYN of LPM_SHIFTREG is
signal IQ : std_logic_vector(LPM_WIDTH downto 0);
begin

	process (CLOCK, ACLR, ASET, SCLR)
	variable IAVALUE, ISVALUE : integer;
	begin
		if ACLR =  '1' then
			IQ <= (OTHERS => '0');
		elsif ASET = '1' then
			if LPM_AVALUE = "UNUSED" then
				IQ <= (OTHERS => '1');
			else
				IAVALUE := str_to_int(LPM_AVALUE);
				IQ <= conv_std_logic_vector(IAVALUE, LPM_WIDTH);
			end if;
		elsif CLOCK'event and CLOCK = '1' then
			if ENABLE = '1' then
				if SCLR = '1' then
					IQ <= (OTHERS => '0');
				elsif SSET = '1' then
					if LPM_SVALUE = "UNUSED" then
						IQ <= (OTHERS => '1');
					else
						ISVALUE := str_to_int(LPM_SVALUE);
						IQ <= conv_std_logic_vector(ISVALUE, LPM_WIDTH);
					end if;
				elsif LOAD = '0' then
					IQ <= (IQ(LPM_WIDTH-1 downto 0) & SHIFTIN);
				else
					IQ(LPM_WIDTH-1 downto 0) <= DATA;
				end if;
			end if;
		end if;
	end process;

	Q <= IQ(LPM_WIDTH-1 downto 0);
	SHIFTOUT <= IQ(LPM_WIDTH);

end LPM_SYN;


---------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all; 
use IEEE.std_logic_unsigned.all;
use std.textio.all;
use work.LPM_COMPONENTS.all;

entity LPM_RAM_DQ is
	generic (LPM_WIDTH : positive;
			 LPM_WIDTHAD : positive;
			 LPM_NUMWORDS : natural := 0;
			 LPM_INDATA : string := "REGISTERED";
			 LPM_ADDRESS_CONTROL: string := "REGISTERED";
			 LPM_OUTDATA : string := "REGISTERED";
			 LPM_FILE : string := "UNUSED";
			 LPM_TYPE : string := L_RAM_DQ;
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  ADDRESS : in std_logic_vector(LPM_WIDTHAD-1 downto 0);
		  INCLOCK : in std_logic := '0';
		  OUTCLOCK : in std_logic := '0';
		  WE : in std_logic;
		  Q : out std_logic_vector(LPM_WIDTH-1 downto 0));

	function int_to_str( value : integer ) return string is
	variable ivalue,index : integer;
	variable digit : integer;
	variable line_no: string(8 downto 1) := "        ";  
	
	begin
		ivalue := value;
		index := 1;
		while (ivalue > 0 ) loop
			digit := ivalue MOD 10;
			ivalue := ivalue/10;
			case digit is
				when 0 =>
					line_no(index) := '0';
				when 1 =>
					line_no(index) := '1';
				when 2 =>
					line_no(index) := '2';
				when 3 =>
					line_no(index) := '3';
				when 4 =>
					line_no(index) := '4';
				when 5 =>
					line_no(index) := '5';
				when 6 =>
					line_no(index) := '6';
				when 7 =>
					line_no(index) := '7';
				when 8 =>
					line_no(index) := '8';
				when 9 =>
					line_no(index) := '9';
				when others =>
					ASSERT FALSE
					REPORT "Illegal number!"
					SEVERITY ERROR;
			end case;
			index := index + 1;
		end loop;
		return line_no;
	end;

	function hex_str_to_int( str : string ) return integer is
	variable len : integer := str'length;
	variable ivalue : integer := 0;
	variable digit : integer;
	begin
		for i in len downto 1 loop
			case str(i) is
				when '0' =>
					digit := 0;
				when '1' =>
					digit := 1;
				when '2' =>
					digit := 2;
				when '3' =>
					digit := 3;
				when '4' =>
					digit := 4;
				when '5' =>
					digit := 5;
				when '6' =>
					digit := 6;
				when '7' =>
					digit := 7;
				when '8' =>
					digit := 8;
				when '9' =>
					digit := 9;
				when 'A' =>
					digit := 10;
				when 'a' =>
					digit := 10;
				when 'B' =>
					digit := 11;
				when 'b' =>
					digit := 11;
				when 'C' =>
					digit := 12;
				when 'c' =>
					digit := 12;
				when 'D' =>
					digit := 13;
				when 'd' =>
					digit := 13;
				when 'E' =>
					digit := 14;
				when 'e' =>
					digit := 14;
				when 'F' =>
					digit := 15;
				when 'f' =>
					digit := 15;
				when others =>
					ASSERT FALSE
					REPORT "Illegal character "&  str(i) & "in Intel Hex File! "
					SEVERITY ERROR;
			end case;
			ivalue := ivalue * 16 + digit;
		end loop;
		return ivalue;
	end;

	procedure Shrink_line(L : inout LINE; pos : in integer) is
	subtype nstring is string(1 to pos);
	variable stmp : nstring;
	begin
		if pos >= 1 then
			read(l, stmp);
		end if;
	end;

end LPM_RAM_DQ;

architecture LPM_SYN of lpm_ram_dq is

--type lpm_memory is array(lpm_numwords-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);
type lpm_memory is array((2**lpm_widthad)-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);

signal data_tmp, data_reg : std_logic_vector(lpm_width-1 downto 0);
signal q_tmp, q_reg : std_logic_vector(lpm_width-1 downto 0);
signal address_tmp, address_reg : std_logic_vector(lpm_widthad-1 downto 0);
signal we_tmp, we_reg : std_logic;

begin

	sync: process(data,data_reg, address, address_reg, we,we_reg, q_tmp, q_reg)
	begin
		if (lpm_address_control = "REGISTERED") then
			address_tmp <= address_reg;
			we_tmp <= we_reg;
		else
			address_tmp <= address;
			we_tmp <= we;
		end if;
		if (lpm_indata = "REGISTERED") then
			data_tmp <= data_reg;
		else
			data_tmp <= data;
		end if;
		if (lpm_outdata = "REGISTERED") then
			q <= q_reg;
		else
			q <= q_tmp;
		end if;
	end process;

	input_reg: process (inclock)
	begin
		if inclock'event and inclock = '1' then
			data_reg <= data;
			address_reg <= address;
			we_reg <= we;
		end if;
	end process;

	output_reg: process (outclock)
	begin
		if outclock'event and outclock = '1' then
			q_reg <= q_tmp;
		end if;
	end process;

	memory: process(data_tmp, we_tmp, address_tmp)
	variable mem_data : lpm_memory;
	variable mem_data_tmp : integer := 0;
	variable mem_init: boolean := false;
	variable i,j,k,lineno: integer := 0;
	variable buf: line ;
	variable booval: boolean ;
	FILE mem_data_file: TEXT IS IN LPM_FILE;
	variable base, byte, rec_type, datain, addr, checksum: string(2 downto 1);
	variable startadd: string(4 downto 1);
	variable ibase: integer := 0;
	variable ibyte: integer := 0;
	variable istartadd: integer := 0;
	variable check_sum_vec, check_sum_vec_tmp: std_logic_vector(7 downto 0);
	begin
		-- INITIALIZE --
		if NOT(mem_init) then
			-- INITIALIZE TO 0 --
			for i in mem_data'LOW to mem_data'HIGH loop
				mem_data(i) := (OTHERS => '0');
			end loop;

			if (LPM_FILE = "UNUSED") then
				ASSERT FALSE
				REPORT "Initialization file not found!"
				SEVERITY WARNING;
			else
				WHILE NOT ENDFILE(mem_data_file) loop
					booval := true;
					READLINE(mem_data_file, buf);
					lineno := lineno + 1;
					check_sum_vec := (OTHERS => '0');
					if (buf(buf'LOW) = ':') then
						i := 1;
						shrink_line(buf, i);
						READ(L=>buf, VALUE=>byte, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format!"
							SEVERITY ERROR;
						end if;
						ibyte := hex_str_to_int(byte);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(ibyte, 8));
						READ(L=>buf, VALUE=>startadd, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
							SEVERITY ERROR;
						end if;
						istartadd := hex_str_to_int(startadd);
						addr(2) := startadd(4);
						addr(1) := startadd(3);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(addr), 8));
						addr(2) := startadd(2);
						addr(1) := startadd(1);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(addr), 8));
						READ(L=>buf, VALUE=>rec_type, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
							SEVERITY ERROR;
						end if;
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(rec_type), 8));
					else
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
						SEVERITY ERROR;
					end if;
					case rec_type is
						when "00"=>
							i := 0;
							k := 0;
							while( i < ibyte ) loop
								mem_data_tmp := 0;
								for j in 0 to 1 loop
									READ(L=>buf, VALUE=>datain,good=>booval);
									if not (booval) then
										ASSERT FALSE
										REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
										SEVERITY ERROR;
									end if;
									check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(datain), 8));
									mem_data_tmp := mem_data_tmp * 256 + hex_str_to_int(datain);
									i := i + 1;
									if (i = ibyte) then
										exit;
									end if;
								end loop;

								mem_data(ibase + istartadd + k) := CONV_STD_LOGIC_VECTOR(mem_data_tmp, lpm_Width);

								k := k + 1;
							end loop;
						when "01"=>
							exit;
						when "02"=>
							ibase := 0;
							if (ibyte /= 2) then
								ASSERT FALSE
								REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format for record type 02! "
								SEVERITY ERROR;
							end if;
							for i in 0 to (ibyte-1) loop
								READ(L=>buf, VALUE=>base,good=>booval);
								ibase := ibase * 256 + hex_str_to_int(base);
								if not (booval) then
									ASSERT FALSE
									REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
									SEVERITY ERROR;
								end if;
								check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(base), 8));
							end loop;
							ibase := ibase * 16;
						when OTHERS =>
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal record type in Intel Hex File! "
							SEVERITY ERROR;
					end case;
					READ(L=>buf, VALUE=>checksum,good=>booval);
					if not (booval) then
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Checksum is missing! "
						SEVERITY ERROR;
					end if;

					check_sum_vec := unsigned(not (check_sum_vec)) + 1 ;
					check_sum_vec_tmp := CONV_STD_LOGIC_VECTOR(hex_str_to_int(checksum),8);

					if (check_sum_vec /= check_sum_vec_tmp) then
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Incorrect checksum!"
						SEVERITY ERROR;
					end if;
				end loop;
			end if;
			mem_init := TRUE;
		end if;

		-- MEMORY FUNCTION --
		if we_tmp = '1' then
			mem_data (conv_integer(address_tmp)) := data_tmp;
		end if;
		q_tmp <= mem_data(conv_integer(address_tmp));
	end process;

end LPM_SYN;


---------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;
use std.textio.all;

entity LPM_RAM_DP is
	generic (LPM_WIDTH : positive;
			 LPM_WIDTHAD : positive;
			 LPM_NUMWORDS : natural := 0;
			 LPM_INDATA : string := "REGISTERED";
			 LPM_OUTDATA : string := "REGISTERED";
			 LPM_RDADDRESS_CONTROL : string := "REGISTERED";
			 LPM_WRADDRESS_CONTROL : string := "REGISTERED";
			 LPM_FILE : string := "UNUSED";
			 LPM_TYPE : string := "LPM_RAM_DP";
			 LPM_HINT : string := "UNUSED");
	port (RDCLOCK : in std_logic := '0';
		  RDCLKEN : in std_logic := '1';
		  RDADDRESS : in std_logic_vector(LPM_WIDTHad-1 downto 0);
		  RDEN : in std_logic := '1';
		  DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  WRADDRESS : in std_logic_vector(LPM_WIDTHad-1 downto 0);
		  WREN : in std_logic;
		  WRCLOCK : in std_logic := '0';
		  WRCLKEN : in std_logic := '1';
		  Q : out std_logic_vector(LPM_WIDTH-1 downto 0));

	function int_to_str( value : integer ) return string is
	variable ivalue,index : integer;
	variable digit : integer;
	variable line_no: string(8 downto 1) := "        ";  
	begin
		ivalue := value;
		index := 1;
		while (ivalue > 0 ) loop
			digit := ivalue MOD 10;
			ivalue := ivalue/10;
			case digit is
				when 0 =>
					line_no(index) := '0';
				when 1 =>
					line_no(index) := '1';
				when 2 =>
					line_no(index) := '2';
				when 3 =>
					line_no(index) := '3';
				when 4 =>
					line_no(index) := '4';
				when 5 =>
					line_no(index) := '5';
				when 6 =>
					line_no(index) := '6';
				when 7 =>
					line_no(index) := '7';
				when 8 =>
					line_no(index) := '8';
				when 9 =>
					line_no(index) := '9';
				when others =>
					ASSERT FALSE
					REPORT "Illegal number!"
					SEVERITY ERROR;
			end case;
			index := index + 1;
		end loop;
		return line_no;
	end;

	function hex_str_to_int( str : string ) return integer is
	variable len : integer := str'length;
	variable ivalue : integer := 0;
	variable digit : integer;
	begin
		for i in len downto 1 loop
			case str(i) is
				when '0' =>
					digit := 0;
				when '1' =>
					digit := 1;
				when '2' =>
					digit := 2;
				when '3' =>
					digit := 3;
				when '4' =>
					digit := 4;
				when '5' =>
					digit := 5;
				when '6' =>
					digit := 6;
				when '7' =>
					digit := 7;
				when '8' =>
					digit := 8;
				when '9' =>
					digit := 9;
				when 'A' =>
					digit := 10;
				when 'a' =>
					digit := 10;
				when 'B' =>
					digit := 11;
				when 'b' =>
					digit := 11;
				when 'C' =>
					digit := 12;
				when 'c' =>
					digit := 12;
				when 'D' =>
					digit := 13;
				when 'd' =>
					digit := 13;
				when 'E' =>
					digit := 14;
				when 'e' =>
					digit := 14;
				when 'F' =>
					digit := 15;
				when 'f' =>
					digit := 15;
				when others =>
					ASSERT FALSE
					REPORT "Illegal character "&  str(i) & "in Intel Hex File! "
					SEVERITY ERROR;
			end case;
			ivalue := ivalue * 16 + digit;
		end loop;
		return ivalue;
	end;

	procedure Shrink_line(L : inout LINE; pos : in integer) is
	subtype nstring is string(1 to pos);
	variable stmp : nstring;
	begin
		if pos >= 1 then
			read(l, stmp);
		end if;
	end;

end LPM_RAM_DP;

architecture LPM_SYN of lpm_ram_dp is

--type lpm_memory is array(lpm_numwords-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);
type lpm_memory is array((2**lpm_widthad)-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);

signal data_tmp, data_reg : std_logic_vector(lpm_width-1 downto 0);
signal q_tmp, q_reg : std_logic_vector(lpm_width-1 downto 0);
signal rdaddress_tmp, rdaddress_reg : std_logic_vector(lpm_widthad-1 downto 0);
signal wraddress_tmp, wraddress_reg : std_logic_vector(lpm_widthad-1 downto 0);
signal wren_tmp, wren_reg : std_logic;
signal rden_tmp, rden_reg : std_logic;

begin
	sync: process(data,data_reg, rdaddress, rdaddress_reg, wren,wren_reg, 
				  rden, rden_reg, q_tmp, q_reg)
	begin
		if (lpm_rdaddress_control = "REGISTERED") then
			rdaddress_tmp <= rdaddress_reg;
			rden_tmp <= rden_reg;
		else
			rdaddress_tmp <= rdaddress;
			rden_tmp <= rden;
		end if;
		if (lpm_wraddress_control = "REGISTERED") then
			wraddress_tmp <= wraddress_reg;
			wren_tmp <= wren_reg; 
		else
			wraddress_tmp <= wraddress;
			wren_tmp <= wren;
		end if;
		if (lpm_indata = "REGISTERED") then
			data_tmp <= data_reg;
		else
			data_tmp <= data;
		end if;
		if (lpm_outdata = "REGISTERED") then
			q <= q_reg;
		else
			q <= q_tmp;
		end if;
	end process;

	input_reg: process (wrclock)
	begin
		if wrclock'event and wrclock = '1' and wrclken = '1' then
			data_reg <= data;
			wraddress_reg <= wraddress;
			wren_reg <= wren;
		end if;
	end process;

	output_reg: process (rdclock)
	begin
		if rdclock'event and rdclock = '1' and rdclken = '1' then
			rdaddress_reg <= rdaddress;
			rden_reg <= rden; 
			q_reg <= q_tmp;
		end if;
	end process;

	memory: process(data_tmp, wren_tmp, rdaddress_tmp, wraddress_tmp, rden_tmp)
	variable mem_data : lpm_memory;
	variable mem_data_tmp : integer := 0;
	variable mem_init: boolean := false;
	variable i,j,k,lineno: integer := 0;
	variable buf: line ;
	variable booval: boolean ;
	FILE mem_data_file: TEXT IS IN LPM_FILE;
	variable base, byte, rec_type, datain, addr, checksum: string(2 downto 1);
	variable startadd: string(4 downto 1);
	variable ibase: integer := 0;
	variable ibyte: integer := 0;
	variable istartadd: integer := 0;
	variable check_sum_vec, check_sum_vec_tmp: std_logic_vector(7 downto 0);
	begin
		-- INITIALIZE --
		if NOT(mem_init) then
			-- INITIALIZE TO 0 --
			for i in mem_data'LOW to mem_data'HIGH loop
				mem_data(i) := (OTHERS => '0');
			end loop;

			if (LPM_FILE = "UNUSED") then
				ASSERT FALSE
				REPORT "Initialization file not found!"
				SEVERITY WARNING;
			else
				WHILE NOT ENDFILE(mem_data_file) loop
					booval := true;
					READLINE(mem_data_file, buf);
					lineno := lineno + 1;
					check_sum_vec := (OTHERS => '0');
					if (buf(buf'LOW) = ':') then
						i := 1;
						shrink_line(buf, i);
						READ(L=>buf, VALUE=>byte, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format!"
							SEVERITY ERROR;
						end if;
						ibyte := hex_str_to_int(byte);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(ibyte, 8));
						READ(L=>buf, VALUE=>startadd, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
							SEVERITY ERROR;
						end if;
						istartadd := hex_str_to_int(startadd);
						addr(2) := startadd(4);
						addr(1) := startadd(3);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(addr), 8));
						addr(2) := startadd(2);
						addr(1) := startadd(1);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(addr), 8));
						READ(L=>buf, VALUE=>rec_type, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
							SEVERITY ERROR;
						end if;
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(rec_type), 8));
					else
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
						SEVERITY ERROR;
					end if;
					case rec_type is
						when "00"=>
							i := 0;
							k := 0;
							while( i < ibyte ) loop
								mem_data_tmp := 0;
								for j in 0 to 1 loop
									READ(L=>buf, VALUE=>datain,good=>booval);
									if not (booval) then
										ASSERT FALSE
										REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
										SEVERITY ERROR;
									end if;
									check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(datain), 8));
									mem_data_tmp := mem_data_tmp * 256 + hex_str_to_int(datain);
									i := i + 1;
									if (i = ibyte) then
										exit;
									end if;
								end loop;

								mem_data(ibase + istartadd + k) := CONV_STD_LOGIC_VECTOR(mem_data_tmp, lpm_Width);

								k := k + 1;
							end loop;
						when "01"=>
							exit;
						when "02"=>
							ibase := 0;
							if (ibyte /= 2) then
								ASSERT FALSE
								REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format for record type 02! "
								SEVERITY ERROR;
							end if;
							for i in 0 to (ibyte-1) loop
								READ(L=>buf, VALUE=>base,good=>booval);
								ibase := ibase * 256 + hex_str_to_int(base);
								if not (booval) then
									ASSERT FALSE
									REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
									SEVERITY ERROR;
								end if;
								check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(base), 8));
							end loop;
							ibase := ibase * 16;
						when OTHERS =>
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal record type in Intel Hex File! "
							SEVERITY ERROR;
					end case;
					READ(L=>buf, VALUE=>checksum,good=>booval);
					if not (booval) then
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Checksum is missing! "
						SEVERITY ERROR;
					end if;

					check_sum_vec := unsigned(not (check_sum_vec)) + 1 ;
					check_sum_vec_tmp := CONV_STD_LOGIC_VECTOR(hex_str_to_int(checksum),8);

					if (check_sum_vec /= check_sum_vec_tmp) then
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Incorrect checksum!"
						SEVERITY ERROR;
					end if;
				end loop;
			end if;
			mem_init := TRUE;
		end if;

		-- MEMORY FUNCTION --
		if wren_tmp = '1' then
			mem_data (conv_integer(wraddress_tmp)) := data_tmp;
		end if;
		if rden_tmp = '1' then
			q_tmp <= mem_data(conv_integer(rdaddress_tmp));
		--else
		--    q_tmp <= (OTHERS => 'Z');
		end if;
	end process;

end LPM_SYN;


---------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;
use std.textio.all;

entity LPM_RAM_IO is
	generic (LPM_WIDTH : positive;
			 LPM_WIDTHAD : positive;
			 LPM_NUMWORDS : natural := 0;
			 LPM_INDATA : string := "REGISTERED";
			 LPM_ADDRESS_CONTROL : string := "REGISTERED";
			 LPM_OUTDATA : string := "REGISTERED";
			 LPM_FILE : string := "UNUSED";
			 LPM_TYPE : string := "LPM_RAM_IO";
			 LPM_HINT : string := "UNUSED");
	port (ADDRESS : in STD_LOGIC_VECTOR(LPM_WIDTHAD-1 downto 0);
		  INCLOCK : in STD_LOGIC := '0';
		  OUTCLOCK : in STD_LOGIC := '0';
		  MEMENAB : in STD_LOGIC := '1';
		  OUTENAB : in STD_LOGIC := 'Z';
		  WE : in STD_LOGIC := 'Z';
		  DIO : inout STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0));

	function int_to_str( value : integer ) return string is
	variable ivalue,index : integer;
	variable digit : integer;
	variable line_no: string(8 downto 1) := "        ";  
	begin
		ivalue := value;
		index := 1;
		while (ivalue > 0 ) loop
			digit := ivalue MOD 10;
			ivalue := ivalue/10;
			case digit is
				when 0 =>
					line_no(index) := '0';
				when 1 =>
					line_no(index) := '1';
				when 2 =>
					line_no(index) := '2';
				when 3 =>
					line_no(index) := '3';
				when 4 =>
					line_no(index) := '4';
				when 5 =>
					line_no(index) := '5';
				when 6 =>
					line_no(index) := '6';
				when 7 =>
					line_no(index) := '7';
				when 8 =>
					line_no(index) := '8';
				when 9 =>
					line_no(index) := '9';
				when others =>
					ASSERT FALSE
					REPORT "Illegal number!"
					SEVERITY ERROR;
			end case;
			index := index + 1;
		end loop;
		return line_no;
	end;

	function hex_str_to_int( str : string ) return integer is
	variable len : integer := str'length;
	variable ivalue : integer := 0;
	variable digit : integer;
	begin
		for i in len downto 1 loop
			case str(i) is
				when '0' =>
					digit := 0;
				when '1' =>
					digit := 1;
				when '2' =>
					digit := 2;
				when '3' =>
					digit := 3;
				when '4' =>
					digit := 4;
				when '5' =>
					digit := 5;
				when '6' =>
					digit := 6;
				when '7' =>
					digit := 7;
				when '8' =>
					digit := 8;
				when '9' =>
					digit := 9;
				when 'A' =>
					digit := 10;
				when 'a' =>
					digit := 10;
				when 'B' =>
					digit := 11;
				when 'b' =>
					digit := 11;
				when 'C' =>
					digit := 12;
				when 'c' =>
					digit := 12;
				when 'D' =>
					digit := 13;
				when 'd' =>
					digit := 13;
				when 'E' =>
					digit := 14;
				when 'e' =>
					digit := 14;
				when 'F' =>
					digit := 15;
				when 'f' =>
					digit := 15;
				when others =>
					ASSERT FALSE
					REPORT "Illegal character "&  str(i) & "in Intel Hex File! "
					SEVERITY ERROR;
			end case;
			ivalue := ivalue * 16 + digit;
		end loop;
		return ivalue;
	end;

	procedure Shrink_line(L : inout LINE; pos : in integer) is
	subtype nstring is string(1 to pos);
	variable stmp : nstring;
	begin
		if pos >= 1 then
			read(l, stmp);
		end if;
	end;

end LPM_RAM_IO;

architecture LPM_SYN of lpm_ram_io is

--type lpm_memory is array(lpm_numwords-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);
type lpm_memory is array((2**lpm_widthad)-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);

signal data_tmp, data_reg, di, do : std_logic_vector(lpm_width-1 downto 0);
signal q_tmp, q_reg , q : std_logic_vector(lpm_width-1 downto 0);
signal address_tmp, address_reg : std_logic_vector(lpm_widthad-1 downto 0);
signal we_tmp, we_reg : std_logic;
signal memenab_tmp, memenab_reg : std_logic;

signal outenab_used : std_logic;

-- provided for MP2 compliance
signal we_used : std_logic;

begin
	sync: process(di, data_reg, address, address_reg, memenab, memenab_reg, 
				  we,we_reg, q_tmp, q_reg)
	begin
		if (lpm_address_control = "REGISTERED") then
			address_tmp <= address_reg;
			we_tmp <= we_reg;
			memenab_tmp <= memenab_reg;
		else
			address_tmp <= address;
			we_tmp <= we;
			memenab_tmp <= memenab;
		end if;
		if (lpm_indata = "REGISTERED") then
			data_tmp <= data_reg;
		else
			data_tmp <= di;
		end if;
		if (lpm_outdata = "REGISTERED") then
			q <= q_reg;
		else
			q <= q_tmp;
		end if;
	end process;

	input_reg: process (inclock)
	begin
		if inclock'event and inclock = '1' then
			data_reg <= di;
			address_reg <= address;
			we_reg <= we;
			memenab_reg <= memenab;
		end if;
	end process;

	output_reg: process (outclock)
	begin
		if outclock'event and outclock = '1' then
			q_reg <= q_tmp;
		end if;
	end process;

	memory: process(data_tmp, we_tmp, memenab_tmp, outenab, address_tmp)
	variable mem_data : lpm_memory;
	variable mem_data_tmp : integer := 0;
	variable mem_init: boolean := false;
	variable i,j,k,lineno: integer := 0;
	variable buf: line ;
	variable booval: boolean ;
	FILE mem_data_file: TEXT IS IN LPM_FILE;
	variable base, byte, rec_type, datain, addr, checksum: string(2 downto 1);
	variable startadd: string(4 downto 1);
	variable ibase: integer := 0;
	variable ibyte: integer := 0;
	variable istartadd: integer := 0;
	variable check_sum_vec, check_sum_vec_tmp: std_logic_vector(7 downto 0);
	begin
		-- INITIALIZE --
		if NOT(mem_init) then
			-- INITIALIZE TO 0 --
			for i in mem_data'LOW to mem_data'HIGH loop
				mem_data(i) := (OTHERS => '0');
			end loop;

			if (outenab = 'Z' and we = 'Z') then
				ASSERT FALSE
				REPORT "One of OutEnab or WE must be used!"
				SEVERITY ERROR;
			end if;

			-- In reality, both are needed in current TDF implementation
			if (outenab /= 'Z' and we /= 'Z') then
				ASSERT FALSE
				REPORT "Only one of OutEnab or WE should be used!"
				-- Change severity to ERROR for full LPM 220 compliance
				SEVERITY WARNING;
			end if;

			-- Comment out the following 5 lines for full LPM 220 compliance
			if (we = 'Z') then
				ASSERT FALSE
				REPORT "WE is required!"
				SEVERITY WARNING;
			end if;

			if (outenab = 'Z') then
				outenab_used <= '0';
				we_used <= '1';
			else
				outenab_used <= '1';
				we_used <= '0';
			end if;
			
			-- Comment out the following 5 lines for full LPM 220 compliance
			if (we = 'Z') then
				we_used <= '0';
			else
				we_used <= '1';
			end if;

			if (LPM_FILE = "UNUSED") then
				ASSERT FALSE
				REPORT "Initialization file not found!"
				SEVERITY WARNING;
			else
				WHILE NOT ENDFILE(mem_data_file) loop
					booval := true;
					READLINE(mem_data_file, buf);
					lineno := lineno + 1;
					check_sum_vec := (OTHERS => '0');
					if (buf(buf'LOW) = ':') then
						i := 1;
						shrink_line(buf, i);
						READ(L=>buf, VALUE=>byte, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format!"
							SEVERITY ERROR;
						end if;
						ibyte := hex_str_to_int(byte);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(ibyte, 8));
						READ(L=>buf, VALUE=>startadd, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
							SEVERITY ERROR;
						end if;
						istartadd := hex_str_to_int(startadd);
						addr(2) := startadd(4);
						addr(1) := startadd(3);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(addr), 8));
						addr(2) := startadd(2);
						addr(1) := startadd(1);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(addr), 8));
						READ(L=>buf, VALUE=>rec_type, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
							SEVERITY ERROR;
						end if;
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(rec_type), 8));
					else
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
						SEVERITY ERROR;
					end if;
					case rec_type is
						when "00"=>
							i := 0;
							k := 0;
							while( i < ibyte ) loop
								mem_data_tmp := 0;
								for j in 0 to 1 loop
									READ(L=>buf, VALUE=>datain,good=>booval);
									if not (booval) then
										ASSERT FALSE
										REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
										SEVERITY ERROR;
									end if;
									check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(datain), 8));
									mem_data_tmp := mem_data_tmp * 256 + hex_str_to_int(datain);
									i := i + 1;
									if (i = ibyte) then
										exit;
									end if;
								end loop;

								mem_data(ibase + istartadd + k) := CONV_STD_LOGIC_VECTOR(mem_data_tmp, lpm_Width);

								k := k + 1;
							end loop;
						when "01"=>
							exit;
						when "02"=>
							ibase := 0;
							if (ibyte /= 2) then
								ASSERT FALSE
								REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format for record type 02! "
								SEVERITY ERROR;
							end if;
							for i in 0 to (ibyte-1) loop
								READ(L=>buf, VALUE=>base,good=>booval);
								ibase := ibase * 256 + hex_str_to_int(base);
								if not (booval) then
									ASSERT FALSE
									REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
									SEVERITY ERROR;
								end if;
								check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(base), 8));
							end loop;
							ibase := ibase * 16;
						when OTHERS =>
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal record type in Intel Hex File! "
							SEVERITY ERROR;
					end case;
					READ(L=>buf, VALUE=>checksum,good=>booval);
					if not (booval) then
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Checksum is missing! "
						SEVERITY ERROR;
					end if;

					check_sum_vec := unsigned(not (check_sum_vec)) + 1 ;
					check_sum_vec_tmp := CONV_STD_LOGIC_VECTOR(hex_str_to_int(checksum),8);

					if (check_sum_vec /= check_sum_vec_tmp) then
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Incorrect checksum!"
						SEVERITY ERROR;
					end if;
				end loop;
			end if;
			mem_init := TRUE;
		end if;

		-- MEMORY FUNCTION --
		if (((we_used = '1' and we_tmp = '1')
			 or (outenab_used = '1' and we_used = '0' and outenab = '0'))
			and memenab_tmp = '1') then
			mem_data (conv_integer(address_tmp)) := data_tmp ;
			q_tmp <= data_tmp ;
		else
			q_tmp <= mem_data(conv_integer(address_tmp)) ; 
		end if;
	end process;

	di <= dio when ((outenab_used = '0' and we = '1')
					or (outenab_used = '1' and outenab = '0'))
			  else (OTHERS => 'Z');
	do <= q when memenab_tmp = '1' else (OTHERS => 'Z') ;
	dio <= do when ((outenab_used = '0' and we = '0')
					or (outenab_used = '1' and outenab = '1'))
			  else (OTHERS => 'Z');

end LPM_SYN;


---------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;
use std.textio.all;

entity LPM_ROM is
	generic (LPM_WIDTH : positive;
			 LPM_WIDTHAD : positive;
			 LPM_NUMWORDS : natural := 0;
			 LPM_ADDRESS_CONTROL : string := "REGISTERED";
			 LPM_OUTDATA : string := "REGISTERED";
			 LPM_FILE : string;
			 LPM_TYPE : string := "LPM_ROM";
			 LPM_HINT : string := "UNUSED");
	port (ADDRESS : in STD_LOGIC_VECTOR(LPM_WIDTHAD-1 downto 0);
		  INCLOCK : in STD_LOGIC := '0';
		  OUTCLOCK : in STD_LOGIC := '0';
		  MEMENAB : in STD_LOGIC := '1';
		  Q : out STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0));

	function int_to_str( value : integer ) return string is
	variable ivalue,index : integer;
	variable digit : integer;
	variable line_no: string(8 downto 1) := "        ";  
	begin
		ivalue := value;
		index := 1;
		while (ivalue > 0 ) loop
			digit := ivalue MOD 10;
			ivalue := ivalue/10;
			case digit is
				when 0 =>
					line_no(index) := '0';
				when 1 =>
					line_no(index) := '1';
				when 2 =>
					line_no(index) := '2';
				when 3 =>
					line_no(index) := '3';
				when 4 =>
					line_no(index) := '4';
				when 5 =>
					line_no(index) := '5';
				when 6 =>
					line_no(index) := '6';
				when 7 =>
					line_no(index) := '7';
				when 8 =>
					line_no(index) := '8';
				when 9 =>
					line_no(index) := '9';
				when others =>
					ASSERT FALSE
					REPORT "Illegal number!"
					SEVERITY ERROR;
			end case;
			index := index + 1;
		end loop;
		return line_no;
	end;

	function hex_str_to_int( str : string ) return integer is
	variable len : integer := str'length;
	variable ivalue : integer := 0;
	variable digit : integer;
	begin
		for i in len downto 1 loop
			case str(i) is
				when '0' =>
					digit := 0;
				when '1' =>
					digit := 1;
				when '2' =>
					digit := 2;
				when '3' =>
					digit := 3;
				when '4' =>
					digit := 4;
				when '5' =>
					digit := 5;
				when '6' =>
					digit := 6;
				when '7' =>
					digit := 7;
				when '8' =>
					digit := 8;
				when '9' =>
					digit := 9;
				when 'A' =>
					digit := 10;
				when 'a' =>
					digit := 10;
				when 'B' =>
					digit := 11;
				when 'b' =>
					digit := 11;
				when 'C' =>
					digit := 12;
				when 'c' =>
					digit := 12;
				when 'D' =>
					digit := 13;
				when 'd' =>
					digit := 13;
				when 'E' =>
					digit := 14;
				when 'e' =>
					digit := 14;
				when 'F' =>
					digit := 15;
				when 'f' =>
					digit := 15;
				when others =>
					ASSERT FALSE
					REPORT "Illegal character "&  str(i) & "in Intel Hex File! "
					SEVERITY ERROR;
			end case;
			ivalue := ivalue * 16 + digit;
		end loop;
		return ivalue;
	end;

	procedure Shrink_line(L : inout LINE; pos : in integer) is
	subtype nstring is string(1 to pos);
	variable stmp : nstring;
	begin
		if pos >= 1 then
			read(l, stmp);
		end if;
	end;

end LPM_ROM;

architecture LPM_SYN of lpm_rom is

--type lpm_memory is array(lpm_numwords-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);
type lpm_memory is array((2**lpm_widthad)-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);

signal q2, q_tmp, q_reg : std_logic_vector(lpm_width-1 downto 0);
signal address_tmp, address_reg : std_logic_vector(lpm_widthad-1 downto 0);

begin

	enable_mem: process(memenab, q2)
	begin
		if (memenab = '1') then
			q <= q2;
		else
			q <= (OTHERS => 'Z');
		end if;
	end process;

	sync: process(address, address_reg, q_tmp, q_reg)
	begin
		if (lpm_address_control = "REGISTERED") then
			address_tmp <= address_reg;
		else
			address_tmp <= address;
		end if;
		if (lpm_outdata = "REGISTERED") then
			q2 <= q_reg;
		else
			q2 <= q_tmp;
		end if;
	end process;

	input_reg: process (inclock)
	begin
		if inclock'event and inclock = '1' then
			address_reg <= address;
		end if;
	end process;

	output_reg: process (outclock)
	begin
		if outclock'event and outclock = '1' then
			q_reg <= q_tmp;
		end if;
	end process;

	memory: process(memenab, address_tmp)
	variable mem_data : lpm_memory;
	variable mem_data_tmp : integer := 0;
	variable mem_init: boolean := false;
	variable i, j, k, lineno : integer := 0;
	variable buf: line ;
	variable booval: boolean ;
	FILE mem_data_file: TEXT IS IN LPM_FILE;
	variable base, byte, rec_type, datain, addr, checksum: string(2 downto 1);
	variable startadd: string(4 downto 1);
	variable ibase: integer := 0;
	variable ibyte: integer := 0;
	variable istartadd: integer := 0;
	variable check_sum_vec, check_sum_vec_tmp: std_logic_vector(7 downto 0);
	begin
		-- INITIALIZE --
		if NOT(mem_init) then
			-- INITIALIZE TO 0 --
			for i in mem_data'LOW to mem_data'HIGH loop
				mem_data(i) := (OTHERS => '0');
			end loop;

			if (LPM_FILE = "UNUSED") then
				ASSERT FALSE
				REPORT "Initialization file not found!"
				SEVERITY ERROR;
			else
				WHILE NOT ENDFILE(mem_data_file) loop
					booval := true;
					READLINE(mem_data_file, buf);
					lineno := lineno + 1;
					check_sum_vec := (OTHERS => '0');
					if (buf(buf'LOW) = ':') then
						i := 1;
						shrink_line(buf, i);
						READ(L=>buf, VALUE=>byte, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format!"
							SEVERITY ERROR;
						end if;
						ibyte := hex_str_to_int(byte);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(ibyte, 8));
						READ(L=>buf, VALUE=>startadd, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
							SEVERITY ERROR;
						end if;
						istartadd := hex_str_to_int(startadd);
						addr(2) := startadd(4);
						addr(1) := startadd(3);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(addr), 8));
						addr(2) := startadd(2);
						addr(1) := startadd(1);
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(addr), 8));
						READ(L=>buf, VALUE=>rec_type, good=>booval);
						if not (booval) then
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
							SEVERITY ERROR;
						end if;
						check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(rec_type), 8));
					else
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
						SEVERITY ERROR;
					end if;
					case rec_type is
						when "00"=>
							i := 0;
							k := 0;
							while( i < ibyte ) loop
								mem_data_tmp := 0;
								for j in 0 to 1 loop
									READ(L=>buf, VALUE=>datain,good=>booval);
									if not (booval) then
										ASSERT FALSE
										REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
										SEVERITY ERROR;
									end if;
									check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(datain), 8));
									mem_data_tmp := mem_data_tmp * 256 + hex_str_to_int(datain);
									i := i + 1;
									if (i = ibyte) then
										exit;
									end if;
								end loop;

								mem_data(ibase + istartadd + k) := CONV_STD_LOGIC_VECTOR(mem_data_tmp, lpm_Width);

								k := k + 1;
							end loop;
						when "01"=>
							exit;
						when "02"=>
							ibase := 0;
							if (ibyte /= 2) then
								ASSERT FALSE
								REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format for record type 02! "
								SEVERITY ERROR;
							end if;
							for i in 0 to (ibyte-1) loop
								READ(L=>buf, VALUE=>base,good=>booval);
								ibase := ibase * 256 + hex_str_to_int(base);
								if not (booval) then
									ASSERT FALSE
									REPORT "[Line "& int_to_str(lineno) & "]:Illegal Intel Hex Format! "
									SEVERITY ERROR;
								end if;
								check_sum_vec := unsigned(check_sum_vec) + unsigned(CONV_STD_LOGIC_VECTOR(hex_str_to_int(base), 8));
							end loop;
							ibase := ibase * 16;
						when OTHERS =>
							ASSERT FALSE
							REPORT "[Line "& int_to_str(lineno) & "]:Illegal record type in Intel Hex File! "
							SEVERITY ERROR;
					end case;
					READ(L=>buf, VALUE=>checksum,good=>booval);
					if not (booval) then
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Checksum is missing! "
						SEVERITY ERROR;
					end if;

					check_sum_vec := unsigned(not (check_sum_vec)) + 1 ;
					check_sum_vec_tmp := CONV_STD_LOGIC_VECTOR(hex_str_to_int(checksum),8);

					if (check_sum_vec /= check_sum_vec_tmp) then
						ASSERT FALSE
						REPORT "[Line "& int_to_str(lineno) & "]:Incorrect checksum!"
						SEVERITY ERROR;
					end if;
				end loop;
			end if;
			mem_init := TRUE;
		end if;

		-- MEMORY FUNCTION --
		--if memenab = '1' then
			q_tmp <= mem_data(conv_integer(address_tmp));
		--else
		--    q_tmp <= (OTHERS => 'Z');
		--end if;
	end process;

end LPM_SYN;


---------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_FIFO is
	generic (LPM_WIDTH : positive;
			 LPM_WIDTHU : positive := 1;
			 LPM_NUMWORDS : positive;
			 LPM_SHOWAHEAD : string := "OFF";
			 LPM_TYPE : string := "LPM_FIFO";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  CLOCK : in std_logic;
		  WRREQ : in std_logic;
		  RDREQ : in std_logic;
		  ACLR : in std_logic := '0';
		  SCLR : in std_logic := '0';
		  Q : out std_logic_vector(LPM_WIDTH-1 downto 0);
		  USEDW : out std_logic_vector(LPM_WIDTHU-1 downto 0);
		  FULL : out std_logic;
		  EMPTY : out std_logic);
end LPM_FIFO; 

architecture LPM_SYN of lpm_fifo is

type lpm_memory is array (lpm_numwords-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);

signal tmp_q : std_logic_vector(lpm_width-1 downto 0);
signal read_id, write_id, count_id : integer := 0;
signal empty_flag : std_logic := '1';
signal full_flag : std_logic := '0';
signal thresh_flag : std_logic;
constant zeros : std_logic_vector(lpm_width-1 downto 0) := (OTHERS => '0');

begin

	process (clock, aclr)
	variable mem_data : lpm_memory := (OTHERS => zeros);
	begin
		if (aclr = '1') then
			if (lpm_showahead /= "ON") then
				tmp_q <= (OTHERS => '0');
			end if;
			full_flag <= '0';
			empty_flag <= '1';
			read_id <= 0;
			write_id <= 0;
			count_id <= 0;
			if (lpm_showahead = "ON" and clock'event and clock = '1') then
				tmp_q <= data;
			end if;
		elsif (clock'event and clock = '1') then
			if (sclr = '1') then
				--tmp_q <= (OTHERS => '0'); 
				full_flag <= '0';
				empty_flag <= '1';
				read_id <= 0;
				write_id <= 0;
				count_id <= 0;
				
				if (rdreq = '1' and empty_flag = '0') then
					tmp_q <= mem_data(read_id);
				end if;
				if (lpm_showahead = "ON" and rdreq = '1') then
					tmp_q <= data;
				end if;
			else
				----- IF BOTH READ AND WRITE -----
				if (wrreq = '1' and full_flag = '0') and
					(rdreq = '1' and empty_flag = '0') then

					mem_data(write_id) := data;
					if (write_id = lpm_numwords - 1) then
						write_id <= 0;
					else
						write_id <= write_id + 1;
					end if;

					tmp_q <= mem_data(read_id);
					if (read_id = lpm_numwords -1) then
						read_id <= 0;
						if (lpm_showahead = "ON") then
							tmp_q <= mem_data(0);
						end if;
					else
						read_id <= read_id + 1;
						if (lpm_showahead = "ON") then
							tmp_q <= mem_data(read_id+1);
						end if;
					end if;

				----- IF WRITE (ONLY) -----
				elsif (wrreq = '1' and full_flag = '0') then

					mem_data(write_id) := data;
					if (lpm_showahead = "ON") then
						tmp_q <= mem_data(read_id);
					end if;
					count_id <= count_id + 1;
					empty_flag <= '0';
					if (count_id + 1 >= lpm_numwords) then
						full_flag <= '1';
						count_id <= 0;
					end if;
					if (write_id = lpm_numwords - 1) then
						write_id <= 0;
					else
						write_id <= write_id + 1;
					end if;

				----- IF READ (ONLY) -----
				elsif (rdreq = '1' and empty_flag = '0') then

					count_id <= count_id - 1;
					if (full_flag = '1' and count_id = 0) then
						count_id <= lpm_numwords - 1;
					end if;    
					full_flag <= '0';
					tmp_q <= mem_data(read_id);
					if (read_id = lpm_numwords -1) then
						read_id <= 0;
						if (lpm_showahead = "ON") then
							tmp_q <= mem_data(0);
						end if;
					else
						read_id <= read_id + 1;
						if (lpm_showahead = "ON") then
							tmp_q <= mem_data(read_id+1);
						end if;
					end if;
					if (count_id - 1 <= 0 and full_flag = '0') then
						empty_flag <= '1';
						if (lpm_showahead = "ON") then
							tmp_q <= data;
						end if;
					end if;

				----- NO READ NOR WRITE -----
				elsif (lpm_showahead = "ON" and empty_flag = '1') then
					tmp_q <= data;
				end if;
			end if;
		end if;
	end process;

	q <= tmp_q;
	full <= full_flag;
	empty <= empty_flag;
	usedw <= conv_std_logic_vector(count_id, lpm_widthu);

end LPM_SYN;


---------------------------------------------------------------------------
--
-- Assume parameters Delay_RdUsedW, Delay_WrUsedW, RdSync_DelayPipe, and
--     WrSync_DelayPipe to be all 0.
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_FIFO_DC is
	generic (LPM_WIDTH : positive ;
			 LPM_WIDTHU : positive := 1;
			 LPM_NUMWORDS : positive;
			 LPM_SHOWAHEAD : string := "OFF";
			 LPM_TYPE : string := "LPM_FIFO_DC";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  WRCLOCK : in std_logic;
		  RDCLOCK : in std_logic;
		  WRREQ : in std_logic;
		  RDREQ : in std_logic;
		  ACLR : in std_logic := '0';
		  Q : out std_logic_vector(LPM_WIDTH-1 downto 0);
		  WRUSEDW : out std_logic_vector(LPM_WIDTHU-1 downto 0);
		  RDUSEDW : out std_logic_vector(LPM_WIDTHU-1 downto 0);
		  WRFULL : out std_logic;
		  RDFULL : out std_logic;
		  WREMPTY : out std_logic;
		  RDEMPTY : out std_logic);
end LPM_FIFO_DC; 

architecture LPM_SYN of lpm_fifo_dc is

type lpm_memory is array (lpm_numwords-1 downto 0) of std_logic_vector(lpm_width-1 downto 0);

signal tmp_q : std_logic_vector(lpm_width-1 downto 0);
signal read_id, write_id, count_id : integer := 0;
signal rdcount_id, wrcount_id : integer := 0;
signal wrempty_flag, rdempty_flag : std_logic := '1';
signal wrfull_flag, rdfull_flag : std_logic := '0';
constant zeros : std_logic_vector(lpm_width-1 downto 0) := (OTHERS => '0');

signal rdempty_count, wrempty_count : integer := 0;
signal rdfull_f2, wrfull_f2 : std_logic := '0';

begin

	process (rdclock, wrclock, aclr)
	variable mem_data : lpm_memory := (OTHERS => zeros);
	begin
		if (aclr = '1') then
			tmp_q <= (OTHERS => '0');
			rdfull_flag <= '0';
			rdempty_flag <= '1';
			wrfull_flag <= '0';
			wrempty_flag <= '1';
			read_id <= 0;
			write_id <= 0;
			count_id <= 0;
			rdcount_id <= 0;
			wrcount_id <= 0;

			rdempty_count <= 0;
			wrempty_count <= 0;
			rdfull_f2 <= '0';
			wrfull_f2 <= '0';
		else
			if (wrclock'event and wrclock = '1') then
				wrcount_id <= count_id;

				-- SET EMPTY FLAG --
				if (wrempty_flag = '1' and wrcount_id > 0) then
					wrempty_flag <= '0';
					wrempty_count <= 0;
				elsif (wrempty_flag = '0' and wrcount_id = 0) then
					if (wrempty_count < 1) then
						wrempty_count <= wrempty_count + 1;
					else
						wrempty_flag <= '1';
						wrempty_count <= 0;
					end if;
				else
					wrempty_count <= 0;
				end if;

				-- SET FULL FLAG --
				if (wrcount_id >= lpm_numwords - 3) then
					wrfull_f2 <= '1';
				else
					wrfull_f2 <= '0';
				end if;
				wrfull_flag <= wrfull_f2;

				if (wrreq = '1' and wrfull_flag = '0') then

					---WRITE DATA---
					mem_data(write_id) := data;

					---INC COUNTER---
					count_id <= count_id + 1;
					wrcount_id <= count_id + 1;

					---SET OUTPUT---
					if (lpm_showahead = "ON") then
						tmp_q <= mem_data(read_id);
					end if;

					---SET FLAGS---
					wrempty_flag <= '0';
					wrempty_count <= 0;
					--if (count_id + 1 >= lpm_numwords - 1) then
					--    wrfull_flag <= '1';
					--    count_id <= 0;
					--end if;

					---INC POINTER---
					if (write_id = lpm_numwords -1) then
						write_id <= 0;
					else
						write_id <= write_id + 1;
					end if;
				end if;
			elsif (rdclock'event and rdclock = '1') then
				rdcount_id <= count_id;

				-- SET EMPTY FLAG --
				if (rdempty_flag = '1' and rdcount_id > 0) then
					if (rdempty_count > -1) then
						rdempty_count <= rdempty_count - 1;
					else
						rdempty_flag <= '0';
						rdempty_count <= 0;
					end if;
				elsif (rdempty_flag = '0' and rdcount_id = 0) then
					rdempty_flag <= '1';
					rdempty_count <= 0;
				else
					rdempty_count <= 0;
				end if;

				-- SET FULL FLAG --
				if (rdcount_id >= lpm_numwords - 3) then
					rdfull_f2 <= '1';
				else
					rdfull_f2 <= '0';
				end if;
				rdfull_flag <= rdfull_f2;

				if (rdreq = '1' and rdempty_flag = '0') then

					---READ DATA/SET OUTPUT---
					tmp_q <= mem_data(read_id);

					---INC COUNTER---
					count_id <= count_id - 1;
					rdcount_id <= count_id - 1;

					---SET FLAGS---
					--if (count_id = 0 and rdfull_flag = '1') then
					--    count_id <= lpm_numwords - 1;
					--end if;
					--if (count_id - 1 = 0 and rdfull_flag = '0') then
					if (count_id - 1 = 0) then
						rdempty_flag <= '1';
						rdempty_count <= 0;
					end if;

					---INC POINTER---
					if (read_id = lpm_numwords -1) then
						read_id <= 0;
						if (lpm_showahead = "ON") then
							tmp_q <= mem_data(0);
						end if;
					else
						read_id <= read_id + 1;
						if (lpm_showahead = "ON") then
							tmp_q <= mem_data(read_id+1);
						end if;
					end if;
				end if;
		   end if;
		end if;

	end process;
	 
	q <= tmp_q;
	wrfull <= wrfull_flag;
	wrempty <= wrempty_flag;
	rdfull <=  rdfull_flag;
	rdempty <= rdempty_flag;
	wrusedw <= conv_std_logic_vector(wrcount_id, lpm_widthu);
	rdusedw <= conv_std_logic_vector(rdcount_id, lpm_widthu);

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_INPAD is
	generic (LPM_WIDTH : positive;
			 LPM_TYPE : string := "LPM_INPAD";
			 LPM_HINT : string := "UNUSED");
	port (PAD : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_INPAD;

architecture LPM_SYN of LPM_INPAD is
begin

	RESULT <=  PAD;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_OUTPAD is
	generic (LPM_WIDTH : positive;
			 LPM_TYPE : string := "L_OUTPAD";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  PAD : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_OUTPAD;

architecture LPM_SYN of LPM_OUTPAD is
begin

	PAD <= DATA;

end LPM_SYN;


--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_BIPAD is
	generic (LPM_WIDTH : positive;
			 LPM_TYPE : string := "LPM_BIPAD";
			 LPM_HINT : string := "UNUSED");
	port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
		  ENABLE : in std_logic;
		  RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
		  PAD : inout std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_BIPAD;

architecture LPM_SYN of LPM_BIPAD is
begin

	process(DATA, PAD, ENABLE)
	begin
		if ENABLE = '1' then
			PAD <= DATA;
			RESULT <= (OTHERS => 'Z');
		else
			RESULT <= PAD;
			PAD <= (OTHERS => 'Z');
		end if;
	end process;

end LPM_SYN;
