addi $2, $0, 1      # initialize $2 = 5    0       20020005
addi $3, $0, 4     # initialize $3 = 12   4       2003000c
addi $4 ,$0,0x14
jalr $4            #  $32  = 0xc
addi $22,$0,22     # not taken
addi $23,$0,23     #taken
jr $ra



 