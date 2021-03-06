; **********************************************************
; * Name : Simon Brennan				   *
; * Student Number : 2021282				   *
; * Date : 26/05/2003					   *
; * Description : This program is a prototype prog to      *
; *		  write and read to an from eeprom memory  *
; * 							   *
; * Inputs : Address 03h  -> Status   		    	   * 
; *	     Address 10Ch -> EEdata			   *
; *	     Address 18Ch -> EEcon1			   *
; *          Address 23h  -> Counter			   *		
; * Version: 1.0 - Works perfectly                         *
; **********************************************************

	list p=16F877
Status 		EQU	03h 	; Address of status register
EEdata		EQU	10Ch	; Address of EEdata register
EEadr		EQU	10Dh	; Address of EEadr Register
EEcon1		EQU	18Ch	; Address of EEcon1 register
EEcon2		EQU	18Dh	;
EEpgd		EQU	07h	; Bit 7 of EEcon1
WREN		EQU 	02h	; Bit 2 of EEcon1
WR		EQU	01h	; Bit 1 of EEcon1
RD		EQU	00h	; Bit 0 of EEcon1
RP0		EQU	05h	; Bank Select Bit in Status Register
RP1		EQU	06h	; Bank Select Bit in Status Register

	ORG 0000h
WRITE
	BSF	Status,RP1	; Switch to Bank 3
	BSF	Status,RP0	; //
	BTFSC	EEcon1,WR	; Check if EEPROM is writing and
	GOTO	$-1		; wait till it's finished
	BCF	Status,RP0	; Switch to Bank 2
	MOVLW	01h		; Set Address to write to
	MOVWF	EEadr		; //
	MOVLW	09h		; Data to write to Address
	MOVWF	EEdata		; //
	BSF	Status,RP0	; Switch to Bank 3
	BCF	EEcon1,EEpgd	; Set memory location	
	BSF	EEcon1,WREN	; Enable EEprom Writing
	MOVLW	055h		; Write 055h to EEcon2
	MOVWF	EEcon2		; //
	MOVLW	0AAh		; Write AAh to EEcon2
	MOVWF	EEcon2		; //
	BSF	EEcon1,WR	; Start write operation
	BCF	EEcon1,WREN	; Disable writing to EEprom
READ
	BSF	Status,RP1	; Switch to Bank 2
	BCF	Status,RP0	; //
	MOVLW	0000h		; Set Address in EEprom to 0000h
	MOVWF	EEdata		; //
	BSF	Status,RP0	; Switch to Bank 3
	BCF	EEcon1,EEpgd	; Point to Address in EEdata
	BSF	EEcon1,RD	; Read EEprom memory
	BCF	Status,RP0	; Switch to bank 2
	MOVF	EEdata,0	; Read value from EEdata
	SUBLW	05h		;
	end 
