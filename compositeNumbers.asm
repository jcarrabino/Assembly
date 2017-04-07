TITLE Program03_Carrabino

; Author: John Carrabino
; Course / project ID : CS 271 - Program 03
; Date: 10 / 30 / 2016
; Description: For this assignment we were required to prompt the
; user to enter their name and have it output to the user in a greeting
; message.We then had to prompt the user to enter numbers in the range
; from - 100 to - 1. If the user enters a positive number the program will
; calculate the amount of numbers entered, along with their sum and average.
; 


INCLUDE Irvine32.inc

ULIMIT EQU <400>
LLIMIT EQU <1>

.data
intro1 BYTE "Composite Numbers	    Programmed by John Carrabino", 0dh, 0ah, 0
ec01 BYTE "*** EC: Program displays numbers in aligned columns. ***", 0dh, 0ah, 0
prompt_1 BYTE "Enter the number of composite numbers you would like to see.", 0dh, 0ah, 0
prompt_2 BYTE "I'll accept orders for up to 400 composites.", 0dh, 0ah, 0

getNum BYTE "Enter the number of composites to display [1 ... 400]: ",0
outOfRange BYTE "Out of range. Try again.", 0

userNum DWORD ?
num DWORD ?
count DWORD ?
gcf DWORD ?
isComposite DWORD ?
space1 BYTE "     ", 0
space2 BYTE "    ", 0
space3 BYTE "   ",0

goodbye BYTE "Results certified by John Carrabino. Goodbye.", 0

.code
main PROC

	call introduction
	call getUserData
	call showComposites
	call farewell
	
	exit
main ENDP


; -------------------------------------------------------- -
; Introduction
;
; Introduces programmer to user and displays a message on
; thescreen outlining what the program does for the user.
; Requires: none
; -------------------------------------------------------- -
introduction PROC

	mov eax, yellow
	call SetTextColor

	;Display message introducing the programmer and describes prog to user
	mov edx, OFFSET intro1
	call WriteString
	mov edx, OFFSET ec01
	call writestring
	call crlf
	mov edx, OFFSET prompt_1
	call WriteString
	mov edx, OFFSET prompt_2
	call writestring
	call crlf

	ret
introduction ENDP


; -------------------------------------------------------- -
; getUserData
;
; Prompts the user to enter a number from 1 to 400. Then
; calls dataValidation to ensure the user entered a valid
; number, if a valid number is entered then it is saved to
; the userNum variable.
; Receives: EAX(the user's input)
; Returns: userNum with valid number stored to it.
; Requires: none
; -------------------------------------------------------- -
getUserData PROC
	
	getData: ; Get a number from the user
	mov edx, OFFSET getNum
	call writestring
	call readInt
	
	mov ebx, 0
	call dataValidation
	call crlf
	cmp ebx, 1
	jne rangeError
	mov userNum, eax
	jmp done

	rangeError: ;Notifies user their num is out of range and loops to get a new number from the user
	mov edx, OFFSET outOfRange
	call writestring
	call crlf
	jmp getData

	done: ; Return to main
	ret
getUserData ENDP


; -------------------------------------------------------- -
; dataValidation
;
; Checks that the user's input is valid.
; Receives: EAX(the user's input)
; Returns: EBX = 1 if valid, 0 if not valid
; Requires: none
; -------------------------------------------------------- -
dataValidation PROC
	
	; Check upper limit
	cmp eax, ULIMIT
	jg notValid

	; Check lower limit
	cmp eax, LLIMIT
	jl notValid

	; If num is valid, set ebx to 1
	mov ebx, 1
	jmp endValidation

	notValid:
	mov ebx,0

	endValidation:
	ret
dataValidation ENDP


; -------------------------------------------------------- -
; showComposites
;
; This procedure loops through the composite numbers and 
; prints the user-specified number of composites to the 
; console. It uses the isItComposite procedure to determine
; if a number is composite of not. If the number is composite
; then the program will print it to the screen and increment 
; the number being tested and the count of how many numbers
; have been printed. If the number is not composite then it
; will only increment the number being tested and pass the 
; new value to isItComposite.
; Receives: isComposite
; Returns: isComposite = 1 if valid, 0 if not valid
; Requires: none
; -------------------------------------------------------- -
showComposites PROC
	
	mov num, 4
	mov count, 0
	mov gcf, 0
	mov ecx, userNum

	beginLoop:
	mov isComposite, 0
	call isItComposite

	mov eax, userNum
	sub eax, count
	mov ecx, eax

	cmp isComposite, 1
	jne notComposite
	inc count
	mov eax, num
	call WriteDec
	cmp eax,10
	jl oneDigit
	cmp eax, 100
	jl twoDigits
	mov edx, OFFSET space3 ; prints appropriate amounbt of spaces for 3 digit numbers
	call writeString
	jmp next
	
	next: ; Check if 10 characters have been printed already
	mov edx, 0
	mov eax, count
	mov ebx, 10
	div ebx
	cmp edx, 0
	je newLine
	inc num
	loop beginLoop
	
	notComposite: ; if num is not composite, increments num and compares count to usernum.
	inc num
	mov eax, userNum
	cmp eax, count
	je endLoop
	loop beginLoop

	newLine: ; Prints newline char after 10 numbers have been printed to the screen.
	call crlf
	jmp notComposite

	twoDigits: ; ensures appropriate amount of spaces are printed for 2-digit numbers
	mov edx, OFFSET space2
	call writestring
	jmp next

	oneDigit: ; ensures appropriate amount of spaces are printed for 1-digit numbers
	mov edx, OFFSET space1
	call writestring
	jmp next

	endLoop:
	ret
showComposites ENDP

; -------------------------------------------------------- -
; showComposites
;
; This procedure accepts an integer from showComposites and
; tests if it is composite by seeing if it is divisible by 
; any number from n-1 to 2. If the number is not divisible 
; by any number in that range, then it is prime, isComposite
; is set to zero and is returned to showComposites. If the 
; number is composite then isComposite is set to 1 and 
; returned to showComposites.
; Receives: isComposite
; Returns: isComposite = 1 if valid, 0 if not valid
; Requires: none
; -------------------------------------------------------- -
isItComposite PROC

	mov eax, lightCyan
	call SetTextColor

	; Stores current num in sequence to ecx and decrements it to find gcf
	mov ecx, num
	dec ecx

	; Loop chacks all values from n-1 to 1 and if gcf >= 2 then isComposite = true = 1
	beginLoop:
	mov edx, 0
	mov eax, num
	mov ebx, ecx
	div ebx

	cmp edx, 0
	je endOfLoop
	loop beginLoop

	endOfLoop:
	mov gcf, ebx
	cmp gcf, 1
	jle done
	mov isComposite, 1
	
	done:
	ret
isItComposite ENDP


; -------------------------------------------------------- -
; farewell
;
; This procedure displays a farewell message to the user.
; Requires: none
; -------------------------------------------------------- -
farewell PROC

	mov eax, lightmagenta
	call SetTextColor
	call crlf
	call crlf
	mov edx, OFFSET goodbye
	call writeString
	call crlf

	ret
farewell ENDP

END main