//*********************************************************
// IEEE STD 1364-2001 Verilog file: div_aegp.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// Convergence division after 
//                 Anderson, Earle, Goldschmidt, and Powers
// Bit width:  WN         WD           WN            WD
//         Numerator / Denominator = Quotient and Remainder
// OR:       Numerator = Quotient * Denominator + Remainder

module div_aegp
 (input         clk, reset,
  input  [8:0] n_in,
  input  [8:0] d_in,
  output reg [8:0] q_out);

  always @(posedge clk or posedge reset) //-> Divider in 
  begin : States                        // behavioral style
    parameter s0=0, s1=1, s2=2;
    reg [1:0] count;
    reg [1:0] state;
    reg [9:0] x, t, f;        // one guard bit 
    reg [17:0] tempx, tempt;

    if (reset)              // Asynchronous reset
      state <= s0;
    else
      case (state) 
        s0 : begin              // Initialization step
          state <= s1;
          count = 0;
          t <= {1'b0, d_in};    // Load denominator
          x <= {1'b0, n_in};    // Load numerator
        end                                           
        s1 : begin            // Processing step 
          f = 512 - t;        // TWO - t
          tempx = (x * f);  // Product in full
          tempt = (t * f);  // bitwidth
          x <= tempx >> 8;  // Factional f
          t <= tempt >> 8;  // Scale by 256
          count = count + 1;
          if (count == 2)     // Division ready ?
            state <= s2;
          else             
            state <= s1;
        end
        s2 : begin       // Output of result
          q_out <= x[8:0]; 
          state <= s0;   // Start next division
        end
      endcase  
  end

endmodule