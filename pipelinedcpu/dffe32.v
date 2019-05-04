module dffe32(A,clk,clrn,AtoB_ControlSignal,B); 
	input [31:0] 	A;
	input 			clk,clrn,AtoB_ControlSignal;
	output reg[31:0]B;
	
	always @(negedge clrn or posedge clk)
		if(clrn == 0)  begin
			B <= 0;
		end else begin
			if(AtoB_ControlSignal) B <= A;
		end
endmodule