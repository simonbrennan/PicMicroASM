; **********************************************************
; * Name : Simon Brennan				   *
; * Student Number : 2021282				   *
; * Date : 5/03/2003					   *
; * Assignment No : LAB3.asm				   *
; * Description : This program is a 8 bit binary counter   *
; *		  that counts in 8421 code, through portd  *
; *		  using a half a second interval loop      *
; * 							   *
; * Inputs : Address 03h -> Status   		    	   *
; * 	     Address 88h -> TrisD		           *
; *          Address 20h -> Loop1			   *	
; *          Address 21h -> Loop2			   *
; *          Address 22h -> Loop3			   *		
; * Outputs: Address 03h -> PortD			   *
; **********************************************************

	list p=16F877
Status 	EQU	03h 	; Address of status register
TrisD  	EQU     88h 	; Address of Tristate Buffer D.
Loop1  	EQU	20h 	; Count variable for the first loop
Loop2  	EQU	21h 	; Count variable for the second loop
Loop3  	EQU	22h 	; Count variable for the first loop
PortD   EQU 	08h 	; Address of Port D.

	ORG 0000h

START
	BSF Status,5	; Change to Memory Bank 1
	CLRF TrisD	; Set all bits on PortD to outputs
	BCF Status,5	; Move to Memory Bank 0
	CLRF PortD	; Switch off all LED's
START2	
	INCF PortD,1    ; Increment portD to make it cound
	CALL DELAY	; Give us a half a second delay	
	Goto START2

DELAY
	;RETURN		;Used for simulation purposes
	MOVLW 03h	;Set delay for 0.5 Second
	MOVWF Loop3 	;Set Loop3 to Loop 3 Times
LOOP	
	DECFSZ Loop1,1  ;Loop 255 times then move to next loop
	Goto LOOP	;Go Back to the beginning of the Loop
	DECFSZ Loop2,1  ;Loop 255 times then move to next loop
	Goto LOOP	;Go Back to the beginning of the Loop	
	DECFSZ Loop3,1  ;Loop 5 times then move to next loop
	RETURN
	Goto LOOP	;Go Back to the beginning of the Loop
	RETURN		;Go back and execute instruction after last call
	
	end		;End of Source
	
