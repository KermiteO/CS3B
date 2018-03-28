;*************************************************************************************
; Program Name:  MASM2.asm
; Programmer:    Omar Kermiche
; Class:         CS3B
; Date:          February 8 2018
; Purpose:
;        To create a simple input/output program in Assembly languange
;*************************************************************************************  
	.386				  ;.386
	.model flat, stdcall  ;use model flat
	option casemap :none  ;option casemap
	
	ExitProcess   PROTO Near32 stdcall, dwExitCode:dword 					        ;capitalization not necessary
	getstring     PROTO Near32 stdcall, lpStringToHold:dword, numChars:dword        ;inputs max of numchars
	putstring     PROTO Near32 stdcall, lpStringToDisplay:dword			            ;displays null-terminated string
	ascint32	  PROTO Near32 stdcall, lpStringToConvert:dword			            ;result in EAX
	intasc32	  PROTO Near32 stdcall, lpStringToHold:dword, dVal:dword   ;converts integer to ascii value
	hexToChar     PROTO Near32 stdcall, lpDestStr:dword,lpSourceStr:dword,dLen:dword;retrieves the address in memory of a number
	getche		  PROTO Near32 stdcall 												;gets a single char and echoes it										
	putch		  PROTO Near32 stdcall, bChar:byte								    ;gets a single character and prints it 

	include \masm32\include\kernel32.inc     ;include kernel32
	include \masm32\include\masm32.inc       ;include masm32
	includelib \masm32\lib\kernel32.lib      ;include kernel32 library
	includelib \masm32\lib\masm32.lib		 ;include masm32 library
	
	.data
	
    headerStr   byte 9, "Name: Omar Kermiche",		;Omar Kermiche
           13, 10, 9, "Class: CS3B",				;Class: CS3B
           13, 10, 9, "Lab: MASM2.asm",				;Lab: MASM2.asm
           13, 10, 9, "Date: 2/27/17",				;Date: 2/27/17
           13, 10, 13, 10,0							;formatting

	numChars 	  word  0  ;numChars
	index		  word  0  ;index
	firstInputNum dword ?  ;first input number
	secInputNum	  dword ?  ;second input number
	sumNum		  dword ?  ;the sum
	differenceNum dword ?  ;the difference
	productNum	  dword ?  ;the product num
	quotientNum	  dword ?  ;the quotient
	remainder  	  dword ?  ;the remainder	
	
	;outputting message as a string	
	firstNumPromp   byte 10,13, "Enter your first number:  ",0   ;first number prompt
	secondNumPrompt byte 10,13, "Enter your second number: ",0	 ;second number prompt	
	sumMessage 		byte 10,13, "The sum is ",0				 	 ;sum output
	diffMessage 	byte 10,13, "The difference is ",0			 ;difference output
	productMessage  byte 10,13, "The product is ",0				 ;product output
	quotientMessage byte 10,13, "The quotient is ",0			 ;quotient output
	remMessage 		byte 10,13, "The remainder is ",0			 ;remainder output
	
	firstInput    byte 10 dup(?)  ;string array
	secInput   	  byte 10 dup(?)  ;string array 2
	finalSecInput byte 10 dup(?)  ;final second input after overflow
	finalSum	  byte 10 dup(?)  ;final sum
	finalDiff	  byte 10 dup(?)  ;final difference
	finalProduct  byte 10 dup(?)  ;final product
	finalQuotient byte 10 dup(?)  ;final quotient
	finalRem	  byte 10 dup(?)  ;final remainder
	
	newLine  DB 0Ah,0									  ;new line in hex					

	
	;error messages for output
	strOverflowAdd	 byte 10,13,"OVERFLOW OCCURED WHEN ADDING",0							     		;overflow when adding
	strOverflowMul	 byte 10,13,"OVERFLOW OCCURED WHEN MULTIPLYING",0									;overflow when multiplying
	strOverflowDiv	 byte 10,13,"You cannot divide by 0. Thus, there is NO quotient or remainder",0		;undefined quotient
	strOverflowConv	 byte 10,13,"OVERFLOW OCCURRED. RE-ENTER VALUE",0									;overflow when converting
	strInvalidString byte 10,13,"INVALID NUMERIC STRING. RE-ENTER VALUE",0								;invalid input
	strProgramEnd	 byte 10,13,"Thanks for using my program!! Good Day!", 13, 10, 0					;end of program message
	
	.code ;code
	
	MAIN: ;main
		INVOKE putstring, ADDR headerStr       ;print header

	printFirstPrompt: 						   ;printfirstprompt
		INVOKE putstring, ADDR firstNumPromp   ;print first Number prompt
		mov numChars, 0						   ;reset number of characters to 0
		mov esi, OFFSET firstInput			   ;initialize index
		mov ecx, LENGTHOF firstInput		   ;set end of loop condition	
	
	getFirstInput:     			  ;getfirstinput
		INVOKE getche 			  ;get character from user 
		cmp al, 0dh				  ;check for hit enter
		je next					  ;if equal jump to next
		cmp al, 08h				  ;check for backspace
		je isback				  ;if there is then jump to isback
		inc numChars			  ;increment number of characters
		mov bx, numChars		  ;move number of characters to bx
		cmp bx, 10				  ;check if bx value equals 10
		jg maxChars				  ;if the max # of characters were entered then jump to maxChars
		mov [esi], al			  ;append firstInput string
		add esi, TYPE firstInput  ;increment index
		jmp getFirstInput		  ;repeat the loop
	
	next:						  		  ;next
		mov bx, numChars				  ;mov numChar to bx	
		cmp bx, 0						  ;check if there are 0 characters
		je endProgram					  ;if there is then end program
		INVOKE ascint32, ADDR firstInput  ;convert string to int
		jc displayInvalidMsg			  ;display invalid if invalid input
		jo displayOvflMsg				  ;display message if overflow 
		mov firstInputNum, eax			  ;move eax into variable
		
		mov esi, OFFSET firstInput			   ;initialize index
		mov ecx, LENGTHOF firstInput		   ;set end of loop condition
		mov ax, 0							   ;move 0 into ax
		mov index, ax						   ;move ax into index
		
		ClearFirstNum: ;clearfirstnumber
			mov bx, numChars			;move numChars to bx
			cmp bx, index				;check if bx equals index num
			je printSecPrompt			;jump to second input prompt if equal
			mov al, 0h					;move 0 into al
			mov [esi], al				;move null into current element
			add esi, TYPE firstInput	;increment esi
			inc index					;increment index
			jmp ClearFirstNum			;loop
	
	printSecPrompt: 						   ;printsecondprompt
		INVOKE putstring, ADDR secondNumPrompt ;print first Number prompt
		mov numChars, 0						   ;reset number of characters to 0
		mov esi, OFFSET secInput			   ;initialize index
		mov ecx, LENGTHOF secInput		   	   ;set end of loop condition
		
	
	getSecondInput:     		  ;getsecondinput
		INVOKE getche 			  ;get character from user 
		cmp al, 0dh				  ;check for hit enter
		je next2				  ;if equal jump to next
		cmp al, 08h				  ;check for backspace
		je isback2				  ;if there is then jump to isback
		inc numChars			  ;increment number of characters
		mov bx, numChars		  ;move number of characters to bx
		cmp bx, 10				  ;check if bx value equals 10
		jg maxChars2			  ;if the max # of characters were entered then jump to maxChars
		mov [esi], al			  ;append firstInput string
		add esi, TYPE secInput    ;increment index
		jmp getSecondInput		  ;repeat the loop
	
	next2:						  		  ;next2

		mov bx, numChars				  ;mov numChar to bx	
		cmp bx, 0						  ;check if there are 0 characters
		je endProgram					  ;if there is then end program

		
		INVOKE ascint32, ADDR secInput    ;convert string to int	
		jc displayInvalidMsg2			  ;display invalid if invalid input
		jo displayOvflMsg2				  ;display message if overflow
		mov secInputNum, eax			  ;move eax to secInputNum
		
		InitializeForLoop:
			mov esi, OFFSET secInput			   ;initialize index
			mov ecx, LENGTHOF secInput		   	   ;set end of loop condition
			mov ax, 0							   ;move 0 into ax
			mov index, ax						   ;move ax into index
		
		ClearSecNum:				;clearsecnum
			mov bx, numChars		;move numChars into bx
			cmp bx, index			;check if bx is equal to index
			je addition				;jump to addition block if equal
			mov al, 0h				;move null into al
			mov [esi], al			;move al into current element
			add esi, TYPE secInput  ;increment esi
			inc index				;increment index
			jmp ClearSecNum			;loop
		
		
	displayInvalidMsg:											;displayInvalidMsg
		INVOKE putstring, ADDR strInvalidString				    ;print invalid message
		mov firstInputNum, 0									;reinitialize variable to 0
		mov eax, 0												;reinitialize register
		INVOKE intasc32, ADDR firstInputNum, firstInput    ;convert from int to string
		jmp printFirstPrompt									;jump back to input prompt
		
	displayOvflMsg:												;displayOvflMsg
		INVOKE putstring, ADDR strOverflowConv					;print invalid message
		mov firstInputNum, 0									;reinitialize variable to 0
		mov eax, 0												;move 0 to eax
		INVOKE intasc32, ADDR firstInputNum, firstInput	;convert int to string
		jmp printFirstPrompt									;jump back to input prompt
		
	maxChars:				;maxChars
		INVOKE putch, 08h	;print a backspace
		
	isback:						 ;isback
		dec numChars			 ;decrement numChars
		mov bx, numChars		 ;move numChars to bx
		cmp bx, 0				 ;move 0 into bx
		jl noBackspace			 ;if no characters jump to noBackspace
		INVOKE putch, 20h		 ;print a space
		INVOKE putch, 08h		 ;print a backspace
		sub esi, TYPE firstInput ;decrement index
		jmp getFirstInput		 ;jump back to et
	
	displayInvalidMsg2:										;displayInvalidMsg2
		INVOKE putstring, ADDR strInvalidString				;print invalid message
		clc 												;clear carry flag
		jmp printSecPrompt									;jump back to input prompt
		
	displayOvflMsg2:										;displayOvflMsg2
		INVOKE putstring, ADDR strOverflowConv				;print invalid message
		
		mov esi, OFFSET secInput			   ;initialize index
		mov ecx, LENGTHOF secInput		   	   ;set end of loop condition
		mov ax, 0							   ;move 0 into ax
		mov index, ax						   ;move ax into index
		
		ClearandReenterNum:			;clearandreenternum
			mov bx, numChars		;move numChars into bx
			cmp bx, index			;check if index is the same as numChars
			je printSecPrompt		;jump back to enter new second number
			mov al, 0h				;move null into al
			mov [esi], al			;move al into current element
			add esi, TYPE secInput  ;increment esi
			inc index				;increment index
			jmp ClearandReenterNum  ;loop
		
	displayOvflAdd:								;displayOvflAdd
		INVOKE putstring, ADDR strOverflowAdd   ;output error message
		jmp difference							;jump to difference block
		
	displayOvflMul:								;displayOvflMul
		INVOKE putstring, ADDR strOverflowMul	;output error message	
		jmp quotient							;jump to quotient block
		
	displayInvalidQuot:							;displayInvalidQuot
		INVOKE putstring, ADDR strOverflowDiv	;output error message
		INVOKE putstring, ADDR newLine			;output newline
		jmp printFirstPrompt					;jump back to enter new first num
		
	maxChars2:				;maxChars
		INVOKE putch, 08h	;print a backspace
		
	isback2:					 ;isback2
		dec numChars			 ;decrement numChars
		mov bx, numChars		 ;move numChars to bx
		cmp bx, 0				 ;move 0 into bx
		jl noBackspace2			 ;if no characters jump to noBackspace
		INVOKE putch, 20h		 ;print a space
		INVOKE putch, 08h		 ;print a backspace
		sub esi, TYPE secInput   ;decrement index
		jmp getSecondInput		 ;jump back to input code block
		
	noBackspace:			;noBackspace
		mov numChars, 0		;reinitialize numChars
		INVOKE putch, 20h	;print a space
		jmp getFirstInput	;jump back to getFirstInput
	
	noBackspace2:			;noBackspace2
		mov numChars, 0		;reinitialize numChars
		INVOKE putch, 20h	;print a space	
		jmp getSecondInput	;jump back to getFirstInput
		
	addition: ;addition
		mov eax, firstInputNum					 ;move firstInputNum to eax
		add eax, secInputNum					 ;sum firstInputNum with secInputNum
		jo displayOvflAdd						 ;display error message if overflow
		mov sumNum, eax							 ;move eax into sumNum
		INVOKE intasc32,  ADDR finalSum, sumNum  ;convert int to ascii
		INVOKE putstring, ADDR sumMessage		 ;print output
		INVOKE putstring, ADDR finalSum			 ;print sum
		
	difference: ;difference
		mov eax, firstInputNum							;move firstInputNum into eax
		sub eax, secInputNum							;subtract second num from first
		mov differenceNum, eax							;move result into variable
		INVOKE putstring, ADDR diffMessage				;print output
		INVOKE intasc32,  ADDR finalDiff, differenceNum ;convert int to string
		INVOKE putstring, ADDR finalDiff				;print difference
		
	product:											;product
		mov eax, firstInputNum							;move firstInputNum to eax
		imul secInputNum								;multiply with second num
		jo displayOvflMul								;if overflow display message
		mov productNum, eax								;store result in variable
		INVOKE putstring, ADDR productMessage			;print output
		INVOKE intasc32,  ADDR finalProduct, productNum ;convert int to string
		INVOKE putstring, ADDR finalProduct				;print product
		
	quotient:												;quotient
		mov eax, firstInputNum								;move firstInputNum into eax
		cdq													;extend dword to qword
		mov ecx, secInputNum								;move secInputNum to ecx
		cmp ecx, 0											;check if second Num is a 0
		je displayInvalidQuot								;if 0 then don't calc quotient
		idiv secInputNum									;divide second num by first
		mov quotientNum, eax								;move quotient into varible
		mov remainder, edx									;move edx to remainder
		INVOKE intasc32, ADDR finalQuotient, quotientNum	;convert int to string
		INVOKE intasc32, ADDR finalRem, remainder			;convert int to string
		INVOKE putstring, ADDR quotientMessage				;print output
		INVOKE putstring, ADDR finalQuotient				;print quotient
		INVOKE putstring, ADDR remMessage					;print remainder output
		INVOKE putstring, ADDR finalRem						;print remainder
		INVOKE putstring, ADDR newLine						;print newline
		jmp printFirstPrompt								;loop back to firstprompt
		
	endProgram: ;endProgram
		
		INVOKE putstring, ADDR newLine ;new line
		INVOKE putstring, ADDR strProgramEnd ;print final output
		
		INVOKE ExitProcess,0  ;program process ends
		PUBLIC MAIN           ;used for linking
	END	;end
