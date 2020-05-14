// Desciption: This is a W x L bit register file.
//*********************************************************
// IEEE STD 1364-2001 Verilog file: reg_file.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module reg_file  #(parameter W = 7, // Bit width -1
                          N  = 15) //Number of register - 1
       (input clk, reg_ena,
        input [W:0] data,
        input [3:0]  rd, rs, rt ,
        output reg [W:0] s, t);

  reg [W:0] r [0:N];
  
  always @(posedge clk) // Input mux inferring registers
  begin : MUX  
    if ((reg_ena == 1) & (rd > 0)) 
      r[rd] <= data; 
  end 

  //  2 output demux without registers
  always @*
  begin : DEMUX
    if (rs > 0) // First source
      s = r[rs];
    else
      s = 0;
    if (rt > 0) // Second source
      t = r[rt];
    else
      t = 0;
  end
                 
endmodule