; **********************************************************
; * Name : Simon Brennan				   *
; * Date : 30/03/2003					   *
; * Description : This program uses the onboard a/d 	   *
; *		  in the PIC to read a analogue voltage    *
; *		 					   *
; *							   *
; * Inputs : Address 03h -> Status   		    	   *
; *	     Address 02h -> PCL				   *
; *	     Address 1h	 -> F				   *		
; *	     Address 9fh -> Adcon1			   *	
; * 	     Address 88h -> TrisD		           *
; *	     Address 85h -> TrisA			   *
; *          Address 20h -> Loop1			   *	
; *          Address 21h -> Loop2			   *
; *          Address 22h -> Loop3			   *		
; *          Address 23h -> Counter			   *		
; * 	     Address 05h -> PortA			   *
; * Outputs: Address 03h -> PortD			   *
; *							   *
; * Version: 0.1 - Basic Interface, read ADcon and display *
; **********************************************************

	list p=16F877
	include <p16f877.inc>
	__CONFIG _BODEN_OFF&_CP_OFF&_WRT_ENABLE_ON&_PWRTE_ON&_WDT_OFF&_XT_OSC&_DEBUG_OFF&_CPD_OFF&_LVP_OFF

PCL		EQU	02h	; Address of program counter
F		EQU	1h	; Result of operation into File
W		EQU	0h	; Result of operation into Working Register
Status 		EQU	03h 	; Address of status register
RP0		EQU	05h	; Bit 5 of Status Register
TrisA   	EQU	85h	; Address of Tristate Buffer A.
TrisB   	EQU	86h	; Address of Tristate Buffer A.
PortA   	EQU	05h	; Address of Port A.
PortB   	EQU	06h	; Address of Port A.
Loop1  		EQU	20h 	; Count variable for the first loop
Loop2  		EQU	21h 	; Count variable for the second loop
Loop3  		EQU	22h 	; Count variable for the first loop
Counter		EQU	23h	; Stores the status of counter
Adh		EQU	1Eh	;
Adl		EQU	9Eh	;
Unit		EQU	24h	;
Ten		EQU	25h	;
Hundred		EQU	26h	;
Temp		EQU	27h	;
Adcon1		EQU	9Fh	; Address of Adcon1.
Adcon0		EQU	1Fh	; Analogue Digital Register
GO		EQU	02h	; GO/Done bit for Adconverter

;Defines for I/O ports that provide LCD data & control
LCD_DATA	equ	PORTB
LCD_CNTL	equ	PORTB

; Defines for I/O pins that provide LCD control
RS		equ	5
E		equ	4

; LCD Module commands
DISP_ON		EQU	0x00C	; Display on
DISP_ON_C	EQU	0x00E	; Display on, Cursor on
DISP_ON_B	EQU	0x00F	; Display on, Cursor on, Blink cursor
DISP_OFF	EQU	0x008	; Display off
CLR_DISP	EQU	0x001	; Clear the Display
ENTRY_INC	EQU	0x006	;
ENTRY_INC_S	EQU	0x007	;
ENTRY_DEC	EQU	0x004	;
ENTRY_DEC_S	EQU	0x005	;
DD_RAM_ADDR	EQU	0x080	; Least Significant 7-bit are for address
DD_RAM_UL	EQU	0x080	; Upper Left coner of the Display
;

	cblock 20h
		Byte
		Count
		Count1	
		Count2	
	endc	


INIT
	BSF	Status,RP0	;Switch to Rambank 1
	MOVLW	B'01000001'	;
	CLRF	Adcon1		;Set all bits on PortA to analogue
	BSF	Adcon1,7	;Set ADFM to righthand justification
	CLRF	TrisA		;
	BSF	TrisA,0		;Set RA0 as input
	CLRF	TrisB		;Set All Bits PortB to output
	BCF	Status,RP0	;Switch to Rambank 0
	CLRF	Unit		;Reset The Unit Value
	CLRF	Ten		;Reset The Tens Value
	CLRF	Hundred		;Reset The Hundreds Value
	MOVLW	B'01000001'	;Set ADC to Channel 0 (RA0), Switch on ADC, Set Sampling Rate to Fosc/32
	MOVWF	Adcon0		;//
