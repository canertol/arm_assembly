;***************************************************************
; Program rotationSignal.s
; This program initializes the GPIO port B
;*************************************************************** 
; EQU Directives
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
GPIO_PORTB_DATA 	EQU 		0x400053FC 				; data address to all pins
PB_INP 				EQU			0x4000503C	
RELOAD_VALUE		EQU 		0x30D40
SPEED_STEP			EQU			0x9350
FAST_LIMIT			EQU			0x9350
SLOW_LIMIT			EQU			0xF4240
;***************************************************************
;LABEL				DIRECTIVE	VALUE					COMMENT
					AREA 		main, READONLY, CODE
					THUMB
					EXPORT 		__main	  				; make available
					EXTERN 		InitSysTick
					EXTERN		INIT_GPIO
					EXTERN		DELAY100
				
__main				MOV			R4, #0x80
					MOV			R5, #1
					LDR			R7,=RELOAD_VALUE
					
					BL			INIT_GPIO				; initialize GPIO port B
					BL			InitSysTick
					
loop				LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R0,#0xF
					BEQ			loop
S_1					MOV			R6, #0
S__1				LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R0,#0xE
					BNE			S_2
					BL			DELAY100				; delay 100ms
					CMP			R6, #1					; if it is the second time 
					BEQ			S_neg_1					; turn on led1
					MOV			R6, #1
					B 			S__1
					
S_neg_1				MOV			R6, #0
S__neg_1			LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R0,#0xF
					BNE			S__neg_1
					BL			DELAY100				; delay 100ms
					CMP			R6, #1					; if it is the second time 
					BEQ			out1
					MOV			R6, #1
					B			S__neg_1		

out1				MOV			R5,#0
					B			loop

S_2					MOV			R6, #0
S__2				LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R0,#0xD
					BNE			S_3
					BL			DELAY100				; delay 100ms
					CMP			R6, #1					; if it is the second time 
					BEQ			S_neg_2					; turn on led1
					MOV			R6, #1
					B 			S__2
					
S_neg_2				MOV			R6, #0
S__neg_2			LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R0,#0xF
					BNE			S__neg_2
					BL			DELAY100				; delay 100ms
					CMP			R6, #1					; if it is the second time 
					BEQ			out2
					MOV			R6, #1
					B			S__neg_2		

out2				MOV			R5,#1
					B			loop
					
S_3					MOV			R6, #0
S__3				LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R0,#0xB
					BNE			S_4
					BL			DELAY100				; delay 100ms
					CMP			R6, #1					; if it is the second time 
					BEQ			S_neg_3					; turn on led1
					MOV			R6, #1
					B 			S__3
					
S_neg_3				MOV			R6, #0
S__neg_3			LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R0,#0xF
					BNE			S__neg_3
					BL			DELAY100				; delay 100ms
					CMP			R6, #1					; if it is the second time 
					BEQ			out3
					MOV			R6, #1
					B			S__neg_3		

out3				LDR			R8,=SPEED_STEP
					ADD			R7,R8
					LDR			R9,=SLOW_LIMIT
					CMP			R7,R9
					BLO			loop
					LDR			R7,=SLOW_LIMIT
					B			loop
					
S_4					MOV			R6, #0
S__4				LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R0,#0x7
					BNE			loop
					BL			DELAY100				; delay 100ms
					CMP			R6, #1					; if it is the second time 
					BEQ			S_neg_4					; turn on led1
					MOV			R6, #1
					B 			S__4
					
S_neg_4				MOV			R6, #0
S__neg_4			LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R0,#0xF
					BNE			S__neg_4
					BL			DELAY100				; delay 100ms
					CMP			R6, #1					; if it is the second time 
					BEQ			out4
					MOV			R6, #1
					B			S__neg_4		

out4				LDR			R8,=SPEED_STEP
					SUB			R7,R8
					LDR			R9,=FAST_LIMIT
					CMP			R7,R9
					BHS			loop
					LDR			R7,=FAST_LIMIT
					B			loop					
					
					
					
					END
					
