;***************************************************************
; Program keypad4x4.s

;*************************************************************** 
; EQU Directives

;***************************************************************
;LABEL				DIRECTIVE	VALUE		COMMENT
GPIO_PORTB_DATA 	EQU 		0x400053FC 				; data address to all pins
PB_INP 				EQU			0x4000503C
PB_OUT 				EQU 		0x400053C0														; PUR Offset 0x510
GPIO_PORTB_PUR		EQU			0x40005510 				; PUR actual address
PUB					EQU			0x0F					; or #2_00001111 B0-3 PULL-UP,B4-7 PULL-DOWN
GPIO_PORTB_DIR 		EQU 		0x40005400
GPIO_PORTB_AFSEL 	EQU 		0x40005420
GPIO_PORTB_DEN 		EQU 		0x4000551C
IOB 				EQU 		0xF0					; B0-3 INPUT, B4-7 OUTPUT
turn_off			EQU			0xFFF					;set led states
led1				EQU			0xEF
led2				EQU			0xDF
led3				EQU			0xBF
led4				EQU			0x7F
SYSCTL_RCGCGPIO 	EQU 		0x400FE608	
;***************************************************************
;LABEL				DIRECTIVE	VALUE					COMMENT
					AREA 		main, READONLY, CODE
					THUMB
					EXTERN		DELAY100
					EXPORT 		__main	  				; makeake available
					EXTERN		CONVRT
				
__main		

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
										
loop			
L1					LDR			R2, =PB_OUT	;READ THE VALUE
					LDR			R0, [R2]
					BIC 		R0, #0xFF
					LDR			R3,	=led1
					ORR 		R0, R3
					STR 		R0, [R2]
					MOV			R0,	#0
					BL			CHECK
					CMP			R0,#1
					BNE			two
					MOV			R7,#0x1
					B			print
two					CMP			R1,#1
					BNE			three
					MOV			R7,#0x2
					B			print		
three				CMP			R2,#1
					BNE			four
					MOV			R7,#0x3
					B			print
four				CMP			R3,#1
					BNE			L2
					MOV			R7,#0x4
					B			print
					
print				BL			CONVRT		
					B			loop
					
L2					LDR			R2, =PB_OUT				;READ THE VALUE
					LDR			R0, [R2]
					BIC 		R0, #0xFF
					LDR			R3,	=led2
					ORR 		R0, R3
					STR 		R0, [R2]		
					MOV			R1,	#0
					BL			CHECK
					CMP			R0,#1
					BNE			six
					MOV			R7,#0x5
					B			print2
six					CMP			R1,#1
					BNE			seven
					MOV			R7,#0x6
					B			print2					
seven				CMP			R2,#1
					BNE			eight
					MOV			R7,#0x7
					B			print2
eight				CMP			R3,#1
					BNE			L3
					MOV			R7,#0x8
					B			print2
					
print2				BL			CONVRT		
					B			loop
					
L3					LDR			R2, =PB_OUT				;READ THE VALUE
					LDR			R0, [R2]
					BIC 		R0, #0xFF
					LDR			R3,	=led3
					ORR 		R0, R3
					STR 		R0, [R2]
					MOV			R2,	#0
					BL			CHECK
					CMP			R0,#1
					BNE			ten
					MOV			R7,#0x9
					B			print3
ten					CMP			R1,#1
					BNE			eleven
					MOV			R7,#0xA
					B			print3					
eleven				CMP			R2,#1
					BNE			twelve
					MOV			R7,#0xB
					B			print3
twelve				CMP			R3,#1
					BNE			L4
					MOV			R7,#0xC
					B			print3
					
print3				BL			CONVRT
					B			loop
					
L4					LDR			R2, =PB_OUT				;READ THE VALUE
					LDR			R0, [R2]
					BIC 		R0, #0xFF
					LDR			R3,	=led4
					ORR 		R0, R3
					STR 		R0, [R2]
					MOV			R3,	#0
					BL			CHECK
					CMP			R0,#1
					BNE			fourteen
					MOV			R7,#0xD
					B			print4
fourteen			CMP			R1,#1
					BNE			fifteen
					MOV			R7,#0xE
					B			print4					
fifteen				CMP			R2,#1
					BNE			sixteen
					MOV			R7,#0xF
					B			print4
sixteen				CMP			R3,#1
					BNE			loop
					MOV			R7,#0x10
					B			print4
					
print4				BL			CONVRT
					B			loop
					
