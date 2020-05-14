//*********************************************************
// IEEE STD 1364-2001 Verilog file: dasign.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
`include "case3s.v" // User-defined component

module dasign              //-> Interface
 (input         clk, reset,
  input signed  [3:0]  x_in0, x_in1, x_in2,
  output [3:0]  lut,
  output reg signed [6:0]  y);
 
  reg  signed  [3:0] x0, x1, x2;
  wire signed  [2:0] table_in;
  wire signed  [3:0] table_out;

  reg [6:0] p;  // Temporary register

  assign table_in[0] = x0[0];
  assign table_in[1] = x1[0];
  assign table_in[2] = x2[0];

  always @(posedge clk or posedge reset)// DA in behavioral
  begin : DA                                       // style
    parameter s0=0, s1=1;
    integer k;
    reg [0:0] state;
    reg [2:0] count;           // Counts the shifts

    if (reset)                 // Asynchronous reset
      state <= s0;
    else
      case (state) 
        s0 : begin             // Initialization step
          state <= s1;
          count = 0;
          p  <= 0;           
          x0 <= x_in0;
          x1 <= x_in1;
          x2 <= x_in2;
        end
        s1 : begin             // Processing step
          if (count == 4) begin// Is sum of product done?
            y <= p;            // Output of result to y and
            state <= s0;       // start next sum of product
        end else begin //Subtract for last accumulator step
          if (count ==3)   // i.e. p/2 +/- table_out * 8
            p <= (p >>> 1) - (table_out <<< 3);  
          else          // Accumulation for all other steps
            p <= (p >>> 1) + (table_out <<< 3);
          for (k=0; k<=2; k= k+1) begin     // Shift bits
            x0[k] <= x0[k+1];
            x1[k] <= x1[k+1];
            x2[k] <= x2[k+1];
          end
          count = count + 1;
          state <= s1;
        end
      end
    endcase  
  end

  case3s LC_Table0 
  ( .table_in(table_in), .table_out(table_out));

  assign lut = table_out; // Provide test signal

endmodule