//*********************************************************
// IEEE STD 1364-2001 Verilog file: cordic.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module cordic #(parameter W = 7)  // Bit width - 1
(input        clk,
 input  signed [W:0] x_in, y_in,
 output reg signed [W:0] r, phi, eps); 
  

// There is bit access in Quartus array types 
// in Verilog 2001, therefore use single vectors 
// but use a separate line for each array!
  reg signed [W:0] x [0:3]; 
  reg signed [W:0] y [0:3]; 
  reg signed [W:0] z [0:3]; 

  always @(posedge clk) begin  //----> Infer registers
    if (x_in >= 0)             // Test for x_in < 0 rotate
      begin                    // 0, +90, or -90 degrees
      x[0] <= x_in; // Input in register 0
      y[0] <= y_in;
      z[0] <= 0;
      end
    else if (y_in >= 0) 
      begin
      x[0] <= y_in;
      y[0] <= - x_in;
      z[0] <= 90;
      end
    else
      begin
      x[0] <= - y_in;
      y[0] <= x_in;
      z[0] <= -90;
      end

    if (y[0] >= 0)                 // Rotate 45 degrees
      begin
      x[1] <= x[0] + y[0];
      y[1] <= y[0] - x[0];
      z[1] <= z[0] + 45;
      end
    else
      begin
      x[1] <= x[0] - y[0];
      y[1] <= y[0] + x[0];
      z[1] <= z[0] - 45;
      end

    if (y[1] >= 0)                 // Rotate 26 degrees
      begin
      x[2] <= x[1] + (y[1] >>> 1); // i.e. x[1] + y[1] /2
      y[2] <= y[1] - (x[1] >>> 1); // i.e. y[1] - x[1] /2
      z[2] <= z[1] + 26;
      end
    else
      begin
      x[2] <= x[1] - (y[1] >>> 1); // i.e. x[1] - y[1] /2
      y[2] <= y[1] + (x[1] >>> 1); // i.e. y[1] + x[1] /2
      z[2] <= z[1] - 26;
      end

    if (y[2] >= 0)                     // Rotate 14 degrees
      begin
        x[3] <= x[2] + (y[2] >>> 2); // i.e. x[2] + y[2]/4
        y[3] <= y[2] - (x[2] >>> 2); // i.e. y[2] - x[2]/4
        z[3] <= z[2] + 14;
      end
    else
      begin
        x[3] <= x[2] - (y[2] >>> 2); // i.e. x[2] - y[2]/4
        y[3] <= y[2] + (x[2] >>> 2); // i.e. y[2] + x[2]/4
        z[3] <= z[2] - 14;
      end

    r   <= x[3];
    phi <= z[3];
    eps <= y[3];
  end                

endmodule