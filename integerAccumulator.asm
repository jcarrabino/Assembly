TITLE Program03_Carrabino

; Author: John Carrabino
; Course / project ID : CS 271 - Program 03
; Date: 10 / 30 / 2016
; Description: For this assignment we were required to prompt the
; user to enter their name and have it output to the user in a greeting
; message.We then had to prompt the user to enter numbers in the range
; from - 100 to - 1. If the user enters a positive number the program will 
; exit, otherwise it will calculate the amount of numbers entered, along 
; with their sum and average.
; 


INCLUDE Irvine32.inc

ULIMIT EQU <-1>

.data
intro1 BYTE "Welcome to the Integer Accumulator", 0dh, 0ah, 0
intro2 BYTE "Programmed by John Carrabino", 0dh, 0ah, 0
ec01 BYTE "*** EC: Numbered the lines during user input ***", 0dh, 0ah, 0
q1 BYTE "What's your name?  ", 0
userName BYTE 36 DUP(0); Input buffer for name up to 35 char long
greeting BYTE "Hello, ", 0
prompt_1 BYTE "Please enter the numbers in [-100, -1].", 0dh, 0ah, 0
prompt_2 BYTE "Enter a non-negative number when you are finished to see the results.", 0dh, 0ah, 0
userError BYTE "You did not enter any valid numbers!", 0
rangeError BYTE "Please enter a number in [-100, -1] or enter a non-negative number to quit.",0
getNum BYTE "Enter number ",0
getNum2 BYTE ": ", 0
encore byte "Continue? (y) / (n): ", 0
choice byte ?
num SDWORD ?
sum SDWORD ?
average SDWORD ?
lineCount DWORD ?
remainder SDWORD ?
accumulator DWORD ?
result_1a BYTE "You entered ", 0
result_1b BYTE " valid numbers.", 0
result_2 BYTE "The sum of your valid numbers is ", 0
result_3 BYTE "The rounded average is ",0
goodbye_1 BYTE "Thank you for playing Integer Accumulator!", 0
goodbye_2 BYTE "It's been a pleasure to meet you, ", 0

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
	call crlf
numPrompt:
; Get a number from the user
	mov edx, OFFSET prompt_1
	call writestring
	mov edx, OFFSET prompt_2
	call writestring
	call crlf

	mov sum, 0 ;Initializes sum to zero
	mov num, 0
	mov eax, 0
	mov accumulator, 0 ; Initializes accumulator to zero
	mov lineCount, 1
	jmp getNumber

rangeCheck:
	mov edx, OFFSET rangeError
	call writestring
	call crlf
	jmp done

getNumber:
	mov edx, OFFSET getNum
	call writestring
	mov eax, lineCount
	call WriteDec
	mov edx, OFFSET getNum2
	call WriteString
	call readint
	inc lineCount
	mov num, eax

	; Checks lower limit using LLIMIT Constant
	cmp eax, LLIMIT
	jl numError
	
	; Checks SIGN FLAG to make sure number entered is negative
	cmp num,0
	jns done

	mov eax, accumulator
	inc eax
	mov accumulator, eax
	mov eax, num
	add eax, sum
	mov sum, eax
	jmp getNumber


done:	
	cmp accumulator, 0
	jz numError

	; Calculates average
	mov eax, sum
	cdq
	mov ebx, accumulator
	idiv ebx
	mov average, eax
	mov remainder,  ebx

	cmp remainder, 5
	jl results
	mov eax, average
	sub eax, 1
	mov average, eax

results: ;Displays number count
	mov edx, OFFSET result_1a
	call writestring
	mov eax, accumulator
	call writedec
	mov edx, OFFSET result_1b
	call writestring
	call crlf

	; Displays sum
	mov edx, OFFSET result_2
	call WriteString
	mov eax, sum
	call writeint
	call crlf

	; Displays rounded average
	mov edx, OFFSET result_3
	call WriteString
	mov eax, average
	call writeint
	call crlf
	jmp bye

longJump:
	jmp numPrompt

numError :
	mov eax, accumulator
	cmp eax, 0
	jle noNumbers
	jmp done
noNumbers:
	mov edx, OFFSET userError
	call writestring
	call crlf
	mov edx, OFFSET encore
	call WriteString
	call readChar
	mov choice, al
	call crlf

; Checks if user enters 'y' to continue
	cmp choice, "y"
	je longJump
	jmp bye

; checks if user enters 'Y' to continue
	cmp choice, "Y"
	je longJump
	jmp bye

bye:
	; Displays parting message
	mov edx, OFFSET goodbye_1
	call writestring
	call crlf
	mov edx, OFFSET goodbye_2
	call writestring
	mov edx, OFFSET userName
	call writestring
	call crlf

		exit

main ENDP
END main
