addi $3 ,$0,0xaa
addi $4 ,$0,0xbb
sw $3 0x64($1)   #0x00($1) = 0xaa
sw $4 0x68($0)   #0x04($0) = 0xbb
display:
      lw      $3, 0x64($1)	      # 23               8C
      #addi    $4, $1, 0x00
      andi    $3, $3, 0x100       #  test if bit 8 is 1                                                                    # 24               90
      beq     $3, $0, dispstuno   #  if bit 8 = 0, display the original stu no. if bit 8 = 1, display the sorted stu no.   # 25               94
      nop
dispsortedstuno:
      lw      $3, 0x68($0)        #  load the sorted student no.
      #addi    $5, $0, 0x04	  #  26               98
      j       displayseg7label                                                                                             # 27               9C
      nop
dispstuno:
      lw      $3, 0x64($0)        #  load the orginal student no.  
      addi    $6, $0, 0x00
displayseg7label: 
      sw      $3,  0x00($2)       #  output to seg7
      #addi    $7,  $2,0x00                                                                        # 29               A4
      j       display                                                                                                      # 2A               A8
      nop
