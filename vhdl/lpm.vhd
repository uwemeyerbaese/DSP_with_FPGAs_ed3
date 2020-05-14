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
-- LPM Synthesizable Models (Support sting type generic)
--------------------------------------------------------------------------
-- Version 1.3    Date 07/30/96
--
-- Modification History
--
-- 1. Changed the DEFAULT value to UNUSED for LPM_SVALUE, LPM_AVALUE,
-- LPM_MODULUS, and LPM_NUMWORDS, LPM_HINT,LPM_STRENGTH, LPM_DIRECTION,
-- and LPM_PVALUE
--
-- 2. Added the two dimentional port components (AND, OR, XOR, and MUX).
--------------------------------------------------------------------------
-- Excluded Functions:
--
--  LPM_RAM_DQ, LPM_RAM_IO, LPM_ROM, and LPM_FSM, and LPM_TTABLE.
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
--    string UNUSED.
--------------------------------------------------------------------------
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;


entity LPM_CONSTANT is
    generic (LPM_WIDTH : positive;
             LPM_CVALUE: natural;
             LPM_TYPE: string := L_CONSTANT;
             LPM_STRENGTH : string := UNUSED);
    port (RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_CONSTANT;

architecture LPM_SYN of LPM_CONSTANT is
begin

  RESULT <= conv_std_logic_vector(LPM_CVALUE, LPM_WIDTH);

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_INV is
    generic (LPM_WIDTH : positive;
             LPM_TYPE: string := L_INV);
    port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
          RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_INV;

architecture LPM_SYN of LPM_INV is
begin

 RESULT <= not DATA;

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_BUSTRI is
    generic (LPM_WIDTH : positive;
             LPM_TYPE: string := L_BUSTRI);
    port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
          ENABLEDT : in std_logic;
          ENABLETR : in std_logic;
          RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
          TRDATA : inout std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_BUSTRI;

architecture LPM_SYN of LPM_BUSTRI is

begin

   process(DATA,TRDATA,ENABLETR,ENABLEDT)
   begin
       if ENABLEDT = '0' and ENABLETR = '1' then
          RESULT <= TRDATA;
          TRDATA <= (OTHERS => 'Z');
       elsif ENABLEDT = '1' and ENABLETR = '0' then
          RESULT <= (OTHERS => 'Z');
          TRDATA <= DATA;
       elsif ENABLEDT = '1' and ENABLETR = '1' then
          RESULT <= DATA;
          TRDATA <= DATA;
       else
          RESULT <= (OTHERS => 'Z');
          TRDATA <= (OTHERS => 'Z');
       end if;
   end process;

end LPM_SYN;



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;


entity LPM_DECODE is
    generic (LPM_WIDTH : positive;
             LPM_DECODES : natural;
             LPM_PIPELINE : integer := 0;
             LPM_TYPE: string := L_DECODE);
    port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
          ACLR : in std_logic := '0';
          CLOCK : in std_logic := '0';
          ENABLE : in std_logic;
          EQ : out std_logic_vector(LPM_DECODES-1 downto 0));
end LPM_DECODE;

architecture LPM_SYN of LPM_DECODE is
type t_eqtmp IS ARRAY (0 to LPM_PIPELINE) of std_logic_vector(LPM_DECODES-1 downto 0);
begin

   process(ACLR, CLOCK, DATA,ENABLE)
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
              elsif CLOCK'event and CLOCK = '1' then
                  eqtmp(0 to LPM_PIPELINE - 1) := eqtmp(1 to LPM_PIPELINE);
              end if;
          end if;
       end if;

       EQ <= eqtmp(0);
   end process;

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use work.LPM_COMPONENTS.all;

entity LPM_ADD_SUB_SIGNED is
    generic (LPM_WIDTH : positive;
             LPM_PIPELINE : integer := 0;
             LPM_DIRECTION : string);
    port (DATAA: in std_logic_vector(LPM_WIDTH downto 1);
          DATAB: in std_logic_vector(LPM_WIDTH downto 1);
          ACLR : in std_logic := '0';
          CLOCK : in std_logic := '0';
          CIN: in std_logic;
          ADD_SUB: in std_logic;
          RESULT: out std_logic_vector(LPM_WIDTH downto 1);
          COUT: out std_logic;
          OVERFLOW: out std_logic);
