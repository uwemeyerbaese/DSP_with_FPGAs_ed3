PACKAGE B_bit_int IS    ------> User-defined types
  SUBTYPE WORD8 IS INTEGER RANGE -2**7 TO 2**7-1;
  SUBTYPE WORD11 IS INTEGER RANGE -2**10 TO 2**10-1;
  SUBTYPE WORD19 IS INTEGER RANGE -2**18 TO 2**18-1;
  TYPE ARRAY_WORD IS ARRAY (0 to 5) OF WORD19;
END B_bit_int;

LIBRARY work;
USE work.B_bit_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY rader7 IS                      ------> Interface
  PORT ( clk, reset     : IN  STD_LOGIC;
         x_in           : IN  WORD8;
         y_real, y_imag : OUT WORD11);
END rader7;

ARCHITECTURE fpga OF rader7 IS

  SIGNAL  count    : INTEGER RANGE 0 TO 15;
  TYPE    STATE_TYPE IS (Start, Load, Run);
  SIGNAL  state    : STATE_TYPE ;
  SIGNAL  accu     : WORD11 := 0;        -- Signal for X[0]
  SIGNAL  real, imag : ARRAY_WORD := (0,0,0,0,0,0);    
                                 -- Tapped delay line array
  SIGNAL  x57, x111, x160, x200, x231, x250 : WORD19 := 0;  
                      -- The (unsigned) filter coefficients
  SIGNAL  x5, x25, x110, x125, x256  : WORD19 ;  
                           -- Auxiliary filter coefficients
  SIGNAL  x, x_0 : WORD8;  -- Signals for x[0]

BEGIN

  States: PROCESS (reset, clk)-----> FSM for RADER filter
  BEGIN
    IF reset = '1' THEN               -- Asynchronous reset
      state <= Start;
    ELSIF rising_edge(clk) THEN  
      CASE state IS
        WHEN Start =>           -- Initialization step 
          state <= Load;
          count <= 1;
          x_0 <= x_in;        -- Save x[0]
          accu <= 0 ;         -- Reset accumulator for X[0]
          y_real  <= 0;
          y_imag  <= 0;
        WHEN Load => -- Apply x[5],x[4],x[6],x[2],x[3],x[1]
          IF count = 8 THEN     -- Load phase done ?
            state <= Run;
          ELSE
            state <= Load;
            accu  <= accu + x ;
          END IF;
          count <= count + 1;
        WHEN Run => -- Apply again x[5],x[4],x[6],x[2],x[3]
          IF count = 15 THEN    -- Run phase done ?
            y_real <= accu;    -- X[0]
            y_imag <= 0;  -- Only re inputs i.e. Im(X[0])=0
            state  <= Start;     -- Output of result 
          ELSE                  -- and start again
            y_real <= real(0) / 256 + x_0;
            y_imag <= imag(0) / 256;
            state <= Run;
          END IF;
          count <= count + 1;
      END CASE;
    END IF;
  END PROCESS States;
 
  Structure: PROCESS     -- Structure of the two FIR
  BEGIN                  -- filters in transposed form
    WAIT UNTIL clk = '1';  
    x <= x_in;
    -- Real part of FIR filter in transposed form
    real(0) <= real(1) + x160  ;   -- W^1
    real(1) <= real(2) - x231  ;   -- W^3
    real(2) <= real(3) - x57   ;   -- W^2
    real(3) <= real(4) + x160  ;   -- W^6
    real(4) <= real(5) - x231  ;   -- W^4
    real(5) <= -x57  ;             -- W^5
   
    -- Imaginary part of FIR filter in transposed form
    imag(0) <= imag(1) - x200  ;   -- W^1
    imag(1) <= imag(2) - x111  ;   -- W^3
    imag(2) <= imag(3) - x250  ;   -- W^2
    imag(3) <= imag(4) + x200  ;   -- W^6
    imag(4) <= imag(5) + x111  ;   -- W^4
    imag(5) <= x250;               -- W^5
  END PROCESS Structure;

  Coeffs: PROCESS  -- Note that all signals 
  BEGIN               -- are globally defined
    WAIT UNTIL clk = '1';  
  -- Compute the filter coefficients and use FFs
    x160   <= x5 * 32; 
    x200   <= x25 * 8; 
    x250   <= x125 * 2; 
    x57    <= x25 + x * 32; 
    x111   <= x110 + x; 
    x231   <= x256 - x25; 
  END PROCESS Coeffs;

  Factors: PROCESS (x, x5, x25)    -- Note that all signals
  BEGIN                            -- are globally defined
  -- Compute the auxiliary factor for RAG without an FF
    x5     <= x * 4 + x;
    x25    <= x5 * 4 + x5;
    x110   <= x25 * 4 + x5 * 2;
    x125   <= x25 * 4 + x25;
    x256   <= x * 256;
  END PROCESS Factors;

END fpga;
