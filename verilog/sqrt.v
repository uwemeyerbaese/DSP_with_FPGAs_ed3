//*********************************************************
// IEEE STD 1364-2001 Verilog file: sqrt.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************

module sqrt  ////> Interface
 (input         clk, reset,
  input  [16:0]  x_in,
  output [16:0]  a_o, imm_o, f_o,  
  output reg [2:0]  ind_o,
  output reg [1:0]  count_o,
  output [16:0]  x_o,pre_o,post_o,
  output reg [16:0]  f_out);
   
  // Define the operation modes:
  parameter load=0, mac=1, scale=2, denorm=3, nop=4;
  //  Assign the FSM states:
  parameter start=0, leftshift=1, sop=2, 
                   rightshift=3, done=4;

  reg [2:0] s, op;
  reg [16:0] x; // Auxilary 
  reg signed [16:0] a, b, f, imm; // ALU data
  reg [16:0] pre, post;
  // Chebychev poly coefficients for 16-bit precision: 
  wire signed [16:0] p [0:4]; 
  
  assign p[0] = 7563;
  assign p[1] = 42299;
  assign p[2] = -29129;
  assign p[3] = 15813;
  assign p[4] = -3778;
  
  always @(posedge reset or posedge clk) //------> SQRT FSM
  begin : States                      // sample at clk rate
    reg signed [3:0] ind;
    reg [1:0] count;

    if (reset)                  // Asynchronous reset
      s <= start;
    else begin 
      case (s)                 // Next State assignments
        start : begin          // Initialization step 
          s <= leftshift; ind = 4;
          imm <= x_in;         // Load argument in ALU
          op <= load; count = 0;
        end
        leftshift : begin      // Normalize to 0.5 .. 1.0
          count = count + 1; a <= pre; op <= scale;
          imm <= p[4];
          if (count == 3) begin // Normalize ready ?
            s <= sop; op <= load; x <= f; 
          end
        end
        sop :  begin            // Processing step
          ind = ind - 1; a <= x;
          if (ind == -1) begin  // SOP ready ?
            s <= rightshift; op <= denorm; a <= post;
          end else begin
            imm <= p[ind]; op <= mac;
          end
        end
        rightshift : begin // Denormalize to original range
          s <= done; op <= nop;
        end
        done :  begin          // Output of results
        f_out <= f;            // I/O store in register
        op<=nop;
        s <= start;  
        end                   // start next cycle
      endcase
    end
    ind_o <= ind;
    count_o <= count;
  end

  always @(posedge clk) // Define the ALU operations
  begin : ALU
    case (op)
        load    : f  <= imm;
        mac     : f  <= (a * f / 32768) + imm;
        scale   : f  <= a * f;
        denorm  : f  <= (a * f /32768);
        nop     : f  <= f;
        default : f  <= f;
    endcase
  end

  always @*
  begin : EXP
    reg [16:0] slv;
    reg [16:0] po, pr;
    integer K, L;

    slv = x_in;
    // Compute pre-scaling:
    for (K=0; K <= 15; K= K+1) 
      if (slv[K] == 1)
        L <= K;
    pre = 1 << (14-L);
    // Compute post scaling:
    po = 1;     
    for (K=0; K <= 7; K= K+1) begin
      if (slv[2*K] == 1)    // even 2^k gets 2^k/2
        po = 1 << (K+8);
//  sqrt(2): CSD Error = 0.0000208 = 15.55 effective bits
// +1 +0. -1 +0 -1 +0 +1 +0 +1 +0 +0 +0 +0 +0 +1
//  9      7     5     3     1               -5
      if (slv[2*K+1] == 1) // odd k has sqrt(2) factor
        po = (1<<(K+9)) - (1<<(K+7)) - (1<<(K+5))
              + (1<<(K+3)) + (1<<(K+1)) + (1<<(K-5));
    end
    post <= po;
  end

  assign a_o = a;   // Provide some test signals as outputs
  assign imm_o = imm;
  assign f_o = f;
  assign pre_o = pre;
  assign post_o = post;
  assign x_o = x;

endmodule