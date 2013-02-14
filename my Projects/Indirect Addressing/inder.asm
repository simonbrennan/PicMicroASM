;******************************************************
;* Program Name : indirect addressing		      *
;* Programmer : Simon Brennan			      *
;* Description : Example prog of indirect addressing  *
;*               (Gonna use it for a serial port RX   *
;*               Buffer)                              *
;******************************************************
	list p=16f877

;General purpose registers

w		equ	00h	; Destination -> Working Register
f		equ	01h     ; Destination -> File
status  	equ	03h	; Address of status register
zflag           equ     02h	; Z-flag of status register

;Indirect addressing registers

indf            equ     00h     ; Reference Address Pointer	
fsr		equ	04h	; Address Pointer

;buffer flag register	

bstatus		equ     40h	; shows status of buffer (0 - Buffer Full)

;buffer declaration
	
	CBLOCK	20h
	buffer:14h		;buffer of 20 bytes
	ENDC

;*************** Start of program ***********************

INIT:
	movlw	 20h		; Initialise indirect pointer to buffer start (20h)
	movwf	 fsr		;
	movlw	 b'10101010'	; Load value to save to buffer
	clrf     bstatus	;
START:
	addlw	01h		; Increment working register (Create values to save to buffer)	
	movwf	indf		; Save value into buffer
	incf	fsr,f		; increment pointer 	  
	movf	fsr,w		; check current address
	sublw	35h		; if the buffer is at max the set buffer
	btfsc   status,zflag	; status flag (bit 0).
	bsf     bstatus,0	;
	btfsc   bstatus,0	; Check for buffer full
	goto    STOP		; if buffer is full stop
	goto	START		; keep looping	
STOP:
	end



