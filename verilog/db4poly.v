//*********************************************************
// IEEE STD 1364-2001 Verilog file: db4poly.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module db4poly     //----> Interface
 (input          clk, reset,
  output         clk2,
  input signed [7:0]   x_in,
  output signed [16:0]  x_e, x_o, g0, g1, // Test signals
  output signed [8:0]   y_out);

  reg signed [7:0] x_odd, x_even, x_wait;
  reg  clk_div2;

// Register for multiplier, coefficients, and taps
  reg signed [16:0] m0, m1, m2, m3, r0, r1, r2, r3; 
  reg signed [16:0] x33, x99, x107;
  reg signed [16:0] y;

  always @(posedge clk or posedge reset) // Split into even
  begin : Multiplex          // and odd samples at clk rate
    parameter even=0, odd=1;
    reg [0:0] state;

    if (reset)              // Asynchronous reset
      state <= even;
    else
      case (state) 
        even : begin
          x_even <= x_in; 
          x_odd  <= x_wait;
          clk_div2 = 1;
          state <= odd;
        end
        odd : begin
          x_wait <= x_in;
          clk_div2 = 0;
          state <= even;
        end
      endcase  
  end

  always @(x_odd, x_even) 
  begin : RAG
// Compute auxiliary multiplications of the filter
    x33  = (x_odd <<< 5) + x_odd;            
    x99  = (x33 <<< 1) + x33;                  
    x107 = x99 + (x_odd << 3);
// Compute all coefficients for the transposed filter
    m0 = (x_even <<< 7) - (x_even <<< 2); // m0 = 124
    m1 = x107 <<< 1;                      // m1 = 214
    m2 = (x_even <<< 6) - (x_even <<< 3) 
                                  + x_even; // m2 =  57
    m3 = x33;                               // m3 = -33
  end

  always @(negedge clk_div2) // Infer registers; 
  begin : AddPolyphase       // use nonblocking assignments
//---------- Compute filter G0             
    r0 <=  r2 + m0;        // g0 = 128
    r2 <=  m2;             // g2 = 57
//---------- Compute filter G1
    r1 <=  -r3 + m1;       // g1 = 214
    r3 <=  m3;             // g3 = -33
// Add the polyphase components 
    y <= r0 + r1; 
  end

// Provide some test signals as outputs 
  assign x_e = x_even; 
  assign x_o = x_odd;
  assign clk2 = clk_div2;
  assign g0 = r0;
  assign g1 = r1;

  assign y_out = y >>> 8; // Connect y / 256 to output

endmodule