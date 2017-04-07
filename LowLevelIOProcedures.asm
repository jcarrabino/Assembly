;-----------------------------------------------------------------------------------------
;TITLE Program06_Carrabino
;-----------------------------------------------------------------------------------------
; 
; Author: John Carrabino
; Assignment: Program 06 Option A
; Date: 12 / 4 / 2016
; Description: This program required us to do the following,
; 1) Implement and test your own ReadVal and WriteVal procedures for unsigned integers.
; 2) Implement macros getString and displayString. The macros may use Irvine’s ReadString 
;   to get input from the user, and WriteString to display output.
;   - getString should display a prompt, then get the user’s keyboard input into a 
;     memory location 
;   - displayString should display the string stored in a specified memory location. 
;   - readVal should invoke the getString macro to get the user’s string of digits.  
;     It should then convert the digit string to numeric, while validating the user’s 
;     input. 
;   - writeVal should convert a numeric value to a string of digits, and invoke the 
;     displayString macro to produce the output.
; 3) Write a small test program that gets 10 valid integers from the user and stores 
;   the numeric values in an array. The program then displays the integers, 
;   their sum, and their average.
;
;----------------------------------------------------------------------------------------- 


INCLUDE Irvine32.inc

MAX EQU <4294967295>


;-------------------------------------------------------------------
;MACRO:  getString
;Description:  Display a prompt, then get the user's keyboard input
;and put into a memory location
;Parameters:  address, length
;Note:  Borrowed from Lecture #26, Slide #7
;-------------------------------------------------------------------
getString MACRO string
	push edx
	push ecx
	
	;reads user input
	mov edx, string
	mov ecx, 200
	call readString

	pop ecx
	pop edx
ENDM

;-------------------------------------------------------------------
;MACRO:  displayString
;Description:  Display the string stored in a specific memory location
;Parameters:  stringResult
;-------------------------------------------------------------------
displayString MACRO uString
	push edx
	mov edx,  uString
	call writeString
	pop edx
ENDM

.data
intro1 BYTE "Designing Low-Level I/O Procedures	   Written by John Carrabino", 0dh, 0ah, 0
ec01 BYTE "*** EC: ... ***", 0dh, 0ah, 0
prompt_1 BYTE "Please provide 10 unsigned decimal integers.", 0dh, 0ah, 0
prompt_2 BYTE "Each number needs to be small enough to fit inside a 32 bit register.", 0dh, 0ah, 0
prompt_3 BYTE "Afer you have finished inputting the raw numbers I will display a list", 0dh, 0ah, 0
prompt_4 BYTE "of the integers, their sum, and their average value.", 0dh, 0ah, 0

getNum BYTE "Please enter unsigned number ",0
endNum BYTE ": ", 0
Error_1 BYTE "ERROR: You did not enter an unsigned number or the number was too big.",0
Error_2 BYTE "Please try again: ",0

uString BYTE 200 DUP(?)
userNum DWORD ?
sum DWORD ?
avg DWORD ?
numArray DWORD 10 DUP(?)
count DWORD ?

space BYTE ", ",0
displayList BYTE "You entered the following numbers: ",0dh,0ah,0
displaySum BYTE "The sum of these numbers is: ",0
displayAvg BYTE "The average is: ",0

goodbye BYTE "Thanks for playing!",0dh,0ah,0

