------------------------------------------------------------------
-- LPM 210 Component Declaration Package  (Support string type generic)
------------------------------------------------------------------
-- Version 1.3   Date 07/30/97
------------------------------------------------------------------
-- Excluded:
--
-- 1. LPM_POLARITY.
-- 2. SCAN pins are eliminated from storage functions.
------------------------------------------------------------------
-- Assumptions:
--
--    LPM_SVALUE, LPM_AVALUE, LPM_MODULUS, and LPM_NUMWORDS, LPM_HINT,
--    LPM_STRENGTH, LPM_DIRECTION, and LPM_PVALUE  default value is
--    string UNUSED.
------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package LPM_COMPONENTS is

constant SIGNED : string := "SIGNED";
constant UNSIGNED : string := "UNSIGNED";
constant ADD : string := "ADD";
constant SUB : string := "SUB";
constant UP : string := "UP";
constant DOWN : string := "DOWN";
constant LOGICAL : string := "LOGICAL";
constant ROTATE : string := "ROTATE";
constant ARITHMETIC : string := "ARITHMETIC";
constant REGISTERED : string := "REGISTERED";
constant UNREGISTERED : string := "UNREGISTERED";
constant F : string := "F";
constant FD : string := "FD";
constant FR : string := "FR";
constant FDR : string := "FDR";
constant UNUSED : string := "UNUSED";
constant FFTYPE_DFF : string := "DFF";
constant FFTYPE_TFF : string := "TFF";
constant L_CONSTANT : string := "LPM_CONSTANT";
constant L_INV : string := "LPM_INV";
constant L_AND : string := "LPM_AND";
constant L_OR : string := "LPM_OR";
constant L_XOR : string := "LPM_XOR";
constant L_BUSTRI : string := "LPM_BUSTRI";
constant L_MUX : string := "LPM_MUX";
constant L_DECODE : string := "LPM_DECODE";
constant L_CLSHIFT : string := "LPM_CLSHIFT";
constant L_ADD_SUB : string := "LPM_ADD_SUB";
constant L_COMPARE : string := "LPM_COMPARE";
constant L_MULT : string := "LPM_MULT";
constant L_ABS : string := "LPM_ABS";
constant L_COUNTER : string := "LPM_COUNTER";
constant L_LATCH : string := "LPM_LATCH";
constant L_FF : string := "LPM_FF";
constant L_SHIFTREG : string := "LPM_SHIFTREG";
constant L_RAM_DQ : string := "LPM_RAM_DQ";
constant L_RAM_IO : string := "LPM_RAM_IO";
constant L_ROM : string := "LPM_ROM";
constant L_TTABLE : string := "LPM_TTABLE";
constant L_FSM : string := "LPM_FSM";
constant L_INPAD : string := "LPM_INPAD";
constant L_OUTPAD : string := "LPM_OUTPAD";
constant L_BIPAD : string := "LPM_BIPAD";
type STD_LOGIC_2D is array (NATURAL RANGE <>, NATURAL RANGE <>) of STD_LOGIC;
function str_to_int(S : string) return integer;

component LPM_COUNTER
        generic (LPM_WIDTH : positive;
                 LPM_MODULUS: string := UNUSED;
                 LPM_AVALUE : string := UNUSED;
                 LPM_SVALUE : string := UNUSED;
                 LPM_DIRECTION : string := UNUSED;
                 LPM_TYPE: string := L_COUNTER;
                 LPM_PVALUE : string := UNUSED;
                 LPM_HINT : string := UNUSED);
        port (DATA: in std_logic_vector(LPM_WIDTH-1 downto 0):= (OTHERS => '0');
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
              EQ : out std_logic;
              Q : out std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

component LPM_ABS
        generic (LPM_WIDTH : positive;
                 LPM_TYPE: string := L_ABS;
                 LPM_HINT : string := UNUSED);
        port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
              RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
              OVERFLOW: out std_logic);
end component;

