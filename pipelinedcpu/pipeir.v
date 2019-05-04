/* IF到ID的寄存器数据和指令过度  现在他属于ID级的代码了*/  
module pipeir(pc4,ins,wir,clk,clrn,dpc4,inst);  //保存流水线的状态 
	input  [31:0] 	pc4,ins;			//ins 第一级清取出的指令   pc4 IF的pc值+4
	input			wir,clk,clrn;		//wir 写pc和写IR流水线存储器信号的
	output [31:0]	dpc4,inst;
	
	//以下连个函数的触发条件为是时钟跳变   在时钟信号产生是 作用 到IR寄存器   
	
	//module dffe32(A,clk,clrn,AtoB_ControlSignal,B);   //e为写信号
	dffe32 pc_plus4	(.A(pc4),.clk(clk),.clrn(clrn),.AtoB_ControlSignal(wir),.B(dpc4));		
	//将pc4的结果传入IR寄存器 以便于下一级别使用  将 pc4传入 dpc4
	
	dffe32 instruction	(.A(ins),.clk(clk),.clrn(clrn),.AtoB_ControlSignal(wir),.B(inst));	
	//ins->inst(ir)将ins传递到IR寄存器  将ins 传到 inst里面去

endmodule
