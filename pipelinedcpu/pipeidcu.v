`include "pipe_ctrl_encode_def.v"
//等价于单周期的ctrl文件
module pipeidcu(mwreg,mrn,ern,ewreg,em2reg,mm2reg,
	rsrtequ,func,op,rs,rt,wreg,m2reg,wmem,ALUOp,regrt
	,aluimm,fwda,fwdb,nostall,sext,pcsource,shift,jal);
	
	input mwreg,ewreg,em2reg,mm2reg,rsrtequ;	//rsrtequ mm2reg 1MEM的数据 0为ALU的数据
	input [4:0] mrn,ern,rs,rt;	//mrn ern rs rt   
	input [5:0] func,op;
	
	output wreg,m2reg,wmem,aluimm,sext,shift,jal;
	output [1:0] regrt;// 00 rd   01 rt    10 $31  11 $ra
	output [3:0] ALUOp;			//ALUOp ALU运算的控制信号
	output [1:0] pcsource;		//npc 的控制选择信号
	output reg[1:0] fwda,fwdb;  	//forwarding  对ALU_A ALU_B的forwarding
	output nostall;   			//stall pipeline due to lw dependent  nop操作
	
	
 	/* // r format */
    wire rtype  = ~|op;
    wire i_add  = rtype& func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0]; // add
    wire i_sub  = rtype& func[5]&~func[4]&~func[3]&~func[2]& func[1]&~func[0]; // sub
    wire i_and  = rtype& func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0]; // and
    wire i_or   = rtype& func[5]&~func[4]&~func[3]& func[2]&~func[1]& func[0]; // or
    wire i_slt  = rtype& func[5]&~func[4]& func[3]&~func[2]& func[1]&~func[0]; // slt
    wire i_sltu = rtype& func[5]&~func[4]& func[3]&~func[2]& func[1]& func[0]; // sltu
    wire i_addu = rtype& func[5]&~func[4]&~func[3]&~func[2]&~func[1]& func[0]; // addu
    wire i_subu = rtype& func[5]&~func[4]&~func[3]&~func[2]& func[1]& func[0]; // subu
    //ext_instr
    wire i_nor  = rtype& func[5]&~func[4]&~func[3]& func[2]& func[1]& func[0]; // nor    nor rd rs rt  100111
    wire i_sll  = rtype&~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0]; // sll    sll rd rs sa  000000
    wire i_srl  = rtype&~func[5]&~func[4]&~func[3]&~func[2]& func[1]&~func[0]; // srl    srl rd rt sa  000010
    wire i_sllv = rtype&~func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0]; // srlv rd, rs, rt	000100
    wire i_srlv = rtype&~func[5]&~func[4]&~func[3]& func[2]& func[1]&~func[0]; // srlv rd, rs, rt	000110
    wire i_jr   = rtype&~func[5]&~func[4]& func[3]&~func[2]&~func[1]&~func[0]; // jr   jr   rs  001000
    wire i_jalr = rtype&~func[5]&~func[4]& func[3]&~func[2]&~func[1]& func[0]; // jalr jalr rs  001001
   // i format
    wire i_addi = ~op[5]&~op[4]& op[3]&~op[2]&~op[1]&~op[0]; // addi
    wire i_ori  = ~op[5]&~op[4]& op[3]& op[2]&~op[1]& op[0]; // ori
    wire i_lw   =  op[5]&~op[4]&~op[3]&~op[2]& op[1]& op[0]; // lw
    wire i_sw   =  op[5]&~op[4]& op[3]&~op[2]& op[1]& op[0]; // sw
    wire i_beq  = ~op[5]&~op[4]&~op[3]& op[2]&~op[1]&~op[0]; // beq
    //ext_instr
    wire i_andi = ~op[5]&~op[4]& op[3]& op[2]&~op[1]&~op[0]; // andi  andi rt, rs, immediate	001100
    wire i_bne  = ~op[5]&~op[4]&~op[3]& op[2]&~op[1]& op[0]; // bne   bne  rs, rt, offset	000101
    wire i_lui  = ~op[5]&~op[4]& op[3]& op[2]& op[1]& op[0]; // lui   lui  rt,  immediate	001111
    wire i_slti = ~op[5]&~op[4]& op[3]&~op[2]& op[1]&~op[0]; // slti  slti rt, rs, immediate	001010
   // j format
    wire i_j    = ~op[5]&~op[4]&~op[3]&~op[2]& op[1]&~op[0];  // j
    wire i_jal  = ~op[5]&~op[4]&~op[3]&~op[2]& op[1]& op[0];  // jal
	//i_rs使用rs作为源操作数 （注意作为目的操作数不算入）
	wire i_rs 	=  i_add | i_sub | i_and | i_or | i_slt | i_sltu | i_addu | i_subu | i_nor |
	i_sllv | i_srlv | i_jr | i_jalr | i_addi | i_ori | i_lw | i_sw | i_beq | i_andi | i_bne | i_slti;
	
	wire i_rt   =  i_sw | i_add | i_sub | i_and | i_or | i_slt | i_sltu | i_addu | i_subu | i_nor | i_sll | i_srl |
	i_sllv | i_srlv | i_beq | i_bne;
//i_add | i_sub | i_and | i_or | i_slt | i_add | i_sub | i_nor | i_sll | i_srl | i_sll | i_srl | i_jr | i_jal | i_add | i_ori | i_lw | i_sw | i_beq | i_and | i_bne | i_lui | i_slt | i_j | i_jal;	

	
	//nop的条件1没有nop操作  为0则nop操作
	assign nostall = ~(ewreg & em2reg & (ern!=0) & (i_rs & (ern==rs) | i_rt & (ern == rt)));
	//当出现lw(em2reg)和ewreg(如add操作)并且在ern=rs目标寄存器就会出现 nop 
	//最简单的暂停流水线就是 停止 wpcir(停止写pc和流水线寄存器IR)
	//当然还要防止写寄存器文件和存储器
	
	
	always @ (ewreg or mwreg or ern or mrn or em2reg or mm2reg or rs or rt) begin
		fwda = 2'b00;  	//default foeward a: no hazards
		if(ewreg & (ern!=0) & (ern==rs) & ~em2reg) begin
			fwda = 2'b01;	//select exe_alu   em2reg ---> 数据来自EXE　ALU
		end else begin
			if(mwreg & (mrn!=0) & (mrn==rs) & ~mm2reg) begin
				fwda = 2'b10;	//select mem_alu 　－－－－>数据来自MEM ALU
			end else begin
				if(mwreg & (mrn!=0) & (mrn==rs) & mm2reg) begin
					fwda = 2'b11;	//select mem_lw;   数据来自 存储器  
				end
			end
		end
		
		fwdb = 2'b00;  	//default foeward b: no hazards
		if(ewreg & (ern!=0) & (ern==rt) & ~em2reg) begin
			fwdb = 2'b01;	//select exe_alu
		end else begin
			if(mwreg & (mrn!=0) & (mrn==rt) & ~mm2reg) begin
				fwdb = 2'b10;	//select mem_alu
			end else begin
				if(mwreg & (mrn!=0) & (mrn==rt) & mm2reg) begin
					fwdb = 2'b11;	//select mem_lw;
				end
			end
		end
	end
	
	assign wreg = (rtype | i_lw | i_addi | i_ori | i_jal | i_andi | i_lui | i_slti | i_jalr) & (~ i_jr) & nostall;  
	//当没有阻塞 才会去执行IR的东西  否则会导致重复执行IR的指令   教材P214
	assign regrt[0]=  i_lw | i_addi | i_ori | i_andi | i_lui | i_slti | i_jal;   //等价于单周期的ALUSRCB （注意i_sw不是  他不会写端口 而是将端口往存储器送 ）
	assign regrt[1]=  i_jal | i_jalr;
	// regrt mux2的控制信号 决定drn的是 rs 还是 rd
	//选择寄存器写的端口控制信号 0为rd 1为rt    还需拓展到jal 和 jalr端口
	 
	assign m2reg= i_lw;		//数据的由存储器而来 有且仅有 lw指令 写存储器控制信号 
	assign shift= i_sll | i_srl;  //5 inst[10:6] to 32 inn32 for sll srl code 
	// 5 shamt字段的拓展操作
	assign aluimm = i_addi | i_lw | i_sw | i_andi | i_lui | i_slti | i_ori;  //16 inst[15:0]  to extend 32imm   for ALU_B port   ALU_B
	//端口的16立即数到32位立即数拓展
	assign sext  = i_addi | i_lw | i_sw | i_beq | i_bne; // 有符号拓展的控制信号
	assign jal  = i_jal | i_jalr; //将pc+8的值链接到目标寄存器  及时将epc8搞到某个目标寄存器  
	
	
	assign ALUOp[0] = i_add | i_lw | i_sw | i_addi | i_and | i_slt | i_addu | i_andi | i_lui | i_slti | i_sll | i_sllv;
	assign ALUOp[1] = i_sub | i_beq | i_bne | i_and | i_sltu | i_subu | i_andi | i_lui | i_srl | i_srlv;
	assign ALUOp[2] = i_or | i_ori | i_slt | i_sltu | i_lui | i_slti;
	assign ALUOp[3] = i_nor | i_sll | i_srl | i_sllv | i_srlv;
	
	assign wmem = i_sw & nostall;	//控制这个wmem的信号   阻塞
	//禁用掉一次 写IR流水线存储器的指令 当存在stall时候 IR的指令会被取出来两次
	//故而在 这个IR 废弃指令 wreg = wreg_org & wpcir;  wmem = wmem & wpcir;  见教材 214页


	// pcsource 控制下一条pc的来源 还要拓展
	//`define NPC_PLUS4   2'b00
	//`define NPC_BRANCH  2'b01
	//`define NPC_JUMP    2'b10
	//`define NPC_RS      2'b11
	
	assign pcsource[0] = i_beq & rsrtequ | i_bne & ~rsrtequ | i_jr | i_jalr ; 
	assign pcsource[1] = i_jr | i_j | i_jal | i_jalr;
	
	
	
endmodule