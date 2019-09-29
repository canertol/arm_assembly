;***************************************************************
; Program pulse_probe.s
;*************************************************************** 
;LABEL		DIRECTIVE	VALUE		COMMENT
            AREA        sdata, DATA, READONLY
            THUMB
PWIDTH     	DCB     	"Pulse width is "
PERIOD     	DCB     	"Period is  "
DUTY     	DCB     	"Duty cycle is  "
;*************************************************************** 
; EQU Directives

;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENTs
TIMER1_CFG			EQU 0x40031000
TIMER1_TAMR			EQU 0x40031004
TIMER1_CTL			EQU 0x4003100C
TIMER1_IMR			EQU 0x40031018
TIMER1_RIS			EQU 0x4003101C ; Timer Interrupt Status
TIMER1_ICR			EQU 0x40031024 ; Timer Interrupt Clear
TIMER1_TAILR		EQU 0x40031028 ; Timer interval
TIMER1_TAMATCHR		EQU 0x40031030	; Match Register
TIMER1_TAPR			EQU 0x40031038
TIMER1_TAR			EQU	0x40031048 ; Timer register
	
;GPIO Registers
GPIO_PORTB_DATA		EQU 0x40005040 ; Access PB4
GPIO_PORTB_DIR 		EQU 0x40005400 ; Port Direction
GPIO_PORTB_AFSEL	EQU 0x40005420 ; Alt Function enable
GPIO_PORTB_DEN 		EQU 0x4000551C ; Digital Enable
GPIO_PORTB_AMSEL 	EQU 0x40005528 ; Analog enable
GPIO_PORTB_PCTL 	EQU 0x4000552C ; Alternate Functions

;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPTM Gate Control

;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
            AREA 		main, READONLY, CODE
            THUMB
			EXTERN		My_Timer0A_Handler		; Reference external subroutines
			EXTERN 		PULSE_INIT				;
			EXTERN		PULSE_PROBE	
			EXTERN      My_Timer1A_Handler 
			EXTERN		CONVRT
			EXTERN		DELAY100
			EXTERN		OutChar
            EXPORT 		__main	  	; Make available

__main 		BL			PULSE_INIT

			LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
			LDR R0, [R1]
			ORR R0, R0, #0x02 ; set bit 2 for port B
			STR R0, [R1]
			NOP ; allow clock to settle
			NOP
			NOP
			LDR R1, =GPIO_PORTB_DIR ; set direction of PB4
			LDR R0, [R1]
			BIC R0, #0x10 			; clear bit 4 for INPUT
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTB_AFSEL ; enable port function
			LDR R0, [R1]
			ORR R0, #0x10		; set bit4 for alternate fuction on PB4
			STR R0, [R1]
			; Set bits 27:24 of PCTL to 7 to enable TIMER1A on PB4
			LDR R1, =GPIO_PORTB_PCTL
			LDR R0, [R1]
			ORR R0, R0, #0x00070000
			STR R0, [R1]
		; clear AMSEL to disable analog
			LDR R1, =GPIO_PORTB_AMSEL
			MOV R0, #0
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTB_DEN ; enable port digital
			LDR R0, [R1]
			ORR R0, R0, #0x10
			STR R0, [R1]
		
			LDR R1, =SYSCTL_RCGCTIMER ; Start Timer1
			LDR R2, [R1]
			ORR R2, R2, #0x02
			STR R2, [R1]
			NOP ; allow clock to settle
			NOP
			NOP
			
			LDR R1, =TIMER1_CTL ; disable timer during setup
			LDR R2, [R1]
			BIC R2, R2, #0x01
			STR R2, [R1]
		; set to 16bit Timer Mode
			LDR R1, =TIMER1_CFG
			MOV R2, #0x04 ; set bits 2:0 to 0x04 for 16bit timer
			STR R2, [R1]
		; set to EDGE TIME, count DOWN
			LDR R1, =TIMER1_TAMR
			MOV R2, #0x1F 
			STR R2, [R1]
		; set edge detection to both
			LDR R1, =TIMER1_CTL
			LDR R2, [R1]
			ORR R2, R2, #0x0E ; set bits 3:2 to 0x03
			STR R2, [R1]
			
			LDR R1, =TIMER1_TAPR
			MOV R2, #15 ; divide clock by 16 to
			STR R2, [R1] ; get 1us clocks
			; set start value
			LDR R1, =TIMER1_TAILR
			LDR R2, =0xFFFF
			STR R2, [R1]
		
			LDR R1, =TIMER1_IMR ; disable timeout interrupt
			MOV R2, #0x00
			STR R2, [R1]

			; Enable timer
			LDR R1, =TIMER1_CTL
			LDR R2, [R1]
			ORR R2, R2, #0x0F ; set bit0 to enable, bit 1 to stall on debug 
			STR R2, [R1] ; and bit2:3 to trigger on BOTH EDGES
			MOV	R8, #3
			NOP
			NOP
			NOP

		; clear interrupt flag
		;	LDR R0, =TIMER1_ICR 
		;	MOV	R1, #0x05
		;	STR R1, [R0]
			; Await edge capture event
			
