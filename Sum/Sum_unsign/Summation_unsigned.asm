	ORG 0H
	JMP START
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;sumation of unsigned number
;input: 16 bits: 70H 71H
;       16 bits: 72H 73H
;output: C and 16 bits 74H 75H
;Reg: A (have been protected), C
SUM_unsigned:
	PUSH Acc;protect Acc
	CLR C;clear C
	;Add low 8 bits
	MOV A,71H
	ADDC A,73H
	MOV 75H,A
	;Add high 8 bits and C
	MOV A,70H
	ADDC A,72H
	MOV 74H,A
	; 
	POP Acc;return Acc
	RET
	
START:
	MOV 70H,#3AH
	MOV 71H,#9FH
	MOV 72H,#0FFH
	MOV 73H,#0EFH
	CALL SUM_unsigned
	MOV A,75H
	MOV P3,A
	MOV A,74H
	MOV P2,A
	END