//*********************************************************
// IEEE STD 1364-2001 Verilog file: fun_text.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
//  A 32-bit function generator using accumulator and ROM
//`include "220model.v"

module fun_text             //----> Interface
  #(parameter WIDTH = 32)   // Bit width
 (input          clk,
  input  [WIDTH-1:0]  M,
  output [7:0]  sin, acc);

  wire [WIDTH-1:0] s, acc32;
  wire [7:0]    msbs;               // Auxiliary vectors
  wire  ADD, ena, aset, sclr, sset; // Auxiliary signals
  wire aload, sload, aclr, ovf1, cin1, clkena; 

  // Default for add:
  assign clkena=0; assign cin1=0; assign ADD=1; 
  //default for FF:
  assign ena=1; assign aclr=0; assign aset=0;
  assign sclr=0; assign sset=0; assign aload=0; 
  assign sload=0; 

  lpm_add_sub add_1                       // Add M to acc32
  ( .result(s), .dataa(acc32), .datab(M)); // Used ports
//  .cout(cr1), .add_sub(ADD), .overflow(ovl1),  // Unused
//  .clock(clk),.cin(cin1), .clken(clkena), .aclr(aclr)); 
//  
    defparam add_1.lpm_width = WIDTH;
    defparam add_1.lpm_representation = "UNSIGNED";


  lpm_ff reg_1                                 // Save accu
  ( .data(s), .q(acc32), .clock(clk));        // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), // Unused ports
//  .sset(sset), .aload(aload), .sload(sload),.sclr(sclr));
    defparam reg_1.lpm_width = WIDTH;
    
  assign msbs = acc32[WIDTH-1:WIDTH-8];
  assign acc  = msbs;

  lpm_rom rom1
  ( .q(sin), .inclock(clk), .outclock(clk), 
                             .address(msbs)); // Used ports
//                    .memenab(ena) ) ;      // Unused port
    defparam rom1.lpm_width = 8; 
    defparam rom1.lpm_widthad = 8;
    defparam rom1.lpm_file = "sine.mif";

endmodule