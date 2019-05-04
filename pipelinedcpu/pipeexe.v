module pipeexe(ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu);
//ALUOut的产生和返回地址的产生 

	input [31:0]	ea,eb,eimm,epc4;
	input [4:0]     ern0;	//
	input [3:0] 	ealuc; 	//alu控制信号
	input 			ealuimm,eshift,ejal;
	
	output[31:0]   	ealu; //e级的ALUOUT
	output[4:0]  	ern;  //返回地值的目标端口 
	
	wire [31:0] 	alua,alub,sa,ealu0,epc8;
	//assign   		sa = {eimm[5:0],eimm[31:6]};//shift  偏移量 shamt字段
	assign       	sa = {26'h0,eimm[10:6]};
	cla32 ret_addr(epc4,32'h4,1'b0,epc8);		//第三个段  pc+4*2
	mux2 #(32) 	alu_ina(ea,sa,eshift,alua);	// 确定 alu_a是来自rs还是 shamt字段 （sll srl.....指令）
	mux2 #(32) 	alu_inb(eb,eimm,ealuimm,alub);	// 确定 alu_b是来自rt 还是16位拓展的32位数立即数
	mux2 #(32) 	save_pc8(ealu0,epc8,ejal,ealu);	// ejal确定这个信号是来自epc8(从第一周期开始pc+8)处理第三条指令   决定ALU的来源
	//跳转不会计算ALu的
	
	assign 			ern = ern0 | {5{ejal}};		// 确定目标寄存器是$ra还是ern0这个目标寄存器   当然日后还要拓展到任意寄存器
	
	alu al_unit     (.A(alua),.B(alub),.ALUOp(ealuc),.C(ealu0));  //计算alu的值 的值 结果为ealu0
	//module alu(A, B, ALUOp, C);
	
 	
	
endmodule

