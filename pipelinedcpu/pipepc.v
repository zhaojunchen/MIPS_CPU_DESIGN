module pipepc(npc,wpc,clk,clrn,pc);		//写PC模块
	input [31:0] 	npc;				//npc
	input        	wpc,clk,clrn;		//wpc写pc信号   clk时钟  clrn复位信号
	output [31:0] 	pc;					//
	dffe32 program_counter(.A(npc),.clk(clk),.clrn(clrn),.AtoB_ControlSignal(wpc),.B(pc)); 	//程序计数器 为pc赋值
	//dffe32 模块  初始化pc的值 当处于时钟信号来到 且 wpc为1时  pc <= npc 
	//dede32(A,clk,clrn,AtoB_ControlSignal,B)
	//clrn为复位信号
	
endmodule 
	
	
	