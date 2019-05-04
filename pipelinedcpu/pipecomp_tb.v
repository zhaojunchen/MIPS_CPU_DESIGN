
// testbench for simulation
module pipecomp_tb();
    
   reg  clk, rstn;
   reg  [4:0] reg_sel;
   wire [31:0] reg_data;
    
// instantiation of pipescom    
   pipecomp U_PIPECOMP(
      .clk(clk), .rstn(rstn), .reg_sel(reg_sel), .reg_data(reg_data) 
   );

  	integer foutput;
  	integer counter = 0;
   
   initial begin
      $readmemh( "./test/test.dat" , U_PIPECOMP.U_IM.ROM); // load instructions into instruction memory
      //$monitor("PC = 0x%8X, instr = 0x%8X", U_PIPECOMP.PC, U_PIPECOMP.instr); // used for debug
      foutput = $fopen("results.txt");
      clk = 1;
      rstn = 1;
      #5 ;
      rstn = 0;
      #20 ;
      rstn = 1;
      #1000 ;
      reg_sel = 7;
   end
   
    always begin
    #(50) clk = ~clk;
	   
    if (clk == 1'b1) begin
      if ((U_PIPECOMP.U_PIPECPU.pc === 32'hxxxxxxxx)) begin
        $fclose(foutput);
        $stop;
      end
      else begin
        if (U_PIPECOMP.PC == 32'h000000ff) begin
          counter = counter + 1;
          $fdisplay(foutput, "pc:\t %h", U_PIPECOMP.PC);
          $fdisplay(foutput, "instr:\t\t %h", U_PIPECOMP.instr);
          $fdisplay(foutput, "rf00-03:\t %h %h %h %h", 0, U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[1], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[2], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[3]);
          $fdisplay(foutput, "rf04-07:\t %h %h %h %h", U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[4], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[5], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[6], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[7]);
          $fdisplay(foutput, "rf08-11:\t %h %h %h %h", U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[8], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[9], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[10], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[11]);
          $fdisplay(foutput, "rf12-15:\t %h %h %h %h", U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[12], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[13], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[14], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[15]);
          $fdisplay(foutput, "rf16-19:\t %h %h %h %h", U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[16], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[17], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[18], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[19]);
          $fdisplay(foutput, "rf20-23:\t %h %h %h %h", U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[20], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[21], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[22], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[23]);
          $fdisplay(foutput, "rf24-27:\t %h %h %h %h", U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[24], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[25], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[26], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[27]);
          $fdisplay(foutput, "rf28-31:\t %h %h %h %h", U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[28], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[29], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[30], U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf[31]);
          //$fdisplay(foutput, "hi lo:\t %h %h", U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf.hi, U_PIPECOMP.U_PIPECPU.id_stage.U_RF.rf.lo);
          $fclose(foutput);
          $stop;
        end
        else begin
          counter = counter + 1;
		  $display("\ncounter: %d", counter);
          $display("pc: %h", U_PIPECOMP.U_PIPECPU.pc);
          $display("instr: %h", U_PIPECOMP.U_PIPECPU.ins);
		  $display("--------------------------");
		  
        end
      end
    end
  end //end always
   
endmodule
