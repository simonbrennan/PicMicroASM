; **********************************************************
; * Name : Simon Brennan				   *
; * Student Number : 2021282				   *
; * Date : 12/03/2003					   *
; * Assignment No : LAB5.asm				   *
; * Description : This program is a 8 bit binary counter   *
; *		  that counts in 8421 code, through portd  *
; *		  using a half a second interval loop      *
; *		  The counter will only count up when	   *
; *		  the switch on PortA bit 4 is pressed 	   *
; * 		  and count down when switch on PortA      * 	
; *		  bit 5 is pressed			   *	
; * 							   *
; * Inputs : Address 03h -> Status   		    	   *
; * 	     Address 88h -> TrisD		           *
; *	     Address 85h -> TrisA			   *
; *          Address 20h -> Loop1			   *	
; *          Address 21h -> Loop2			   *
; *          Address 22h -> Loop3			   *		
; * 	     Address 05h -> PortA			   *
; *	     Address 9Fh -> Adcon1	
; * Outputs: Address 03h -> PortD			   *
; *							   *
; * Version: 1.0 - Works perfectly                         *
; **********************************************************

	list p=16F877
Status 		EQU	03h 	; Address of status register
TrisA   	EQU	85h	; Address of Tristate Buffer A.
TrisD  		EQU     88h 	; Address of Tristate Buffer D.
Loop1  		EQU	20h 	; Count variable for the first loop
Loop2  		EQU	21h 	; Count variable for the second loop
Loop3  		EQU	22h 	; Count variable for the first loop
PortA   	EQU	05h	; Address of Port A.
PortD   	EQU 	08h 	; Address of Port D.
Adcon1		EQU	9Fh	; Address of Adcon1.

	ORG 0000h

START
	BSF 	Status,5	; Change to Memory Bank 1
	MOVLW 	0FFh		; Used to make PortA Digital
	MOVWF 	Adcon1  	; Set all bits on PortA to Digital
	CLRF 	TrisD		; Set all bits on PortD to outputs
	CLRF	TrisA		; Set all bits on PortA to outputs
	BSF 	TrisA,4		; Set Bit 3 on PortA to input
	BSF 	TrisA,5		; Set Bit 4 on PortA to input
	BCF 	Status,5	; Move to Memory Bank 0
	CLRF 	PortD		; Switch off all LED's

SWITCH
	BTFSS 	PortA,4		; Check if switch has been pressed
	CALL 	CUP		; Go and count up by one
	BTFSS 	PortA,5		; Check if switch has been pressed
	CALL	CDOWN		; Go and count down by one 
	MOVF	PortA,0		; Check to see if both switches have been pressed
	BTFSC 	Status,2	; If both switches have been pressed Go to error state else carry on
	CALL	ERR		; Go into the error state
	CALL 	DELAY		; Give us half a second delay
	GOTO 	SWITCH     	; Go and check switch again
CUP
	BTFSC	PortA,5		; Go and check if other (RA5) has been pressed
	INCF 	PortD		; Go and count one up
	RETURN			;
CDOWN
	BTFSC 	PortA,4		; Go and check if other (RA4) has been pressed
	DECF 	PortD		; Go and count one down
	RETURN			;
ERR
	CLRF 	PortD		; Switch of all LED's (PortD)
	COMF 	PortD,1		; Switch all LED's on (PortD)	
	CALL 	DELAY		; Give us a half a second delay		
	CLRF	PortD		; Switch of all LED's
	MOVF 	PortA,0		; Check switch status again
	BTFSS   Status,2	; Check if switches are being pressed
	RETURN			; 
	GOTO	ERR		; Loop again until only one switch is being pressed


DELAY
	;RETURN			;Used for simulation purposes
	MOVLW 	03h		;Set delay for 0.5 Second
	MOVWF 	Loop3	 	;Set Loop3 to Loop 3 Times
LOOP	
	DECFSZ 	Loop1,1  	;Loop 255 times then move to next loop
	Goto 	LOOP		;Go Back to the beginning of the Loop
	DECFSZ 	Loop2,1  	;Loop 255 times then move to next loop
	Goto 	LOOP		;Go Back to the beginning of the Loop	
	RETURN			;
	DECFSZ 	Loop3,1  	;Loop 5 times then move to next loop
	Goto 	LOOP		;Go Back to the beginning of the Loop
	RETURN			;Go back and execute instruction after last call
	end			;End of Source

