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
;***************************************************************
;LABEL				DIRECTIVE	VALUE					COMMENT
					AREA 		main, READONLY, CODE
					THUMB
					EXPORT 		rotationSignal	  		; make available
					EXTERN		INIT_GPIO				; 
					EXTERN      InitSysTick
				
rotationSignal		PUSH		{LR}
					BL			InitSysTick				; initialize Sys Tick
					BL			INIT_GPIO				; initialize GPIO port B
					CMP			R5, #0					; R5=0 => clock wise
					BNE			counterclockwise		; otherwise counter clockwise
					
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
					
finish				POP			{LR}					; exit from interrupt handler
					BX			LR
					
					END