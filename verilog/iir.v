//*********************************************************
// IEEE STD 1364-2001 Verilog file: iir.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module iir #(parameter W = 14)     // Bit width - 1
      ( input  signed [W:0] x_in,  // Input
        output signed [W:0] y_out,  // Result
        input         clk);   
  
  reg signed [W:0] x, y;

// initial begin
//  y=0;
//  x=0;
// end

// Use FFs for input and recursive part 
always @(posedge clk) begin    // Note: there is a signed
  x  <= x_in;                  // integer in Verilog 2001
  y  <= x + (y >>> 1) + (y >>> 2); // >>> uses fewer LEs

//y  <= x + y / 2 + y / 4; // div with / uses more LEs

end                                

assign  y_out = y;           // Connect y to output pins

endmodule