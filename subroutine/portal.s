;***************************************************************
; Program portal.s

; This program guesses decimal numbers using binary search method.
; The number is to be an integer in the range (0; 2n), i.e. 
; 0 < number < 2n, where n < 32 and n is determined by a user-input.
;*************************************************************** 
; EQU Directives

;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENTs
FIRST		EQU			0x20006000
DIVISOR		EQU			1000000000  ;0x3B9ACA00
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
            AREA 		main, READONLY, CODE
            THUMB
			EXTERN		CONVRT		; Reference external subroutines
			EXTERN 		InChar		;
            EXPORT 		__main	  	; Make available

__main 		
			MOV			R8,#10		; R2 <- 10
get			BL			InChar		; read first digit of n
			CMP			R5,#0x20	;
			BEQ			complete
			SUB			R5,#0x30	;			
			MUL			R0,R8		;
			ADD			R0,R5		;
			B			get

complete	MOV			R5,R0	
			MOV			R6,R5
			MOV			R12,R5
start		
portal1		MOV			R1,#0
			CMP 		R5,#100		; Check PORTAL 1
			BMI			portal2		; R5<0?
			MOV			R1,#1		; PORTAL 1 available!

			
portal2		MOV			R2,#0
			CMP			R5,#51		; Check PORTAL 2
			BMI			portal3		; R5<0?
			UBFX 		R0,R5,#0,#1 ; R0 <- LSB of R5
			CMP			R0,#1		; R5 % 2 = 1?
			BNE			portal3
			MOV			R2,#1		; PORTAL 2 available!
			

portal3		MOV			R3,#0
			UBFX 		R0,R5,#0,#1 ; R0 <- LSB of R5
			CMP			R0,#0		; Check PORTAL 3
			BNE			portal4		; R5 % 2 = 0?
			MOV			R3,#1		; PORTAL 3 available!
			
			
portal4		MOV			R4,#0
			MOV			R0,#7		; Check PORTAL 4
			UDIV		R0,R5,R0	; 
			MOV			R8,#7
			MUL			R0,R8		; 
			CMP			R0,R5		; R5 % 7 = 0?
			BNE			check1		;
			MOV			R4,#1		; PORTAL 4 available!
			
check1		ADD			R0,R1,R2
			ADD			R0,R3
			ADD			R0,R4
			CMP			R0,#0
			BNE			check2
			CMP			R5,R6
			BPL			finish
			MOV			R6,R5
			B			finish
check2		CMP			R5,#0
			BNE			choose
			MOV			R6,R5
			B			finish
			
choose		CMP 		R1,#1
			BNE			skip1
			PUSH		{R5}
			SUB			R5,#47
			MOV			R1,#0
			B			other_turn

skip1		CMP			R2,#1
			BNE			skip2
			PUSH		{R5}
			LDR			R0,=DIVISOR
			MOV			R8,#0
			MOV			R9,#10
			MOV			R10,#1
LOOP		UDIV		R7,R5,R0	; R7 <- R5 % DIVISOR
			SUBS		R11,R7,R8		; remove higher order digits
			CMP			R11,#0		;
			BEQ			jump		;
			MUL			R10,R11		;
jump		MUL			R8,R7,R9	; higher order digits				
			UDIV		R0,R9		; DIVISOR <- DIVISOR/10 for the next integer
			CMP			R0,#0
			BNE			LOOP
			SUB			R5,R10
			MOV			R2,#0
			B			other_turn
						
skip2		CMP			R3,#1
			BNE			skip3
			MOV			R0,#2
			PUSH		{R5}
			UDIV		R5,R0
			MOV			R3,#0
			B			other_turn

skip3		CMP			R4,#1
			BNE			finish
			MOV			R0,#3
			UDIV		R11,R5,R0
			MUL			R11,R0
			PUSH		{R5}
			SUB			R5,R11
			MOV			R4,#0
			B			other_turn

other_turn	PUSH		{R0-R4}
			PUSH		{LR}
			BL			start
			POP			{LR}
			POP			{R0-R5}
			B			choose
			
finish		CMP			R12,R5
			BEQ			output
			BX			LR
			
output		MOV			R7,R6
			BL			CONVRT
			
			B			__main

			END