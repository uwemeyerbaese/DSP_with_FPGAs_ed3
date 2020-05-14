//*********************************************************
// IEEE STD 1364-2001 Verilog file: div_res.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// Restoring Division
// Bit width:  WN         WD           WN            WD
//         Numerator / Denominator = Quotient and Remainder
// OR:       Numerator = Quotient * Denominator + Remainder

module div_res(
  input         clk, reset,
  input  [7:0] n_in,
  input  [5:0] d_in,
  output reg [5:0] r_out,
  output reg [7:0] q_out);

  parameter s0=0, s1=1, s2=2, s3=3; // State assignments

  // Divider in behavioral style
  always @(posedge clk or posedge reset) 
  begin : F // Finite state machine 
    reg [3:0] count;
    reg [1:0] s;          // FSM state 
    reg  [13:0] d;        // Double bit width unsigned
    reg  signed [13:0] r; // Double bit width signed
    reg  [7:0] q;

    if (reset)              // Asynchronous reset
      s <= s0;
    else
      case (s) 
        s0 : begin         // Initialization step 
          s <= s1;
          count = 0;
          q <= 0;           // Reset quotient register
          d <= d_in << 7;   // Load aligned denominator
          r <= n_in;        // Remainder = numerator
        end                                           
        s1 : begin         // Processing step 
          r <= r - d;      // Subtract denominator
          s <= s2;
        end
        s2 : begin          // Restoring step
          if (r < 0) begin  // Check r < 0 
            r <= r + d;     // Restore previous remainder
            q <= q << 1;     // LSB = 0 and SLL
            end
          else
            q <= (q << 1) + 1; // LSB = 1 and SLL
          count = count + 1;
          d <= d >> 1;

          if (count == 8)   // Division ready ?
            s <= s3;
          else             
            s <= s1;
        end
        s3 : begin       // Output of result
          q_out <= q[7:0]; 
          r_out <= r[5:0]; 
          s <= s0;   // Start next division
        end
      endcase  
  end

endmodule