START
	CALL	ADREAD		;Go into the Km/h reading part
	GOTO	START		;Loop to start
ADREAD
	CLRF	Unit		;Reset The Unit Value
	CLRF	Ten		;Reset The Tens Value
	CLRF	Hundred		;Reset The Hundreds Value
	BSF	Adcon0,GO	; Start A/D Conversion
	CALL	DELAY		; Delay for aquisition
	CALL	CONVERT		; Convert AD value to Units, Tens, Hundreds
	CALL	UPDATEDISP	; Update LCD Displays
	BTFSS	PortA,4		; Keep showing km/h unit switch pressed for next mode
	RETURN			;
	GOTO	ADREAD		;
UPDATEDISP
	call	InitLCD
	call	clrLCD
	call	L1homeLCD	;cursor on line 1
 	movlw	' '
	call	putcLCD
 	movlw	' '
	call	putcLCD
 	movlw	' '
	call	putcLCD
 	movlw	' '
	call	putcLCD
	movlw	'A'
	call	putcLCD
	movlw	'/'
	call	putcLCD
	movlw	'D'
	call	putcLCD
	movlw	' '
	call	putcLCD
	movlw	'V'
	call	putcLCD
	movlw	'a'
	call	putcLCD
	movlw	'l'
	call	putcLCD
	movlw	'u'
	call	putcLCD
	movlw	'e'
	call	putcLCD

	call	L2homeLCD
	movlw	' '
	call	putcLCD
 	movlw	' '
	call	putcLCD
 	movlw	' '
	call	putcLCD
 	movlw	' '
	call	putcLCD
 	movf	Hundred,W
	addlw	31h
	call	putcLCD
 	movf	Ten,W
	addlw	31h
	call	putcLCD
 	movf	Unit,W
	addlw	31h;
	call	putcLCD
	movlw	' '
	call	putcLCD
	movlw	'm'
	call	putcLCD
	movlw	'V'
	call	putcLCD
	movlw	' '
	call	putcLCD
 	movlw	' '
	call	putcLCD
	movlw	' '
	call	putcLCD
	CALL	DELAY		;
	RETURN			;
CONVERT	
	BSF	Status,RP0	; Move to Bank 1
	MOVF	Adl,W		;
	BCF	Status,RP0	;
	MOVWF	Temp		;
	BTFSC	Temp,7		; Check 512
	CALL	CHK512		;
	CALL	CHKUNIT		;
	CALL	CHKTEN		;
	BTFSC	Temp,6		;
	CALL	CHK256		;
	CALL	CHKUNIT		;
	CALL	CHKTEN		;
	BTFSC	Temp,5		;
	CALL	CHK128		;
	CALL	CHKUNIT		;
	CALL	CHKTEN		;
	BTFSC	Temp,4		;
	CALL	CHK64		;
	CALL	CHKUNIT		;
	CALL	CHKTEN		;
	BTFSC	Temp,3		;
	CALL	CHK32		;
	CALL	CHKUNIT		;
	CALL	CHKTEN		;
	BTFSC	Temp,2		;
	CALL	CHK16		;
	CALL	CHKUNIT		;
	CALL	CHKTEN		;
	BTFSC	Temp,1		;
	CALL	CHK8		;
	CALL	CHKUNIT		;
	CALL	CHKTEN		;
	BTFSC	Temp,0		;
	CALL	CHK4		;
	CALL	CHKUNIT		;
	CALL	CHKTEN		;
	BTFSC	Adh,1		;
	CALL	CHK2		;
	CALL	CHKUNIT		;
	CALL	CHKTEN		;
	BTFSC	Adh,0		;	
	CALL	CHK1		;
	CALL	CHKUNIT		;
	CALL	CHKTEN		;
	RETURN			;
CHK512
	INCF	Hundred		; Add 5 to hundred
	INCF	Hundred		; 
	INCF	Hundred		; 
	INCF	Hundred		; 
	INCF	Hundred		; 
	INCF	Ten		; Add 1 to ten
	INCF	Unit		; Add 2 to unit
	INCF	Unit		;
	RETURN
