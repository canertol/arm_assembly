;************************************************************
; Your SystemTimer.s source file to implement
; initialization and ISR
;************************************************************
; Definitions of the labels standing for
; the address of the registers
NVIC_ST_CTRL 	EQU 0xE000E010
NVIC_ST_RELOAD 	EQU 0xE000E014
NVIC_ST_CURRENT EQU 0xE000E018
SHP_SYSPRI3 	EQU 0xE000ED20
; end of the register label defintions
; 0x61A80 = 400000 -> 400000*250 ns = 100 ms
RELOAD_VALUE	EQU 0x61A80
;************************************************************
; Initialization area
;************************************************************
;LABEL 		DIRECTIVE 		VALUE		 COMMENT
			AREA 			init_isr, CODE, READONLY, ALIGN=2
			THUMB
			EXPORT 			InitSysTick
				
InitSysTick	PROC
			PUSH			{LR,R0,R1}
; first disable system timer and the related interrupt
; then configure it to use internal oscillator PIOSC/4
			LDR 			R1 , =NVIC_ST_CTRL
			MOV 			R0 , #0
			STR 			R0 , [R1]
; now set the time-out period
			LDR				R1 , =NVIC_ST_RELOAD
			LDR 			R0 , =RELOAD_VALUE
			STR 			R0 , [R1]
; time out period is set
; now set the current timer value to the time out value
			LDR 			R1 , =NVIC_ST_CURRENT
			STR 			R0 , [R1]
; current timer = time out period
; now set the priority level
			LDR 			R1 , =SHP_SYSPRI3
			MOV 			R0 , #0x40000000
			STR 			R0 , [R1]
; priority is set to 2
; now enable system timer and the related interrupt
			LDR 			R1 , =NVIC_ST_CTRL
			MOV 			R0 , #0x03
			STR 			R0 , [R1]
; set up for system time is now complete
			POP				{LR,R0,R1}
			BX 				LR
			ENDP
			
			END