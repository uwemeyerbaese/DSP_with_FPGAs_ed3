PACKAGE n_bits_int IS          -- User-defined types
  SUBTYPE BITS8 IS INTEGER RANGE -128 TO 127;
  SUBTYPE BITS9 IS INTEGER RANGE -2**8 TO 2**8-1;
  SUBTYPE BITS17 IS INTEGER RANGE -2**16 TO 2**16-1;
  TYPE ARRAY_BITS8_4 IS ARRAY (0 TO 3) of BITS8;
  TYPE ARRAY_BITS9_3 IS ARRAY (0 TO 2) of BITS9;
  TYPE ARRAY_BITS17_5 IS ARRAY (0 TO 4) of BITS17;
END n_bits_int;

LIBRARY work;
USE work.n_bits_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY cmoms IS                          ------> Interface
  GENERIC (IL : INTEGER := 3);-- Input puffer length -1 
  PORT (clk              : IN  STD_LOGIC;
        x_in             : IN  BITS8;
        reset            : IN  STD_LOGIC;
        count_o          : OUT INTEGER RANGE 0 TO 12;
        ena_in_o, ena_out_o : OUT BOOLEAN;
        t_out             : out INTEGER RANGE 0 TO 2;
        d1_out           : out BITS9;
        c0_o, c1_o, c2_o, c3_o : OUT BITS9;
        xiir_o, y_out    : OUT BITS9);
END cmoms;

ARCHITECTURE fpga OF cmoms IS

  SIGNAL count  : INTEGER RANGE 0 TO 12; -- Cycle R_1*R_2
  SIGNAL t      : INTEGER RANGE 0 TO 2;
  SIGNAL ena_in, ena_out : BOOLEAN; -- FSM enables
  SIGNAL x, ibuf : ARRAY_BITS8_4 := (0,0,0,0); -- TAP regs.
  SIGNAL xiir : BITS9 := 0; -- iir filter output
  -- Precomputed value for d**k :
  CONSTANT d1 : ARRAY_BITS9_3 := (0,85,171);
  CONSTANT d2 : ARRAY_BITS9_3 := (0,28,114);
  CONSTANT d3 : ARRAY_BITS9_3 := (0,9,76);
  -- Spline matrix output: 
  SIGNAL c0, c1, c2, c3     : BITS9 := 0;

BEGIN
  t_out <= t;
  d1_out <= d1(t);
  FSM: PROCESS (reset, clk)    ------> Control the system 
  BEGIN                              -- sample at clk rate
    IF reset = '1' THEN              -- Asynchronous reset
      count <= 0;
      t <= 1;
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
        WHEN 3 | 7 | 11 =>   
          ena_out <= TRUE; 
         WHEN others => 
          ena_out <= FALSE;
      END CASE;
 -- Compute phase delay 
      IF ENA_OUT THEN 
        IF t >= 2 THEN
          t <= 0;
        ELSE
         t <= t + 1;
        END IF;
      END IF;
    END IF;
  END PROCESS FSM;

--  Coeffs: H(z)=1.5/(1+0.5z^-1)
  IIR: PROCESS (clk)             ------> Behavioral Style 
    VARIABLE x1 : BITS9 := 0;
  BEGIN   -- Compute iir coefficients first 
    IF rising_edge(clk) THEN  -- iir: 
      IF ENA_IN THEN
        xiir <= 3 * x1 / 2 - xiir / 2;
        x1 := x_in;
      END IF;
    END IF;
  END PROCESS;

  TAP: PROCESS             ------> One tapped delay line 
  BEGIN
    WAIT UNTIL clk = '1';
    IF ENA_IN THEN
      FOR I IN 1 TO IL LOOP 
        ibuf(I-1) <= ibuf(I);      -- Shift one
      END LOOP;
      ibuf(IL) <= xiir;         -- Input in register IL
    END IF;
  END PROCESS;

  GET: PROCESS    ------> Get 4 samples at one time 
  BEGIN                    
    WAIT UNTIL clk = '1';
    IF ENA_OUT THEN
      FOR I IN 0 TO IL LOOP -- take over input buffer
        x(I) <= ibuf(I);    
      END LOOP;
    END IF;
  END PROCESS;

  -- Compute sum-of-products:
  SOP: PROCESS (clk, x, c0, c1, c2, c3, ENA_OUT) 
  VARIABLE y, y0, y1, y2, y3, h0, h1 : BITS17; 
  BEGIN                              -- pipeline registers
-- Matrix multiplier C-MOMS matrix: 
--    x(0)      x(1)      x(2)      x(3)
--    0.3333    0.6667    0          0
--   -0.8333    0.6667    0.1667     0
--    0.6667   -1.5       1.0       -0.1667
--   -0.1667    0.5      -0.5        0.1667
  IF ENA_OUT THEN  
    IF clk'event and clk = '1' THEN
      c0 <= (85 * x(0) + 171 * x(1))/256;
      c1 <= (171 * x(1) - 213 * x(0) + 43 * x(2)) / 256;
      c2 <= (171 * x(0) - 43 * x(3))/256 - 3*x(1)/2 + x(2);
      c3 <= 43 * (x(3) - x(0)) / 256 +  (x(1) - x(2))/2;
-- No Farrow structure, parallel LUT for delays
-- for u=0:3, y=y+f(u)*d^u; end;
      y :=  h0 + h1;
      h0 := y0 + y1;
      h1 := y2 + y3;
      y0 := c0 * 256;
      y1 := c1 * d1(t);
      y2 := c2 * d2(t);
      y3 := c3 * d3(t);
    END IF;
  END IF;
  y_out <= y/256; -- Connect to output

END PROCESS SOP;
  c0_o <= c0; -- Provide some test signal as outputs
  c1_o <= c1;
  c2_o <= c2;
  c3_o <= c3;
  count_o <= count;
  ena_in_o <= ena_in;
  ena_out_o <= ena_out;
  xiir_o <= xiir;

END fpga;
