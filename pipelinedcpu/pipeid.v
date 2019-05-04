module pipeid (mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,wrn,wdi,ealu,
			malu,mmo,wwreg,clk,clrn,bpc,jpc,pcsource,nostall,wreg,
			m2reg,wmem,ALUOp,aluimm,a,b,imm,rn,shift,jal,reg_sel,reg_data);
	/* 寄存器堆和控制文件 */
	/* 1.计算每个npc的值 jpc bpc pc4一直 rpc是da
	   2.译码指令 得到所有的控制信号  nostall为wpcir实例化
	*/


	input  [31:0]	dpc4,inst,wdi,ealu,malu,mmo;	//要写的数据   mmo来自存储器的数据  用于forward
	//wdi: 写回数据 wrn：写到那个端口  wm2reg：控制写数据来源ALU/MEM   
	input  [4:0]   	ern,mrn,wrn;					//写目标端口  0 rs 1 rt  决定写个谁的  一级一级的传递和保存
													//由于都要用 所以都传递进来
	input 			mwreg,ewreg,em2reg,mm2reg,wwreg;//写寄存器的控制信号  wwreg写寄存器堆的信号 
	input    		clk,clrn;						//时钟信号 
	
	output [31:0]  	bpc,jpc,a,b,imm;		// a b  imm 等其实就是 da db dimm drn……			
	output [4:0]  	rn;
	output [3:0] 	ALUOp;
	output [1:0]  	pcsource;
	output   		nostall,wreg,m2reg,wmem,aluimm,shift,jal;
	
	input [4:0] reg_sel;
	output[31:0]reg_data;
	
	wire   [5:0] 	op,func;
	wire   [4:0]	rs,rt,rd;
 	wire   [31:0]	qa,qb,br_offset;	
	wire   [15:0]	ext16;
	wire   [1:0]    fwda,fwdb;
	wire 			sext,rsrtequ,e;
	wire   [1:0]	regrt;
	
	//inst为ir寄存器的取值（第一级的ins演化而来 ins->inst在顶层文件的 inst_reg函数实例化得来的）
	//在pipelinedcpu完成实例化
	assign  	func	= inst[5:0];			//实例化ID级的指令
	assign  	op 		= inst[31:26];
	assign 		rs 		= inst[25:21];
	assign 		rt 		= inst[20:16];
	assign 		rd 		= inst[15:11];
	assign 		jpc  	= {dpc4[31:28],inst[25:0],2'b00};  //jpc 计算跳转地址(J指令jal指令)
	//pc4 jpc
	//J	opcode (6)	address (26)   将这个26为左移2为然后加上pc的最高4位
	

	
	//实例化这个 译码文件（等价于单周期文件的ctrl.v文件）
	pipeidcu cpu(.mwreg(mwreg),.mrn(mrn),.ern(ern),.ewreg(ewreg),.em2reg(em2reg),.mm2reg(mm2reg),
	.rsrtequ(rsrtequ),.func(func),.op(op),.rs(rs),.rt(rt),.wreg(wreg),.m2reg(m2reg),.wmem(wmem),
	.ALUOp(ALUOp),.regrt(regrt),.aluimm(aluimm),.fwda(fwda),.fwdb(fwdb),.nostall(nostall),.sext(sext),
	.pcsource(pcsource),.shift(shift),.jal(jal));
	
	//clk下跳时操作 RF寄存器   千万注意 流水代码的RF模块一定要在这个clk的下降沿写入
	RF U_RF(.clk(~clk),.clrn(clrn),.RFWr(wwreg),.A1(rs),.A2(rt),.A3(wrn),.WD(wdi),.RD1(qa),.RD2(qb),.reg_sel(reg_sel),.reg_data(reg_data)); 
	//寄存器文件  当clrn下降沿是 寄存器文件设置为0   注意这个wrn是看来自WB级的控制信号  wwreg也是wb的控制信号 是但是是 wreg->ewreg->mwreg传来的
	//当写寄存器是 wdi写入寄存器的数据  ern写寄存器的目标寄存器地址 同时取出寄存器的RS RT的知道qa，qb   但是后来会转为da db

	assign  	rpc = qa;
	
	mux4 #(5) 	des_reg_no(rd,rt,5'b11111,rs,regrt,rn);			// regrt制定目标寄存器 regrt 0 则为默认的rd目标寄存器 
													// 否则为rt寄存器
	
	mux4 #(32) 	alu_a(qa,ealu,malu,mmo,fwda,a);  	// fwda 控制信号 决定ALU_A的数据来源
	//elau是来自的EXE级的数据相关（EXE的ALUOUT）   
	//malu是来自MEM级别的ALUOUT但是本质上是EXE级的ALUOUt
	//但是传入了MEM级，因此为malu  (教材P216图例)
	//mmo 来存储器取数的前推，周期暂停一个     这个是 数据冒险有关
	
	mux4 #(32) 	alu_b(qb,ealu,malu,mmo,fwdb,b);		// fwdb 控制信号 决定ALU_B的数据来源
	//同上面的分析
	
	
	assign 		rsrtequ	= ~|(a^b);  	//rsrtequ = (a==b) 这个信号的等价于单周期Zero信号
	// 会在beq和bne做减法的时候区分这两个信号
	// i_beq & rsrtequ | i_bne & ~rsrtequ
	
	assign 		e 		= sext & inst[15];			//得到这个立即数的符号位数   
	//没有sext则为无符号拓展 直接加上0在前面
	assign		ext16	= {16{e}};					// 立即数前缀
	assign 		imm 	= {ext16,inst[15:0]};		//16立即数的拓展   有符号的拓展
	assign		br_offset = {imm[29:0],2'b00};		//j指令  左移两位   分支指令  dpc4+分支偏移量  
	cla32  		br_addr (dpc4,br_offset,1'b0,bpc);	//bpc 跳转的地址  dpc4 pc+4 加上 便偏移的跳转地址
	//bpc为branch跳转的pc地址计算   dpc（pc+4） +  立即数的2为左移
	//rpc  
	
 		
endmodule



