TITLE Program02

; Author: John Carrabino
; Course / project ID : CS 271 - Program 02
; Date: 10 / 16 / 2016
; Description: For this assignment we were required to prompt the
; user to enter their name and have it output to the user in a greeting
; message.We then had to prompt the user for the number of fibonacci
; terms they wish to view from the range of 1 to 46 (range of DWORD).
; The first POST - TEST LOOP is used for DATA VALIDATION for number of
;  terms the user wishes to calculate.It does so by comparing the user's
; input with predefined CONSTANTs for the upper and lower limits of the
; data range.The program then takes the valid user input and carries
; out a COUNTED LOOP which calculates a new fibonacci term during each
; iteration then compares the amount of iterations to see if they are
; equal to the user's number. When the loop has performed the user
; determined amount of iterations it will teminate and display a
; farewell message to the user.


INCLUDE Irvine32.inc

ULIMIT EQU <46>
LLIMIT EQU <1>

.data
intro1 BYTE "Fibonacci Numbers", 0dh, 0ah, 0
intro2 BYTE "Programmed by John Carrabino", 0dh, 0ah, 0
ec01 BYTE "*** EC: Program displays numbers in alligned columns. ***", 0dh, 0ah, 0
q1 BYTE "What's your name?  ", 0
userName BYTE 36 DUP(0); Input buffer for name up to 35 char long
greeting BYTE "Hello, ", 0
prompt_1 BYTE "Enter the number of Fibonacci terms to be displayed", 0dh, 0ah, 0
prompt_2 BYTE "Give the number as an integer in the range [1 .. 46].", 0dh, 0ah, 0
getNum BYTE "How many Fibonacci terms do you want? ", 0
TAB = 9
num DWORD ?
prev1 DWORD ?
prev2 DWORD ?
result DWORD ?
nextLine DWORD ?
loopCount DWORD ?
rangeError BYTE "Out of range. Enter a number in [1 .. 46]", 0
certified BYTE "Results certified by John Carrabino.", 0dh, 0ah, 0
goodbye BYTE "Goodbye, ", 0

.code
main PROC

; Introduction
	mov edx, OFFSET intro1
	call WriteString
	mov edx, OFFSET intro2
	call WriteString
	mov edx, OFFSET ec01
	call writestring
	call crlf


; Get user data
	mov edx, OFFSET q1
	call writestring
	mov edx, OFFSET userName
	mov ecx, 35
	call readstring
	mov edx, OFFSET greeting
	call writeString
	mov edx, OFFSET userName
	call writestring
	call crlf

; Get a number from the user
	mov edx, OFFSET prompt_1
	call writestring
	mov edx, OFFSET prompt_2
	call writestring
	call crlf
	jmp getNumber


rangeCheck:		; notifies user if their number is out of range
	mov edx, OFFSET rangeError
	call writestring
	call crlf

getNumber:
	mov edx, OFFSET getNum
	call writestring
	call readint
	mov num, eax

; Checks lower limit using LLIMIT Constant
	mov eax, num
	cmp eax, LLIMIT
	jge checkULIMIT
	jmp rangeCheck


checkULIMIT:	;Checks upper limit using ULIMIT Constant
	mov eax, num
	cmp eax, ULIMIT
	jg rangeCheck

; Display Fibonacci Numbers
	mov prev1, 1
	mov prev2, 1
	mov ecx, 0
	call crlf

loopStart:		; increments counter at the start of each loop
	inc ecx

; prints the first value in the fibonacci sequence
	cmp ecx, 1
	jne calcTwo
	mov eax, prev1
	call writedec
	mov al, TAB
	call writechar
	call writechar
	jmp loopStart


calcTwo:		; prints the second value in the fibonacci sequence
	cmp ecx, 2
	jne nextCalc
	mov eax, prev1
	call writedec
	mov al, TAB
	call writechar
	call writechar
	jmp loopStart


nextCalc:		; calculates each additional term in the sequence from 3 to n
	mov eax, prev2
	add eax, prev1
	mov result, eax
	call writedec
	mov al, TAB
	call writechar

; checks if more than 35 terms are printed to ensure only one TAB is used
	cmp ecx, 35
	jge oneTab
	call writechar
	oneTab:
	mov eax, prev1
	mov prev2, eax
	mov eax, result
	mov prev1, eax

; calculates loop count MOD 5 to see if a newline is needed
	mov loopCount, ecx
	mov eax, loopCount
	cdq
	mov ebx, 5
	div ebx
	mov nextLine, edx
	mov eax, nextLine
	cmp eax, 0
	jne endOfLoop
	call crlf
	jmp endOfLoop


endOfLoop:		; Compares loop count to user num to see if more iterations are needed or not
	mov eax, ecx
	cmp eax, num
	jne loopStart
	jmp done


done:			; Goodbye!
	mov edx, OFFSET certified
	call crlf
	call crlf
	call writestring
	mov edx, OFFSET goodbye
	call WriteString
	mov edx, OFFSET userName
	call writestring
	call crlf

exit

main ENDP
END main