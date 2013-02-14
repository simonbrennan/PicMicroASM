; **********************************************************
; * Program Name : Serial port TX for PIC		   *
; * Programmer : Simon , Gordon 			   *
; * Description : This program allows a PC to send a start *
; *               character ('s') and RX data from PIC     *
; **********************************************************

	list p=16F877	
	include <p16f877.inc>

PCL		EQU	02h	; Address of program counter
F		EQU	1h	; Send Result to File
W		EQU	0h	; Send Result to Working Register
Status 		EQU	03h 	; Address of status register
TrisA   	EQU	85h	; Address of Tristate Buffer A.
TrisC		EQU     87h	; Address of Tristate Buffer C.
TrisD  		EQU     88h 	; Address of Tristate Buffer D.
Loop1  		EQU	24h 	; Count variable for the first loop
Loop2  		EQU	25h 	; Count variable for the second loop
Loop3  		EQU	26h 	; Count variable for the third loop
PortA   	EQU	05h	; Address of Port A.
PortD   	EQU 	08h 	; Address of Port D.
TXSTA		EQU	98h	; Serial Port Transmit Control Register
SPBRG		EQU	99h	; Serial Port Baud Rate Generator Setting Register
TXREG		EQU	19h	; Serial Port Transmit register
RCREG		EQU	1Ah	; Serial Port Receive
RCSTA		EQU	18h	; Serial Port Receive register control register
Adcon1		EQU	9Fh	; Analogue Digital Register
PIR1		EQU	0Ch	; Analogue Digital Register
PIE1            EQU	8CH	; Peripheral Interupt Enable

; Start of Interupt Vector 
	ORG 0000h
	GOTO MAIN	
	
	ORG 0004h		; Start of interupt vector
INTER
	BCF	RCSTA,4		; Disable Continuous Recieve while board Transmits
	BSF	Status,5	; Move to memory bank 1
	BSF     TXSTA,5		; Enable USART Transmit
	BCF	Status,5	; Move to memory bank 0
	movwf   TXREG		; Send value to serial port
	BSF	RCSTA,4		; Enable Continuous Recieve and wait for next start character
	RETFIE

	

;Start of main program
MAIN
	BSF	Status,5	; Move to memory bank 1
	MOVLW	0FFh		; set tris bits 6,7 for TX and RX, rest of pins
	MOVWF	TrisC           ; to input
	CLRF    TrisD		; Set all bits on portd to outputs

;Initialize Serial Port
	MOVLW	19h		; Set the baud rate to 9600
	MOVWF   SPBRG		; //
	MOVLW	b'00000000'	; Set serial port = on , asynchronous, brgh = 0, 
	MOVWF	TXSTA		; //
	BCF 	Status,5	; Move to Memory Bank 0
	MOVLW	b'10000000'	; Set serial port = on 
	MOVWF	RCSTA		; //
	CLRF    PortD		;

;Initialize Recieve Interupts
	BSF     Status,5	; Move to memory bank 1
	BSF	PIE1,5		; Enable USART Recieve Interupts	
	BCF     Status,5	; Move to memory bank 0 
	MOVLW 	B'11000000'	; Global Interupt Enable, Peripheral Interupt enable
	MOVWF 	INTCON 		; //
	MOVLW	00h		; Set Working Register to 0
	BSF	RCSTA,4		; Enable Continuous Recieve

;Start to recieve values
START
	movlw	2Eh		; Value to send to PC
	GOTO START		; loaded into the Working Reg when the interupt occurs
	end			;








