	ORG 0H
	JMP START
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;display hex to 7 seg LED
;input: 51H 52H
;output: P0,P2,P3,P1
;Reg: A (has been protected), DPTR
DISPLAY:
	MOV DPTR,#table
	MOV A,52H
	ANL A,#0FH
	MOVC A,@A+DPTR
	MOV P1,A
	MOV A,52H
	RR A
	RR A
	RR A
	RR A
	ANL A,#0FH
	MOVC A,@A+DPTR
	MOV P3,A
	MOV A,51H
	ANL A,#0FH
	MOVC A,@A+DPTR
	MOV P2,A
	MOV A,51H
	RR A
	RR A
	RR A
	RR A
	ANL A,#0FH
	MOVC A,@A+DPTR
	MOV P0,A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;sumation of unsigned number
;input: 16 bits: 70H 71H
;       16 bits:     73H
;output: C and 16 bits 74H 75H
;Reg: A (have been protected), C
Sum:
	PUSH Acc;protect Acc
	CLR C;clear C
	;Add low 8 bits
	MOV A,71H
	ADDC A,73H
	MOV 75H,A
	;Add high 8 bits and C
	MOV A,70H
	ADDC A,#0
	MOV 74H,A
	; 
	POP Acc;return Acc
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Subtraction of unsigned number
;input: 2 bytes: 76H 77H
;		2 bytes:     79H
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
	SUBB A,#0
	MOV 7AH,A
	;
	POP Acc;get back Acc
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Convert a 16 bits binary to BCD code
;input: 6BH,6CH
;output: 6DH,6EH,6FH
;Reg: A(have been protected), B(have been protected), C, 50H
;Using devision subroutine
convert:
	PUSH Acc;protect Acc
	PUSH B;protect B
	;clear result
	MOV 6DH,#0
	MOV 6EH,#0
	MOV 6FH,#0
	;division input with 10.
	MOV 66H,#10
	MOV A,6CH
	MOV 65H,A
	MOV A,6BH
	MOV 64H,A
	CALL division
	;quotient -> 6BH,6CH to next division
	MOV A,68H
	MOV 6CH,A
	MOV A,67H
	MOV 6BH,A
	;remainder -> low 6FH
	MOV A,69H
	MOV 6FH,A
	;division 6BH,6CH with 10
	MOV 66H,#10
	MOV A,6CH
	MOV 65H,A
	MOV A,6BH
	MOV 64H,A
	CALL division
	;quotient -> 6BH,6CH to next division
	MOV A,68H
	MOV 6CH,A
	MOV A,67H
	MOV 6BH,A
	;remainder -> high 6FH
	MOV 50H,#4
turn_left_4_6F:
	MOV A,69H
	ADD A,69H
	MOV 69H,A
	DEC 50H
	MOV A,50H
	CJNE A,#0, turn_left_4_6F
	MOV A,69H
	ADD A,6FH
	MOV 6FH,A
	;division 6BH,6CH with 10
	MOV 66H,#10
	MOV A,6CH
	MOV 65H,A
	MOV A,6BH
	MOV 64H,A
	CALL division 
	;quotient -> 6BH,6CH to next division
	MOV A,68H
	MOV 6CH,A
	MOV A,67H
	MOV 6BH,A
	;remainder -> low 6EH
	MOV A,69H
	MOV 6EH,A
	;division 6BH,6CH with 10
	MOV 66H,#10
	MOV A,6CH
	MOV 65H,A
	MOV A,6BH
	MOV 64H,A
	CALL division 
	;quotient -> 6BH,6CH to next division
	MOV A,68H
	MOV 6CH,A
	MOV A,67H
	MOV 6BH,A
	;remainder -> high 6EH
	MOV 50H,#4
turn_left_4_6E:
	MOV A,69H
	ADD A,69H
	MOV 69H,A
	DEC 50H
	MOV A,50H
	CJNE A,#0, turn_left_4_6E
	MOV A,69H
	ADD A,6EH
	MOV 6EH,A
	;division 6BH,6CH with 10
	MOV 66H,#10
	MOV A,6CH
	MOV 65H,A
	MOV A,6BH
	MOV 64H,A
	CALL division 
	;quotient -> 6BH,6CH to next division
	MOV A,68H
	MOV 6CH,A
	MOV A,67H
	MOV 6BH,A
	;remainder -> low 6DH
	MOV A,69H
	MOV 6DH,A
	;division 6BH,6CH with 10
	MOV 66H,#10
	MOV A,6CH
	MOV 65H,A
	MOV A,6BH
	MOV 64H,A
	CALL division 
	;quotient -> 6BH,6CH to next division
	MOV A,68H
	MOV 6CH,A
	MOV A,67H
	MOV 6BH,A
	;remainder -> high 6DH
	MOV 50H,#4
turn_left_4_6D:
	MOV A,69H
	ADD A,69H
	MOV 69H,A
	DEC 50H
	MOV A,50H
	CJNE A,#0, turn_left_4_6D
	MOV A,69H
	ADD A,6DH
	MOV 6DH,A
	;
	POP B;get back B
	POP Acc;get back A	
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
START:
;;;;;;;;;;;;;;;;;;;;;;;;;;
;Display initial
	MOV P0,#0
	MOV P1,#0
	MOV P2,#0
	MOV P3,#0
;;;;;;;;;;;;;;;;;;;;;;;;;;
	;begin calculation
	;41797+187=41984
	 MOV 70H,#high 41797
	 MOV 71H,#low 41797
	 MOV 73H,#187
	 CALL Sum
	 ;41984/86=488...18
	 MOV A,74H
	 MOV 64H,A
	 MOV A,75H
	 MOV 65H,A
	 MOV 66H,#86
	 CALL division
	 ;488-232=256
	 MOV A,67H
	 MOV 76H,A
	 MOV A,68H
	 MOV 77H,A
	 MOV 79H,#232
	 CALL Subtraction
	 ;256*210=53760
	 MOV A,7AH
	 MOV 7CH,A
	 MOV A,7BH
	 MOV 7DH,A
	 MOV 7FH,#210
	 CALL Multi
	 ;53760-156=53604
	 MOV A,61H
	 MOV 76H,A
	 MOV A,62H
	 MOV 77H,A
	 MOV 79H,#156
	 CALL Subtraction
	 ;53604/57=940...24
	 MOV A,7AH
	 MOV 64H,A
	 MOV A,7BH
	 MOV 65H,A
	 MOV 66H,#57
	 CALL division
	 ;940+53=993
	 MOV A,67H
	 MOV 70H,A
	 MOV A,68H
	 MOV 71H,A
	 MOV 73H,#53
	 CALL Sum
	 ;993*56=55608
	 MOV A,74H
	 MOV 7CH,A
	 MOV A,75H
	 MOV 7DH,A
	 MOV 7FH,#56
	 CALL Multi
	;begin display
	MOV A,62H
	MOV 52H,A
	MOV A,61H
	MOV 51H,A
	CALL display
STOP:
	JMP STOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Table of LED
table:
	DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH,39H,5EH,79H,71H
	END	