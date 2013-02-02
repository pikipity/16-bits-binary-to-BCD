	ORG 0H
	JMP START
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Multiplication of unsigned number
;input: 16 bits: 7CH 7DH
;        8 bits:     7FH
;output 24 bits: 60H 61H 62H
;REG:A(have been protected), B(have been protected), 63H, C
Multi:
	PUSH Acc;protect Acc
	PUSH B;protect B
	;Multiply low 8 bits
	MOV A,7DH
	MOV B,A
	MOV A,7FH
	MUL AB
	MOV 62H,A
	MOV A,B
	MOV 61H,A
	;Multiply high 8 bits
	MOV A,7CH
	MOV B,A
	MOV A,7FH
	MUL AB
	MOV 63H,A
	MOV A,B
	MOV 60H,A
	;Summation center 8 bits
	CLR C
	MOV A,63H
	ADD	A,61H
	MOV 61H,A
	;Add C and high 8 bits
	MOV A,60H
	ADDC A,#0
	MOV 60H,A
	;
	POP B;back B
	POP Acc;back Acc
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
	MOV 7CH,#10H
	MOV 7DH,#0EFH
	MOV 7FH,#0CDH
	CALL MULTI
	MOV A,60H
	MOV P1,A
	MOV A,61H
	MOV P2,A
	MOV A,62H
	MOV P3,A
	END