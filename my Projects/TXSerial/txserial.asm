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
TrisC           EQU     87h	; Address of Tristate Buffer C.
TrisD  		EQU     88h 	; Address of Tristate Buffer D.
PortA   	EQU	05h	; Address of Port A.
PortD   	EQU 	08h 	; Address of Port D.
TXSTA		EQU	98h	; Serial Port Transmit Control Register
SPBRG		EQU	99h	; Serial Port Baud Rate Generator Setting Register
TXREG		EQU	19h	; Serial Port Transmit register
RCSTA		EQU	18h	; Serial Port Receive register
Adcon1		EQU	9Fh	;Analogue Digital Register
Count           EQU     20h	;     

	ORG 0000h		
INIT
	BSF	Status,5	; Move to memory bank 1
	BSF     TrisC,6		; Set TrisC bit 7 to output (For Serial TX)
;Serial Port Init		; 
	MOVLW	19h		; Set the baud rate to 9600 and brgh=1
	MOVWF   SPBRG		; //
	MOVLW	b'00100100'	; Set serial port = on , asynchronous, brgh = 1, Transmit enable
	MOVWF	TXSTA		; //
	BCF 	Status,5	; Move to Memory Bank 0
	MOVLW   b'10000000'     ; Enable Serial Port
	MOVWF	RCSTA		; //	
	CLRF    Count		;
	INCF    Count		;
START
	MOVF	Count,W		;
	MOVWF   TXREG           ; Send data to serial port
	INCF    Count
	BSF     Status,5	; Go to ram bank 1
	btfss   TXSTA,1		; Check if transmitter is busy
	goto    $-1		; Wait till transmitter is finished before sending again
	BCF     Status,5	; Go to ram bank 0
	GOTO 	START     	; Go and check the switches again
	end			; end of source