end LPM_ADD_SUB_SIGNED;

architecture LPM_SYN of LPM_ADD_SUB_SIGNED is

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
         if LPM_DIRECTION = ADD then
            resulttmp(LPM_PIPELINE) := A + B + CIN;
         elsif LPM_DIRECTION = work.LPM_COMPONENTS.SUB then
            resulttmp(LPM_PIPELINE) := A - B - CIN;
         else
            if ADD_SUB = '1' then
                resulttmp(LPM_PIPELINE) := A + B + CIN;
            else
                resulttmp(LPM_PIPELINE) := A - B - CIN;
            end if;
         end if;

         if (resulttmp(LPM_PIPELINE) > (2 ** (LPM_WIDTH-1)) -1) or
            (resulttmp(LPM_PIPELINE) < -2 ** (LPM_WIDTH-1)) then

              overflowtmp(LPM_PIPELINE) := '1';
         else
              overflowtmp(LPM_PIPELINE) := '0';
         end if;

         couttmp(LPM_PIPELINE) := resulttmp(LPM_PIPELINE)(LPM_WIDTH);

         if LPM_PIPELINE > 0 then
            if ACLR = '1' then
               overflowtmp := (OTHERS => '0');
               couttmp := (OTHERS => '0');
               for i in 0 to LPM_PIPELINE loop
                   resulttmp(i) := (OTHERS => '0');
               end loop;
            elsif CLOCK'event and CLOCK = '1' then
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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_ADD_SUB_UNSIGNED is
    generic (LPM_WIDTH : positive;
             LPM_PIPELINE : integer := 0;
             LPM_DIRECTION : string);
    port (DATAA: in std_logic_vector(LPM_WIDTH downto 1);
          DATAB: in std_logic_vector(LPM_WIDTH downto 1);
          ACLR : in std_logic := '0';
          CLOCK : in std_logic := '0';
          CIN: in std_logic;
          ADD_SUB: in std_logic;
          RESULT: out std_logic_vector(LPM_WIDTH downto 1);
          COUT: out std_logic;
          OVERFLOW: out std_logic);
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
         if LPM_DIRECTION = ADD then
            resulttmp(LPM_PIPELINE) := A + B + CIN;
         elsif LPM_DIRECTION = work.LPM_COMPONENTS.SUB then
            resulttmp(LPM_PIPELINE) := A - B - CIN;
         else
            if ADD_SUB = '1' then
                resulttmp(LPM_PIPELINE) := A + B + CIN;
            else
                resulttmp(LPM_PIPELINE) := A - B - CIN;
            end if;
         end if;

         if (resulttmp(LPM_PIPELINE) > (2 ** (LPM_WIDTH-1)) -1) or
            (resulttmp(LPM_PIPELINE) < -2 ** (LPM_WIDTH-1)) then

              overflowtmp(LPM_PIPELINE) := '1';
         else
              overflowtmp(LPM_PIPELINE) := '0';
         end if;

         couttmp(LPM_PIPELINE) := resulttmp(LPM_PIPELINE)(LPM_WIDTH);

         if LPM_PIPELINE > 0 then
            if ACLR = '1' then
               overflowtmp := (OTHERS => '0');
               couttmp := (OTHERS => '0');
               for i in 0 to LPM_PIPELINE loop
                   resulttmp(i) := (OTHERS => '0');
               end loop;
            elsif CLOCK'event and CLOCK = '1' then
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


library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_ADD_SUB is
    generic (LPM_WIDTH : positive;
             LPM_REPRESENTATION : string;
             LPM_DIRECTION : string;
             LPM_TYPE: string := L_ADD_SUB;
             LPM_PIPELINE : integer := 0;
             LPM_HINT : string := UNUSED);
    port (DATAA: in std_logic_vector(LPM_WIDTH downto 1);
          DATAB: in std_logic_vector(LPM_WIDTH downto 1);
          ACLR : in std_logic := '0';
          CLOCK : in std_logic := '0';
          CIN: in std_logic;
          ADD_SUB: in std_logic;
          RESULT: out std_logic_vector(LPM_WIDTH downto 1);
          COUT: out std_logic;
          OVERFLOW: out std_logic);
end LPM_ADD_SUB;

