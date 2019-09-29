;***************************************************************
; Program rotationSignal.s
; This subroutine sends  GPIO port B the necessary signals to
; demonstrate the Full Step Mode in both directions 
; (cw or ccw depending on the register R5 ).
;*************************************************************** 
; EQU Directives
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
GPIO_PORTB_DATA 	EQU 		0x400053FC 				; data address to all pins
PB_INP 				EQU			0x4000503C
PB_OUT 				EQU 		0x400053C0	
GPIO_PORTB_ICR		EQU			0x4000541C		
NVIC_ST_CTRL 	EQU 0xE000E010
;***************************************************************
;LABEL				DIRECTIVE	VALUE					COMMENT
					AREA 		main, READONLY, CODE
					THUMB
					EXPORT 		stepSignal	  		; make available
					EXTERN		INIT_GPIO				;
					EXTERN 		InitSysTick
						
stepSignal			PUSH		{LR}
					CMP			R8,#1
					BEQ			CHECK
					MOV			R6,R0				
					BL			InitSysTick				
									
					MOV			R8, #1
					B			break
					
CHECK				CMP			R0,#0xE
					MOVEQ		R5,#0
					CMP			R0,#0xD
					MOVEQ		R5,#1
					
					
release				LDR			R0,=PB_INP
					LDR			R0,[R0]
					CMP			R0,#0xF
					BEQ			check2
					B			check3
					
check2				CMP			R9, #1
					BEQ			turn
					MOV			R9, #1
					B			release
					
check3				CMP			R9, #1
					BEQ			finish
					MOV			R9,#1
					MOV			R8,#0
					BL			InitSysTick	
					B			break

turn  				CMP			R5, #0					; R5=0 => clockwise
					BEQ			clockwise
					B			counterclockwise

					
clockwise			LDR			R0, =PB_OUT				; output pins PB[7:4]
					LDR			R1, [R0]				;
					BIC 		R1, #0xFF
					ORR 		R1, R4					; make output high
					STR 		R1, [R0]
					LSR			R4, #1					; shift right the output
					CMP			R4, #0x08				;
					MOVEQ		R4, #0x80				;
					B			finish

counterclockwise	LDR			R0, =PB_OUT				; output pins PB[7:4]
					LDR			R1, [R0]				;
					BIC 		R1, #0xFF
					ORR 		R1, R4					; make output high
					STR 		R1, [R0]
					LSL			R4, #1					; shift right the output
					CMP			R4, #0x100				;
					MOVEQ		R4, #0x10				;
					B			finish
					
finish				MOV			R8, #0
					MOV			R9, #0
					LDR 		R1, =NVIC_ST_CTRL
					MOV 		R0, #0
					STR 		R0, [R1]
break				POP			{LR}									; exit from interrupt handler
					BX			LR
					
					END