component LPM_MULT
        generic (LPM_WIDTHA : positive;
                 LPM_WIDTHB : positive;
                 LPM_WIDTHS : positive;
                 LPM_WIDTHP : positive;
                 LPM_REPRESENTATION : string := UNSIGNED;
                 LPM_PIPELINE : integer := 0;
                 LPM_TYPE: string := L_MULT;
                 LPM_HINT : string := UNUSED);
        port (DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
              DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
              ACLR : in std_logic := '0';
              CLOCK : in std_logic := '1';
              SUM: in std_logic_vector(LPM_WIDTHS-1 downto 0) := (OTHERS => '0');
              RESULT : out std_logic_vector(LPM_WIDTHP-1 downto 0));
end component;

component LPM_COMPARE
        generic (LPM_WIDTH : positive;
                 LPM_REPRESENTATION : string := SIGNED;
                 LPM_PIPELINE : integer := 0;
                 LPM_TYPE: string := L_COMPARE;
                 LPM_HINT : string := UNUSED);
        port (DATAA: in std_logic_vector(LPM_WIDTH-1 downto 0);
              DATAB: in std_logic_vector(LPM_WIDTH-1 downto 0);
              ACLR : in std_logic := '0';
              CLOCK : in std_logic := '1';
              AGB: out std_logic;
              AGEB: out std_logic;
              AEB: out std_logic;
              ANEB: out std_logic;
              ALB: out std_logic;
              ALEB: out std_logic);
end component;

component LPM_ADD_SUB
        generic (LPM_WIDTH: positive;
                 LPM_REPRESENTATION: string := SIGNED;
                 LPM_DIRECTION: string := UNUSED;
                 LPM_HINT : string := UNUSED;
                 LPM_PIPELINE : integer := 0;
                 LPM_TYPE: string := L_ADD_SUB);
        port (DATAA: in std_logic_vector(LPM_WIDTH-1 downto 0);
              DATAB: in std_logic_vector(LPM_WIDTH-1 downto 0);
              ACLR : in std_logic := '0';
              CLOCK : in std_logic := '1';
              CIN: in std_logic := '0';
              ADD_SUB: in std_logic := '1';
              RESULT: out std_logic_vector(LPM_WIDTH-1 downto 0);
              COUT: out std_logic;
              OVERFLOW: out std_logic);
end component;

component LPM_LATCH
        generic (LPM_WIDTH : positive;
                 LPM_PVALUE : string := UNUSED;
                 LPM_TYPE: string := L_LATCH;
                 LPM_AVALUE : string := UNUSED;
                 LPM_HINT : string := UNUSED);
        port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
              GATE : in std_logic;
              ASET : in std_logic := '0';
              ACLR : in std_logic := '0';
              Q : out std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

component LPM_FF
        generic (LPM_WIDTH : positive;
                 LPM_AVALUE : string := UNUSED;
                 LPM_FFTYPE: string := FFTYPE_DFF;
                 LPM_TYPE: string := L_FF;
                 LPM_SVALUE : string := UNUSED);
                 --LPM_HINT : string := UNUSED);
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
end component;

component LPM_SHIFTREG
        generic (LPM_WIDTH : positive;
                 LPM_AVALUE : string := UNUSED;
                 LPM_DIRECTION: string := UNUSED;
                 LPM_TYPE: string := L_SHIFTREG;
                 LPM_SVALUE : string := UNUSED;
                 LPM_HINT : string := UNUSED);
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
end component;

component LPM_DECODE
        generic (LPM_WIDTH : positive;
                 LPM_TYPE: string := L_DECODE;
                 LPM_PIPELINE : integer := 0;
                 LPM_DECODES : natural;
                 LPM_HINT : string := UNUSED);
        port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
              CLOCK : in std_logic := '1';
              ACLR : in std_logic := '0';
              ENABLE : in std_logic := '1';
              EQ : out std_logic_vector(LPM_DECODES-1 downto 0));
end component;

