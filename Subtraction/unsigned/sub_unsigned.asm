	ORG 0H
	JMP START
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Subtraction of unsigned number
;input: 2 bytes: 76H 77H
;		2 bytes: 78H 79H
;output: C and 2bytes: 7AH 7BH
;Reg: A(have been protected), C
Subtraction:
	PUSH Acc;protect Acc
	CLR C;Clear C
	;subtraction of low 8 bits
	MOV A,77H
	SUBB A,79H
	MOV 7BH,A
	;subtraction of high 8 bits
	MOV A,76H
	SUBB A,78H
	MOV 7AH,A
	;
	POP Acc;get back Acc
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
	MOV 76H,#0FFH
	MOV 77H,#00H
	MOV 78H,#00H
	MOV 79H,#01H
	CALL Subtraction
	MOV A,7BH
	MOV P3,A
	MOV A,7AH
	MOV P2,A
	END

	