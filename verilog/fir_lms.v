//*********************************************************
// IEEE STD 1364-2001 Verilog file: fir_lms.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// This is a generic LMS FIR filter generator 
// It uses W1 bit data/coefficients bits

module fir_lms         //----> Interface
 #(parameter W1 = 8,   // Input bit width
             W2 = 16,  // Multiplier bit width 2*W1
             L  = 2,   // Filter length 
            Delay = 3) // Pipeline steps of multiplier
 (input clk,  // 1 bit input 
  input signed [W1-1:0] x_in, d_in,  // Inputs
  output signed [W2-1:0] e_out, y_out,  // Results
  output signed [W1-1:0] f0_out, f1_out);  // Results

// Signed data types are supported in 2001
// Verilog, and used whenever possible
  reg  signed [W1-1:0] x [0:1]; // Data array 
  reg  signed [W1-1:0] f [0:1]; // Coefficient array 
  reg  signed [W1-1:0] d;
  wire signed [W1-1:0] emu;
  wire signed [W2-1:0] p [0:1]; // 1. Product array 
  wire signed [W2-1:0] xemu [0:1]; // 2. Product array 
  wire signed [W2-1:0]  y, sxty, e, sxtd; 

  wire  clken, aclr;
  wire  signed [W2-1:0] sum;  // Auxilary signals


  assign sum=0; assign aclr=0; // Default for mult
  assign clken=0;
  
  always @(posedge clk) // Store these data or coefficients
    begin: Store
      d <= d_in; // Store desired signal in register 
      x[0] <= x_in; // Get one data sample at a time 
      x[1] <= x[0];   // shift 1
      f[0] <= f[0] + xemu[0][15:8]; // implicit divide by 2
      f[1] <= f[1] + xemu[1][15:8]; 
  end

// Instantiate L pipelined multiplier
  genvar I;
  generate
    for (I=0; I<L; I=I+1) begin: Mul_fx
  lpm_mult mul_xf             // Multiply  x[I]*f[I] = p[I]
    ( .dataa(x[I]), .datab(f[I]), .result(p[I])); 
//   .clock(clk), .sum(sum),
//   .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_xf.lpm_widtha = W1;  
    defparam mul_xf.lpm_widthb = W1;
    defparam mul_xf.lpm_widthp = W2;  
    defparam mul_xf.lpm_widths = W2;
//    defparam mul_xf.lpm_pipeline = Delay;
    defparam mul_xf.lpm_representation = "SIGNED";
    end // for loop
  endgenerate



  assign y = p[0] + p[1];  // Compute ADF output

  // Scale y by 128 because x is fraction
  assign e = d - (y >>> 7) ;
  assign emu = e >>> 1;  // e*mu divide by 2 and 
                        // 2 from xemu makes mu=1/4

// Instantiate L pipelined multiplier
  generate
    for (I=0; I<L; I=I+1) begin: Mul_xemu
  lpm_mult mul_I          // Multiply xemu[I] = emu * x[I];
    ( .dataa(x[I]), .datab(emu), .result(xemu[I])); 
//   .clock(clk), .sum(sum),
//   .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_I.lpm_widtha = W1;  
    defparam mul_I.lpm_widthb = W1;
    defparam mul_I.lpm_widthp = W2;  
    defparam mul_I.lpm_widths = W2;
//    defparam mul_I.lpm_pipeline = Delay;
    defparam mul_I.lpm_representation = "SIGNED";
    end // for loop
  endgenerate

  assign  y_out  = y;    // Monitor some test signals
  assign  e_out  = e;
  assign  f0_out = f[0];
  assign  f1_out = f[1];

endmodule