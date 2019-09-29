;***************************************************************
; Program rotationSignal.s
; This program initializes the GPIO port B
;*************************************************************** 
; EQU Directives
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
GPIO_PORTB_DATA 	EQU 		0x400053FC 				; data address to all pins								
;***************************************************************
;LABEL				DIRECTIVE	VALUE					COMMENT
					AREA 		main, READONLY, CODE
					THUMB
					EXPORT 		__main	  				; make available
					EXTERN 		InitSysTick
					EXTERN		INIT_GPIO
				
__main				MOV			R4, #0x80
					MOV			R5, #1
					BL			INIT_GPIO				; initialize GPIO port B
					BL			InitSysTick
					
loop				B			loop
					END
					