loop		LDR R1, =TIMER1_RIS
			LDR R2, [R1]
			ANDS R2, #0x04 ; isolate CAERIS bit
			;CMP	R2, #0x04
			BEQ loop ; if no capture, then loop
			
			; clear interrupt flag
			LDR R0, =TIMER1_ICR 
			MOV	R1, #0x04
			STR R1, [R0]
			
			; take timer value
			LDR R6, =TIMER1_TAR	
			LDR	R6, [R6]
			LSR R6, #4
			
			LDR R0, =GPIO_PORTB_DATA
			LDR R0, [R0]
			AND	R0, #0x10
			CMP	R0, #0x10
			BNE	_negedge
_posedge	
			CMP	R8, #3
			MOVEQ R9, #1
			SUBS R8, #1
			BEQ	print
			MOV	R11, R6
			B   loop
_negedge	
			CMP	R8, #3
			MOVEQ R9, #2
			SUBS R8, #1
			BEQ	print			
			MOV	R12, R6
			B	loop
			
			
						
print		MOV	R8, #3
			CMP R9, #0
			BNE	check
			
			MOV	R9, #0
			MOV	R10, #30
			LDR R0, =TIMER1_ICR 
			MOV	R1, #0x04
			STR R1, [R0]
			B	loop
		;CHECK TIMEOUT
check		LDR R1, =TIMER1_RIS
			LDR R2, [R1]
			ANDS R2, #0x01 ; isolate TATORIS bit
			BEQ	continue
			LDR R0, =TIMER1_ICR 
			MOV	R1, #0x04
			STR R1, [R0]
			B	loop
			
continue	MOV	R0, #0xFFE
			CMP	R12, R0
			BEQ	finish
			MOV R5,#0xA
			BL	OutChar
			CMP	R9, #2
			BEQ	negprint
			;PULSE WIDTH
			SUB	R7, R11, R12
			MOV	R1, R7
			MOV R5,#0x57
			BL	OutChar
			MOV R5,#0x3D
			BL	OutChar
			PUSH {LR}
			BL	CONVRT
			POP {LR}
			; PERIOD
			SUB	R7, R11, R6
			MOV R5,#0x20
			BL	OutChar
			MOV R5,#0x50
			BL	OutChar
			MOV R5,#0x3D
			BL	OutChar
			PUSH {LR}
			BL	CONVRT
			POP {LR}
			; DUTY CYCLE
			MOV	R2, #100
			MUL	R1, R2
			UDIV R7, R1, R7
			MOV R5,#0x20
			BL	OutChar
			MOV R5,#0x44
			BL	OutChar
			MOV R5,#0x3D
			BL	OutChar
			PUSH {LR}
			BL	CONVRT
			POP {LR}
			MOV	R11, R6
			B	finish
			
negprint	;PULSE WIDTH
			SUB	R7, R11, R6
			MOV	R1, R7
			MOV R5,#0x57
			BL	OutChar
			MOV R5,#0x3D
			BL	OutChar
			PUSH {LR}
			BL	CONVRT
			POP {LR}
			; PERIOD
			SUB	R7, R12, R6
			MOV R5,#0x20
			BL	OutChar
			MOV R5,#0x50
			BL	OutChar
			MOV R5,#0x3D
			BL	OutChar
			PUSH {LR}
			BL	CONVRT
			POP {LR}
			; DUTY CYCLE
			MOV	R2, #100
			MUL	R1, R2
			UDIV R7, R1, R7
			MOV R5,#0x20
			BL	OutChar
			MOV R5,#0x44
			BL	OutChar
			MOV R5,#0x3D
			BL	OutChar
			PUSH {LR}
			BL	CONVRT
			POP {LR}
			MOV	R12, R6		
			; clear interrupt flag
finish		;MOV R5,#0xA
			;BL	OutChar
			MOV	R9, #0
			MOV	R10, #20
delay		BL	DELAY100
			SUBS R10, #1
			BNE	delay
			LDR R0, =TIMER1_ICR 
			MOV	R1, #0x04
			STR R1, [R0]
			B	loop

			END
