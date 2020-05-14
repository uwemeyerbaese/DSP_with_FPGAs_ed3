LIBRARY lpm;
USE lpm.lpm_components.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

PACKAGE mul_package IS    -- User-defined components
  COMPONENT ccmul
    GENERIC (W2  : INTEGER := 17;   -- Multiplier bit width
             W1  : INTEGER := 9;    -- Bit width c+s sum
             W   : INTEGER := 8);   -- Input bit width 
    PORT
    (clk   : IN STD_LOGIC; -- Clock for the output register
     x_in, y_in, c_in: IN  STD_LOGIC_VECTOR(W-1 DOWNTO 0);  
                                                  -- Inputs
     cps_in, cms_in  : IN  STD_LOGIC_VECTOR(W1-1 DOWNTO 0); 
                                                  -- Inputs
     r_out, i_out    : OUT STD_LOGIC_VECTOR(W-1 DOWNTO 0));   
                                                 -- Results
  END COMPONENT;
END mul_package;

LIBRARY work;
USE work.mul_package.ALL;


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

LIBRARY lpm;
USE lpm.lpm_components.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY bfproc IS
  GENERIC (W2  : INTEGER := 17;    -- Multiplier bit width
           W1  : INTEGER := 9;     -- Bit width c+s sum
           W   : INTEGER := 8);    -- Input bit width 
  PORT
  (clk               : STD_LOGIC;
   Are_in, Aim_in, c_in,                    -- 8 bit inputs
   Bre_in, Bim_in    : IN  STD_LOGIC_VECTOR(W-1 DOWNTO 0);   
   cps_in, cms_in    : IN  STD_LOGIC_VECTOR(W1-1 DOWNTO 0);
                                      -- 9 bit coefficients
   Dre_out, Dim_out,                       -- 8 bit results
   Ere_out, Eim_out  : OUT STD_LOGIC_VECTOR(W-1 DOWNTO 0)
                                       := (OTHERS => '0'));
END bfproc;

ARCHITECTURE fpga OF bfproc IS

  SIGNAL dif_re, dif_im                          -- Bf out
                          : STD_LOGIC_VECTOR(W-1 DOWNTO 0); 
  SIGNAL Are, Aim, Bre, Bim : INTEGER RANGE -128 TO 127:=0;  
                                      -- Inputs as integers
  SIGNAL c           : STD_LOGIC_VECTOR(W-1 DOWNTO 0)
                               := (OTHERS => '0'); -- Input
  SIGNAL cps, cms    : STD_LOGIC_VECTOR(W1-1 DOWNTO 0)
                            := (OTHERS => '0'); -- Coeff in
BEGIN

  PROCESS   -- Compute the additions of the butterfly using
  BEGIN      -- integers and store inputs in flip-flops
    WAIT UNTIL clk = '1';
    Are     <= CONV_INTEGER(Are_in);
    Aim     <= CONV_INTEGER(Aim_in);
    Bre     <= CONV_INTEGER(Bre_in);
    Bim     <= CONV_INTEGER(Bim_in);
    c       <= c_in;                -- Load from memory cos
    cps     <= cps_in;          -- Load from memory cos+sin
    cms     <= cms_in;          -- Load from memory cos-sin
    Dre_out <= CONV_STD_LOGIC_VECTOR( (Are + Bre )/2, W);
    Dim_out <= CONV_STD_LOGIC_VECTOR( (Aim + Bim )/2, W);
  END PROCESS;
  
  -- No FF because butterfly difference "diff" is not an
  PROCESS (Are, Bre, Aim, Bim)            -- output port
  BEGIN                           
    dif_re <= CONV_STD_LOGIC_VECTOR(Are/2 - Bre/2, 8);
    dif_im <= CONV_STD_LOGIC_VECTOR(Aim/2 - Bim/2, 8);
  END PROCESS;  
  
---- Instantiate the complex twiddle factor multiplier ----
  ccmul_1: ccmul                   -- Multiply (x+jy)(c+js)
    GENERIC MAP ( W2 => W2, W1 => W1, W => W)
    PORT MAP  ( clk => clk, x_in => dif_re, y_in => dif_im,
                c_in => c, cps_in => cps, cms_in => cms, 
                r_out => Ere_out, i_out => Eim_out);
                      
END fpga;
