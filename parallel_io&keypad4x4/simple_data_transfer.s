;***************************************************************
; Program simple_data_transfer.s
; This program, takes inputs from push buttons and reflect the
; status of the buttons to the LEDs that are connected to the 
; output port for approximately every 5 seconds. Namely, an input 
; should be read for every 5 seconds and the status of that reading
; should remain at the output until the next reading. The status 
;of a pressed button is 1 and the status of a released button is 0.
;*************************************************************** 
; EQU Directives
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
;***************************************************************
;LABEL				DIRECTIVE	VALUE					COMMENT
					AREA 		main, READONLY, CODE
					THUMB
					EXTERN		DELAY100
					EXPORT 		__main	  	; makeake available
			
				
__main		
GPIO_PORTB_DATA 	EQU 		0x400053FC 				; data address to all pins
														; PUR Offset 0x510
GPIO_PORTB_PUR		EQU			0x40005510 				; PUR actual address
PUB					EQU			0x0F					; or #2_00001111 B0-3 PULL-UP,B4-7 PULL-DOWN
GPIO_PORTB_DIR 		EQU 		0x40005400
GPIO_PORTB_AFSEL 	EQU 		0x40005420
GPIO_PORTB_DEN 		EQU 		0x4000551C
IOB 				EQU 		0xF0					; B0-3 INPUT, B4-7 OUTPUT
turn_off			EQU			0xFFF					;set led states
led1				EQU			0xFEF
led2				EQU			0xFDF
led3				EQU			0xFBF
led4				EQU			0xF7F
SYSCTL_RCGCGPIO 	EQU 		0x400FE608	


					LDR 		R1, =SYSCTL_RCGCGPIO
					LDR 		R0, [R1]
					ORR 		R0, R0, #0x12
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
					STR 		R0, [R1] 				; config. of port B ends
					
					LDR			R0, =GPIO_PORTB_PUR
					MOV			R1, #PUB
					STR			R1, [R0]
					
					LDR			R1, =GPIO_PORTB_DATA	;READ THE VALUE
					LDR			R0, [R1]
					BIC 		R0, #0xFF
					ORR 		R0, #IOB
					STR 		R0, [R1]
					
check2				LDR			R2, =GPIO_PORTB_DATA	;READ THE VALUE
					LDR			R0, [R2]
					BIC 		R0, #0xFF
					LDR			R3,	=turn_off
					ORR 		R0, R3
					STR 		R0, [R1]
					
check				MOV			R4, #0					; button1 counter
					MOV			R5, #0					; button2 counter
					MOV			R6, #0					; button3 counter
					MOV			R7, #0					; button4 counter
					MOV			R8, #50					; COUNTER = 35
					LDR			R2, =GPIO_PORTB_DATA	;READ THE VALUE
					LDR			R2, [R2]
					UBFX		R0, R2, #0, #4
					MOV			R2, #0xF
					CMP			R2, R0				
					BNE			LED1
					
loop				SUBS		R8,#1					; wait 5 seconds
					CMP			R8,R4
					BEQ			check2	
					BL			DELAY100
					B			loop
					
LED1				LDR			R2, =GPIO_PORTB_DATA	;READ THE VALUE
					LDR			R2, [R2]
					UBFX		R3, R2, #0, #1			
					CMP			R3,#0
					BNE			LED2
					BL			DELAY100				; delay 100ms
					CMP			R4, #1					; if it is the second time 
					BEQ			out1					; turn on led1
					ADD			R4, #1
					B 			LED1
out1				MOV			R4,#0
					LDR			R2, =GPIO_PORTB_DATA	;READ THE VALUE
					LDR			R0, [R2]
					BIC 		R0, #0xFF
					LDR			R3,	=led1
					ORR 		R0, R3
					STR 		R0, [R1]
					
					
LED2				LDR			R2, =GPIO_PORTB_DATA	;READ THE VALUE
					LDR			R2, [R2]
					UBFX		R3, R2, #0, #2
					LSR			R3, #1
					CMP			R3,#0
					BNE			LED3
					BL			DELAY100				; delay 100ms
					CMP			R5, #1					; if it is the second time 
					BEQ			out2					; turn on led1
					ADD			R5, #1
					B 			LED2
out2				MOV			R5,#0
					LDR			R2, =GPIO_PORTB_DATA	;READ THE VALUE
					LDR			R0, [R2]
					BIC 		R0, #0xFF
					LDR			R3,	=led2
					ORR 		R0, R3
					STR 		R0, [R1]
					
					
LED3				LDR			R2, =GPIO_PORTB_DATA	;READ THE VALUE
					LDR			R2, [R2]
					UBFX		R3, R2, #0, #3
					LSR			R3, #2
					CMP			R3,#0
					
					BNE			LED4
					BL			DELAY100				; delay 100ms
					CMP			R6, #1					; if it is the second time 
					BEQ			out3					; turn on led1
					ADD			R6, #1
					B 			LED3
out3				MOV			R6,#0
					LDR			R6, =GPIO_PORTB_DATA	;READ THE VALUE
					LDR			R0, [R2]
					BIC 		R0, #0xFF
					LDR			R3,	=led3
					ORR 		R0, R3
					STR 		R0, [R1]
					
					
LED4				LDR			R2, =GPIO_PORTB_DATA	;READ THE VALUE
					LDR			R2, [R2]
					UBFX		R3, R2, #0, #4
					LSR			R3, #3
					CMP			R3,#0
					BNE			check
					BL			DELAY100				; delay 100ms
					CMP			R7, #1					; if it is the second time 
					BEQ			out4					; turn on led1
					ADD			R7, #1
					B 			LED4
out4				MOV			R7,#0
					LDR			R2, =GPIO_PORTB_DATA	;READ THE VALUE
					LDR			R0, [R2]
					BIC 		R0, #0xFF
					LDR			R3,	=led4
					ORR 		R0, R3
					STR 		R0, [R1]
					B			check
					
					END