architecture LPM_SYN of LPM_ADD_SUB is

   component LPM_ADD_SUB_SIGNED
             generic (LPM_WIDTH : positive;
                      LPM_PIPELINE : integer := 0;
                      LPM_DIRECTION : string := UNUSED);
             port (DATAA: in std_logic_vector(LPM_WIDTH downto 1);
                   DATAB: in std_logic_vector(LPM_WIDTH downto 1);
                   ACLR : in std_logic := '0';
                   CLOCK : in std_logic := '0';
                   CIN: in std_logic;
                   ADD_SUB: in std_logic;
                   RESULT: out std_logic_vector(LPM_WIDTH downto 1);
                   COUT: out std_logic;
                   OVERFLOW: out std_logic);
   end component;

   component LPM_ADD_SUB_UNSIGNED
             generic (LPM_WIDTH : positive;
                      LPM_PIPELINE : integer := 0;
                      LPM_DIRECTION : string := UNUSED);
             port (DATAA: in std_logic_vector(LPM_WIDTH downto 1);
                   DATAB: in std_logic_vector(LPM_WIDTH downto 1);
                   ACLR : in std_logic := '0';
                   CLOCK : in std_logic := '0';
                   CIN: in std_logic;
                   ADD_SUB: in std_logic;
                   RESULT: out std_logic_vector(LPM_WIDTH downto 1);
                   COUT: out std_logic;
                   OVERFLOW: out std_logic);
   end component;


begin

L1: if LPM_REPRESENTATION = UNSIGNED generate

U:  LPM_ADD_SUB_UNSIGNED
     generic map (LPM_WIDTH => LPM_WIDTH, LPM_DIRECTION => LPM_DIRECTION,
                  LPM_PIPELINE => LPM_PIPELINE)
     port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR, CLOCK => CLOCK,
               CIN => CIN, ADD_SUB => ADD_SUB,RESULT => RESULT, COUT => COUT,
               OVERFLOW => OVERFLOW);

    end generate;

L2: if LPM_REPRESENTATION = SIGNED generate

V:  LPM_ADD_SUB_SIGNED
     generic map (LPM_WIDTH => LPM_WIDTH, LPM_DIRECTION => LPM_DIRECTION,
                  LPM_PIPELINE => LPM_PIPELINE)
     port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR, CLOCK => CLOCK,
               CIN => CIN, ADD_SUB => ADD_SUB,RESULT => RESULT, COUT => COUT,
               OVERFLOW => OVERFLOW);

    end generate;

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use work.LPM_COMPONENTS.all;

entity LPM_COMPARE_SIGNED is
    generic (LPM_WIDTH : positive;
             LPM_PIPELINE : integer := 0);
    port (DATAA: in std_logic_vector(LPM_WIDTH-1 downto 0);
          DATAB: in std_logic_vector(LPM_WIDTH-1 downto 0);
          ACLR : in std_logic := '0';
          CLOCK : in std_logic := '0';
          AGB: out std_logic;
          AGEB: out std_logic;
          AEB: out std_logic;
          ANEB: out std_logic;
          ALB: out std_logic;
          ALEB: out std_logic);
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
             elsif CLOCK'event and CLOCK = '1' then
                agbtmp(0 to LPM_PIPELINE - 1) :=  agbtmp(1 to LPM_PIPELINE);
                agebtmp(0 to LPM_PIPELINE - 1) := agebtmp(1 to LPM_PIPELINE) ;
                anebtmp(0 to LPM_PIPELINE - 1) := anebtmp(1 to LPM_PIPELINE);
                aebtmp(0 to LPM_PIPELINE - 1) := aebtmp(1 to LPM_PIPELINE);
                albtmp(0 to LPM_PIPELINE - 1) := albtmp(1 to LPM_PIPELINE);
                alebtmp(0 to LPM_PIPELINE - 1) := alebtmp(1 to LPM_PIPELINE);
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_COMPARE_UNSIGNED is
    generic (LPM_WIDTH : positive;
             LPM_PIPELINE : integer := 0);
    port (DATAA: in std_logic_vector(LPM_WIDTH-1 downto 0);
          DATAB: in std_logic_vector(LPM_WIDTH-1 downto 0);
          ACLR : in std_logic := '0';
          CLOCK : in std_logic := '0';
          AGB: out std_logic;
          AGEB: out std_logic;
          AEB: out std_logic;
          ANEB: out std_logic;
          ALB: out std_logic;
          ALEB: out std_logic);
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
             elsif CLOCK'event and CLOCK = '1' then
                agbtmp(0 to LPM_PIPELINE - 1) :=  agbtmp(1 to LPM_PIPELINE);
                agebtmp(0 to LPM_PIPELINE - 1) := agebtmp(1 to LPM_PIPELINE) ;
                anebtmp(0 to LPM_PIPELINE - 1) := anebtmp(1 to LPM_PIPELINE);
                aebtmp(0 to LPM_PIPELINE - 1) := aebtmp(1 to LPM_PIPELINE);
                albtmp(0 to LPM_PIPELINE - 1) := albtmp(1 to LPM_PIPELINE);
                alebtmp(0 to LPM_PIPELINE - 1) := alebtmp(1 to LPM_PIPELINE);
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

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_COMPARE is
    generic (LPM_WIDTH : positive;
             LPM_REPRESENTATION : string := SIGNED;
             LPM_TYPE: string := L_COMPARE;
             LPM_PIPELINE : integer := 0;
             LPM_HINT : string := UNUSED);
    port (DATAA: in std_logic_vector(LPM_WIDTH-1 downto 0);
          DATAB: in std_logic_vector(LPM_WIDTH-1 downto 0);
          ACLR : in std_logic := '0';
          CLOCK : in std_logic := '0';
          AGB: out std_logic;
          AGEB: out std_logic;
          AEB: out std_logic;
          ANEB: out std_logic;
          ALB: out std_logic;
          ALEB: out std_logic);
