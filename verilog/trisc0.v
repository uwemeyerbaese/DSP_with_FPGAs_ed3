//*********************************************************
// IEEE STD 1364-2001 Verilog file: trisc0.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// Title: T-RISC stack machine 
// Description: This is the top control path/FSM of the 
// T-RISC, with a single three-phase clock cycle design
// It has a stack machine/0-address-type instruction word
// The stack has only four words.
//`include "220model.v"

module trisc0 #(parameter WA = 7,  // Address bit width -1
                          WD = 7)    // Data bit width -1 
 (input reset, clk,  // Clock for the output register
  output  jc_OUT, me_ena,
  input [WD:0] iport,
  output reg [WD:0] oport,
  output [WD:0] s0_OUT, s1_OUT, dmd_IN, dmd_OUT,
  output [WA:0] pc_OUT, dma_OUT, dma_IN,
  output [7:0]  ir_imm,
  output [3:0]  op_code);

  //parameter ifetch=0, load=1, store=2, incpc=3;
  reg [1:0] state;
  
  wire [3:0] op;   
  wire [WD:0] imm, dmd;
  reg [WD:0] s0, s1, s2, s3;
  reg [WA:0] pc;
  wire [WA:0] dma;
  wire [11:0] pmd, ir;
  wire eq, ne, not_clk;
  reg mem_ena, jc;

// OP Code of instructions:
  parameter 
  add  = 0,  neg   = 1, sub  = 2, opand = 3, opor = 4, 
  inv  = 5,  mul   = 6, pop  = 7, pushi = 8, push = 9, 
  scan = 10, print = 11, cne = 12, ceq  = 13, cjp = 14,
  jmp  = 15;

// Code of FSM:
  always @(op) // Sequential FSM of processor
               // Check store in register ? 
      case (op)  // always store except Branch
        pop     : mem_ena <= 1;
        default : mem_ena <= 0;
      endcase
      
  always @(negedge clk or posedge reset)    
      if (reset == 1)  // update the program counter
        pc <= 0;
      else begin    // use falling edge
        if (((op==cjp) & (jc==0)) | (op==jmp)) 
          pc <= imm;
        else 
          pc <= pc + 1; 
      end

  always @(posedge clk or posedge reset) 
    if (reset)         // compute jump flag and store in FF
      jc <= 0;
    else
      jc <= ((op == ceq) & (s0 == s1)) | 
                                ((op == cne) & (s0 != s1));

  // Mapping of the instruction, i.e., decode instruction
  assign op  = ir[11:8];   // Operation code
  assign dma = ir[7:0];    // Data memory address
  assign imm = ir[7:0];    // Immidiate operand

  lpm_rom prog_rom
  ( .outclock(clk),.address(pc), .q(pmd));  // Used ports
// .inclock(clk),  .memenab(ena)); // Unused
    defparam prog_rom.lpm_width = 12;    
    defparam prog_rom.lpm_widthad = 8;
    defparam prog_rom.lpm_outdata = "REGISTERED"; 
    defparam prog_rom.lpm_address_control = "UNREGISTERED";
    defparam prog_rom.lpm_file = "TRISC0FAC.MIF";
 
  assign not_clk = ~clk;

  lpm_ram_dq data_ram
  ( .inclock(not_clk),.address(dma), .q(dmd), 
    .data(s0), .we(mem_ena));  // Used ports
// .outclock(clk)); // Unused
    defparam data_ram.lpm_width = 8;    
    defparam data_ram.lpm_widthad = 8;
    defparam data_ram.lpm_indata = "REGISTERED"; 
    defparam data_ram.lpm_outdata = "UNREGISTERED"; 
    defparam data_ram.lpm_address_control = "REGISTERED";
    
  
  always @(posedge clk)
  begin : ALU
    integer temp;
    
    case (op) 
      add    :   s0  <= s0 + s1;
      neg    :   s0  <= -s0;
      sub    :   s0  <= s1 - s0;
      opand  :   s0  <= s0 & s1;
      opor   :   s0  <= s0 | s1;
      inv    :   s0  <= ~ s0; 
      mul    :   begin temp  = s0 * s1;  // double width
                 s0  <= temp[WD:0]; end  // product
      pop    :   s0  <= s1;
      pushi  :   s0  <= imm;
      push   :   s0  <= dmd;
      scan   :   s0 <= iport;
      print  :   begin oport <= s0; s0<=s1; end
      default:   s0 <= 0;
    endcase
    case (op) // SPECIFY THE STACK OPERATIONS
      pushi, push, scan : begin s3<=s2; s2<=s1; s1<=s0; end
                                               // Push type
      cjp, jmp,  inv | neg : ;   // Do nothing for branch
      default :  begin s1<=s2; s2<=s3; s3<=0; end 
                                          // Pop all others
    endcase
  end

  // Extra test pins:
  assign dmd_OUT = dmd; assign dma_OUT = dma; //Data memory 
  assign dma_IN = dma; assign dmd_IN  = s0;
  assign pc_OUT = pc; assign ir = pmd; assign ir_imm = imm; 
  assign op_code = op;  // Program control
  // Control signals:
  assign jc_OUT = jc; assign me_ena = mem_ena; 
  // Two top stack elements:
  assign s0_OUT = s0; assign s1_OUT = s1; 

endmodule