CHK256
	INCF	Hundred		; Add 2 to hundred
	INCF	Hundred		; 
	INCF	Ten		; Add 5 to ten
	INCF	Ten		; 
	INCF	Ten		; 
	INCF	Ten		; 
	INCF	Ten		; 
	INCF	Unit		; Add 6 to unit
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	RETURN
CHK128
	INCF	Hundred		; Add 1 to hundred
	INCF	Ten		; Add 2 to ten
	INCF	Ten		; 
	INCF	Unit		; Add 8 to unit
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	RETURN
CHK64
	INCF	Ten		; Add 6 to ten
	INCF	Ten		; 
	INCF	Ten		; 
	INCF	Ten		; 
	INCF	Ten		; 
	INCF	Ten		; 
	INCF	Unit		; Add 4 to unit
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	RETURN
CHK32
	INCF	Ten		; Add 3 to ten
	INCF	Ten		; 
	INCF	Ten		; 
	INCF	Unit		; Add 2 to unit
	INCF	Unit		;
	RETURN
CHK16
	INCF	Ten		; Add 1 to ten
	INCF	Unit		; Add 6 to unit
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	RETURN
CHK8	
	INCF	Unit		; Add 8 to unit
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	RETURN
CHK4
	INCF	Unit		; Add 4 to unit
	INCF	Unit		;
	INCF	Unit		;
	INCF	Unit		;
	RETURN			;
CHK2
	INCF	Unit		; Add 2 to unit
	INCF	Unit		;
	RETURN			;
CHK1
	INCF	Unit		; Add 1 to unit
	RETURN			;

	
CHKUNIT
	MOVF	Unit,0		;
	SUBLW	09h		; Loop 9 times
	BTFSC	Status,2	; Unit = 9 so return
	RETURN			
	BTFSS	Status,0	; Unit < 9 so return
	CALL	DO1		;
	RETURN			
DO1
	INCF	Ten		;
	MOVLW	B'00001010'	;
	SUBWF	Unit,1		;	
	RETURN	
	
CHKTEN
	MOVF	Ten,0		;
	SUBLW	09h		; Subtract 9 times
	BTFSC	Status,2	; Ten = 9 so return
	RETURN			
	BTFSS	Status,0	; Unit < 9 so add difference to hundred
	CALL	DO2		;
	RETURN			
DO2
	INCF	Hundred		;
	MOVLW	B'00001010'	;
	SUBWF	Ten,1		;	
	RETURN

;*******************************************************************
;* The LCD Module Subroutines                                      *
;* Command sequence for 2 lines of 5x16 characters                 *
;*******************************************************************
InitLCD
	bcf	STATUS,RP0	; Bank 0
	bcf	STATUS,RP1
	clrf	LCD_DATA	; Clear LCD data & control bits
	bsf	STATUS,RP0	; Bank 1
	movlw	0xc0		; Initialize inputs/outputs for LCD
	movwf	LCD_DATA
	btfsc	PCON,NOT_POR	; Check to see if POR reset or other
	goto	InitLCDEnd

	bcf	STATUS,RP0	; If POR reset occured, full init LCD
	call	LongDelay
	movlw   0x02		; Init for 4-bit interface
	movwf   LCD_DATA
	bsf     LCD_CNTL, E
	bcf     LCD_CNTL, E
	call	LongDelay

	movlw	b'00101000'
	call	SendCmd
	movlw	DISP_ON		; Turn display on
	call	SendCmd
	movlw	ENTRY_INC	; Configure cursor movement
	call	SendCmd
	movlw	DD_RAM_ADDR	; Set writes for display memory
	call	SendCmd

InitLCDEnd			; Always clear the LCD and set
	bcf	STATUS,RP0	; the POR bit when exiting
	call	clrLCD
	bsf	STATUS,RP0
	bsf	PCON,NOT_POR
	bcf	STATUS,RP0
	return

