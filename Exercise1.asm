	lui   s1,0xFFFFF
	addi a1,x0,1		# 加指令
	addi a2,x0,2		# 减指令
	addi a3,x0,3		# 与指令
	addi a4,x0,4		# 或指令
	addi a5,x0,5		# 左移指令
	addi a6,x0,6		# 右移指令
	addi a7,x0,7		# 乘指令
switled:                        
	lw   s0,0x70(s1)	# read switch
	# 分解指令
	srli s2,s0,0x15		# s2存运算类型:SW[23:21]
	andi s3,s0,0x000FF	# s3存操作数A:SW[7:0]
	srli s4,s0,8
	andi s4,s4,0x000FF	# s4存操作数B:SW[15:8]
	add s0,x0,x0		# 清空s0
	# 不同运算类型
	beq  s2,a1,madd
	beq  s2,a2,msub
	beq  s2,a3,mand
	beq  s2,a4,mor
	beq  s2,a5,mleft
	beq  s2,a6,mright
	beq  s2,a7,mmult
opBack:	
	sw   s0,0x60(s1)	# write led	
    	sw   s0,0x00(s1)	
	jal switled
	
madd:				# 加
	add s0,s3,s4
	andi s0,s0,0xff
	jal opBack
	
msub:				# 减
	sub s0,s3,s4
	andi s0,s0,0xff
	jal opBack
	
mand:				# 与
	and s0,s3,s4
	jal opBack
	
mor:				# 或
	or s0,s3,s4
	jal opBack
	
mleft:				# 左移
	sll s0,s3,s4
	andi s0,s0,0xff
	jal opBack
	
mright:				# 右移
	addi s5,x0,0		# 计数变量
	andi s6,s3,0x80		# A的符号位
	add s0,s3,x0		
RLOOP:
	bge s5,s4,REXIT
	srli s0,s0,1
	beq s6,x0,RJUMP		#若符号位为0，只右移
	addi s0,s0,0x80		#若符号位为1，右移后符号位为1
RJUMP:	
	addi s5,s5,1
	jal RLOOP
REXIT:	jal opBack

mmult:				# 乘法，通过Booth算法实现
	addi s5,x0,0		# 循环计数变量
	addi s6,x0,7
	andi s7,s3,0x80		# A的符号位
	andi s8,s4,0x80		# B的符号位
	sub s3,s3,s7		# A的数值
	sub s4,s4,s8		# B的数值
MLOOP:	
	bge s5,s6,EXIT		# 循环7次
	andi s9,s4,1		# s9取s4的最后一位
	beq s9,x0,MJUMP		# 若为0，不加A
	add s0,s0,s3		# 若为1，加A
MJUMP:	
	slli s3,s3,1		# A左移一位，等价于部分积右移
	srli s4,s4,1		# B右移一位
	addi s5,s5,1		# 计数+1
	jal MLOOP
EXIT:	
	xor s7,s7,s8
	slli s7,s7,7
	add s0,s0,s7
	jal opBack