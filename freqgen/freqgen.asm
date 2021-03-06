; =================================================================
; = Written By : Simon Brennan					  =
; = Date Written : 7 January 2004				  =
; = Description : This program uses timer0 to generate a square	  =
; = 		  wave form at a selectable frequncy		  = 
; = Version : 1.00 - Generate a 2khz wave			  =
; =           1.01 - Added Saving of w-reg, status reg during     =
; =	      	     the tmr0 interupt call. 
; =================================================================
	list p=16f877

; Variable equates

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
temw		equ	24H	;
temstat		equ	25H	;

org	0000h   
        goto    INIT
	
	org     0004h
INTSERVICE
	movwf 	temw   		;Copy W to TEMP register
	swapf 	status,0 	;Swap status to be saved into W
	clrf 	status 		;bank 0, regardless of current bank, Clears IRP,RP1,RP0
	movwf 	temstat     	;Save status to bank zero STATUS_TEMP register

	bsf     portd,0
	bcf     intcon,2	; Clear the tmr0 flag
	movlw   32h		; Set TMR0 to count 50 times
	movwf   tmr0		; //
	
	clrf 	status 		;bank 0, regardless of current bank, Clears IRP,RP1,RP0
	swapf 	temstat,0 	;Swap STATUS_TEMP register into W
				;(sets bank to original state)
	movwf 	status 		;Move W into STATUS register
	swapf 	temw,1 		;Swap W_TEMP
	swapf 	temw,0 		;Swap W_TEMP into W
	retfie

INIT
	movlw   65h		; Set TMR0 to count 100 times
	movwf   tmr0		; //		
	movlw	b'10100000'	; Enable interupts, Enable TMR0 interupt
	movwf	intcon		; //
	bsf     status,rp0	; Move to rambank 1
	clrf    trisd		; Set all bits on PortD to output
	movlw   b'10000000'     ; Disable portb pullup resistors, Set tmr0 clock to internal,
	movwf   optionreg	; Set prescaler to tmr0, set prescaler 1:128
	bcf     status,rp0	; move to rambank 0
	clrf    portd		; Clear all outputs on portd
START
	clrf	portd		;
	goto    START		;  Loop forever
	end			; end of source code


