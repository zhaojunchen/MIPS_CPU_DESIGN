addi $1,$0,0x1234
addi $2 ,$0,0x3
sll $5,$1,0x2
srl $6,$1,0x2
sllv $3,$1,$2
srlv $4,$1,$2
#$1 = 0x1234 $2 = 0x2   $3 = 0x000048d0 $4 = 0x0000048d
	