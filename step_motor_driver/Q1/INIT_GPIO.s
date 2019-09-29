;***************************************************************
; Program INIT_GPIO.s
; This program initializes the GPIO port B
;*************************************************************** 
; EQU Directives
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
GPIO_PORTB_DATA 	EQU 		0x400053FC 				; data address to all pins
														; PUR Offset 0x510
GPIO_PORTB_PUR		EQU			0x40005510 				; PUR actual address
PUB					EQU			0x0F					; or #2_00001111 B0-3 PULL-UP,B4-7 PULL-DOWN
GPIO_PORTB_DIR 		EQU 		0x40005400
GPIO_PORTB_AFSEL 	EQU 		0x40005420
GPIO_PORTB_DEN 		EQU 		0x4000551C
GPIO_PORTB_IS		EQU			0x40005404				
GPIO_PORTB_IBE		EQU			0x40005408
GPIO_PORTB_IEV		EQU			0x4000540C
GPIO_PORTB_IM		EQU			0x40005410
GPIO_PORTB_ICR		EQU			0x4000541C
IOB 				EQU 		0xF0					; B0-3 INPUT, B4-7 OUTPUT
NVIC_ENABLE			EQU			0xE000E100
SYSCTL_RCGCGPIO 	EQU 		0x400FE608
;***************************************************************
;LABEL				DIRECTIVE	VALUE					COMMENT
					AREA 		main, READONLY, CODE
					THUMB
					EXPORT 		INIT_GPIO	  	; make available
							
INIT_GPIO			PUSH		{LR}					
					LDR 		R1, =SYSCTL_RCGCGPIO
					LDR 		R0, [R1]
					ORR 		R0, R0, #0x1F
					STR 		R0, [R1]
					NOP
					NOP
					NOP 								; let GPIO clock stabilize
					
					LDR 		R1, =GPIO_PORTB_DIR 	; config. of port B starts
					LDR 		R0, [R1]
					BIC 		R0, #0xFF
					ORR 		R0, #IOB
					STR 		R0, [R1]
					LDR 		R1, =GPIO_PORTB_AFSEL
					LDR 		R0, [R1]
					BIC 		R0, #0xFF
					STR 		R0, [R1]
					LDR 		R1, =GPIO_PORTB_DEN
					LDR 		R0, [R1]
					ORR 		R0, #0xFF
					STR 		R0, [R1] 					
					LDR			R0, =GPIO_PORTB_PUR
					MOV			R1, #PUB
					STR			R1, [R0]				; config. of port B ends					
				
				
					POP			{LR}	
					
					
					BX 			LR
					END