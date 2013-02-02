	ORG 0H
	JMP START
;;;;;;;;;;;;;;;;;;;;;;;;;
;Division for unsigned integer
;input: 16 bits: 64H 65H
;        8 bits: 66H
;output: quotient: 67H 68H
;        remainder: 69H
;Reg: A(has been protected), B(has been protected), C, 6AH
division:
	PUSH Acc;protect Acc
	PUSH B;protect B
	CLR C;clear C
	;clear result
	MOV 67H,#0
	MOV 68H,#0
	MOV 69H,#0
	MOV 70H,#0
	MOV 6BH,#0
	;division for high 8 bits
	MOV A,66H
	MOV B,A
	MOV A,64H
	DIV AB
	;quotient go to high quotient of final result
	MOV 67H,A
	;remiander go to remainder of final result
	MOV A,B
	MOV 69H,A
	;begin 8 times of loop
	MOV 6AH,#8
division_loop:
	;rotate 65H left with C
	MOV A,65H
	RLC A
	MOV 65H,A
	;rotate 69H left with C
	MOV A,69H
	RLC A
	MOV 69H,A;result -> rotate 69H and 65H left together with C
	;69H - 66H
	CLR C
	MOV A,69H
	SUBB A,66H;if negative C=1, otherwise C=0. Result in A
	;
	JC division_quotient_set_0;if C=1, go to division_quotient_set_0
division_quotient_set_1:;if C=0, go down
	MOV 69H,A;sub result go to 69H
	;most right bit of 68H set 1
	SETB C
	MOV A,68H
	RLC A
	MOV 68H,A
	;go to dicision
	JMP division_loop_dicision
division_quotient_set_0:;if C=1, go down
	;most right bit of 68H set 0
	CLR C
	MOV A,68H
	RLC A
	MOV 68H,A
division_loop_dicision:
	DEC 6AH
	MOV A,6AH
	CJNE A,#0,division_loop
	;
	POP B;get back B
	POP Acc;get back Acc
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
START:
	MOV P2,#0
	MOV P3,#0
	MOV P1,#0
	MOV 64H,#46H
	MOV 65H,#01H
	MOV 66H,#2AH
	CALL division
	MOV A,68H
	MOV P2,A
	MOV A,67H
	MOV P3,A
	END