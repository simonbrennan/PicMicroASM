; Program to add two numbers
	
	list p=16F877

numb1	equ 20h		;address of 1st number
numb2	equ 21h		;address of 2nd number
answ	equ 22h		;address where result is to be saved

	org 0000h	;reset vector address

MainProgram
	movf	numb1,0	;fetch 1st number
	addwf	numb2,0 ;add 2nd number and store result
	movwf	answ    ;store result
	goto	$	;trap program(jump same lane)

	end		;end of source program