component LPM_CONSTANT
        generic (LPM_WIDTH : positive;
                 LPM_CVALUE: natural;
                 LPM_TYPE: string := L_CONSTANT;
                 LPM_STRENGTH : string := UNUSED;
                 LPM_HINT : string := UNUSED);
        port (RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

component LPM_INV
        generic (LPM_WIDTH : positive;
                 LPM_TYPE: string := L_INV;
                 LPM_HINT : string := UNUSED);
        port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
              RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

component LPM_BUSTRI
        generic (LPM_WIDTH : positive;
                 LPM_TYPE: string := L_BUSTRI;
                 LPM_HINT : string := UNUSED);
        port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
              ENABLEDT : in std_logic := '0';
              ENABLETR : in std_logic := '0';
              RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
              TRIDATA : inout std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

component LPM_INPAD
        generic (LPM_WIDTH : positive;
                 LPM_TYPE: string := L_INPAD;
                 LPM_HINT : string := UNUSED);
        port (PAD : in std_logic_vector(LPM_WIDTH-1 downto 0);
              RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

component LPM_OUTPAD
        generic (LPM_WIDTH : positive;
                 LPM_TYPE: string := L_OUTPAD;
                 LPM_HINT : string := UNUSED);
        port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
              PAD : out std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

component LPM_BIPAD
        generic (LPM_WIDTH : positive;
                 LPM_TYPE: string := L_BIPAD;
                 LPM_HINT : string := UNUSED);
        port (DATA : in std_logic_vector(LPM_WIDTH-1 downto 0);
              ENABLE : in std_logic;
              RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0);
              PAD: inout std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

component LPM_CLSHIFT
        generic (LPM_WIDTH: positive;
                 LPM_WIDTHDIST: positive;
                 LPM_TYPE: string := L_CLSHIFT;
                 LPM_SHIFTTYPE: string := LOGICAL;
                 LPM_HINT : string := UNUSED);
        port (DATA: in STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0);
              DISTANCE: in STD_LOGIC_VECTOR(LPM_WIDTHDIST-1 downto 0);
              DIRECTION: in STD_LOGIC := '0';
              RESULT: out STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0);
              UNDERFLOW: out STD_LOGIC;
              OVERFLOW: out STD_LOGIC);
end component;

component LPM_RAM_DQ
         generic (LPM_WIDTH: positive;
                  LPM_TYPE: string := L_RAM_DQ;
                  LPM_WIDTHAD: positive;
                  LPM_NUMWORDS: string := UNUSED;
                  LPM_FILE: string := UNUSED;
                  LPM_INDATA: string := REGISTERED;
                  LPM_ADDRESS_CONTROL: string := REGISTERED;
                  LPM_OUTDATA: string := REGISTERED;
                  LPM_HINT : string := UNUSED);
         port (DATA: in STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0);
               ADDRESS: in STD_LOGIC_VECTOR(LPM_WIDTHAD-1 downto 0);
               WE: in STD_LOGIC := '1';
               INCLOCK: in STD_LOGIC := '1';
               OUTCLOCK: in STD_LOGIC := '1';
               Q: out STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0));
end component;

component LPM_RAM_IO
         generic (LPM_WIDTH: positive;
                  LPM_TYPE: string := L_RAM_IO;
                  LPM_WIDTHAD: positive;
                  LPM_NUMWORDS: string := UNUSED;
                  LPM_FILE: string := UNUSED;
                  LPM_INDATA: string := REGISTERED;
                  LPM_ADDRESS_CONTROL: string := REGISTERED;
                  LPM_OUTDATA: string := REGISTERED;
                  LPM_HINT : string := UNUSED);
         port (ADDRESS: in STD_LOGIC_VECTOR(LPM_WIDTHAD-1 downto 0);
               WE: in STD_LOGIC;
               INCLOCK: in STD_LOGIC := '1';
               OUTCLOCK: in STD_LOGIC := '1';
               OUTENAB: in STD_LOGIC := '1';
               MEMENAB: in STD_LOGIC := '1';
               DIO: inout STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0));
