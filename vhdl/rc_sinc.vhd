PACKAGE n_bits_int IS          -- User-defined types
  SUBTYPE BITS8 IS INTEGER RANGE -128 TO 127;
  SUBTYPE BITS9 IS INTEGER RANGE -2**8 TO 2**8-1;
  SUBTYPE BITS17 IS INTEGER RANGE -2**16 TO 2**16-1;
  TYPE ARRAY_BITS8_11 IS ARRAY (0 TO 10) of BITS8;
  TYPE ARRAY_BITS9_11 IS ARRAY (0 TO 10) of BITS9;
  TYPE ARRAY_BITS8_3 IS ARRAY (0 TO 2) of BITS8;
  TYPE ARRAY_BITS8_4 IS ARRAY (0 TO 3) of BITS8;
  TYPE ARRAY_BITS17_11 IS ARRAY (0 TO 10) of BITS17;
END n_bits_int;

LIBRARY work;
USE work.n_bits_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY rc_sinc IS                         ------> Interface
  GENERIC (OL : INTEGER := 2; -- Output buffer length -1
           IL : INTEGER := 3; -- Input buffer length -1 
           L  : INTEGER := 10 -- Filter length -1
           );
  PORT (clk                    : IN  STD_LOGIC;
        x_in                   : IN  BITS8;
        reset                  : IN  STD_LOGIC;
        count_o                : OUT INTEGER RANGE 0 TO 12;
        ena_in_o, ena_out_o,ena_io_o : OUT BOOLEAN;
        f0_o, f1_o, f2_o       : OUT BITS9;
        y_out                  : OUT BITS9);
END rc_sinc;

ARCHITECTURE fpga OF rc_sinc IS

  SIGNAL count  : INTEGER RANGE 0 TO 12; -- Cycle R_1*R_2
  SIGNAL ena_in, ena_out, ena_io : BOOLEAN; -- FSM enables
  -- Constant arrays for multiplier and taps:
  CONSTANT c0  : ARRAY_BITS9_11 
              := (-19,26,-42,106,212,-53,29,-21,16,-13,11); 
  CONSTANT c2  : ARRAY_BITS9_11 
              := (11,-13,16,-21,29,-53,212,106,-42,26,-19);
  SIGNAL x : ARRAY_BITS8_11 := (0,0,0,0,0,0,0,0,0,0,0); 
                             -- TAP registers for 3 filters
  SIGNAL ibuf : ARRAY_BITS8_4 := (0,0,0,0); -- in registers
  SIGNAL obuf : ARRAY_BITS8_3 := (0,0,0);  -- out registers
  SIGNAL f0, f1, f2     : BITS9 := 0; -- Filter outputs

BEGIN

  FSM: PROCESS (reset, clk)     ------> Control the system 
  BEGIN                              -- sample at clk rate
    IF reset = '1' THEN              -- Asynchronous reset
      count <= 0;
    ELSIF rising_edge(clk) THEN  
      IF count = 11 THEN  
        count <= 0;
      ELSE
        count <= count + 1;
      END IF;
      CASE count IS
        WHEN 2 | 5 | 8 | 11 =>   
          ena_in <= TRUE; 
         WHEN others => 
          ena_in <= FALSE;
      END CASE;
      CASE count IS
        WHEN 4 | 8 =>   
          ena_out <= TRUE; 
         WHEN others => 
          ena_out <= FALSE;
      END CASE;
      IF COUNT = 0 THEN
        ena_io <= TRUE;
      ELSE
        ena_io <= FALSE;
      END IF;
    END IF;
  END PROCESS FSM;

  INPUTMUX: PROCESS           ------> One tapped delay line
  BEGIN
    WAIT UNTIL clk = '1';
    IF ENA_IN THEN
      FOR I IN IL DOWNTO 1 LOOP 
        ibuf(I) <= ibuf(I-1);       -- shift one
      END LOOP;
      ibuf(0) <= x_in;               -- Input in register 0
    END IF;
  END PROCESS;

  OUPUTMUX: PROCESS           ------> One tapped delay line
  BEGIN
    WAIT UNTIL clk = '1';
    IF ENA_IO THEN  -- store 3 samples in output buffer
      obuf(0) <= f0 ;
      obuf(1) <= f1; 
      obuf(2) <= f2 ;
    ELSIF ENA_OUT THEN
      FOR I IN OL DOWNTO 1 LOOP 
        obuf(I) <= obuf(I-1);       -- shift one
      END LOOP;
    END IF;
  END PROCESS;

  TAP: PROCESS                ------> One tapped delay line
  BEGIN                        -- get 4 samples at one time
    WAIT UNTIL clk = '1';  
    IF ENA_IO THEN
      FOR I IN 0 TO 3 LOOP -- take over input buffer
        x(I) <= ibuf(I);    
      END LOOP;
      FOR I IN 4 TO 10 LOOP -- 0->4; 4->8 etc.
        x(I) <= x(I-4);       -- shift 4 taps
      END LOOP;
    END IF;
  END PROCESS;

  SOP0: PROCESS (clk, x) --> Compute sum-of-products for f0
  VARIABLE sum : BITS17;
  VARIABLE p : ARRAY_BITS17_11;
  BEGIN
    FOR I IN 0 TO L LOOP -- Infer L+1  multiplier
      p(I) := c0(I) * x(I);
    END LOOP;
    sum := p(0);
    FOR I IN 1 TO L  LOOP      -- Compute the direct
      sum := sum + p(I);         -- filter adds
    END LOOP;
    IF clk'event and clk = '1' THEN
      f0 <= sum /256;
    END IF;
  END PROCESS SOP0;

  SOP1: PROCESS (clk, x) --> Compute sum-of-products for f1
  BEGIN
    IF clk'event and clk = '1' THEN
      f1 <= x(5);  -- No scaling, i.e. unit inpulse
    END IF;
  END PROCESS SOP1;

  SOP2: PROCESS (clk, x) --> Compute sum-of-products for f2
  VARIABLE sum : BITS17;
  VARIABLE p : ARRAY_BITS17_11;
  BEGIN
    FOR I IN 0 TO L LOOP -- Infer L+1  multiplier
      p(I) := c2(I) * x(I);
    END LOOP;
    sum := p(0);
    FOR I IN 1 TO L  LOOP      -- Compute the direct
      sum := sum + p(I);         -- filter adds
    END LOOP;
    IF clk'event and clk = '1' THEN
      f2 <= sum /256;
    END IF;
  END PROCESS SOP2;
  
  f0_o <= f0;        -- Provide some test signal as outputs
  f1_o <= f1;
  f2_o <= f2;
  count_o <= count;
  ena_in_o <= ena_in;
  ena_out_o <= ena_out;
  ena_io_o <= ena_io;

  y_out <= obuf(OL); -- Connect to output

END fpga;
