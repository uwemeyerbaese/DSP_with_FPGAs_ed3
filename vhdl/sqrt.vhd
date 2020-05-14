PACKAGE n_bits_int IS          -- User-defined types
  SUBTYPE BITS9 IS INTEGER RANGE -2**8 TO 2**8-1;
  SUBTYPE BITS17 IS INTEGER RANGE -2**16 TO 2**16-1;
  TYPE ARRAY_BITS17_5 IS ARRAY (0 TO 4) of BITS17;
  TYPE STATE_TYPE IS (start,leftshift,sop,rightshift,done);
  TYPE OP_TYPE IS (load, mac, scale, denorm, nop);
END n_bits_int;

LIBRARY work;
USE work.n_bits_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY sqrt IS                          ------> Interface
  PORT (clk, reset : IN  STD_LOGIC;
        x_in       : IN  BITS17;
        a_o, imm_o, f_o    : OUT BITS17;
        ind_o  : OUT INTEGER RANGE 0 TO 4;
        count_o : OUT INTEGER RANGE 0 TO 3;
        x_o,pre_o,post_o : OUT BITS17;
        f_out    : OUT BITS17);
END sqrt;

ARCHITECTURE fpga OF sqrt IS

  SIGNAL s    : STATE_TYPE;
  SIGNAL op   : OP_TYPE;

  SIGNAL x : BITS17:= 0; -- Auxilary 
  SIGNAL a,b,f,imm : BITS17:= 0; -- ALU data
  -- Chebychev poly coefficients for 16-bit precision: 
  CONSTANT p : ARRAY_BITS17_5 := 
         (7563,42299,-29129,15813,-3778);
  SIGNAL pre, post : BITS17;

BEGIN

  States: PROCESS(clk)    ------> SQRT in behavioral style
   VARIABLE ind  : INTEGER RANGE -1 TO 4:=0;
   VARIABLE count  : INTEGER RANGE 0 TO 3;
  BEGIN
    IF reset = '1' THEN           -- Asynchronous reset
      s <= start;
    ELSIF rising_edge(clk) THEN 
      CASE s IS                 -- Next State assignments
      WHEN start =>              -- Initialization step 
        s <= leftshift;
        ind := 4;
        imm <= x_in;    -- Load argument in ALU
        op <= load;
        count := 0;
      WHEN leftshift =>          -- Normalize to 0.5 .. 1.0
         count := count + 1;
         a <= pre;
         op <= scale;
         imm <= p(4);
        IF count = 3 THEN -- Normalize ready ?
          s <= sop;
          op<=load;
          x <= f; 
        END IF;
      WHEN sop =>          -- Processing step
        ind := ind - 1;
        a <= x;
        IF ind =-1  THEN -- SOP ready ?
          s <= rightshift;
          op<=denorm;
          a <= post;
        ELSE
          imm <= p(ind);          
          op<=mac;
        END IF;
      WHEN rightshift =>   -- Denormalize to original range
         s <= done;
         op<=nop;
      WHEN done =>                 -- Output of results
        f_out <= f;     ------> I/O store in register
        op<=nop;
        s <= start;                 -- start next cycle
      END CASE;
    END IF;
    ind_o <= ind;
    count_o <= count;
  END PROCESS States;

  ALU: PROCESS
  BEGIN
    WAIT UNTIL clk = '1';  
    CASE OP IS
      WHEN load   =>   f  <= imm;
      WHEN mac    =>   f  <= a * f /32768 + imm;
      WHEN scale  =>   f  <= a * f;
      WHEN denorm =>   f  <= a * f /32768;
      WHEN nop    =>   f  <= f;
      WHEN others =>   f  <= f;
    END CASE;
  END PROCESS ALU;

  EXP: PROCESS(x_in)
  VARIABLE slv : STD_LOGIC_VECTOR(16 DOWNTO 0);
  VARIABLE po, pr : BITS17;
  BEGIN
    slv := CONV_STD_LOGIC_VECTOR(x_in, 17);
    pr := 2**14;     -- Compute pre- and post scaling
    FOR K IN 0 TO 15 LOOP
      IF slv(K) = '1' THEN
        pre <= pr;
      END IF;
      pr := pr / 2;
    END LOOP;
    po := 1;     -- Compute pre- and post scaling
    FOR K IN 0 TO 7 LOOP
      IF slv(2*K) = '1' THEN -- even 2^k get 2^k/2
        po := 256*2**K;
      END IF;
--  sqrt(2): CSD Error = 0.0000208 = 15.55 effective bits
-- +1 +0. -1 +0 -1 +0 +1 +0 +1 +0 +0 +0 +0 +0 +1
--  9      7     5     3     1               -5
      IF slv(2*K+1) = '1' THEN -- odd k has sqrt(2) factor
        po := 2**(K+9)-2**(K+7)-2**(K+5)+2**(K+3)
                               +2**(K+1)+2**K/32;
      END IF;
      post <= po;
    END LOOP;

  END PROCESS EXP;

  a_o<=a;   -- Provide some test signals as outputs
  imm_o<=imm;
  f_o <= f;
  pre_o<=pre;
  post_o<=post;
  x_o<=x;

END fpga;