end component;

component LPM_ROM
         generic (LPM_WIDTH: positive;
                  LPM_TYPE: string := L_ROM;
                  LPM_WIDTHAD: positive;
                  LPM_NUMWORDS: string := UNUSED;
                  LPM_FILE: string ;
                  LPM_ADDRESS_CONTROL: string := REGISTERED;
                  LPM_OUTDATA: string := REGISTERED;
                  LPM_HINT : string := UNUSED);
          port (ADDRESS: in STD_LOGIC_VECTOR(LPM_WIDTHAD-1 downto 0);
                INCLOCK: in STD_LOGIC := '1';
                OUTCLOCK: in STD_LOGIC := '1';
                MEMENAB: in STD_LOGIC := '1';
                Q: out STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0));
end component;

component LPM_TTABLE
        generic (LPM_WIDTHIN: positive;
                 LPM_WIDTHOUT: positive;
                 LPM_TYPE: string := L_TTABLE;
                 LPM_FILE: string ;
                 LPM_TRUTHTYPE : string := FD;
                 LPM_HINT : string := UNUSED);
        port (DATA: in std_logic_vector(LPM_WIDTHIN-1 downto 0);
              RESULT: out std_logic_vector(LPM_WIDTHOUT-1 downto 0));
end component;

component LPM_FSM
        generic (LPM_WIDTHIN: positive;
                 LPM_WIDTHOUT: positive;
                 LPM_WIDTHS: positive := 1;
                 LPM_TYPE: string := L_FSM;
                 LPM_FILE: string ;
                 LPM_AVALUE: string := UNUSED;
                 LPM_TRUTHTYPE : string := FD;
                 LPM_HINT : string := UNUSED);
        port (DATA: in std_logic_vector(LPM_WIDTHIN-1 downto 0);
              CLOCK: in std_logic;
              ASET: in std_logic := '0';
              STATE: out std_logic_vector(LPM_WIDTHS-1 downto 0);
              RESULT: out std_logic_vector(LPM_WIDTHOUT-1 downto 0));
end component;

component LPM_AND
        generic (LPM_WIDTH : positive;
                 LPM_SIZE : positive;
                 LPM_HINT : string := UNUSED);
        port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0, LPM_WIDTH-1 downto 0);
              RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

component LPM_OR
        generic (LPM_WIDTH : positive;
                 LPM_SIZE : positive;
                 LPM_HINT : string := UNUSED);
        port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0, LPM_WIDTH-1 downto 0);
              RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

component LPM_XOR
        generic (LPM_WIDTH : positive;
                 LPM_SIZE : positive;
                 LPM_HINT : string := UNUSED);
        port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0, LPM_WIDTH-1 downto 0);
              RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

component LPM_MUX
        generic (LPM_WIDTH: positive;
                 LPM_WIDTHS : positive;
                 LPM_PIPELINE : integer := 0;
                 LPM_SIZE: positive;
                 LPM_HINT : string := UNUSED);
        port (DATA : in std_logic_2D(LPM_SIZE-1 downto 0, LPM_WIDTH-1 downto 0);
              ACLR : in std_logic := '0';
              CLOCK : in std_logic := '0';
              SEL : in std_logic_vector(LPM_WIDTHS-1 downto 0);
              RESULT : out std_logic_vector(LPM_WIDTH-1 downto 0));
end component;

end;

package body LPM_COMPONENTS is

    function str_to_int( s : string ) return integer is
    variable len : integer := s'length;
    variable ivalue : integer := 0;
    variable digit : integer;
    begin
    for i in len downto 1 loop
       case s(i) is
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
          when others =>
           ASSERT FALSE
           REPORT "Illegal Character "&  s(i) & "in string parameter! "
           SEVERITY ERROR;
   end case;
   ivalue := ivalue * 10 + digit;
   end loop;
   return ivalue;
 end;

end;
