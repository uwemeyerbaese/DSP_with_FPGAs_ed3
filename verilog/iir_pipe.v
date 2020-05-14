//*********************************************************
// IEEE STD 1364-2001 Verilog file: iir_pipe.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module iir_pipe      //----> Interface
 #(parameter W = 14) // Bit width - 1
 (input          clk,
  input signed [W:0]  x_in,     // Input
  output signed [W:0]  y_out);  // Result

  reg signed [W:0] x, x3, sx;
  reg signed [W:0] y, y9;  
            
  always @(posedge clk)  // Infer FFs for input, output and
  begin                  // pipeline stages; 
    x   <= x_in;         // use nonblocking FF assignments
    x3  <= (x >>> 1) + (x >>> 2); 
                              // i.e. x / 2 + x / 4 = x*3/4
    sx  <= x + x3; // Sum of x element i.e. output FIR part
    y9  <= (y >>> 1) + (y >>> 4); 
                            // i.e. y / 2 + y / 16 = y*9/16
    y   <= sx + y9;                       // Compute output
  end

  assign y_out = y ;   // Connect register y to output pins

endmodule