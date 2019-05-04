module pipecomp(clk, rstn, reg_sel, reg_data);
   input          clk;
   input          rstn;
   input [4:0]    reg_sel;
   output[31:0]  reg_data;
   
   wire [31:0]    instr;
   wire [31:0]    PC;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout;
   
   //wire rst = ~rstn;  一直使用 rstn
       
  // instantiation of single-cycle CPU   
   pipelinedcpu U_PIPECPU(
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
		 

         
  // instantiation of data memory  
   dm    U_DM(
         .clk(clk),           // input:  cpu clock
         .DMWr(MemWrite),     // input:  ram write
         .addr(dm_addr[8:2]), // input:  ram address
         .din(dm_din),        // input:  data to ram
         .dout(dm_dout)       // output: data from ram
         );
         
  // instantiation of intruction memory (used for simulation)
   im    U_IM ( 
      .addr(PC[8:2]),     // input:  rom address
      .dout(instr)        // output: instruction
   );
        
endmodule


