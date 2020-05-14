//*********************************************************
// IEEE STD 1364-2001 Verilog file: ammod.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module ammod #(parameter W = 8)  // Bit width - 1
 (input        clk,              //----> Interface
  input signed [W:0] r_in,
  input signed [W:0] phi_in,
  output reg signed [W:0] x_out, y_out, eps); 

  reg signed [W:0] x [0:3]; // There is bit access in 2D 
  reg signed [W:0] y [0:3]; // array types in  
  reg signed [W:0] z [0:3]; //  Quartus Verilog 2001

  always @(posedge clk) begin //----> Infer register
    if (phi_in > 90)           // Test for |phi_in| > 90
      begin                    // Rotate 90 degrees 
      x[0] <= 0;                 
      y[0] <= r_in;              // Input in register 0
      z[0] <= phi_in - 'sd90;
      end
    else  
      if (phi_in < - 90)
        begin
        x[0] <= 0;
        y[0] <= - r_in;
        z[0] <= phi_in + 'sd90;
        end
      else
        begin
        x[0] <= r_in;
        y[0] <= 0;
        z[0] <= phi_in;
        end

    if (z[0] >= 0)                  // Rotate 45 degrees
      begin
      x[1] <= x[0] - y[0];
      y[1] <= y[0] + x[0];
      z[1] <= z[0] - 'sd45;
      end
    else
      begin
      x[1] <= x[0] + y[0];
      y[1] <= y[0] - x[0];
      z[1] <= z[0] + 'sd45;
      end

    if (z[1] >= 0)                 // Rotate 26 degrees
      begin
      x[2] <= x[1] - (y[1] >>> 1); // i.e. x[1] - y[1] /2
      y[2] <= y[1] + (x[1] >>> 1); // i.e. y[1] + x[1] /2
      z[2] <= z[1] - 'sd26;
      end
    else
      begin
      x[2] <= x[1] + (y[1] >>> 1); // i.e. x[1] + y[1] /2
      y[2] <= y[1] - (x[1] >>> 1); // i.e. y[1] - x[1] /2
      z[2] <= z[1] + 'sd26;
      end

    if (z[2] >= 0)                     // Rotate 14 degrees
      begin
        x[3] <= x[2] - (y[2] >>> 2); // i.e. x[2] - y[2]/4
        y[3] <= y[2] + (x[2] >>> 2); // i.e. y[2] + x[2]/4
        z[3] <= z[2] - 'sd14;
      end
    else
      begin
        x[3] <= x[2] + (y[2] >>> 2); // i.e. x[2] + y[2]/4
        y[3] <= y[2] - (x[2] >>> 2); // i.e. y[2] - x[2]/4
        z[3] <= z[2] + 'sd14;
      end

    x_out <= x[3];
    eps   <= z[3];
    y_out <= y[3];
  end                

endmodule