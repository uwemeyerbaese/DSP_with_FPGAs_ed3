//*********************************************************
// IEEE STD 1364-2001 Verilog file: lfsr.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module lfsr           //----> Interface
  (input      clk,
  output [6:1]  y);  // Result

  reg [6:1] ff; // Note that reg is keyword in Verilog and 
                               // can not be variable name
  integer i;
        
  always @(posedge clk) begin // Length-6 LFSR with xnor
    ff[1] <= ff[5] ~^ ff[6]; // Use nonblocking assignment
    for (i=6; i>=2 ; i=i-1) // Tapped delay line: shift one 
      ff[i] <= ff[i-1];
  end

  assign   y = ff;         // Connect to I/O pins

endmodule