.code
main PROC
	;===================================================================
	;Introduction:
	;Display message introducing the programmer and describes prog to user
	;===================================================================
	displayString OFFSET intro1
	call crlf
	displayString OFFSET prompt_1
	displayString OFFSET prompt_2
	displayString OFFSET prompt_3
	displayString OFFSET prompt_4
	call crlf

	;sets up registers for user input loop
	mov eax, 0
	mov ecx, 10
	mov esi, OFFSET numArray
	mov edi, OFFSET numArray
	mov count, 0

	;===================================================================
	; This user input loop executes 10 times and accepts unsigned ints
	; from the user using the readVal procedure.
	;==================================================================
	uInputLoop:
		displayString  OFFSET getNum

		push OFFSET ERROR_2		;[ebp + 24]
		push OFFSET ERROR_1		;[ebp + 20]
		push count				;[ebp + 16]
		push edi				;[ebp + 12]
		push OFFSET uString		;[ebp + 8]
		call readVal

		mov ebx, count
		lea edi, [esi + ebx * TYPE DWORD]
		inc count
	loop uInputLoop
	
	; Sets up registers for subsequent loop
	mov esi, OFFSET numArray
	mov ecx, 10
	mov count, 0
	mov uString, 0
	call crlf

	;===================================================================
	; This loop reads over the array of ints received from the user and
	; converts them to strings/prints them to the console using the
	; writeVal procedure.
	;==================================================================
	displayString OFFSET displayList
	listLoop:
		;Code snippet to clear contents of uString
		xor al,al
		lea edi, [uString]
		cld
		mov ecx, 200
		rep stosb

		mov ebx, count
		lea edi, [esi + ebx * TYPE DWORD]
		inc count
		mov eax, [edi]
		mov userNum, eax
		
		push userNum			;[ebp + 12]
		push OFFSET uString		;[ebp + 8]
		call writeVal

		mov ecx, 11
		sub ecx, count

		cmp count, 9
		ja skip
		displayString OFFSET space
		skip:

	loop listLoop
	
	;Sets up registers for calcSum loop
	call crlf
	mov ecx, 10
	mov eax, 0
	mov edx, 0
	mov ebx, 0
	mov count, 0
	mov esi, OFFSET numArray

	calcSum:
		mov edx, [esi + ebx]
		add eax, edx
		add ebx, 4
	loop calcSum

	call crlf
	mov sum, eax 
	displayString OFFSET displaySum
	
	;Code snippet to clear contents of uString
	xor al,al
	lea edi, [uString]
	cld
	mov ecx, 200
	rep stosb

	push sum
	push OFFSET uString
	call writeVal
	call crlf

	mov ebx, 10
	mov eax, sum
	cdq
	div ebx
	mov avg, eax
	
	;Code snippet to clear contents of uString
	xor al,al
	lea edi, [uString]
	cld
	mov ecx, 200
	rep stosb

	call crlf 
	displayString OFFSET displayAvg
	push avg
	push OFFSET uString
	call writeVal
	call crlf
	call crlf
	displayString OFFSET goodbye
	
	exit
main ENDP

; -------------------------------------------------------- -
; readVal
;
;
; Receives: The memory address of numArray & uString, and 
; the value stored in count.
; Returns: Converts user's string into an int and stores it
; at the correct index position in numArray
; Requires: numArray, uString, count (loop counter)
; -------------------------------------------------------- -
readVal PROC
	ENTER 0,0
	pushad

	getNumber:
		mov edx, [ebp + 8]		;@uStringz
	
		getString edx

		cmp eax, 10
		ja invalid

		mov esi, edx	; esi == @uString
		mov eax, 0
		mov ecx, 0
		mov ebx, 10

	readBytes:
		lodsb
		cmp ax, 0
		je done

		cmp ax, 57	;checks that ASCII char <= 9
		ja invalid
	
		cmp ax, 48	; checks that ASCII char >= 0
		jb invalid

		sub ax, 48
		xchg eax, ecx
		mul ebx
		jnc valid

	invalid:
		mov edx, [ebp + 20]	;@ERROR_!
		call writeString
		call crlf
		mov edx, [ebp + 24]	;@ERROR_2
		call writestring
		jmp getNumber

	valid:
		add eax, ecx
		xchg eax, ecx
		jmp readBytes

	done:
		mov ebx, [ebp+16]
		xor edx, edx

	countLoop:
		cmp ebx, 0
		jbe endCount
		add edx, 4
	endCount:
	
	; loads 
	xchg eax, ecx
	mov esi, [ebp+12]	;@numArray
	add esi, edx
	mov [esi], eax

	popad
	LEAVE
	ret 20
readVal ENDP

; -------------------------------------------------------- -
; writeVal
;
;
; Receives: The number located at the current index of numArray
; and a black uString variable. 
; Returns: Translates decimal digits into ascii values and stores
; them in the uString variable as a string of bytes to be read by
; displayString
; Requires: numArray[i] & uString variables
; -------------------------------------------------------- -
writeVal PROC
	ENTER 0,0
	pushad
	
	mov eax, 10
	mov ecx, 0
	mov ebx, [ebp + 12]	;numArray[i]
	mov edi, [ebp + 8]	;@uString
	
	countLoop:
		cmp ebx, eax
		jb singleDigit
		mov edx, 10
		mul edx
		add ecx, 1
		jmp countLoop

	singleDigit: 
		cmp ecx, 0
		jbe endCount
		mov eax, ecx
		add edi, eax
	endCount:
	
	std
	mov eax, [ebp + 12]
	modLoop:
		xor edx, edx
		cdq
		mov ebx, 10
		div ebx
		mov ebx, eax

		cmp eax, 0
		je handleZero
		add edx, 48
		xchg eax, edx
		stosb
		xchg eax, edx
		jmp endLoop

	handleZero:
		add edx, 48
		xchg eax, edx
		stosb
		xchg eax, edx
		mov edx, 10

	endLoop:
		mov eax, ebx
		cmp eax, 0
		ja modLoop

	done:
		inc edi
		displayString edi

	popad
	LEAVE
	ret 8
writeVal ENDP

END main