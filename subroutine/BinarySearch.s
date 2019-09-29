;***************************************************************
; Program BinarySearch.s

; This program guesses decimal numbers using binary search method.
; The number is to be an integer in the range (0; 2n), i.e. 
; 0 < number < 2n, where n < 32 and n is determined by a user-input.
;*************************************************************** 
; EQU Directives
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENTs
FIRST		EQU			0x20006000
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
            AREA 		main, READONLY, CODE
            THUMB
			EXTERN		CONVRT		; Reference external subroutines
			EXTERN		UPBND		;
			EXTERN 		InChar		;
            EXPORT 		__main	  	; Make available

__main 		MOV			R6,#2		; R6 <- 2	
			MOV			R2,#10		; R2 <- 10
get			BL			InChar		; read first digit of n
			CMP			R5,#0x20	;
			BEQ			complete
			SUB			R5,#0x30	;			
			MUL			R0,R2		;
			ADD			R0,R5		;
			B			get

complete	MOV			R5,R0	
						
			MOV			R2,#1	
loop1		MUL			R2,R6		; R2 <- 2^n
			SUBS		R5,#1		; n--
			BNE			loop1
			
			SUB			R2,#1		; R2 <- HIGH		
			MOV			R1,#1		; R1 <- LOW
			MOV			R0,#2		; R0 <- starting state
			
guess		PUSH		{LR}		; put LR into the stack
			BL 			UPBND		; update search boundaries
			POP			{LR}	
			MOV			R7,R3
			PUSH		{LR}		; put LR into the stack
			BL 			CONVRT		; convert decimal and print
			POP			{LR}		; get LR from the stack
			
			BL			InChar		; get the feedback U, D or C	
			
			CMP			R5,#0x43	; check C
			BEQ			done
			CMP			R5,#0x44	; check D
			BNE			U
			MOV			R0,#0x0
			B			guess
U			CMP			R5,#0x55	; check U
			BNE			__main
			MOV			R0,#0x1
			B			guess
			
done		B 			done							
			END