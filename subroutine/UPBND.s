;***************************************************************
; Program UPBND.s
;***************************************************************
;SYMBOL		DIRECTIVE	VALUE			COMMENT

;***************************************************************
; Program section
;***************************************************************
;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		main, READONLY, CODE
            THUMB
            EXPORT 		UPBND			; Make available
				
UPBND 	 	PUSH		{R4-R6}			; store registers
			MOV			R4,#2
			CMP			R1,R2			; high==low?
			BNE			switch
equal		MOV			R3,R1
			B			exit
			
switch	 	TEQ			R0,R4		
			BEQ			start			; initial state
			TEQ			R0,#1
			BEQ			up				; up state
			TEQ			R0,#0
			BEQ			down			; down state
			
start		ADD			R3,R1,R2		; R3 <- high + low
			UDIV		R3,R4			; R3 <- MIDDLE
			B			exit
			
up			MOV			R1,R3			; LOW <- MIDDLE
			ADD			R3,R1,R2
			UDIV		R3,R4			; R3 <- MIDDLE
			SUB			R5,R2,R1		; high==low+1?
			CMP			R5,#1
			BNE			exit
			MOV			R3,R2
			B 			exit
						
down		MOV			R2,R3			; HIGH <- MIDDLE
			ADD			R3,R1,R2
			UDIV		R3,R4			; R3 <- MIDDLE
			SUB			R5,R2,R1		; high==low+1?
			CMP			R5,#1			;
			BNE			exit			;
			MOV			R3,R1			;
			B 			exit
						
exit			
			POP			{R4-R6}			; restore registers*
			BX  		LR				; Return to caller
								
			ALIGN                       ; make sure the end of this section is aligned
			END                         ; end of file