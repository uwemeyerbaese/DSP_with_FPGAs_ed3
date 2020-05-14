//*********************************************************
// IEEE STD 1364-2001 Verilog file: fir6dlms.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// This is a generic DLMS FIR filter generator 
// It uses W1 bit data/coefficients bits

module fir6dlms        //----> Interface
 #(parameter W1 = 8,   // Input bit width
            W2 = 16,   // Multiplier bit width 2*W1
            L  = 2,    // Filter length 
            Delay = 3) // Pipeline steps of multiplier
 (input clk,  // 1 bit input 
  input signed [W1-1:0] x_in, d_in,  // Inputs
  output signed [W2-1:0] e_out, y_out,  // Results
  output signed [W1-1:0] f0_out, f1_out);  // Results

// 2D array types memories are supported by Quartus II
// in Verilog, use therefore single vectors
  reg signed [W1-1:0] x [0:4], f0, f1;  
  reg signed [W1-1:0] f[0:1];  
  reg  signed [W1-1:0] d[0:3]; // Desired signal array
  wire signed [W1-1:0] emu;
  wire signed [W2-1:0] xemu[0:1]; // Product array
  wire signed [W2-1:0] p[0:1]; // Product array
  wire  signed [W2-1:0]  y, sxty, e, sxtd; 

  wire  clken, aclr;
  wire  signed [W2-1:0] sum;  // Auxilary signals


  assign sum=0; assign aclr=0; // Default for mult
  assign clken=0;

  always @(posedge clk) // Store these data or coefficients
    begin: Store
      d[0] <= d_in; // Shift register for desired data 
      d[1] <= d[0];
      d[2] <= d[1];
      d[3] <= d[2];
      x[0] <= x_in; // Shift register for data 
      x[1] <= x[0];   
      x[2] <= x[1];
      x[3] <= x[2];
      x[4] <= x[3];
      f[0] <= f[0] + xemu[0][15:8]; // implicit divide by 2
      f[1] <= f[1] + xemu[1][15:8]; 
  end

// Instantiate L pipelined multiplier
  genvar I;
  generate
    for (I=0; I<L; I=I+1) begin: Mul_fx
  lpm_mult mul_xf             // Multiply  x[I]*f[I] = p[I]
  (.clock(clk), .dataa(x[I]), .datab(f[I]), .result(p[I]));
//  .sum(sum), .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_xf.lpm_widtha = W1;  
    defparam mul_xf.lpm_widthb = W1;
    defparam mul_xf.lpm_widthp = W2;  
    defparam mul_xf.lpm_widths = W2;
    defparam mul_xf.lpm_pipeline = Delay;
    defparam mul_xf.lpm_representation = "SIGNED";
    end // for loop
  endgenerate

  assign y = p[0] + p[1];  // Compute ADF output

  // Scale y by 128 because x is fraction
  assign e = d[3] - (y >>> 7);
  assign emu = e >>> 1;  // e*mu divide by 2 and 
                        // 2 from xemu makes mu=1/4

// Instantiate L pipelined multiplier
  generate
    for (I=0; I<L; I=I+1) begin: Mul_xemu
  lpm_mult mul_I          // Multiply xemu[I] = emu * x[I];
    (.clock(clk), .dataa(x[I+Delay]), .datab(emu), 
                                         .result(xemu[I]));
//  .sum(sum), .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_I.lpm_widtha = W1;  
    defparam mul_I.lpm_widthb = W1;
    defparam mul_I.lpm_widthp = W2;  
    defparam mul_I.lpm_widths = W2;
    defparam mul_I.lpm_pipeline = Delay;
    defparam mul_I.lpm_representation = "SIGNED";
    end // for loop
  endgenerate

  assign  y_out  = y;    // Monitor some test signals
  assign  e_out  = e;
  assign  f0_out = f[0];
  assign  f1_out = f[1];

endmodule