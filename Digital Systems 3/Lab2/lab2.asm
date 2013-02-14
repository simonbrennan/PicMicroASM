; **********************************************************
; * Name : Simon Brennan				   *
; * Student Number : 2021282				   *
; * Date : 17/02/2003					   *
; * Assignment No : LAB2.asm				   *
; * Description : This program switches a LED connected	   *
; *		  to PORTD (Bit 7) on for 1 second and 	   *
; *		  off for 1 second continuosly using a 	   *
; *               loop.        				   *
; * 							   *
; * Inputs : Address 03h -> Status   		    	   *
; * 	     Address 88h -> TrisD		           *
; *          Address 20h -> Count1 			   *	
; *          Address 21h -> Count2			   *
; *          Address 22h -> Count3			   *		
; * Outputs: Address 03h -> PortD			   *
; **********************************************************

	list p=16F877
Status 	EQU	03h 	; Address of Status register
TrisD  	EQU     88h 	; Address of Tristate Buffer D.
Count1 	EQU	20h 	; Count variable for the first loop
Count2 	EQU	21h 	; Count variable for the second loop
Count3 	EQU	22h 	; Count variable for the first loop
PortD   EQU 	08h 	; Address of Port D.

	ORG 0000h

START
	BSF Status,5		; Change to Memory Bank 1
	CLRF TrisD		; Set all bits on PortD to outputs
	BCF Status,5		; Move to Memory Bank 0
	CLRF PortD		; Switch off all LED's
START2	
	BSF PortD,7 	   	; Switch LED on PortD, bit 7 on
	CALL DELAY		; Give us a 1 second delay	
	BCF PortD,7		; Switch LED on PortD, bit 7 off
	CALL DELAY		; Give us a 1 Second Delay
	Goto START2

DELAY
	MOVLW 	05h		;Set delay for 1 Second
	MOVWF 	Count3	 	;Set Loop3 to Loop 5 Times
	;RETURN			;Only used for Simulation purposes
LOOP	
	DECFSZ 	Count1,1 	 ;Loop 255 times then move to next loop
	Goto 	LOOP		;Go Back to the beginning of the Loop
	DECFSZ 	Count2,1 	;Loop 255 times then move to next loop
	Goto 	LOOP		;Go Back to the beginning of the Loop	
	DECFSZ 	Count3,1  	;Loop 5 times then move to next loop
	Goto 	LOOP		;Go Back to the beginning of the Loop
	RETURN			;Go back and execute instruction after last call
	
	end			;End of Source
	
