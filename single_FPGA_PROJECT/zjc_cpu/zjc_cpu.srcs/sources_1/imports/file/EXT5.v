
module EXT5( Imm_5, EXTOp_5, Imm32_5 );
    
   input  [4:0] Imm_5;
   input         EXTOp_5;
   output [31:0] Imm32_5;
   
   assign Imm32_5 = (EXTOp_5) ? {{27{Imm_5[4]}}, Imm_5} : {27'd0, Imm_5}; // signed-extension or zero extension  
   //from 5 imm to 32 imm
       
endmodule
