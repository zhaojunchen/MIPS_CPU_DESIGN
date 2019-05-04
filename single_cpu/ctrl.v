// `include "ctrl_encode_def.v"


module ctrl(Op, Funct, Zero, 
            RegWrite, MemWrite,
            EXTOp, EXTOp_5, ALUOp, NPCOp, 
            ALUSrc,ALUSrcA, GPRSel, WDSel
            );
            
   input  [5:0] Op;       // opcode
   input  [5:0] Funct;    // funct
   input        Zero;
   
   output       RegWrite; // control signal for register write
   output       MemWrite; // control signal for memory write
   output       EXTOp;    // control signal to signed extension
   output       EXTOp_5;  // control signal to signal 5-32 extension
   output [3:0] ALUOp;    // ALU opertion
   output [1:0] NPCOp;    // next pc operation
   output       ALUSrc;   // ALU source for B 
   output       ALUSrcA;  // ALU source for A  for imm5 to 32 to ALU_A

   output [1:0] GPRSel;   // general purpose register selection
   output [1:0] WDSel;    // (register) write data selection
   
  /* // r format */
   wire rtype  = ~|Op;
   wire i_add  = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // add
   wire i_sub  = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]&~Funct[0]; // sub
   wire i_and  = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]&~Funct[1]&~Funct[0]; // and
   wire i_or   = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]&~Funct[1]& Funct[0]; // or
   wire i_slt  = rtype& Funct[5]&~Funct[4]& Funct[3]&~Funct[2]& Funct[1]&~Funct[0]; // slt
   wire i_sltu = rtype& Funct[5]&~Funct[4]& Funct[3]&~Funct[2]& Funct[1]& Funct[0]; // sltu
   wire i_addu = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]& Funct[0]; // addu
   wire i_subu = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]& Funct[0]; // subu
   //ext_instr
   wire i_nor  = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]& Funct[1]& Funct[0]; // nor    nor rd rs rt  100111
   wire i_sll  = rtype&~Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // sll    sll rd rs sa  000000
   wire i_srl  = rtype&~Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]&~Funct[0]; // srl    srl rd rt sa  000010
   wire i_sllv = rtype&~Funct[5]&~Funct[4]&~Funct[3]& Funct[2]&~Funct[1]&~Funct[0]; // srlv rd, rs, rt	000100
   wire i_srlv = rtype&~Funct[5]&~Funct[4]&~Funct[3]& Funct[2]& Funct[1]&~Funct[0]; // srlv rd, rs, rt	000110
   wire i_jr   = rtype&~Funct[5]&~Funct[4]& Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // jr   jr   rs  001000
   wire i_jalr = rtype&~Funct[5]&~Funct[4]& Funct[3]&~Funct[2]&~Funct[1]& Funct[0]; // jalr jalr rs  001001

  // i format
   wire i_addi = ~Op[5]&~Op[4]& Op[3]&~Op[2]&~Op[1]&~Op[0]; // addi
   wire i_ori  = ~Op[5]&~Op[4]& Op[3]& Op[2]&~Op[1]& Op[0]; // ori
   wire i_lw   =  Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]& Op[0]; // lw
   wire i_sw   =  Op[5]&~Op[4]& Op[3]&~Op[2]& Op[1]& Op[0]; // sw
   wire i_beq  = ~Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]&~Op[0]; // beq
   //ext_instr
   wire i_andi = ~Op[5]&~Op[4]& Op[3]& Op[2]&~Op[1]&~Op[0]; // andi  andi rt, rs, immediate	001100
   wire i_bne  = ~Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]& Op[0]; // bne   bne  rs, rt, offset	000101
   wire i_lui  = ~Op[5]&~Op[4]& Op[3]& Op[2]& Op[1]& Op[0]; // lui   lui  rt,  immediate	001111
   wire i_slti = ~Op[5]&~Op[4]& Op[3]&~Op[2]& Op[1]&~Op[0]; // slti  slti rt, rs, immediate	001010

  // j format
   wire i_j    = ~Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]&~Op[0];  // j
   wire i_jal  = ~Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]& Op[0];  // jal
   

  // generate control signals   //rtype代表R指令
  assign RegWrite   = (rtype | i_lw | i_addi | i_ori | i_jal | i_andi | i_lui | i_slti | i_jalr) & (~ i_jr); // register write
  
  assign MemWrite   = i_sw;                           // memory write
  assign ALUSrc     = i_lw | i_sw | i_addi | i_ori | i_andi | i_lui | i_slti;    // ALU B is from instruction immediate
  assign ALUSrcA    = i_sll| i_srl ;              			  //ALU_A is from 5-32 Immediate
  assign EXTOp      = i_addi | i_lw | i_sw | i_andi | i_lui | i_slti;           // signed extension
  assign EXTOp_5    = i_sll | i_srl;

  // GPRSel_RD   2'b00
  // GPRSel_RT   2'b01
  // GPRSel_31   2'b10
  assign GPRSel[0] = i_lw | i_addi | i_ori | i_andi | i_lui | i_slti;
  assign GPRSel[1] = i_jal | i_jalr;
  
  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 

  assign WDSel[0] = i_lw;
  assign WDSel[1] = i_jal | i_jalr;

  // NPC_PLUS4   2'b00
  // NPC_BRANCH  2'b01
  // NPC_JUMP    2'b10
  // NPC_RS      2'b11
  assign NPCOp[0] = i_beq & Zero | i_bne & ~Zero | i_jr | i_jalr;
  assign NPCOp[1] = i_j | i_jr | i_jalr | i_jal;
  
  // ALU_NOP   4'b0000
  // ALU_ADD   4'b0001
  // ALU_SUB   4'b0010
  // ALU_AND   4'b0011
  // ALU_OR    4'b0100
  // ALU_SLT   4'b0101
  // ALU_SLTU  4'b0110
  // ALU_NOR   4'b1000
  // ALU_SLL   4'b1001
  // ALU_SRL   4'b1010
  
  assign ALUOp[0] = i_add | i_lw | i_sw | i_addi | i_and | i_slt | i_addu | i_andi | i_lui | i_slti | i_sll | i_sllv;
  assign ALUOp[1] = i_sub | i_beq | i_bne | i_and | i_sltu | i_subu | i_andi | i_lui | i_srl | i_srlv;
  assign ALUOp[2] = i_or | i_ori | i_slt | i_sltu | i_lui | i_slti;
  assign ALUOp[3] = i_nor | i_sll | i_srl | i_sllv | i_srlv;

endmodule
