//*********************************************************
// IEEE STD 1364-2001 Verilog file: lfsr6s3.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module lfsr6s3           //----> Interface
 (input       clk,
  output [6:1]  y);  // Result

  reg [6:1] ff; // Note that reg is keyword in Verilog and 
                               // can not be variable name

  always @(posedge clk) begin // Implement three-step 
    ff[6] <= ff[3];           // length-6 LFSR with xnor; 
    ff[5] <= ff[2];         // use nonblocking assignments
    ff[4] <= ff[1];           
    ff[3] <= ff[5] ~^ ff[6];
    ff[2] <= ff[4] ~^ ff[5];
    ff[1] <= ff[3] ~^ ff[4];
  end

  assign  y = ff; 

endmodule