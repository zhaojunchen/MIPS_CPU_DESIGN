addi $1,$0,0x1234
addi $2,$0,0x4321
bne  $1,$2,L
addi $5,$0,5
j L2
L:
addi $4,$0,4

L2:
j L2

#$1 = 0x1234
#$2 = 0x4321
#$4 = 4
#$5 =NULL
