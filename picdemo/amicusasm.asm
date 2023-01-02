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

EXTERN prompt_r
EXTERN cmd_proc_r

;******************************************************************************
;Configuration bits
;Microchip has changed the format for defining the configuration bits, please 
;see the .inc file for futher details on notation.  Below are a few examples.

CONFIG	FOSC  = HS    ; high-speed occillator   
CONFIG  FCMEN = OFF   ; failsafe clock monitior disabled
CONFIG  IESO  = OFF   ; oscilator switchover mode disabled
CONFIG  PWRT  = ON    ; power-up timer enable
CONFIG  BOREN = OFF   ; brown-out reset disabled
CONFIG  WDTEN = OFF   ; watchdog timer enable controlled by SWDTEN in WDTCON
CONFIG  MCLRE = ON    ; MCLRE pin enabled (master clear reset pin)
CONFIG  DEBUG = OFF
; CONFIG  CCP2MX = ON
;CONFIG  LVP   = ON       

;******************************************************************************
;Variable definitions
; These variables are only needed if low priority interrupts are used. 
; More variables may be needed to store other special function registers used
; in the interrupt routines.

udata
	rxdata res 1
	rxflag res 1
	WREG_TEMP res 1	  ;variable used for context saving 
	STATUS_TEMP	res 1 ;variable used for context saving
	BSR_TEMP res 1	  ;variable used for context saving

;******************************************************************************
;EEPROM data
; Data to be programmed into the Data EEPROM is defined here
;	ORG	0xf00000
;	DE	"Test Data",0,1,2,3,4,5

;******************************************************************************
;Reset vector
; This code will start executing when a reset occurs.

ORG	0x0000
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

	movlw 0x00          ; initialize our bit toggle field

	; TIMER0 interrupt
	btfss INTCON,TMR0IF ; TIMER0 flag check. skip next instruction if clear
    goto rxisr

	movlw 0x01
	movwf PORTA         ; toggling our test pins
	clrf PORTA

	bcf   INTCON,TMR0IF ; clear the flag
	
rxisr:
	; USART receive interrupt
	btfss PIR1,RCIF     ; check for receive interrupt
	goto isrexit

	movlw 0x02
	movwf PORTA         ; toggling our test pins
	clrf  PORTA

	; check for framing error
	
	movlw 0x08
	btfsc RCSTA,FERR
	movwf PORTA         ; toggling our test pins
	clrf  PORTA
	
	movf RCREG,W
	movwf rxdata
	movlw 0x00

	bsf  rxflag,0x01
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

	; Timer 0
	bsf T0CON,T08BIT
	bcf T0CON,T0CS    ; clock source internal
	bsf T0CON,PSA     ; disable prescaler

	clrf LATA ; Alternate method

	clrf  LATC 
	clrf TRISC  ; port C as outputs. USART config will handle the RX/TX pins.

	; PWM configuration
	bsf   TRISC,1  ; disable PWM output
	movlw 0xff
	movwf PR2       ; set PWM period
	bsf   CCP2CON,CCP2M3
	bsf   CCP2CON,CCP2M2
	clrf  CCPR2H    ; PWM high byte
	movlw 0xf5
	movwf CCPR2L    ; PWM low byte
	bcf   PIR1,TMR2IF
	clrf  T2CON
	bsf   T2CON,TMR2ON
pwmstart:
	btfsc PIR1,TMR2IF
	goto pwmstart
	bcf TRISC,1  ; set as output



	movlw 0xE0 ; Configure I/O
	movwf ANSEL ; for digital inputs 

	clrf   TRISA ; Set port A as outputs

   	movlw  0x19   ; 0x19=decimal 25 for 9600 baud given 16MHz Fosc
	movwf  SPBRG 
	bcf    TXSTA,BRGH
	bcf    BAUDCON,BRGH


	bsf    TRISC, TX     
	bsf    TRISC, RX
 	bsf    RCSTA, SPEN
	bsf    TXSTA, SPEN   ; automatically configures for output
    
	bcf    TXSTA, SYNC   ; asyncronous
	bcf    RCSTA, SYNC	

    bsf    RCSTA, CREN

	bsf    TXSTA, TXEN   ; transmit enable	

; enable interrupts
	bsf INTCON, TMR0IE  ; enable timer0 interrupt
	bsf INTCON, PEIE    ; enable peripheral interrupts for usart
	bsf PIE1, RCIE      ; enable receive interrupt
	bsf IPR1, RCIP      ; set recieve priority to high
	bsf INTCON, GIE     ; global interrupt enable

prompt:
	call prompt_r  ; paint the user prompt to the serial terminal

loop:
	btfss rxflag,0x01 ; wait on a received command byte
	goto loop
	bcf rxflag,0x01

	; echo the command
	movf  rxdata,W
echo:
	btfss TXSTA,TRMT
	goto  echo
	movwf TXREG
	
	movf  rxdata,W
	call cmd_proc_r

	goto prompt
;******************************************************************************
;End of program

end