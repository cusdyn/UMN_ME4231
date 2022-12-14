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

#define ZERO   0x30   ; characters '1' through '9' control DC output
#define DCINC 0x71   ; duty cycle increment from '1' to '9' 

GLOBAL  cmd_proc_r
EXTERN pwm_dc_out_r


;***** VARIABLE DEFINITIONS
        UDATA
cmd   res 1
cval  res 1
newval res 1
cnt  res 1

;***** SUBROUTINES ******************************************************
        CODE

cmd_proc_r
	movwf cmd  ; hold command

	movlw 0x61  ; 'a'
	subwf cmd,W 
	btfsc STATUS,Z
	retlw   1       ; return in mode=1 ADC controlling duty cycle
	

	movlw 0x00   
	movwf cnt
	movlw ZERO
	movwf cval
  checkval:
	movf  cmd,W
	subwf cval,W 
	btfss STATUS,Z
	goto  next
	movlw DCINC
	mulwf cnt    ; multiply low PWM by loop counter. 16 bit result

	; pwm_dc_out expects desired 10-bit PWM to be in PRODH:PRODL
	call pwm_dc_out_r

	goto  done
  next:
	movf  cval,w
	addlw 0x01
	movwf cval
	movf  cnt,w
	addlw 0x01
	movwf cnt
	goto  checkval
  done:

 	movlw 0x04
	movwf PORTA         ; toggling our test pins
	clrf  PORTA

	retlw   0

END
