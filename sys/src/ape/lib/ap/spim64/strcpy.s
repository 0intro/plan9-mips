TEXT	strcpy(SB), $0

	MOVV	s2+8(FP),R2		/* R2 is from pointer */
	MOVV	R1, R3			/* R3 is to pointer */

/*
 * align 'from' pointer
 */
l1:
	AND	$3, R2, R5
	ADDVU	$1, R2
	BEQ	R5, l2
	MOVB	-1(R2), R5
	ADDVU	$1, R3
	MOVB	R5, -1(R3)
	BNE	R5, l1
	RET

/*
 * test if 'to' is also alligned
 */
l2:
	AND	$3,R3, R5
	BEQ	R5, l4

/*
 * copy 4 at a time, 'to' not aligned
 */
l3:
	MOVW	-1(R2), R4
	ADDVU	$4, R2
	ADDVU	$4, R3
	AND	$0xff,R4, R5
	MOVB	R5, -4(R3)
	BEQ	R5, out

	SRL	$8,R4, R5
	AND	$0xff, R5
	MOVB	R5, -3(R3)
	BEQ	R5, out

	SRL	$16,R4, R5
	AND	$0xff, R5
	MOVB	R5, -2(R3)
	BEQ	R5, out

	SRL	$24,R4, R5
	MOVB	R5, -1(R3)
	BNE	R5, l3

out:
	RET

/*
 * word at a time both aligned
 */
l4:
	MOVW	$0xff000000, R7
	MOVW	$0x00ff0000, R8

l5:
	ADDVU	$4, R3
	MOVW	-1(R2), R4	/* fetch */

	ADDVU	$4, R2
	AND	$0xff,R4, R5	/* is it byte 0 */
	AND	$0xff00,R4, R6	/* is it byte 1 */
	BEQ	R5, b0

	AND	R8,R4, R5	/* is it byte 2 */
	BEQ	R6, b1

	AND	R7,R4, R6	/* is it byte 3 */
	BEQ	R5, b2

	MOVW	R4, -4(R3)	/* store */
	BNE	R6, l5
	JMP	out

b0:
	MOVB	$0, -4(R3)
	JMP	out

b1:
	MOVB	R4, -4(R3)
	MOVB	$0, -3(R3)
	JMP	out

b2:
	MOVH	R4, -4(R3)
	MOVB	$0, -2(R3)
	JMP	out
