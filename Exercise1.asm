	lui   s1,0xFFFFF
	addi a1,x0,1		# ��ָ��
	addi a2,x0,2		# ��ָ��
	addi a3,x0,3		# ��ָ��
	addi a4,x0,4		# ��ָ��
	addi a5,x0,5		# ����ָ��
	addi a6,x0,6		# ����ָ��
	addi a7,x0,7		# ��ָ��
switled:                        
	lw   s0,0x70(s1)	# read switch
	# �ֽ�ָ��
	srli s2,s0,0x15		# s2����������:SW[23:21]
	andi s3,s0,0x000FF	# s3�������A:SW[7:0]
	srli s4,s0,8
	andi s4,s4,0x000FF	# s4�������B:SW[15:8]
	add s0,x0,x0		# ���s0
	# ��ͬ��������
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
	
madd:				# ��
	add s0,s3,s4
	andi s0,s0,0xff
	jal opBack
	
msub:				# ��
	sub s0,s3,s4
	andi s0,s0,0xff
	jal opBack
	
mand:				# ��
	and s0,s3,s4
	jal opBack
	
mor:				# ��
	or s0,s3,s4
	jal opBack
	
mleft:				# ����
	sll s0,s3,s4
	andi s0,s0,0xff
	jal opBack
	
mright:				# ����
	addi s5,x0,0		# ��������
	andi s6,s3,0x80		# A�ķ���λ
	add s0,s3,x0		
RLOOP:
	bge s5,s4,REXIT
	srli s0,s0,1
	beq s6,x0,RJUMP		#������λΪ0��ֻ����
	addi s0,s0,0x80		#������λΪ1�����ƺ����λΪ1
RJUMP:	
	addi s5,s5,1
	jal RLOOP
REXIT:	jal opBack

mmult:				# �˷���ͨ��Booth�㷨ʵ��
	addi s5,x0,0		# ѭ����������
	addi s6,x0,7
	andi s7,s3,0x80		# A�ķ���λ
	andi s8,s4,0x80		# B�ķ���λ
	sub s3,s3,s7		# A����ֵ
	sub s4,s4,s8		# B����ֵ
MLOOP:	
	bge s5,s6,EXIT		# ѭ��7��
	andi s9,s4,1		# s9ȡs4�����һλ
	beq s9,x0,MJUMP		# ��Ϊ0������A
	add s0,s0,s3		# ��Ϊ1����A
MJUMP:	
	slli s3,s3,1		# A����һλ���ȼ��ڲ��ֻ�����
	srli s4,s4,1		# B����һλ
	addi s5,s5,1		# ����+1
	jal MLOOP
EXIT:	
	xor s7,s7,s8
	slli s7,s7,7
	add s0,s0,s7
	jal opBack