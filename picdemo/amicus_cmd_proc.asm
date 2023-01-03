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

#define ONE   0x31
#define TWO   0x32
#define THREE 0x33
#define FOUR  0x34
#define FIVE  0x35
#define SIX   0x36
#define SEVEN 0x37
#define EIGHT 0x38
#define NINE  0x39
#define MAX   0x3A

    GLOBAL      cmd_proc_r


;***** VARIABLE DEFINITIONS
        UDATA
cmd   res 1
ccprlh res 1
ccprll res 1
cval  res 1
newval res 1
cnt  res 1
;***** SUBROUTINES ******************************************************
        CODE


cmd_proc_r
	movwf cmd  ; hold command
	movf  CCPR2L,W   ; hold current DC
	movwf ccprlh
	movf  CCP2CON,W   ; hold current DC
	movwf ccprll
	movlw 0x30
	andwf ccprll,1 

	movlw 0x01   
	movwf cnt
	movlw ONE  ; assume new command of 1
	movwf cval
  checkval:
	movf  cmd,W
	subwf cval,W 
	btfss STATUS,Z
	goto  next
	movlw 0x71
	mulwf cnt    ; multiply low PWM by loop counter. 16 bit result
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


 	movlw 0x04
	movwf PORTA         ; toggling our test pins
	clrf  PORTA

	retlw   0

END
