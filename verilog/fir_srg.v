//*********************************************************
// IEEE STD 1364-2001 Verilog file: fir_srg.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module fir_srg          //----> Interface
 (input        clk,
  input signed [7:0] x,
  output reg signed [7:0] y);

// Tapped delay line array of bytes
  reg  signed  [7:0] tap [0:3]; 
// For bit access use single vectors in Verilog
  integer I;

  always @(posedge clk)  //----> Behavioral style
  begin : p1
   // Compute output y with the filter coefficients weight.
   // The coefficients are [-1  3.75  3.75  -1]. 
   // Multiplication and division for Altera MaxPlusII can 
   // be done in Verilog 2001 with signed shifts ! 
    y <= (tap[1] <<< 1) + tap[1] + (tap[1] >>> 1) - tap[0]
         + ( tap[1] >>> 2) + (tap[2] <<< 1) + tap[2]
         + (tap[2] >>> 1) + (tap[2] >>> 2) - tap[3];

    for (I=3; I>0; I=I-1) begin  
      tap[I] <= tap[I-1];  // Tapped delay line: shift one 
    end
    tap[0] <= x;   // Input in register 0
  end

endmodule