; **********************************************************
; * Programmer : Simon Brennan				   *
; * Date : 19/10/2003					   *
; * Description : This program is a simple running light   *
; *		  circuit (Night Rider)                    *
; * 							   *
; * Inputs : Address 03h -> Status   		    	   *
; * 	     Address 88h -> TrisD		           *
; *	     Address 85h -> TrisA			   *
; *          Address 20h -> Loop1			   *	
; *          Address 21h -> Loop2			   *
; *          Address 22h -> Loop3			   *		
; * 	     Address 05h -> PortA			   *
; *	     Address 9Fh -> Adcon1			   *
; * Outputs: Address 03h -> PortD			   *
; *							   *
; * Version: 0.1 - Make Lights run in one direction        *
; **********************************************************

	list p=16F877
rp0		EQU	05h	; Bit 5 of Status Register (Ram bank select)
f		EQU	01h	; Result of operation into File
w		EQU	00h	; Result of operation into Working Register
zflag		EQU     02h	; Zflag of status register
pcl		EQU	02h	; Address of program counter latch
status 		EQU	03h 	; Address of status register
porta   	EQU	05h	; Address of Port A.
portd   	EQU 	08h 	; Address of Port D.
loop1  		EQU	20h 	; Count variable for the first loop
loop2  		EQU	21h 	; Count variable for the second loop
loop3		EQU	22h	; Count variable for the third loop
counter		EQU	23h	; Counter variable for running lights.
trisa   	EQU	85h	; Address of Tristate Buffer A.
trisd  		EQU     88h 	; Address of Tristate Buffer D.
adcon1		EQU	9Fh	; Address of Adcon1.

	ORG 0000h
INIT
	bsf	status,rp0	; Switch to Rambank 1
	movlw   0FFh		; Set all bits on PortA to digital using Adcon1
        movwf   adcon1		; //
	movlw   0ffh		; Set all bits on PortA to input
	movwf   trisa		; //
        clrf    trisd           ; Set all bits on PortD to output (For Led's)
	bcf     status,rp0	; Switch to Rambank 0
	clrf    portd		; Switch off all Led's on portd
        clrf    counter		; Switch		
START
	clrf    portd		;
	btfsc	porta,5		; check if the switch has been pressed
	goto    START		; do nothing if the switch is not pressed
	movf    counter,w	; Check if the counter is at zero
	btfsc   status,zflag	; //
	call    GOUP		; If it is at zero then go and count up (Move LED's to right)
	sublw   03h		; Check if counter is a 7 (Must start going other way)
	btfsc   status,zflag	; //
	call    GODOWN		; If it is at seven then go and count down (Move LED's to left)
        goto    START		; loop this code forever
GOUP
	call    DELAY		; Give us a delay
	movf	counter,w	; use lookup table to get led value
        call    LIGHTCODE	; //
	movwf   portd		; Put returned value into portd
	incf	counter		; increment the counter
	movf    counter,w	; check if counter is at 7
	sublw   03h		; //
	btfsc	status,zflag	;
	return			;
	goto    GOUP		;
GODOWN
	call    DELAY		; Give us a delay
	movf	counter,w	; use lookup table to get led value
        call    LIGHTCODE	; //
	movwf   portd		; Put returned value into portd
	decf	counter		; decrement the counter
	movf    counter,w	; check if counter is at 0
	btfsc	status,zflag	;
	return			;
	goto    GODOWN		;

LIGHTCODE
	movf	counter,w	; //
	addwf	pcl,f		; Set the value on seven segment display to counter
	retlw	b'10000001'	;Decode 
	retlw	b'01000010'	;Decode 
	retlw	b'00100100'	;Decode 
	retlw	b'00011000'	;Decode 
	retlw	b'00011000'	;Decode 
	retlw	b'00100100'	;Decode 
	retlw	b'01000010'	;Decode 
	retlw	b'10000001'	;Decode 
DELAY
	;return			;Used for simulation purposes
	movlw 	01h		;Set delay for 0.1 Second (100ms)
	movwf 	loop3	 	;Set Loop3 to Loop 3 Times
LOOP	
	decfsz 	loop1,1  	;Loop 255 times then move to next loop
	goto 	LOOP		;Go Back to the beginning of the Loop
	decfsz 	loop2,1  	;Loop 255 times then move to next loop
	goto 	LOOP		;Go Back to the beginning of the Loop	
	decfsz 	loop3,1  	;Loop 5 times then move to next loop
	goto 	LOOP		;Go Back to the beginning of the Loop
	return			;Go back and execute instruction after last call
	end			;End of Source


