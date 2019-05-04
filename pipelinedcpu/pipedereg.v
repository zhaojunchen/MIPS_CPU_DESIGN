module pipedereg(dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,drn,dshift,djal,dpc4,clk,clrn,ewreg,em2reg,ewmem,ealuc,ealuimm,ea,eb,eimm,ern,eshift,ejal,epc4);
	input [31:0]	da,db,dimm,dpc4;	//来自第2级的rs rt的值 传到了 ID/MEM寄存器 	
	input [4:0]		drn;				//写的目标寄存器 
	input [3:0]  	daluc; 				//ID的aluc操作
	input 			dwreg,dm2reg,dwmem,daluimm,dshift,djal;//以上几个信号 均是来自ID级的
	input  			clk,clrn;			//时钟信号  shift移动位置操作
	
	output reg[31:0]  	ea,eb,eimm,epc4;	//EXE的信号 在clk的作用下 ID/MEM寄存器取值
	output reg[4:0]	    ern;				//写目标寄存器 
	output reg[3:0]     ealuc;				// aluc操作
	output reg  		ewreg,em2reg,ewmem,ealuimm,eshift,ejal;   //eshift控制shamt的偏移 sll srl等   
	//ejal控制跳转的ALU操作 跳转不会用到 ALU 所有这个是 ALU的MUX选择器
	//ealumm控制这个立即数的信号 
	//
	
	
	always @(negedge clrn or posedge clk)
		if (clrn==0) begin
			ewreg		<= 0;
			em2reg 		<= 0;
			ewmem		<= 0;
			ealuc		<= 0;
			ealuimm		<= 0;
			ea			<= 0;
			eb			<= 0;
			eimm		<= 0;
			ern			<= 0;
			eshift		<= 0;
			ejal		<= 0;
			epc4		<= 0;
		end else begin
			ewreg		<= dwreg;
		   	em2reg 		<= dm2reg;
		   	ewmem		<= dwmem;
		   	ealuc		<= daluc;
		   	ealuimm		<= daluimm;
		   	ea			<= da;
		   	eb			<= db;
		   	eimm		<= dimm;
		   	ern			<= drn;
		   	eshift		<= dshift;
		   	ejal		<= djal;
		   	epc4		<= dpc4;
		end
			
endmodule
