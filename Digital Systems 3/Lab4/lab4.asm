; **********************************************************
; * Name : Simon Brennan				   *
; * Student Number : 2021282				   *
; * Date : 10/03/2003					   *
; * Assignment No : LAB4.asm				   *
; * Description : This program is a 8 bit binary counter   *
; *		  that counts in 8421 code, through portd  *
; *		  using a half a second interval loop      *
; *		  The counter will only count up when	   *
; *		  the switch on PortA bit 4 is pressed 	   *	
; * 							   *
; * Inputs : Address 03h -> Status   		    	   *
; *	     Address 85h -> TrisA			   *			 	     
; *	     Address 88h -> TrisD			   *	 
; *          Address 20h -> Loop1			   *	
; *          Address 21h -> Loop2			   *
; *          Address 22h -> Loop3			   *		
; *	     Address 05h -> PortA	
; * Outputs: Address 03h -> PortD			   *
; **********************************************************

	list p=16F877
Status 	EQU	03h 	; Address of status register
TrisA   EQU	85h	; Address of Tristate Buffer A.
TrisD  	EQU     88h 	; Address of Tristate Buffer D.
Loop1  	EQU	20h 	; Count variable for the first loop
Loop2  	EQU	21h 	; Count variable for the second loop
Loop3  	EQU	22h 	; Count variable for the first loop
PortA   EQU	05h	; Address of Port A.
PortD   EQU 	08h 	; Address of Port D.

	ORG 0000h

START
	BSF Status,5	; Change to Memory Bank 1
	CLRF TrisD	; Set all bits on PortD to outputs
	BSF TrisA,4	; Set Bit 3 on PortA to input
	BCF Status,5	; Move to Memory Bank 0
	CLRF PortD	; Switch off all LED's

SWITCH
	BTFSS PortA,4	; Check if switch has been pressed
	INCF PortD,1    ; Increment portD to make it cound
	CALL DELAY	; Give us a half a second delay		
	GOTO SWITCH     ; Go and check switch again

DELAY
	;RETURN		;Used for simulation purposes
	MOVLW 03h	;Set delay for 0.5 Second
	MOVWF Loop3 	;Set Loop3 to Loop 3 Times
LOOP	
	DECFSZ Loop1,1  ;Loop 255 times then move to next loop
	Goto LOOP	;Go Back to the beginning of the Loop
	DECFSZ Loop2,1  ;Loop 255 times then move to next loop
	Goto LOOP	;Go Back to the beginning of the Loop	
	RETURN		;
	DECFSZ Loop3,1  ;Loop 5 times then move to next loop
	Goto LOOP	;Go Back to the beginning of the Loop
	RETURN		;Go back and execute instruction after last call
	
	end		;End of Source

