;***************************************************************
; Program BCD.s
; This program converts the hex value to a BCD number with three
; digits (X.YZ) between 3.30 and 0.00 .
;*************************************************************** 
; EQU Directives
;***************************************************************
;LABEL		DIRECTIVE	VALUE				COMMENT
			AREA 		main, READONLY, CODE
			THUMB
			EXTERN		__ADC
			EXTERN		CONVRT				; Reference external subroutines	
			EXTERN		OutChar
			EXPORT 		__main	  			; Make available
			
__main 		PUSH		{LR}
			BL			__ADC
			POP			{LR}
			PUSH		{LR}
			BL			CONVRT
			POP			{LR}
			MOV			R0, R7
loop		BL			__ADC
			CMP			R7, R0
			ITE HS 						; R1 <- |R7-R0|
			SUBHS 		R1, R7, R0		; 	
			SUBLO 		R1, R0, R7		;	
			CMP			R1, #20			; Treshold = 0.20 Volt
			BLO			loop
			CMP			R7, #10			; Single digit or not
			BHS			high
			MOV 		R5,#0xA			; New line
			BL			OutChar
			MOV 		R5,#0x30		; print "0"
			BL			OutChar
			MOV 		R5,#0x2E		; print "."
			BL			OutChar
			MOV 		R5,#0x30		; print "0"
			BL			OutChar
			PUSH		{LR}
			BL			CONVRT			; print single digit
			POP			{LR}
			MOV			R0, R7	
			B			loop
			
high		MOV			R2, #100
			MOV			R8, R7
			UDIV		R7, R2
			MOV 		R5,#0xA			; add new line
			BL			OutChar
			PUSH		{LR}
			BL			CONVRT			; print the quotient
			POP			{LR}
			MOV 		R5,#0x2E		; print "."
			BL			OutChar
			CMP			R7, #0
			BNE			THREE
			MOV			R7, R8
			PUSH		{LR}
			BL			CONVRT			; print the quotient
			POP			{LR}
			MOV			R0, R8	
			B			loop
			
THREE		MUL			R7, R2
			SUBS		R7, R8, R7
			CMP			R7, #10
			BHS			high2
			MOV 		R5,#0x30		; print "0"
			BL			OutChar	
high2		PUSH		{LR}
			BL			CONVRT			; print the remainder
			POP			{LR}
			MOV			R0, R8
			B			loop		
			END