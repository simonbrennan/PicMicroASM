;************************************************
;* TEST1.ASM                                    *
;************************************************
;* PIC16F87x Development unit Test routine      *
;* Written by:  Pat Ellis	                *
;*              Senior Lecturer			*
;*              TWR Elec. Eng.			*
;* Date:        16 May 2001	                *
;* Revision:	1                               *
;************************************************
;* This Program Puts a binary count sequence on * 
;* PortD to test the operation of the unit.	*
;* The configuration is as follows:		*
;* 	Crystal		4 Mhz			*
;*	Jumper j3 on  				*
;*	software delay of +/- 0,2 sec		*
;*						*
;*						*
;* 						*
;************************************************
	list p = 16f877
	include <p16f877.inc>

	cblock 20h

		count
		count1
	endc 	

	org 00

; Locates startup code @ the reset vector
	nop			;0x0000
	bsf	STATUS,RP0	;Bank1
	clrf	TRISD	
	bcf	STATUS,RP0	;Bank 0
	clrf	PORTD

main	call	delay
	incf	PORTD,1
	goto	main


delay	decfsz	count,1
	goto	delay
	decfsz	count1,1
	goto 	delay
	return

	end
