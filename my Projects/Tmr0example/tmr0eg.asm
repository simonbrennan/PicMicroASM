;**********************************************************
;* Program Name : Timer0 test program                     *
;* Date written : 24 October 2003			  *
;* Description : This program demostrates how to setup    *
;*               and use the Tmr0 function of PIC         *
;* Interupts : Yes, Tmr0 Interupt			  *
;**********************************************************
	list p=16f877

rp0		equ	05h	; Bit 5 of Status Register (Ram bank select)
f		equ	01h	; Result of operation into File
w		equ	00h	; Result of operation into Working Register
tmr0		equ     01h	; Timer 0 register
zflag		equ     02h	; Zflag of status register
pcl		equ	02h	; Address of program counter latch
status 		equ	03h 	; Address of status register
porta   	equ	05h	; Address of Port A.
portd   	equ 	08h 	; Address of Port D.
intcon          equ     0Bh	; Address of interupt control register
loop1  		equ	20h 	; Count variable for the first loop
loop2  		equ	21h 	; Count variable for the second loop
loop3		equ	22h	; Count variable for the third loop
counter		equ	23h	; Counter variable for running lights.
optionreg	equ	81h	; TMR0 option register
trisa   	equ	85h	; Address of Tristate Buffer A.
trisd  		equ     88h 	; Address of Tristate Buffer D.
adcon1		equ	9Fh	; Address of Adcon1.

	org	0000h   
        goto    INIT
	
	org     0004h
INTSERVICE
	incf    portd
	bcf     intcon,2	; Clear the tmr0 flag
	movlw   15h		; Set TMR0 to count 6 times
	movwf   tmr0		; //
	retfie

INIT
	movlw   15h		; Set TMR0 to count 6 times
	movwf   tmr0		; //
	movlw	b'10100000'	; Enable interupts, Enable TMR0 interupt
	movwf	intcon		; //
	bsf     status,rp0	; Move to rambank 1
	clrf    trisd		; Set all bits on PortD to output
	movlw   b'10000110'     ; Disable portb pullup resistors, Set tmr0 clock to internal,
	movwf   optionreg	; Set prescaler to tmr0, set prescaler 1:128
	bcf     status,rp0
	clrf    portd		; Clear all outputs on portd
START
				; Do nothing forever, Wait fo interupt
	GOTO    START
	end			;end of source
