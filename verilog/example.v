//*********************************************************
// IEEE STD 1364-2001 Verilog file: example.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
//`include "220model.v"   // Using predefined components

module example   //----> Interface
  #(parameter WIDTH =8)    // Bit width 
 (input  clk,
  input  [WIDTH-1:0] a, b, op1,
  output [WIDTH-1:0] sum, d);

  wire [WIDTH-1:0]  c;         // Auxiliary variables
  reg  [WIDTH-1:0]  s;         // Infer FF with always
  wire [WIDTH-1:0] op2, op3;

  wire  clkena, ADD, ena, aset, sclr, sset, aload, sload,
                 aclr, ovf1, cin1; // Auxiliary lpm signals

// Default for add:
  assign cin1=0; assign aclr=0; assign ADD=1; 

  assign ena=1; assign aclr=0; assign aset=0; 
  assign sclr=0; assign sset=0; assign aload=0; 
  assign sload=0; assign clkena=0; // Default for FF

  assign op2 = b;       // Only one vector type in Verilog;
             // no conversion int -> logic vector necessary

// Note when using 220model.v ALL component's signals
// must be defined, default values can only be used for 
// the parameters.

  lpm_add_sub add1          //----> Component instantiation
  ( .result(op3), .dataa(op1), .datab(op2)); // Used ports
//  .cin(cin1),.cout(cr1), .add_sub(ADD), .clken(clkena), 
//  .clock(clk), .overflow(ovl1), .aclr(aclr)); // Unused
    defparam add1.lpm_width = WIDTH;
    defparam add1.lpm_representation = "SIGNED";

  lpm_ff reg1  
  ( .data(op3), .q(sum), .clock(clk));  // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr),
//  .sset(sset), .aload(aload), .sload(sload)); // Unused
    defparam reg1.lpm_width = WIDTH;

  assign c = a + b; //----> Continuous assignment statement
 
  always @(posedge clk)  //----> Behavioral style
  begin : p1             // Infer register 
    s = c + s;           // Signal assignment statement
  end
  assign d = s;

endmodule