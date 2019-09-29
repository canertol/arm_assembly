;***************************************************************
; Program main.s
; This program, in an infinite loop, waits for a user prompt 
; (any key to be pressed) and prints the decimal equivalent of
; the number stored in 4 bytes starting from the memory location NUM.
;*************************************************************** 
; EQU Directives
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
NUM		  	EQU     	0x20005000   
X			EQU			0x05F5E100 	; 10^9 in decimal
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
            AREA 		main, READONLY, CODE
            THUMB
			EXTERN		CONVRT		; Reference external subroutines
			EXTERN 		InChar		;
            EXPORT 		__main	  	; Make available

__main 		MOV			R5,#0x0		; Initialization of the registers
			MOV			R6,#0x0		;
			
			LDR			R7,=NUM		; R7 <- memory location of the number
			LDR			R0,=X		; R0 <- number
			STR			R0,[R7]		; store the number in the address NUM
			
get 		BL			InChar		; infinite loop waitin for input
			CMP			R5,R6		; check the input
			BNE			continue	; break the loop
			B 			get
				
continue	

			LDR			R7,[R7]
			PUSH		{LR}		; put LR into the stack
			BL 			CONVRT		; convert decimal and print
			POP			{LR}		; get LR from the stack
			MOV			R5,#0x0
			
			B 			__main
			
			ALIGN
			END