CHECK				PUSH		{LR}
					MOV			R0, #0
					MOV			R1, #0
					MOV			R1, #0
					MOV			R3, #0
					
					MOV			R4, #0					; button1 counter
					MOV			R5, #0					; button2 counter
					MOV			R6, #0					; button3 counter
					MOV			R7, #0					; button4 counter
					
R_1					LDR			R2, =PB_INP				;READ THE VALUE
					LDR			R2, [R2]
					UBFX		R3, R2, #0, #1			
					CMP			R3,#0
					BNE			R_2
					BL			DELAY100				; delay 100ms
					CMP			R4, #1					; if it is the second time 
					BEQ			R_neg_1					; turn on led1
					ADD			R4, #1
					B 			R_1
R_neg_1				LDR			R2, =PB_INP				;READ THE VALUE
					LDR			R2, [R2]
					UBFX		R3, R2, #0, #1			
					CMP			R3,#1
					BNE			R_neg_1
					BL			DELAY100				; delay 100ms
					CMP			R5, #1					; if it is the second time 
					BEQ			out1
					ADD			R5, #1
					B			R_neg_1		

out1				MOV			R0, #1
					MOV			R1, #0
					MOV 		R2, #0
					MOV			R3, #0
					POP			{LR}
					BX			LR
									
											
R_2					LDR			R2, =PB_INP				;READ THE VALUE
					LDR			R2, [R2]
					LSR			R2,#1
					UBFX		R3, R2, #0, #1			
					CMP			R3,#0
					BNE			R_3
					BL			DELAY100				; delay 100ms
					CMP			R4, #1					; if it is the second time 
					BEQ			R_neg_2					; turn on led1
					ADD			R4, #1
					B 			R_2
R_neg_2				LDR			R2, =PB_INP				;READ THE VALUE
					LDR			R2, [R2]
					LSR			R2,#1
					UBFX		R3, R2, #0, #1			
					CMP			R3,#1
					BNE			R_neg_2
					BL			DELAY100				; delay 100ms
					CMP			R5, #1					; if it is the second time 
					BEQ			out2
					ADD			R5, #1
					B			R_neg_2		

out2				MOV			R0, #0
					MOV			R1, #1
					MOV 		R2, #0
					MOV			R3, #0
					POP			{LR}
					BX			LR
					
					
					
R_3					LDR			R2, =PB_INP				;READ THE VALUE
					LDR			R2, [R2]
					LSR			R2,#2
					UBFX		R3, R2, #0, #1			
					CMP			R3,#0
					BNE			R_4
					BL			DELAY100				; delay 100ms
					CMP			R4, #1					; if it is the second time 
					BEQ			R_neg_3					; turn on led1
					ADD			R4, #1
					B 			R_3
R_neg_3				LDR			R2, =PB_INP				;READ THE VALUE
					LDR			R2, [R2]
					LSR			R2,#2
					UBFX		R3, R2, #0, #1			
					CMP			R3,#1
					BNE			R_neg_3
					BL			DELAY100				; delay 100ms
					CMP			R5, #1					; if it is the second time 
					BEQ			out3
					ADD			R5, #1
					B			R_neg_3		

out3				MOV			R0, #0
					MOV			R1, #0
					MOV 		R2, #1
					MOV			R3, #0
					POP			{LR}
					BX			LR
					
					
					
R_4					LDR			R2, =PB_INP				;READ THE VALUE
					LDR			R2, [R2]
					LSR			R2,#3
					UBFX		R3, R2, #0, #1			
					CMP			R3,#0
					BNE			finish 
					BL			DELAY100				; delay 100ms
					CMP			R4, #1					; if it is the second time 
					BEQ			R_neg_4					; turn on led1
					ADD			R4, #1
					B 			R_4
R_neg_4				LDR			R2, =PB_INP				;READ THE VALUE
					LDR			R2, [R2]
					LSR			R2,#3
					UBFX		R3, R2, #0, #1			
					CMP			R3,#1
					BNE			R_neg_4
					BL			DELAY100				; delay 100ms
					CMP			R5, #1					; if it is the second time 
					BEQ			out4
					ADD			R5, #1
					B			R_neg_4		

out4				MOV			R0, #0
					MOV			R1, #0
					MOV 		R2, #0
					MOV			R3, #1
					POP			{LR}
					BX			LR
finish				POP			{LR}
					MOV			R0, #0
					MOV			R1, #0
					MOV 		R2, #0
					MOV			R3, #0
					BX			LR
			
								
					END
					