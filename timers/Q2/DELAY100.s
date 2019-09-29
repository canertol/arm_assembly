;***************************************************************
; Program DELAY100.s
; This program, causes approximately 100 msec delay upon calling.
;*************************************************************** 
; EQU Directives
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
COUNTER		EQU			0x0
LIMIT		EQU         0x30D3A
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
            AREA 		main, READONLY, CODE
            THUMB
            EXPORT 		DELAY100	  	; Make available
				
DELAY100    
			PUSH		{R0-R12}
			PUSH		{LR}
			LDR			R0,=COUNTER		; R0<- COUNTER
			LDR			R1,=LIMIT
loop		ADD			R0,#1			; COUNTER++
			CMP			R0,R1
			BEQ			exit
			B			loop
			
exit		POP			{LR}
			POP			{R0-R12}
			BX			LR
			
			END