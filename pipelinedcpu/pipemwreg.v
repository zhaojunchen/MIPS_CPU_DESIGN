module pipemwreg(mwreg,mm2reg,mmo,malu,mrn,clk,clrn,wwreg,wm2reg,wmo,walu,wrn);
	input [31:0]  	mmo,malu;	//mmo MEM级从存储器出来的数据
	input [4:0] 	mrn;
	input 			mwreg,mm2reg; //寄存器写   mm2reg选择存储器的数据
	input 			clk,clrn;
	
	output reg[31:0] 	wmo,walu;		//传递第四级别ALUOUt     wmo为数据存储器取出的值 lw使用的
	output reg[4:0]		wrn;			//wrn写目标
	output reg 			wwreg,wm2reg;	//
	
	always @(negedge clrn or posedge clk)
		if(clrn==0) begin
			wwreg	<=0;
			wm2reg	<=0;
			wmo		<=0;
			walu	<=0;
			wrn		<=0;
		end else begin
			wwreg	<= mwreg	;
			wm2reg	<= mm2reg	;
			wmo		<= mmo		;  //传到WB级 为lw提供帮助
			walu	<= malu		; 
	        wrn		<= mrn		;
		end
endmodule