;*******************************************************************
;*SendChar - Sends character to LCD                                *
;*This routine splits the character into the upper and lower       * 
;*nibbles and sends them to the LCD, upper nibble first.           *
;*******************************************************************
putcLCD
	movwf	Byte		; Save WREG in Byte variable
	call	Delay
	swapf	Byte,W		; Write upper nibble first
	andlw	0x0f
	movwf	LCD_DATA
	bsf	LCD_CNTL, RS	; Set for data
	bsf	LCD_CNTL, E	; Clock nibble into LCD
	bcf	LCD_CNTL, E
	movf	Byte,W		; Write lower nibble last
	andlw	0x0f
	movwf	LCD_DATA
	bsf	LCD_CNTL, RS	; Set for data
	bsf	LCD_CNTL, E	; Clock nibble into LCD
	bcf	LCD_CNTL, E
	return

;*******************************************************************
;* SendCmd - Sends command to LCD                                  *
;* This routine splits the command into the upper and lower        * 
;* nibbles and sends them to the LCD, upper nibble first.          *
;*******************************************************************
SendCmd
	movwf	Byte		; Save WREG in Byte variable
	call	Delay
	swapf	Byte,W		; Send upper nibble first
	andlw	0x0f
	movwf	LCD_DATA
	bcf	LCD_CNTL,RS	; Clear for command
	bsf	LCD_CNTL,E	; Clock nibble into LCD
	bcf	LCD_CNTL,E
	movf	Byte,W		; Write lower nibble last
	andlw	0x0f
	movwf	LCD_DATA
	bcf	LCD_CNTL,RS	; Clear for command
	bsf	LCD_CNTL,E	; Clock nibble into LCD
	bcf	LCD_CNTL,E
	return

;*******************************************************************
;* clrLCD - Clear the contents of the LCD                          *
;*******************************************************************
clrLCD
	movlw	CLR_DISP	; Send the command to clear display
	call	SendCmd
	return


;*******************************************************************
;* L1homeLCD - Moves the cursor to home position on Line 1         *
;*******************************************************************
L1homeLCD
	movlw	DD_RAM_ADDR|0x00 ; Send command to move cursor to 
	call	SendCmd		 ; home position on line 1
	return

;*******************************************************************
;* L2homeLCD - Moves the cursor to home position on Line 2         *
;*******************************************************************
L2homeLCD
	movlw	DD_RAM_ADDR|0x28 ; Send command to move cursor to
	call	SendCmd		 ; home position on line 2
	return


;*******************************************************************
;* Delay - Generic LCD delay                                       *
;* Since the microcontroller can not read the busy flag of the     *
;* LCD, a specific delay needs to be executed between writes to    *
;* the LCD.                                                        *
;*******************************************************************
Delay				; 2 cycles for call
	clrf	Count		; 1 cycle to clear counter variable
Dloop
	decfsz	Count,f		; These two instructions provide a
	goto	Dloop		; (256 * 3) -1 cycle count
	return			; 2 cycles for return


;*******************************************************************
;* LongDelay - Generic long LCD delay                              *
;* POR delay for the LCD panel.                                    *
;*******************************************************************
LongDelay
	clrf	Count
	clrf	Count1
	movlw	0x03
	movwf	Count2
LDloop
	decfsz	Count,f
	goto	LDloop
	decfsz	Count1,f
	goto	LDloop
	decfsz	Count2,f
	goto	LDloop
	return

DELAY
	;RETURN			;Used for simulation purposes
	MOVLW 	01h		;Set delay for 0.5 Second
	MOVWF 	Loop3	 	;Set Loop3 to Loop 3 Times
LOOP	
	DECFSZ 	Loop1,1  	;Loop 255 times then move to next loop
	Goto 	LOOP		;Go Back to the beginning of the Loop
	DECFSZ 	Loop2,1  	;Loop 255 times then move to next loop
	Goto 	LOOP		;Go Back to the beginning of the Loop	
	DECFSZ 	Loop3,1  	;Loop 5 times then move to next loop
	Goto 	LOOP		;Go Back to the beginning of the Loop
	RETURN			;Go back and execute instruction after last call
	end			;End of Source

