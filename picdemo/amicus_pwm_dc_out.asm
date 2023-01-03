;************************************************************************
;                                                                       *
;   Filename:      amicus_cmd_proc.asm                                          *
;   Date:          12/31/2022                                              *
;  
;                                                                       *
;                                                                       *
;************************************************************************
;                                                                       *
;   Files required: none                                                *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    
;     process command byte in W
;************************************************************************

#include    <P18F25K20.INC>   ; any baseline device will do

GLOBAL      pwm_dc_out_r


;***** VARIABLE DEFINITIONS
        UDATA
ccprlh res 1
ccprll res 1
;***** SUBROUTINES ******************************************************
        CODE


pwm_dc_out_r
	; we assume an immediately preceeding multiply has a 16-bit
    ; result in PRODH:PRODL from which we will map to the 10-bit 
	; duty cycle

	movf  PRODH,W  ; 2 MSBs of 10-bit DC are in the PRODH register
	movwf ccprlh;  seed the high duty cycle byte
	movlw 0x03;    ; mask result
	andwf ccprlh,1;

	rlncf ccprlh,1
	rlncf ccprlh,1
	rlncf ccprlh,1
	rlncf ccprlh,1
	rlncf ccprlh,1
	rlncf ccprlh,1

	movf  PRODL,W
	movwf ccprll;  seed the low duty cycle byte
	movlw 0xFC;    
	andwf ccprll,1 ; mask LSBs
	rrncf ccprll,1 ; rotate right
	rrncf ccprll,1

	movf ccprll,W
	iorwf  ccprlh,1  ; finalize ccprlh: what is written to CCP2RL

	; now get the two LSBs 
	movf  PRODL,W
	movwf ccprll;  seed the low duty cycle byte again
	movlw 0x03;    
	andwf ccprll,1 ; mask LSBs

	; command
	movf ccprlh,W
	movwf CCPR2L    ; PWM duty cycle most signignificant bits

	movf ccprll,W
	rlncf ccprll,1
	rlncf ccprll,1
	rlncf ccprll,1
	rlncf ccprll,1
	movf  ccprll,W
	iorwf CCP2CON,1    ; PWM duty cycle least signignificant bits

	retlw   0
END
