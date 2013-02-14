; **********************************************************
; * Program Name : Serial port TX for PIC		   *
; * Programmer : Simon Brennan   			   *
; * Description : Serial Recieve using interupts, Displays *
; *             : to LCD display, Dynamic Display Update   *
; **********************************************************

	list p=16F877	
	include <p16f877.inc>
		__CONFIG _BODEN_OFF&_CP_OFF&_WRT_ENABLE_ON&_PWRTE_ON&_WDT_OFF&_XT_OSC&_DEBUG_OFF&_CPD_OFF&_LVP_OFF

;Standard Program Registers

PCL		EQU	02h	; Address of program counter
F		EQU	1h	; Send Result to File
W		EQU	0h	; Send Result to Working Register
zflag           equ     02h	; Zero Flag of Status register
Status 		EQU	03h 	; Address of status register
status          equ     03h
TrisA   	EQU	85h	; Address of Tristate Buffer A.
TrisC		EQU     87h	; Address of Tristate Buffer C.
TrisD  		EQU     88h 	; Address of Tristate Buffer D.
PortA   	EQU	05h	; Address of Port A.
PortD   	EQU 	08h 	; Address of Port D.

;Serial Port Registers
TXSTA		EQU	98h	; Serial Port Transmit Control Register
SPBRG		EQU	99h	; Serial Port Baud Rate Generator Setting Register
TXREG		EQU	19h	; Serial Port Transmit register
RCREG		EQU	1Ah	; Serial Port Receive
RCSTA		EQU	18h	; Serial Port Receive register control register

;Indirect addressing registers

indf            equ     00h     ; Reference Address Pointer	
fsr		equ	04h	; Address Pointer

;buffer flag register	

bstatus		equ     40h	; shows status of buffer (0 - Buffer Full)

;Interupt Control Registers
PIR1		EQU	0Ch	; Analogue Digital Register
PIE1            EQU	8CH	; Peripheral Interupt Enable

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
		Temp	
		Temw
		Temstat
		Temp2
	endc	

;RX buffer declaration
	
	CBLOCK	29h
	buffer:14h		;buffer of 20 bytes
	ENDC

; Start of Interupt Vector 
	ORG 0000h
	GOTO MAIN	
	
	ORG 0004h		; Start of interupt vector
INTER
	MOVWF 	Temw   		;Copy W to TEMP register
	SWAPF 	STATUS,0 	;Swap status to be saved into W
	CLRF 	STATUS 		;bank 0, regardless of current bank, Clears IRP,RP1,RP0
	MOVWF 	Temstat     	;Save status to bank zero STATUS_TEMP register

	MOVF RCREG,W		; Load RCREG, and send it to portd once interupt completes
	MOVWF Temp		; Store Recieved Value in Temp variable
	MOVWF indf		; Save Received value into recieve buffer
	incf	fsr,f		; increment pointer 
;	movf	fsr,w		; check current address
;	sublw	35h		; if the buffer is at max the set buffer
;	btfsc   status,zflag	; status flag (bit 0).
;	bsf     bstatus,0	;
;	btfsc   bstatus,0	; Check for buffer full
;	clrf    fsr		; reset buffer pointer

	CLRF 	STATUS 		;bank 0, regardless of current bank, Clears IRP,RP1,RP0

	SWAPF 	Temstat,0 	;Swap STATUS_TEMP register into W
				;(sets bank to original state)
	MOVWF 	STATUS 		;Move W into STATUS register
	SWAPF 	Temw,1 		;Swap W_TEMP
	SWAPF 	Temw,0 		;Swap W_TEMP into W
	RETFIE			;return from interrupt(restores pc to original state)

;Start of main program
MAIN
	BSF	Status,5	; Move to memory bank 1
	MOVLW	0FFh		; set tris bits 6,7 for TX and RX, rest of pins
	MOVWF	TrisC           ; to input
	CLRF    TrisD		; Set all bits on portd to outputs

;Initialize Serial Port
	MOVLW	19h		; Set the baud rate to 9600
	MOVWF   SPBRG		; //
	MOVLW	b'00000100'	; Set serial port = on , asynchronous, brgh = 1, 
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
	CLRF    Temp		;
	CLRF	Temp2		;
	movlw	 29h		; Initialise indirect pointer to buffer start (29h)
	movwf	 fsr		; Recieve Buffer


;Start to recieve values
START
	movf	fsr,w		; check current address
	sublw	2Fh		; if the buffer is at 5, then display it to LCD
	btfss   status,zflag	; status flag (bit 0).
        goto    START		; Wait for five chars before displaying to LCD 
TEST2	
	movlw   29h		;
	movwf  	fsr		; reset pointer so we can read the rx values
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
	movlw	' '
	call	putcLCD
	movlw	'R'
	call	putcLCD
	movlw	'X'
	call	putcLCD
	movlw	' '
	call	putcLCD
	call	L2homeLCD
 	movf	indf,w		; load value in buffer at pointer
	incf    fsr		; increment pointer
	call	putcLCD
	movf	indf,w		; load value in buffer at pointer
	incf    fsr		; increment pointer 	
	call	putcLCD
 	movf	indf,w		; load value in buffer at pointer
	incf    fsr		; increment pointer
	call	putcLCD
	movf	indf,w		; load value in buffer at pointer
	incf    fsr		; increment pointer
	call	putcLCD
	movf	indf,w		; load value in buffer at pointer
	incf    fsr		; increment pointer
	call    putcLCD		;
	movf	indf,w		; load value in buffer at pointer
	incf    fsr		; increment pointer
	call    putcLCD		;
TEST
	movlw	' '
	call	putcLCD
	movlw	' '
	call	putcLCD
 	movlw	' '
	call	putcLCD
	movlw	' '
	call	putcLCD
	movlw	' '
	call	putcLCD
	movlw	' '
	call	putcLCD
	movlw   29h		; Reset pointer again
	movwf   fsr
	GOTO START		; loaded into the Working Reg when the interupt occurs

;************************************************
;* Contains subroutines to control an external  *
;* lcd panel in 4-bit mode.  These routines     *
;* were designed specifically for the panel on  *
;* the MCU201 workshop demo board, but should   *
;* work with other LCDs with a HD44780 type     *
;* controller.                                  *
;* Routines include:                            *
;*   - InitLCD to initialize the LCD panel      *
;*   - putcLCD to write a character to LCD      *
;*   - SendCmd to write a command to LCD        *
;*   - clrLCD to clear the LCD display          *
;*   - L1homeLCD to return cursor to line 1 home*
;*   - L2homeLCD to return cursor to line 2 home*
;************************************************

;

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
	END