end LPM_COMPARE;

architecture LPM_SYN of LPM_COMPARE is

    component LPM_COMPARE_SIGNED
        generic (LPM_WIDTH : positive;
                 LPM_PIPELINE : integer := 0);
        port (DATAA: in std_logic_vector(LPM_WIDTH-1 downto 0);
              DATAB: in std_logic_vector(LPM_WIDTH-1 downto 0);
              ACLR : in std_logic := '0';
              CLOCK : in std_logic := '0';
              AGB: out std_logic;
              AGEB: out std_logic;
              AEB: out std_logic;
              ANEB: out std_logic;
              ALB: out std_logic;
              ALEB: out std_logic);
    end component;

    component LPM_COMPARE_UNSIGNED
        generic (LPM_WIDTH : positive;
                 LPM_PIPELINE : integer := 0);
        port (DATAA: in std_logic_vector(LPM_WIDTH-1 downto 0);
              DATAB: in std_logic_vector(LPM_WIDTH-1 downto 0);
              ACLR : in std_logic := '0';
              CLOCK : in std_logic := '0';
              AGB: out std_logic;
              AGEB: out std_logic;
              AEB: out std_logic;
              ANEB: out std_logic;
              ALB: out std_logic;
              ALEB: out std_logic);
    end component;

begin

L1: if LPM_REPRESENTATION = UNSIGNED generate

       U1: LPM_COMPARE_UNSIGNED
           generic map (LPM_WIDTH => LPM_WIDTH, LPM_PIPELINE => LPM_PIPELINE)
           port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR,
                     CLOCK => CLOCK, AGB => AGB, AGEB => AGEB,
                     AEB => AEB, ANEB => ANEB, ALB => ALB, ALEB => ALEB);
    end generate;

L2: if LPM_REPRESENTATION = SIGNED generate

       U2: LPM_COMPARE_SIGNED
           generic map (LPM_WIDTH => LPM_WIDTH, LPM_PIPELINE => LPM_PIPELINE)
           port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR,
                     CLOCK => CLOCK, AGB => AGB, AGEB => AGEB,
                     AEB => AEB, ANEB => ANEB, ALB => ALB, ALEB => ALEB);

    end generate;

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use work.LPM_COMPONENTS.all;

