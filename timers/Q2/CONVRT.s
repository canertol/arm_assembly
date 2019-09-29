;***************************************************************
; Program CONVRT.s
;***************************************************************
;SYMBOL		DIRECTIVE	VALUE			COMMENT
DIVISOR		EQU			1000000000      ;0x3B9ACA00
RESERVED	EQU			0x20004000	
TEN			EQU			0xA
;***************************************************************
; Program section
;***************************************************************
;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		main, READONLY, CODE
            THUMB
			EXTERN 		OutStr			; Reference external subroutine	
            EXPORT 		CONVRT			; Make available
				
CONVRT 	 	PUSH		{R0-R6,R8-R12}	; store registers
			LDR			R0,=DIVISOR		; Initialization of registers
			LDR			R5,=RESERVED	;
			MOV			R3,#0x0
			MOV			R4,#0x0
			MOV			R2,#0xA
			
zeros		UDIV		R1,R7,R0		; R1 <- R7 % R0*
			SUBS		R6,R1,R4		; remove higher order digits
			ADD			R6,#0x30		; Convert R6 into ascii code
			CMP			R6,#0x30		; check if R6 is zero
			BEQ			jump			; go to nonzero if the first nonzero entry comes
			MOV			R8,R5
			B			ignore
jump		MOV			R6,#0x20		; R6 <- SPACE
			STRB		R6,[R5],#1		; Store R6 to memory
			MUL			R4,R1,R2		; higher order digits	
			UDIV		R0,R2			; DIVISOR <- DIVISOR/10 for the next integer
			CMP			R0,#0			
			BNE			zeros
			SUB			R5,#2
			MOV			R8,R5
nonzero		UDIV		R1,R7,R0		; R1 <- R4 % R0*
			SUBS		R6,R1,R4		; remove higher order digits
			ADD			R6,#0x30		; Convert into ascii code
ignore		STRB		R6,[R5],#1		
			MUL			R4,R1,R2		; higher order digits				
			UDIV		R0,R2			; DIVISOR <- DIVISOR/10 for the next integer
			CMP			R0,#0			
			BNE			nonzero
			MOV 		R0,#0x04		; end of the string
			STRB		R0,[R5]
			MOV			R5,R8			; restore R5
			PUSH		{LR}
			BL			OutStr			; Print the integer
			POP			{LR}
			
			POP			{R0-R6,R8-R12}	; restore registers*
			BX  		LR				; Return to caller
				
				
			ALIGN                       ; make sure the end of this section is aligned
			END                         ; end of file