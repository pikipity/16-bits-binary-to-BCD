	ORG 0H
	JMP START
	ORG 0BH;use timer 0
	JMP DISPLAY
	ORG 30H;avoid interval address
	MOV SP,#30H
;;;;;;;;;;;;;;;;;;;;;;;;;;
;Display five 7-seg LEDs
;note: the most left LED is number 1
;input: 5FH, 5EH, 5DH, 5CH, 5BH
;output: P2.0, P2.1, P2.2 -> choose LED
;        P1 -> display
;REG: A (has been protect), DPTR, 5AH
DISPLAY:
	PUSH Acc
	;choose LED
	MOV A,5AH
	MOV P2,A
	;choose number
	MOV A,5AH
	CJNE A,#0,next1
display0:
	MOV A,5FH
	MOVC A,@A+DPTR
	MOV P1,A
	JMP display_end
next1:
	CJNE A,#1,next2
display1:
	MOV A,5EH
	MOVC A,@A+DPTR
	MOV P1,A
	JMP display_end
next2:
	CJNE A,#2,next3
display2:
	MOV A,5DH
	MOVC A,@A+DPTR
	MOV P1,A
	JMP display_end
next3:
	CJNE A,#3,next4
display3:
	MOV A,5CH
	MOVC A,@A+DPTR
	MOV P1,A
	JMP display_end
next4:
	CJNE A,#4,display_end
display4:
	MOV A,5BH
	MOVC A,@A+DPTR
	MOV P1,A
	JMP display_end
display_end:
	MOV A,5AH
	CJNE A,#4,add_5AH
	JMP clear_5AH
clear_5AH:
	MOV 5AH,#0
	JMP displayend
add_5AH:
	INC 5AH
	JMP displayend
	;
displayend:
	MOV TL0,#low (65536-0)
	MOV TH0,#high (65536-0)
	POP Acc
	RETI		
;table of LED
table:
	DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
START:
;;;;;;;;;;;;;;;;;;;;;;;;;;
;Display initial
	MOV P1,#0
	MOV P2,#0FFH
	MOV 5AH,#0
	MOV DPTR,#table
;;;;;;;;;;;;;;;;;;;;;;;;;;
;Timer initial
	MOV TMOD,#1;use timer 0 mode 1
	MOV TL0,#low (65536-50000)
	MOV TH0,#high (65536-50000)
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interval initial
	SETB ET0;start timer0 interval
	;
	SETB EA;start interval
	SETB TR0;start timing
	MOV 5FH,#1
	MOV 5EH,#2
	MOV 5DH,#3
	MOV 5CH,#4
	MOV 5BH,#5
STOP:
	JMP STOP
	END	