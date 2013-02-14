; **********************************************************
; * Program Name : Serial port TX for PIC		   *
; * Programmer : Simon Brennan				   *
; * Registers : 					   *
; *	     Address 03h -> Status                         *
; *	     Address 02h -> PCL				   *
; *	     Address 1h	 -> F				   *		
; *	     Address 9fh -> Adcon1			   *	
; *	     Address 85h -> TrisA			   *
; * 	     Address 88h -> TrisD		           *
; *          Address 20h -> Loop1			   *	
; *          Address 21h -> Loop2			   *
; *          Address 22h -> Loop3			   *		
; *          Address 23h -> Counter			   *		
; * 	     Address 05h -> PortA			   *
; *	     Address 05h -> PortD			   *	
; *	     Address 98h -> TXSTA			   *		
; *	     Address 99h -> SPBRG		           *
; *	     Address 19h -> TXREG		           *
; *	     Address 18h -> RCSTA		           *
; *							   *
; * Version: 0.1 - Test Version		                   *
; **********************************************************

	list p=16F877
PCL		EQU	02h	; Address of program counter
F		EQU	1h	; Send Result to File
W		EQU	0h	; Send Result to Working Register
Status 		EQU	03h 	; Address of status register
TrisA   	EQU	85h	; Address of Tristate Buffer A.
TrisC		EQU     87h	;
TrisD  		EQU     88h 	; Address of Tristate Buffer D.
Loop1  		EQU	20h 	; Count variable for the first loop
Loop2  		EQU	21h 	; Count variable for the second loop
Loop3  		EQU	22h 	; Count variable for the third loop
PortA   	EQU	05h	; Address of Port A.
PortD   	EQU 	08h 	; Address of Port D.
TXSTA		EQU	98h	; Serial Port Transmit Control Register
SPBRG		EQU	99h	; Serial Port Baud Rate Generator Setting Register
TXREG		EQU	19h	; Serial Port Transmit register
RCREG		EQU	1Ah	; Serial Port Receive
RCSTA		EQU	18h	; Serial Port Receive register control register
Adcon1		EQU	9Fh	; Analogue Digital Register
PIR1		EQU	0Ch	; Analogue Digital Register
Zflag		EQU     02h	;
Tempreg		EQU	23h	; Temp Receive Register

	ORG 0000h		
INIT
	BSF	Status,5	; Move to memory bank 1
	movlw	0FFh		;set tris bits for TX and RX
	movwf	TrisC           ;
	clrf    TrisD		;
INITSERIAL	
	MOVLW	19h		; Set the baud rate to 9600 
	MOVWF   SPBRG		; //
	MOVLW	b'00000100'	; Set serial port = on , asynchronous, brgh = 1, 
	MOVWF	TXSTA		; //
	BCF 	Status,5	; Move to Memory Bank 0
	MOVLW	b'10010000'	; Set serial port = on , continuous recieve
	MOVWF	RCSTA		; //
	CLRF    PortD		;
START
	movf    RCREG,W		; Get the received serial port value
	movwf	PortD
TEST
	GOTO 	START     	; Go and check the switches again
	end			;End of Source
		