entity LPM_MULT_SIGNED is
   generic (LPM_WIDTHA : positive;
            LPM_WIDTHB : positive;
            LPM_WIDTHS : positive;
            LPM_WIDTHP : positive;
            LPM_PIPELINE : integer := 0);
   port (DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
         DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
         ACLR : in std_logic := '0';
         CLOCK : in std_logic := '0';
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
             elsif CLOCK'event and CLOCK = '1' then
                resulttmp(0 to LPM_PIPELINE - 1) := resulttmp(1 to LPM_PIPELINE);
             end if;
          end if;
       end if;

       RESULT <= resulttmp(0);
   end process;

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_MULT_UNSIGNED is
   generic (LPM_WIDTHA : positive;
            LPM_WIDTHB : positive;
            LPM_WIDTHS : positive;
            LPM_WIDTHP : positive;
            LPM_PIPELINE : integer := 0);
   port (DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
         DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
         ACLR : in std_logic := '0';
         CLOCK : in std_logic := '0';
         SUM : in std_logic_vector(LPM_WIDTHS-1 downto 0);
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
             elsif CLOCK'event and CLOCK = '1' then
                resulttmp(0 to LPM_PIPELINE - 1) := resulttmp(1 to LPM_PIPELINE);
             end if;
          end if;
       end if;

       RESULT <= resulttmp(0);
   end process;

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_MULT is
   generic (LPM_WIDTHA : positive;
            LPM_WIDTHB : positive;
            LPM_WIDTHS : positive;
            LPM_REPRESENTATION : string := UNSIGNED ;
            LPM_WIDTHP : positive;
            LPM_TYPE: string := L_MULT;
            LPM_PIPELINE : integer := 0;
            LPM_HINT : string := UNUSED);
   port (DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
         DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
         ACLR : in std_logic := '0';
         CLOCK : in std_logic := '0';
         SUM : in std_logic_vector(LPM_WIDTHS-1 downto 0);
         RESULT : out std_logic_vector(LPM_WIDTHP-1 downto 0));
end LPM_MULT;

architecture LPM_SYN of LPM_MULT is

     component LPM_MULT_UNSIGNED
       generic (LPM_WIDTHA : positive;
            LPM_WIDTHB : positive;
            LPM_WIDTHS : positive;
            LPM_WIDTHP : positive;
            LPM_PIPELINE : integer := 0);
       port (DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
            DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
            ACLR : in std_logic := '0';
            CLOCK : in std_logic := '0';
            SUM : in std_logic_vector(LPM_WIDTHS-1 downto 0);
            RESULT : out std_logic_vector(LPM_WIDTHP-1 downto 0));
     end component;

     component LPM_MULT_SIGNED
       generic (LPM_WIDTHA : positive;
            LPM_WIDTHB : positive;
            LPM_WIDTHS : positive;
            LPM_WIDTHP : positive;
            LPM_PIPELINE : integer := 0);
       port (DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
            DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
            ACLR : in std_logic := '0';
            CLOCK : in std_logic := '0';
            SUM : in std_logic_vector(LPM_WIDTHS-1 downto 0);
            RESULT : out std_logic_vector(LPM_WIDTHP-1 downto 0));
     end component;

begin

L1: if LPM_REPRESENTATION = UNSIGNED generate

       U1: LPM_MULT_UNSIGNED generic map (LPM_WIDTHA => LPM_WIDTHA,
                       LPM_WIDTHB => LPM_WIDTHB, LPM_WIDTHS => LPM_WIDTHS,
                       LPM_WIDTHP => LPM_WIDTHP, LPM_PIPELINE => LPM_PIPELINE)
          port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR,
                    SUM => SUM, CLOCK => CLOCK, RESULT => RESULT);
    end generate;

L2: if LPM_REPRESENTATION = SIGNED generate

       U1: LPM_MULT_SIGNED generic map (LPM_WIDTHA => LPM_WIDTHA,
                       LPM_WIDTHB => LPM_WIDTHB, LPM_WIDTHS => LPM_WIDTHS,
                       LPM_WIDTHP => LPM_WIDTHP, LPM_PIPELINE => LPM_PIPELINE)
          port map (DATAA => DATAA, DATAB => DATAB, ACLR => ACLR,
                    SUM => SUM, CLOCK => CLOCK, RESULT => RESULT);
    end generate;

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use work.LPM_COMPONENTS.all;

entity LPM_ABS is
    generic (LPM_WIDTH : positive := 2;
             LPM_TYPE: string := L_ABS);
    port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
          RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
          OVERFLOW: out std_logic);
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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_COUNTER is
     generic (LPM_WIDTH : positive;
              LPM_MODULUS : string := UNUSED;
              LPM_DIRECTION : string := UNUSED;
              LPM_AVALUE : string := UNUSED;
              LPM_SVALUE : string := UNUSED;
              LPM_TYPE: string := L_COUNTER;
              LPM_PVALUE : string := UNUSED;
              LPM_HINT : string := UNUSED);
     port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
           CLOCK : in std_logic;
           CLK_EN : in std_logic;
           CNT_EN : in std_logic;
           UPDOWN : in std_logic;
           SLOAD : in std_logic;
           SSET : in std_logic;
           SCLR : in std_logic;
           ALOAD : in std_logic;
           ASET : in std_logic;
           ACLR : in std_logic;
	   EQ : out std_logic;
           Q : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_COUNTER;

