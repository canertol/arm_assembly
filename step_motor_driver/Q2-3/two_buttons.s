;***************************************************************
; Program rotationSignal.s
; This program initializes the GPIO port B
;*************************************************************** 
; EQU Directives
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
GPIO_PORTB_DATA 	EQU 		0x400053FC 				; data address to all pins		
GPIO_PORTB_MIS		EQU			0x40005418 
PB_INP 				EQU			0x4000503C	
;***************************************************************
;LABEL				DIRECTIVE	VALUE					COMMENT
					AREA 		main, READONLY, CODE
					THUMB
					EXPORT 		__main	  				; make available
					EXTERN		INIT_GPIO
					EXTERN		stepSignal
						
__main				PROC
					MOV			R4, #0x80
					MOV			R5, #0
					MOV			R6, #2
					MOV			R7, #2
					BL			INIT_GPIO				; initialize GPIO port B
					CPSIE  		I;
					MOV			R8, #0
					MOV			R9, #0
loop				LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R8, #1
					BEQ			loop
loop2				CMP			R9, #1
					BNE			skip
					BEQ			loop2
skip				LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R0,#0xF
					BEQ			loop
					BL			stepSignal
					B			loop
					ENDP
					END
					
