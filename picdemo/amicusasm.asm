;******************************************************************************
;   This file is a basic template for assembly code for a PIC18F2520. Copy    *
;   this file into your project directory and modify or add to it as needed.  *
;                                                                             *
;   Refer to the MPASM User's Guide for additional information on the         *
;   features of the assembler.                                                *
;                                                                             *
;   Refer to the PIC18Fx420/x520 Data Sheet for additional                    *
;   information on the architecture and instruction set.                      *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Filename:                                                                *
;    Date:                                                                    *
;    File Version:                                                            *
;                                                                             *
;    Author:                                                                  *
;    Company:                                                                 *
;                                                                             * 
;******************************************************************************
;                                                                             *
;    Files Required: P18F2520.INC                                             *
;                                                                             *
;******************************************************************************

	LIST P=18F2520		;directive to define processor
	#include <P18F25K20.INC>	;processor specific variable definitions

;******************************************************************************
;Configuration bits
;Microchip has changed the format for defining the configuration bits, please 
;see the .inc file for futher details on notation.  Below are a few examples.



;   Oscillator Selection:
    CONFIG	FOSC  = HS   
	CONFIG  FCMEN  = OFF
	CONFIG  IESO  = OFF  
	CONFIG  PWRT  = ON
	CONFIG  BOREN = OFF

	CONFIG  WDTEN = OFF
	CONFIG  MCLRE = ON
	CONFIG  DEBUG = OFF
;	CONFIG  LVP   = ON       

;******************************************************************************
;Variable definitions
; These variables are only needed if low priority interrupts are used. 
; More variables may be needed to store other special function registers used
; in the interrupt routines.

		CBLOCK	0x080
		WREG_TEMP	;variable used for context saving 
		STATUS_TEMP	;variable used for context saving
		BSR_TEMP	;variable used for context saving
		ENDC

		CBLOCK	0x000
		EXAMPLE		;example of a variable in access RAM
		ENDC

;******************************************************************************
;EEPROM data
; Data to be programmed into the Data EEPROM is defined here

		ORG	0xf00000

		DE	"Test Data",0,1,2,3,4,5

;******************************************************************************
;Reset vector
; This code will start executing when a reset occurs.

		ORG	0x0000
		
		rxdata EQU 0x00
		rxtest EQU 0x01
		rxflag EQU 0x00

goto	Main		;go to start of main code

;******************************************************************************
;High priority interrupt vector
; This code will start executing when a high priority interrupt occurs or
; when any interrupt occurs if interrupt priorities are not enabled.

		ORG	0x0008

		bra	HighInt		;go to high priority interrupt routine

;******************************************************************************
;Low priority interrupt vector and routine
; This code will start executing when a low priority interrupt occurs.
; This code can be removed if low priority interrupts are not used.

		ORG	0x0018

		movff	STATUS,STATUS_TEMP	;save STATUS register
		movff	WREG,WREG_TEMP		;save working register
		movff	BSR,BSR_TEMP		;save BSR register

;	*** low priority interrupt code goes here ***


		movff	BSR_TEMP,BSR		;restore BSR register
		movff	WREG_TEMP,WREG		;restore working register
		movff	STATUS_TEMP,STATUS	;restore STATUS register
		retfie

;******************************************************************************
;High priority interrupt routine
; The high priority interrupt code is placed here to avoid conflicting with
; the low priority interrupt vector.

HighInt:

;	*** high priority interrupt code goes here ***

	MOVLW 0x00          ; initialize our bit toggle field

	; TIMER0 interrupt
	BTFSS INTCON,TMR0IF ; TIMER0 flag check. skip next instruction if clear
    goto rxisr

	MOVLW 0x01
	MOVWF PORTA         ; toggling our test pins
	CLRF PORTA

	BCF   INTCON,TMR0IF ; clear the flag
	
rxisr:
	; USART receive interrupt
	BTFSS PIR1,RCIF     ; check for receive interrupt
	goto isrexit

	MOVLW 0x02
	MOVWF PORTA         ; toggling our test pins
	CLRF PORTA

	; check for framing error
	
	movlw 0x08
	btfsc RCSTA,FERR
	MOVWF PORTA         ; toggling our test pins
	CLRF PORTA
	

	movf RCREG,W
	BTFSC TXSTA,TRMT
	MOVWF TXREG

	movwf EXAMPLE
	bsf  rxflag,0x01


;	BCF  PIR1,RCIF	    ; clear the flag



isrexit:




	retfie	FAST

;******************************************************************************
;Start of main program
; The main program code is placed here.

Main:

;	clock config
	bsf OSCCON,IRCF0
	bsf OSCCON,IRCF1
	bsf OSCCON,IRCF2

;	bsf OSCTUNE,TUN0

; Timer 0
	bsf T0CON,T08BIT
	bcf T0CON,T0CS    ; clock source internal
	bsf T0CON,PSA     ; disable prescaler

;	*** main code goes here ***
	CLRF PORTA ; Initialize PORTA by
; clearing output
; data latches
	CLRF LATA ; Alternate method

	CLRF PORTC
	CLRF LATC 
	MOVLW 0xCF
	MOVWF TRISC


; to clear output
; data latches
	MOVLW  0xE0 ; Configure I/O
	MOVWF  ANSEL ; for digital inputs 

	CLRF   TRISA ; Set port A as outputs

;	USART config
   	MOVLW  0x19   ; 0x19=decimal 25 for 9600 baud given 16MHz Fosc
	MOVWF  SPBRG 
	BCF    TXSTA,BRGH
	BCF    BAUDCON,BRGH


	bsf    TRISC, TX     
	bsf    TRISC, RX
 	bsf    RCSTA, SPEN
	bsf    TXSTA, SPEN   ; automatically configures for output
    
	bcf    TXSTA, SYNC   ; asyncronous
	bcf    RCSTA, SYNC	

    bsf    RCSTA, CREN


	bsf    TXSTA, TXEN   ; transmit enable	

;	MOVLW 0x19
;	MOVWF TXREG

; enable interrupts
	bsf INTCON, TMR0IE  ; enable timer0 interrupt
	bsf INTCON, PEIE    ; enable peripheral interrupts for usart
	bsf PIE1, RCIE      ; enable receive interrupt
	bsf IPR1, RCIP      ; set recieve priority to high
	bsf INTCON, GIE     ; global interrupt enable

loop:


;	MOVLW 0x35
;	BTFSC TXSTA,TRMT
;	MOVWF TXREG
;	btfss RCSTA, OERR  ; check for overrun
;	goto toggle
;	bcf  RCSTA, CREN  ; clear overrun
;	movlw 0x04
;	MOVWF PORTA         ; toggling our test pins
;	CLRF PORTA
	btfss rxflag,0x01
	goto loop

	MOVLW 0x04
	MOVWF PORTA         ; toggling our test pins
	CLRF PORTA

	bcf rxflag,0x01

;	MOVLW 0x35
;	MOVWF EXAMPLE	
;	MOVF EXAMPLE,0

; display prompt
;	BTFSC TXSTA,TRMT
;	MOVWF TXREG

	goto loop
;******************************************************************************
;End of program

		END
