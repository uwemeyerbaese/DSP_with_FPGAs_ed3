PACKAGE n_bits_int IS          -- User-defined types
  SUBTYPE BITS8 IS INTEGER RANGE -128 TO 127;
  SUBTYPE BITS9 IS INTEGER RANGE -2**8 TO 2**8-1;
  SUBTYPE BITS17 IS INTEGER RANGE -2**16 TO 2**16-1;
  TYPE ARRAY_BITS8_4 IS ARRAY (0 TO 3) of BITS8;
END n_bits_int;

LIBRARY work;
USE work.n_bits_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY farrow IS                          ------> Interface
  GENERIC (IL : INTEGER := 3); -- Input puffer length -1 
  PORT (clk                    : IN  STD_LOGIC;
        x_in                   : IN  BITS8;
        reset                  : IN  STD_LOGIC;
        count_o                : OUT INTEGER RANGE 0 TO 12;
        ena_in_o, ena_out_o    : OUT BOOLEAN;
        c0_o, c1_o, c2_o, c3_o : OUT BITS9;
        d_out, y_out           : OUT BITS9);
END farrow;

ARCHITECTURE fpga OF farrow IS

  SIGNAL count  : INTEGER RANGE 0 TO 12; -- Cycle R_1*R_2
  CONSTANT delta : INTEGER := 85; -- Increment d
  SIGNAL ena_in, ena_out : BOOLEAN; -- FSM enables
  SIGNAL x, ibuf : ARRAY_BITS8_4 := (0,0,0,0); -- TAP reg.
  SIGNAL  d : BITS9 := 0; -- Fractional Delay scaled to 8 bits
  -- Lagrange matrix outputs: 
  SIGNAL c0, c1, c2, c3     : BITS9 := 0;

BEGIN

  FSM: PROCESS (reset, clk)   ------> Control the system 
  VARIABLE dnew : BITS9 := 0;
  BEGIN                      -- sample at clk rate
    IF reset = '1' THEN              -- Asynchronous reset
      count <= 0;        
      d <= delta;
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
        dnew := d + delta;
        IF dnew >= 255 THEN
         d <= 0;
        ELSE
         d <= dnew;
        END IF;
      END IF;
    END IF;
  END PROCESS FSM;

  TAP: PROCESS             ------> One tapped delay line 
  BEGIN
    WAIT UNTIL clk = '1';
    IF ENA_IN THEN
      FOR I IN 1 TO IL LOOP 
        ibuf(I-1) <= ibuf(I);      -- Shift one
      END LOOP;
      ibuf(IL) <= x_in;         -- Input in register IL
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

  --> Compute sum-of-products:
  SOP: PROCESS (clk, x, d, c0, c1, c2, c3, ENA_OUT) 
  VARIABLE y : BITS9;
  BEGIN
-- Matrix multiplier iV=inv(Vandermonde) c=iV*x(n-1:n+2)'
--      x(0)   x(1)         x(2)     x(3)
-- iV=    0    1.0000         0         0
--   -0.3333   -0.5000    1.0000   -0.1667
--    0.5000   -1.0000    0.5000         0
--   -0.1667    0.5000   -0.5000    0.1667
  IF ENA_OUT THEN  
    IF clk'event AND clk = '1' THEN
      c0 <= x(1);
      c1 <= -85 * x(0)/256 - x(1)/2 + x(2) - 43 * x(3)/256;
      c2 <= (x(0) + x(2)) /2 - x(1) ;
      c3 <= (x(1) - x(2))/2 + 43 * (x(3) - x(0))/256;
    END IF;

-- Farrow structure = Lagrange with Horner schema
-- for u=0:3, y=y+f(u)*d^u; end;
  y := c2 + (c3 * d) / 256; -- d is scale by 256
  y := (y * d) / 256 + c1;
  y := (y * d) / 256 + c0;

    IF clk'event AND clk = '1' THEN
      y_out <= y; -- Connect to output + store in register
    END IF;
  END IF;
END PROCESS SOP;
  
  c0_o <= c0;     -- Provide some test signals as outputs
  c1_o <= c1;
  c2_o <= c2;
  c3_o <= c3;
  count_o <= count;
  ena_in_o <= ena_in;
  ena_out_o <= ena_out;
  d_out <= d;

END fpga;
