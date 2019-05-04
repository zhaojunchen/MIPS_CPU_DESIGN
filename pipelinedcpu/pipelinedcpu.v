module pipelinedcpu(clock,resetn,pc,ins,malu,mmo,mb,mwmem,reg_sel,reg_data);
 //malu待处理的存储器地址 .malu(dm_addr)
 //mwmem 写存储器的信号  .mwmem(MemWrite)在第四级出现  对于 sw指令 
 //.mmo(dm_dout) 从数据存储器输出的数据  lw指令 
 // sw存数据  是来自 mb（rt）的寄存器值 
 
 /* 实例化的文件
   sccpu U_PIPECPU(
         .clock(clk),               // input:  cpu clock
         .resetn(rstn),             // input:  reset  初值为1  	当下跳是复位
         .ins(instr),             	// input:  instruction   	在IM存储器 取指令
         .mmo(dm_dout),        		// input:  data to cpu    	在Dm里面取出数据 存入寄存器  
         .mwmem(MemWrite),       	// output: memory write signal  写sw存储器信号
         .pc(PC),                   // output: PC				PC信号 IM存储器的 取指令地址
         .malu(dm_addr),          	// output: address from cpu to memory
         .mb(dm_din),        		// output: data from cpu to memory   从mb寄存器 写入这个存储器
         .reg_sel(reg_sel),         // input:  register selection
         .reg_data(reg_data)        // output: register data
         );
		 
	*/
  
	
	input 			clock,resetn;		//时钟信号 
	input [31:0]	ins;				//外部输入 从这个IM指令存储器里面的来的 时钟信号 来临自动完成取指令操作
	input [31:0] 	mmo;				//写入存储器的数据  来自 取值的  mwmem = 1 是mmo才写入malu这个地址
	output[31:0] 	pc;					//输出信号 输出到外部的 IM操作（取指令）  
	output[31:0]	mb;					//写数据存储器   这个值作为输出 将写到这个数据存储器 
	output			mwmem;				//写信号   sw信号的写存储器信号
	output[31:0]    malu;  				//写寄存器的地址   malu作为计算出的存储器的地址
	input [4:0]		reg_sel;			//use for debug
	output[31:0]	reg_data;			//use for debug
	
	wire [31:0] ealu,walu;				//malu is output
	wire [31:0] bpc,jpc,npc,pc4,dpc4,inst,da,db,dimm,ea,eb,eimm;  
	wire [31:0] epc4,wmo,wdi;			//epc4 dpc4传的
	wire [4:0] 	drn,ern0,ern,mrn,wrn;	//写寄存器的目标寄存器号
	wire [3:0] 	daluc,ealuc;//daluc = ALUOp;
	wire [1:0] 	pcsource;	//pcsource 实例化于
	wire wpcir;				//写pc信号 和 写IR寄存器 在译码级确定这个值
	wire dwreg,dm2reg,dwmem,daluimm,dshift,djal;	//jal
	wire ewreg,em2reg,ewmem,ealuimm,eshift,ejal;
	wire mwreg,mm2reg;    //mwmem    写数据存储器信号   改为输出信号
	wire wwreg,wm2reg;
	
	/* IF级代码 */
	//实现NPC-->PC的代码    此外  由于此时 PC 有了值  就会在适中触发下去IM存储器去取指令ins;
	pipepc prog_cnt(.npc(npc),.wpc(wpcir),.clk(clock),.clrn(resetn),.pc(pc));	//将npc的信号给pc
	//module pipepc(npc,wpc,clk,clrn,pc);		//写PC模块
	
	
	pipeif if_stage(.pcsource(pcsource),.pc(pc),.bpc(bpc),.jpc(jpc),.rpc(da),.npc(npc),.pc4(pc4));	
	//module pipeif(pcsource,pc,bpc,jpc,rpc,npc,pc4);     注意 在jr $register 里面 ra在 da级别出现
	//计算npc的值 (npc在在下一个周期自然会再次将值赋值给pc的)  注意在jr ra这种指令时这个值在da里面第二周期里面即可获得
	//module pipeif(pcsource,pc,bpc,jpc,rpc,npc,pc4,ins);	//IF的组合电路   这里要确定NPC的值 
	//注意去除这个ins取出指令的操作实在pipelinedcpu操作的外部 完成的  取指令在NPC->PC 是就完成了
	
	/* ID级的代码 */
	
	pipeir inst_reg(.pc4(pc4),.ins(ins),.wir(wpcir),.clk(clock),.clrn(resetn),.dpc4(dpc4),.inst(inst));
	/* IF到ID的寄存器数据和指令过度*/  
	//module pipeir(pc4,ins,wir,clk,clrn,dpc4,inst);
	
	

	/* ID级的组合电路 */
	
	pipeid id_stage(.mwreg(mwreg),.mrn(mrn),.ern(ern),.ewreg(ewreg),.em2reg(em2reg),.mm2reg(mm2reg),
	.dpc4(dpc4),.inst(inst),.wrn(wrn),.wdi(wdi),.ealu(ealu),.malu(malu),.mmo(mmo),.wwreg(wwreg),
	.clk(clock),.clrn(resetn),.bpc(bpc),.jpc(jpc),.pcsource(pcsource),
	.nostall(wpcir),.wreg(dwreg),.m2reg(dm2reg),.wmem(dwmem),.ALUOp(daluc),.aluimm(daluimm),.a(da),.b(db),
	.imm(dimm),.rn(drn),.shift(dshift),.jal(djal),.reg_sel(reg_sel),.reg_data(reg_data));
	
	/*module pipeid (mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,wrn,wdi,ealu,
			malu,mmo,wwreg,clk,clrn,bpc,jpc,pcsource,nostall,wreg,
			m2reg,wmem,ALUOp,aluimm,a,b,imm,rn,shift,jal);
	*/
	

	pipedereg de_reg(dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,drn,dshift,djal,dpc4,clock,resetn,ewreg,em2reg,ewmem,
	ealuc,ealuimm,ea,eb,eimm,ern0,eshift,ejal,epc4);//主：输出ern0来自drn   ern = ern0 | {5{ejal}}  所以后期还要加一个MUX选择器  jalr
	/* module pipedereg(dwreg,dm2reg,dwmem,daluc,daluimm,da,db,
	dimm,drn,dshift,djal,dpc4,clk,clrn,ewreg,em2reg,ewmem,ealuc,ealuimm,
	ea,eb,eimm,ern,eshift,ejal,epc4); */
	
	/* exe计算ALUOUt的结果 */
	pipeexe exe_stage(ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu); //注输入ern0 输出 ern
	
	/* EXE MEM的流水线寄存器保存状态 */
	pipeemreg em_reg(ewreg,em2reg,ewmem,ealu,eb,ern,clock,resetn,mwreg,mm2reg,mwmem,malu,mb,mrn);

	/* 本机的取DM数据存储器指令 被转移在外部执行了 */
	
	// MEM/WB 寄存器电路 
	//在时钟的控制下完成 这一级流水线状态的保存
	//include:目标寄存器 写寄存堆信号 mm存储器数据信号 等
	pipemwreg mw_reg(mwreg,mm2reg,mmo,malu,mrn,clock,resetn,wwreg,wm2reg,wmo,walu,wrn);
	
	/* WB级组合电路确定 写回的数据 */
	//确当写回的操作的数据来源是哪儿 
	//walu 或者 wmo(from : mmo) 
	mux2 #(32) wb_stage(walu,wmo,wm2reg,wdi);  
	
endmodule