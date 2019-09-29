;***************************************************************
; Program pulse_main.s


;*************************************************************** 
; EQU Directives

;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENTs

;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
            AREA 		main, READONLY, CODE
            THUMB
			EXTERN		My_Timer0A_Handler		; Reference external subroutines
			EXTERN 		PULSE_INIT				;
            EXPORT 		__main	  	; Make available

__main 		BL			PULSE_INIT
			B			.
			
			END