architecture LPM_SYN of LPM_COUNTER is
signal COUNT : std_logic_vector(LPM_WIDTH-1 downto 0);

begin

   Counter: process (CLOCK,ACLR,ASET,ALOAD,DATA)
   variable IAVALUE, ISVALUE : integer;
   begin
       if ACLR =  '1' then
              COUNT <= (OTHERS => '0');
       elsif ASET = '1' then
          if LPM_AVALUE = UNUSED then
              COUNT <= (OTHERS => '1');
          else
              IAVALUE := str_to_int(LPM_AVALUE);
              COUNT <= conv_std_logic_vector(IAVALUE, LPM_WIDTH);
          end if;
       elsif ALOAD = '1' then
              COUNT <= DATA;
       elsif CLOCK'event and CLOCK = '1' then
          if CLK_EN = '1' then
              if SCLR = '1' then
                 COUNT <= (OTHERS => '0');
              elsif SSET = '1' then
                 if LPM_SVALUE = UNUSED then
                     COUNT <= (OTHERS => '1');
                 else
                     ISVALUE := str_to_int(LPM_SVALUE);
                     COUNT <= conv_std_logic_vector(ISVALUE, LPM_WIDTH);
                 end if;
              elsif SLOAD = '1' then
                    COUNT <= DATA;
              elsif CNT_EN = '1' then
                 if LPM_DIRECTION = UNUSED then
                    if UPDOWN = '1' then
                        COUNT <= COUNT + 1;
                    else
                        COUNT <= COUNT - 1;
                    end if;
                 elsif LPM_DIRECTION = UP then
                    COUNT <= COUNT + 1;
                 elsif LPM_DIRECTION = DOWN then
                    COUNT <= COUNT - 1;
                 else
                    COUNT <= COUNT + 1; --Anything other than legal values.
                 end if;
              end if;
           end if;
       end if;
   end process Counter;


   Decode: process (COUNT)
   begin
       if LPM_MODULUS = UNUSED then
          if (COUNT = (2 ** LPM_WIDTH) -1) then
             EQ <= '1';
          else
             EQ <= '0';
          end if;
       else
          if COUNT = str_to_int(LPM_MODULUS)-1 then
             EQ <= '1';
          else
             EQ <= '0';
          end if;
       end if;
   end process Decode;

   Q <= COUNT;

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.LPM_COMPONENTS.all;

entity LPM_FF is
     generic (LPM_WIDTH : positive;
              LPM_AVALUE : string := UNUSED;
              LPM_SVALUE : string := UNUSED;
              LPM_FFTYPE : string := FFTYPE_DFF;
              LPM_TYPE: string := L_FF);
     port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
           CLOCK : in std_logic;
           ASET : in std_logic;
           ACLR : in std_logic;
           ALOAD: in std_logic;
           SSET : in std_logic;
           SCLR : in std_logic;
           SLOAD : in std_logic;
           ENABLE : in std_logic;
           Q : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_FF;

