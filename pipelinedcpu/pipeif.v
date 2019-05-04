module pipeif(pcsource,pc,bpc,jpc,rpc,npc,pc4);
	input  [31:0] pc,bpc,jpc,rpc;	// pc4 rpc bpc jpc  rpc是寄存器
	input  [1:0]  pcsource;			//pc控制信号
	output [31:0] npc,pc4;
	
	cla32 pc_plus4(pc,32'h4,1'b0,pc4);//32位数先行进位加法器  参考于 教材P72（无进位版本）
	mux4 #(32) next_pc(pc4,bpc,jpc,rpc,pcsource,npc);
	//根据pcsource确定这个采用那种npc的赋值
	//注意赋值的编号和单周期保持一致
endmodule


/*	
	此段代码实现
	1.pc4 = pc+4
	2.npc =mux[pcsource](pc4,bpc,jpc,rpc);

*/

// pcsource control signal
//`define NPC_PLUS4   2'b00
//`define NPC_BRANCH  2'b01
//`define NPC_JUMP    2'b10
//`define NPC_RS      2'b11