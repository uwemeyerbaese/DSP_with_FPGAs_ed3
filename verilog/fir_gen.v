//*********************************************************
// IEEE STD 1364-2001 Verilog file: fir_gen.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// This is a generic FIR filter generator 
// It uses W1 bit data/coefficients bits
module fir_gen 
#(parameter W1 = 9,   // Input bit width
            W2 = 18,  // Multiplier bit width 2*W1
            W3 = 19,  // Adder width = W2+log2(L)-1
            W4 = 11,  // Output bit width
            L  = 4,   // Filter length 
            Mpipe = 3) // Pipeline steps of multiplier
 (input clk, Load_x,  // std_logic 
  input signed [W1-1:0] x_in, c_in,  // Inputs
  output signed [W4-1:0] y_out);  // Results

  reg signed [W1-1:0]  x;
  wire signed [W3-1:0]  y;
// 1D array types i.e. memories supported by Quartus
// in Verilog 2001; first bit then vector size
  reg  signed [W1-1:0] c [0:3]; // Coefficient array 
  wire signed [W2-1:0] p [0:3]; // Product array
  reg  signed [W3-1:0] a [0:3]; // Adder array

  wire  signed [W2-1:0] sum;  // Auxilary signals
  wire  clken, aclr;

  assign sum=0; assign aclr=0; // Default for mult
  assign clken=0;
                                                
//----> Load Data or Coefficient
  always @(posedge clk) 
    begin: Load
    if (! Load_x) begin
      c[3] <= c_in; // Store coefficient in register 
      c[2] <= c[3];   // Coefficients shift one 
      c[1] <= c[2];
      c[0] <= c[1];
      end
    else begin
      x <= x_in; // Get one data sample at a time
    end
  end

//----> Compute sum-of-products
  always @(posedge clk) 
    begin: SOP
  // Compute the transposed filter additions
    a[0] <= p[0] + a[1];
    a[1] <= p[1] + a[2];
    a[2] <= p[2] + a[3];
    a[3] <= p[3]; // First TAP has only a register
  end
  assign y = a[0];

  genvar I; //Define loop variable for generate statement
  generate
  for (I=0; I<L; I=I+1) begin: MulGen
// Instantiate L pipelined multiplier
  lpm_mult mul_I            // Multiply  x*c[I] = p[I]  
    (.clock(clk), .dataa(x), .datab(c[I]), .result(p[I])); 
//  .sum(sum), .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_I.lpm_widtha = W1;  
    defparam mul_I.lpm_widthb = W1;
    defparam mul_I.lpm_widthp = W2;  
    defparam mul_I.lpm_widths = W2;
    defparam mul_I.lpm_pipeline = Mpipe;
    defparam mul_I.lpm_representation = "SIGNED";
  end
  endgenerate

  assign y_out = y[W3-1:W3-W4];

endmodule