architecture LPM_SYN of LPM_FF is
signal IQ : std_logic_vector(LPM_WIDTH-1 downto 0);
begin

   process (DATA,CLOCK,ACLR,ASET,ALOAD)
   variable IAVALUE, ISVALUE : integer;
   begin
       if ACLR =  '1' then
              IQ <= (OTHERS => '0');
       elsif ASET = '1' then
          if LPM_AVALUE = UNUSED then
              IQ <= (OTHERS => '1');
          else
              IAVALUE := str_to_int(LPM_AVALUE);
              IQ <= conv_std_logic_vector(IAVALUE, LPM_WIDTH);
          end if;
       elsif ALOAD = '1' then
          if LPM_FFTYPE = FFTYPE_TFF then
              IQ <= DATA;
          end if;
       elsif CLOCK'event and CLOCK = '1' then
          if ENABLE = '1' then
              if SCLR = '1' then
                 IQ <= (OTHERS => '0');
              elsif SSET = '1' then
                 if LPM_SVALUE = UNUSED then
                   IQ <= (OTHERS => '1');
                 else
                   ISVALUE := str_to_int(LPM_SVALUE);
                   IQ <= conv_std_logic_vector(ISVALUE, LPM_WIDTH);
                 end if;
              elsif  SLOAD = '1' then
                 if LPM_FFTYPE = FFTYPE_TFF then
                   IQ <= DATA;
                 end if;
              else
                 if LPM_FFTYPE = FFTYPE_TFF then
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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.LPM_COMPONENTS.all;

entity LPM_SHIFTREG is
     generic (LPM_WIDTH : positive;
              LPM_AVALUE : string := UNUSED;
              LPM_SVALUE : string := UNUSED;
              LPM_PVALUE : string := UNUSED;
              LPM_DIRECTRION : string := UNUSED;
              LPM_TYPE: string := L_SHIFTREG);
     port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
           CLOCK : in std_logic;
           ASET : in std_logic;
           ACLR : in std_logic;
           SSET : in std_logic;
           SCLR : in std_logic;
           ENABLE : in std_logic;
           LOAD : in std_logic;
           SHIFTIN : in std_logic;
           SHIFTOUT : out std_logic;
           Q : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_SHIFTREG;

architecture LPM_SYN of LPM_SHIFTREG is
signal IQ : std_logic_vector(LPM_WIDTH downto 0);
begin

   process (CLOCK,ACLR,ASET,SCLR)
   variable IAVALUE, ISVALUE : integer;
   begin
       if ACLR =  '1' then
              IQ <= (OTHERS => '0');
       elsif ASET = '1' then
           if LPM_AVALUE = UNUSED then
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
                     if LPM_SVALUE = UNUSED then
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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.LPM_COMPONENTS.all;

entity LPM_LATCH is
     generic (LPM_WIDTH : positive;
              LPM_AVALUE : string := UNUSED;
              LPM_PVALUE : string := UNUSED;
              LPM_TYPE: string := L_LATCH);
     port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
           GATE : in std_logic;
           ASET : in std_logic;
           ACLR : in std_logic;
           Q : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_LATCH;

architecture LPM_SYN of LPM_LATCH is

begin

   process (DATA,GATE,ACLR,ASET)
   variable IAVALUE : integer;
   begin
       if ACLR =  '1' then
              Q <= (OTHERS => '0');
       elsif ASET = '1' then
          if LPM_AVALUE = UNUSED then
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


library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_INPAD is
    generic (LPM_WIDTH : positive;
             LPM_TYPE: string := L_INPAD);
    port (PAD : in std_logic_vector(LPM_WIDTH-1 downto 0);
          RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_INPAD;

architecture LPM_SYN of LPM_INPAD is
begin

 RESULT <=  PAD;

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_OUTPAD is
    generic (LPM_WIDTH : positive;
             LPM_TYPE: string := L_OUTPAD);
    port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
          PAD : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_OUTPAD;

architecture LPM_SYN of LPM_OUTPAD is
begin

   PAD <= DATA;

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_BIPAD is
    generic (LPM_WIDTH : positive;
             LPM_TYPE: string := L_BIPAD);
    port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
          ENABLE : in std_logic;
          RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
          PAD : inout std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_BIPAD;

architecture LPM_SYN of LPM_BIPAD is

begin

    process(DATA,PAD,ENABLE)
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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;


entity LPM_CLSHIFT is
    generic (LPM_WIDTH : positive;
             LPM_WIDTHDIST : positive;
             LPM_SHIFTTYPE : string;
             LPM_TYPE: string := L_CLSHIFT);
    port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
          DISTANCE : in std_logic_vector(LPM_WIDTHDIST-1 downto 0);
          DIRECTION : in std_logic;
          UNDERFLOW : out std_logic;
          OVERFLOW : out std_logic;
          RESULT: out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_CLSHIFT;

architecture LPM_SYN of LPM_CLSHIFT is
signal IRESULT : std_logic_vector(LPM_WIDTH-1 downto 0);
signal TMPDATA : std_logic_vector(LPM_WIDTHDIST downto 1);
begin

   process(DATA,DISTANCE,DIRECTION)
   begin

      TMPDATA <= (OTHERS => '0');
      if LPM_SHIFTTYPE = ARITHMETIC then
         if DIRECTION = '0' then
            IRESULT <= conv_std_logic_vector((conv_integer(DATA) * (2**LPM_WIDTHDIST)), LPM_WIDTH);
         else
            IRESULT <= conv_std_logic_vector((conv_integer(DATA) / (2**LPM_WIDTHDIST)), LPM_WIDTH);
         end if;

      elsif LPM_SHIFTTYPE = ROTATE then
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
      if LPM_SHIFTTYPE = LOGICAL or LPM_SHIFTTYPE = ROTATE then
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

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_AND is
    generic (LPM_WIDTH : positive ;
             LPM_SIZE : positive );
    port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0,LPM_WIDTH-1 downto 0);
          RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_AND;

