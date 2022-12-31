;************************************************************************
;                                                                       *
;   Filename:      amicus_prompt.asm                                          *
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
;     paint a prompt to a terminal
;************************************************************************

    #include    <P18F25K20.INC>   ; any baseline device will do

    GLOBAL      prompt_r


;***** VARIABLE DEFINITIONS
        UDATA


;***** SUBROUTINES ******************************************************
        CODE


prompt_r
 
	cret:
		MOVLW 0x0D
		BTFSS TXSTA,TRMT
		goto cret
		MOVWF TXREG
	lfeed:
		MOVLW 0x0A
		BTFSS TXSTA,TRMT
		goto lfeed
		MOVWF TXREG
	psym:
		MOVLW 0x3E
		BTFSS TXSTA,TRMT
		goto psym
		MOVWF TXREG
		MOVLW 0x04
		MOVWF PORTA         ; toggling our test pins
		CLRF PORTA
	    retlw   0

END