architecture LPM_SYN of LPM_AND is

signal RESULT_INT : std_logic_2d(LPM_SIZE-1 downto 0,LPM_WIDTH-1 downto 0);

begin

   L1 : for i in 0 to LPM_WIDTH-1 generate
           RESULT_INT(0,i) <= DATA(0,i);
        L2:      for j in 0 to LPM_SIZE-2 generate
                    RESULT_INT(j+1,i) <=  RESULT_INT(j,i) and DATA(j+1,i);
           L3:      if j = LPM_SIZE-2 generate
                       RESULT(i) <= RESULT_INT(LPM_SIZE-1,i);
                    end generate L3;
                end generate L2;
        end generate L1;

end LPM_SYN;

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_OR is
    generic (LPM_WIDTH : positive ;
             LPM_SIZE : positive );
    port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0,LPM_WIDTH-1 downto 0);
          RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_OR;

architecture LPM_SYN of LPM_OR is

signal RESULT_INT : std_logic_2d(LPM_SIZE-1 downto 0,LPM_WIDTH-1 downto 0);

begin

   L1 : for i in 0 to LPM_WIDTH-1 generate
           RESULT_INT(0,i) <= DATA(0,i);
        L2 : for j in 0 to LPM_SIZE-2 generate
                RESULT_INT(j+1,i) <=  RESULT_INT(j,i) or DATA(j+1,i);
            L3 : if j = LPM_SIZE-2 generate
                     RESULT(i) <= RESULT_INT(LPM_SIZE-1,i);
            end generate L3;
        end generate L2;
   end generate L1;

end LPM_SYN;

library IEEE;
use IEEE.std_logic_1164.all;
use work.LPM_COMPONENTS.all;

entity LPM_XOR is
    generic (LPM_WIDTH : positive ;
             LPM_SIZE : positive );
    port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0,LPM_WIDTH-1 downto 0);
          RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end LPM_XOR;

architecture LPM_SYN of LPM_XOR is

signal RESULT_INT : std_logic_2d(LPM_SIZE-1 downto 0,LPM_WIDTH-1 downto 0);

begin

   L1 : for i in 0 to LPM_WIDTH-1 generate
            RESULT_INT(0,i) <= DATA(0,i);
       L2: for j in 0 to LPM_SIZE-2 generate
               RESULT_INT(j+1,i) <=  RESULT_INT(j,i) xor DATA(j+1,i);
          L3:  if j = LPM_SIZE-2 generate
                   RESULT(i) <= RESULT_INT(LPM_SIZE-1,i);
          end generate L3;
       end generate L2;
  end generate L1;

end LPM_SYN;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.LPM_COMPONENTS.all;

entity LPM_MUX is
    generic (LPM_WIDTH: positive ;
             LPM_WIDTHS : positive;
             LPM_SIZE: positive;
             LPM_PIPELINE : integer := 0);
    port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0, LPM_WIDTH-1 downto 0);
          ACLR : in std_logic := '0';
          CLOCK : in std_logic := '0';
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
             elsif CLOCK'event and CLOCK = '1' then
                 resulttmp(0 to LPM_PIPELINE - 1) := resulttmp(1 to LPM_PIPELINE);

             end if;
          end if;

          RESULT <= resulttmp(0);
       end if;

   end process;

end LPM_SYN;
