TITLE Program03_Carrabino

; Author: John Carrabino
; Course / project ID : CS 271 - Program 05
; Date: 11 / 20 / 2016
; Description: For this project we were required to practice passing parameters 
; on the system stack. We were required to have the user specify the amount of
; elements to add to the array in the range from 10 - 200. We then had to fill
; the array with random integers from 100 - 999, sort the array into descending 
; order, calculate the median value, and display the unsorted array, median, and
; sorted array to the user.
; 


INCLUDE Irvine32.inc

MIN EQU <10>
MAX EQU <200>
LO EQU <100>
HI EQU <999>

.data
intro1 BYTE "Sorting Random Integers		Programmed by John Carrabino", 0dh, 0ah, 0
ec01 BYTE "*** EC: ... ***", 0dh, 0ah, 0
prompt_1 BYTE "This program generates random numbers in the range [100 .. 999],", 0dh, 0ah, 0
prompt_2 BYTE "displays the original list, sorts the list, and calculates the", 0dh, 0ah, 0
prompt_3 BYTE "median value. Finally, it displays the list sorted in descending order.", 0dh, 0ah, 0

getNum BYTE "How many numbers should be generated? [10 .. 200]: ",0
outOfRange BYTE "Invalid input", 0

userNum DWORD ?
numArray DWORD 200 DUP(?)
count DWORD ?

unsorted BYTE "The unsorted random numbers: ", 0dh,0ah,0
space BYTE "    ",0
medianO1 BYTE "The median is ",0
medianE1 BYTE "Then medians are ",0
medianE2 BYTE " and ",0
mediEND BYTE ".",0dh, 0ah, 0

sorted BYTE "The sorted list: ", 0dh, 0ah, 0
goodbye BYTE "Results certified by John Carrabino. Goodbye.", 0

.code
main PROC
	call introduction

	push OFFSET userNum
	call getUserData

	
	push OFFSET numArray
	push [userNum]
	call fillArray

	push OFFSET unsorted
	push OFFSET numArray
	push [userNum]
	call displayList
	
	push [userNum]
	push OFFSET numArray
	call sortList

	push [userNum]
	push OFFSET numArray
	call displayMed


	push OFFSET sorted
	push OFFSET numArray
	push [userNum]
	call displayList

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
	mov edx, OFFSET prompt_3
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
	ENTER 0,0

	getData: ; Get a number from the user
	mov edx, OFFSET getNum
	call writestring
	call readDec
	
	mov ebx, 0
	call dataValidation
	cmp ebx, 1
	jne rangeError
	mov ebx, [ebp + 8]
	mov [ebx], eax
	jmp done

	rangeError: ;Notifies user their num is out of range and loops to get a new number from the user
	mov edx, OFFSET outOfRange
	call writestring
	call crlf
	call crlf
	jmp getData

	done: ; Return to main
	LEAVE
	ret 4
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
	cmp eax, MAX
	jg notValid

	; Check lower limit
	cmp eax, MIN
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
; fillArray
;
; Receives: The starting address of numArray and userNum
; Returns: numArray is returned filled with random ints
; Requires: none
; -------------------------------------------------------- -
fillArray PROC
	Enter 0,0
	pushad
	mov esi, [ebp+12]	;stores address of numArray[0] in esi
	mov ecx, [ebp + 8]	;stores value of userNum to ecx for loop counter
	call randomize
	
	arrayFill:
	mov eax, HI
	call Randomrange
	
	;Check LLIMIT
	cmp eax, LO
	jl arrayFill

	mov [esi], eax
	add esi, TYPE DWORD
	loop arrayFill

	popad
	LEAVE
	ret 8
fillArray ENDP

; -------------------------------------------------------- -
; sortList
;
; Receives: The starting address of numArray and userNum
; Returns: numArray is returned sorted in descending order
; Requires: numArray must be initialized/filled
; -------------------------------------------------------- -
sortList PROC
	ENTER 0,0
	pushad

	mov esi, [ebp + 8]		; @array[0]
	mov eax, [ebp + 12]		; array size
	sub eax, 1
	mov ecx, 4
	mul ecx
	mov ecx, eax			; sets ecx to the highest index

	xor eax,eax				; sets eax to zero to be the low index

	mov ebx, ecx			; sets ebx to the highest index

	call quickSort

	popad
	pushad
	push [ebp + 8]
	push [ebp + 12]
	call swapper
	popad
	LEAVE
	ret 8
sortList ENDP

; -------------------------------------------------------- -
; swapper 
;
; Receives: The starting address numArray sorted in ascending 
;			order and userNum
; Returns: numArray sorted in descending order
; Requires: numArray sorted in ascending order
; -------------------------------------------------------- -
swapper PROC
	ENTER 0,0

	mov esi, [ebp + 12]		; @array[0]
	mov eax, [ebp + 8]		; array size
	lea edi, [esi+eax*4-4]	; @array[lastElement]

	cmp esi, edi
	jae done

	next:
	mov eax, [esi]
	cmp eax, LO
	jl iskip
	mov ebx, [edi]
	cmp ebx, LO
	jl jskip
	mov [edi], eax
	mov [esi], ebx
	add esi, TYPE DWORD
	sub edi, TYPE DWORD
	cmp esi, edi
	jb next
	jmp done

	iskip:
	add esi, TYPE DWORD
	jmp next

	jskip:
	sub edi, TYPE DWORD
	jmp next

	done:
	LEAVE
	ret 8
swapper ENDP

; -------------------------------------------------------- -
; quickSort (recursive): Modeled after recursive algorithm
; covered in CS 162, as detailed below
;
;void quickSort(int arr[], int start, int end)
;{
;   if (start < end)
;   {
;     // Partition the array and get the pivot point
;     int p = partition(arr, start, end);
;		
;     // Sort the portion before the pivot point
;     quickSort(arr, start, p - 1);
;		
;     // Sort the portion after the pivot point
;     quickSort(arr, p + 1, end);
;   }
;}
;
; Receives: ESI (numArray starting address), EBX (j), EAX(i)
; Returns: numArray sorted in ascending order
; Requires: numArray must be initialized and filled 
; -------------------------------------------------------- -
quickSort PROC
	ENTER 0,0
	

	cmp eax,ebx
	jge theEnd		;stop if lowIndex >= highIndex

	push eax		; low index = eax = i
	push ebx		; high index = ebx = j
	add ebx,4		; j = high index + 1

	; edi == array[low index]
	mov edi, [esi + eax]

	outerLoop:

		iLoop:
		add eax, 4		; i++
		cmp eax, ebx	; exit loop if i >= j
		jge jLoop

		; if array[i] >= pivot then exit loop
		cmp [esi + eax], edi
		jge jLoop

		; else repeat loop
		jmp iLoop

		jLoop:
		sub ebx, 4		; j--

		; if array[j] <= pivot, exit loop
		cmp [esi + ebx], edi
		jle jLoopEnd

		; else repeat loop
		jmp jLoop

		jLoopEnd:
		; if i >= j end the main loop
		cmp eax,ebx
		jge outerLoopEnd

		; else swap array[i] with array[j]
		push [esi+eax]
		push [esi+ebx]
		pop [esi+eax]
		pop [esi+ebx]

		; repeat outter loop
		jmp outerLoop

	outerLoopEnd:
	; store high index to edi
	pop edi

	; store low index to ecx
	pop ecx

	; if i == j do not swap
	cmp ecx, ebx
	je noSwap

	; else, swap the element at the low index with the one in the high index
	push [esi+ecx]
	push [esi+ebx]
	pop [esi+ecx]
	pop [esi+ebx]

	noSwap:
	;set eax to low index
	mov eax,ecx
	push edi	; save high index
	push ebx	; save j

	sub ebx, 4	; ebx == j-1

	call quickSort

	; store j in eax
	pop eax
	add eax, 4	; eax == j+1

	pop ebx		; stores high index in ebx
	call quickSort

	theEnd:
	LEAVE
	ret
quickSort ENDP


; -------------------------------------------------------- -
; displayMed
;
; Receives: The starting address of numArray and userNum
; Returns: Calculates median and displays it to the console
; Requires: numArray must be filled & sorted
; -------------------------------------------------------- -
displayMed PROC
	ENTER 0,0
	mov esi, [ebp + 8]		; @array[0]
	mov eax, [ebp + 12]		; array size

	; Check if there are an even/odd number of elements
	mov ebx, 2
	cdq
	div ebx
	cmp edx, 0
	jne oddArray

	; if even size
	mov ebx, 4
	sub eax, 1
	mul ebx
	mov ecx, [esi + eax]
	add eax, 4
	mov ebx, eax
	mov eax, [esi + ebx] 
	add eax, ecx
	xor edx, edx
	mov ebx, 2
	cdq
	div ebx
	add eax, 1
	jmp display

	oddArray: ; else odd size
	mov ebx, 4
	mul ebx
	mov ecx, [esi + eax]
	mov eax, ecx

	display:
	call crlf
	call crlf
	mov edx, OFFSET medianO1
	call writestring
	call writedec
	mov edx, OFFSET mediEND
	call writestring 
	call crlf
	jmp theEnd

	theEnd:
	LEAVE
	ret 8
displayMed ENDP


; -------------------------------------------------------- -
; displayList
;
; Receives: The string indicating whether a sorted/unsorted
;			array will be displayed, starting address of 
;			numArray and userNum
; Returns: Displays sorted/unsorted array contents to console
; Requires: Initialized/filled numArray
; -------------------------------------------------------- -
displayList PROC
	Enter 4,0
	pushad
	mov edx, [ebp + 16]	; stores what type of list is being displayed
	mov esi, [ebp + 12]	; stores address of numArray[0] in esi
	mov ecx, [ebp + 8]	; stores value of userNum to ecx for loop counter
	mov edi, [ebp - 4]
	mov edi, 0
	; identifies if list is sorted/unsorted
	call crlf
	call writestring
	
	;print first element
	first:
	mov eax, [esi]
	add esi, TYPE DWORD
	call writedec
	mov edx, OFFSET space
	call writestring
	dec ecx
	inc edi
	jmp arrayPrint

	
	arrayPrint:
	mov edx, 0
	mov eax, edi
	mov ebx, 10
	div ebx
	cmp edx, 0
	jne addspace
	call crlf

	addSpace:
	mov eax, [esi]
	add esi, TYPE DWORD
	call writedec
	mov edx, OFFSET space
	call writestring
	inc edi
	loop arrayPrint
	
	call crlf
	popad
	LEAVE
	ret 12
displayList ENDP


; -------------------------------------------------------- -
; farewell
;
; This procedure displays a farewell message to the user.
; Requires: none
; -------------------------------------------------------- -
farewell PROC
	call crlf
	mov edx, OFFSET goodbye
	call writeString
	call crlf

	ret
farewell ENDP

END main


























;TITLE Program06_Carrabino

; Author: John Carrabino
; Course / project ID : CS 271 - Program 05
; Date: 11 / 20 / 2016
; Description: 
; 


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
intro1 BYTE "Designing Low-Level I/O Procedures		Programmed by John Carrabino", 0dh, 0ah, 0
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
	mov eax, 0
	call introduction
	
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

		push count				;[ebp+16]
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
	mov edx, OFFSET prompt_3
	call writestring
	mov edx, OFFSET prompt_4
	call writestring
	call crlf

	ret
introduction ENDP


; -------------------------------------------------------- -
; readVal
;
;
; Receives: 
; Returns: 
; Requires: 
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
		mov edx, OFFSET Error_1
		call writeString
		call crlf
		mov edx, OFFSET Error_2
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
	ret 12
readVal ENDP

; -------------------------------------------------------- -
; writeVal
;
;
; Receives: 
; Returns: 
; Requires: 
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

; -------------------------------------------------------- -
; farewell
;
; This procedure displays a farewell message to the user.
; Requires: none
; -------------------------------------------------------- -
farewell PROC
	call crlf
	mov edx, OFFSET goodbye
	call writeString
	call crlf

	ret
farewell ENDP

END main

















;TITLE Program06_Carrabino

; Author: John Carrabino
; Course / project ID : CS 271 - Program 05
; Date: 11 / 20 / 2016
; Description: 
; 


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
	mov edx,  OFFSET uString
	call writeString
	pop edx
ENDM

.data
intro1 BYTE "Designing Low-Level I/O Procedures		Programmed by John Carrabino", 0dh, 0ah, 0
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
temp DWORD ?
numArray DWORD 10 DUP(?)
count DWORD ?

space BYTE ", ",0
displayList BYTE "You entered the following numbers: ",0dh,0ah,0
displaySum BYTE "The sum of these numbers is: ",0
displayAvg BYTE "The average is: ",0

goodbye BYTE "Thanks for playing!",0dh,0ah,0

.code
main PROC
	call introduction
	
	mov ecx, 10
	mov esi, OFFSET numArray
	mov count, 0

	uInputLoop:
		displayString getNum
		push count				;[ebp + 16]
		push OFFSET numArray	;[ebp + 12]
		push OFFSET uString		;[ebp + 8]
		call readVal

		mov ebx, count
		lea edi, [esi + ebx * TYPE DWORD]
		inc count
		mov eax, [edi]
		call writedec
		call crlf

	loop uInputLoop
	


	mov esi, OFFSET numArray
	mov ecx, 10
	mov count, 0
	mov uString, 0

	displayString displayList

	listLoop:
	mov ebx, count
	
	lea edi, [esi + ebx * TYPE DWORD]
	inc count
	mov eax, [edi]
	mov userNum, eax

	
	push userNum			;[ebp + 12]
	push OFFSET uString		;[ebp + 8]
	call writeVal

	displayString space

	loop listLoop
	
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
	mov edx, OFFSET prompt_3
	call writestring
	mov edx, OFFSET prompt_4
	call writestring
	call crlf

	ret
introduction ENDP


; -------------------------------------------------------- -
; readVal
;
;
; Receives: 
; Returns: 
; Requires: 
; -------------------------------------------------------- -
readVal PROC
	ENTER 0,0
	pushad

	getNumber:
	mov edx, [ebp + 8]		;@uString
	
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
	mov edx, OFFSET Error_1
	call writeString
	call crlf
	mov edx, OFFSET Error_2
	call writestring
	jmp getNumber

	valid:
	add eax, ecx
	xchg eax, ecx
	jmp readBytes

	done:
	xchg eax, ecx
	mov edx, [ebp + 16]					; loop count
	mov esi, [ebp + 8]					; @numArray
	lea edi, [esi + edx * TYPE DWORD]	; @numArray[i]
	mov [edi], eax

	popad
	LEAVE
	ret 12
readVal ENDP

; -------------------------------------------------------- -
; writeVal
;
;
; Receives: 
; Returns: 
; Requires: 
; -------------------------------------------------------- -
writeVal PROC
	ENTER 0,0
	pushad

	mov eax, [ebp + 12]	;numArray[i]
	mov edi, [ebp + 8]	;@uString
	mov ebx, 10
	

	done:

	popad
	LEAVE
	ret 8
writeVal ENDP

; -------------------------------------------------------- -
; farewell
;
; This procedure displays a farewell message to the user.
; Requires: none
; -------------------------------------------------------- -
farewell PROC
	call crlf
	mov edx, OFFSET goodbye
	call writeString
	call crlf

	ret
farewell ENDP

END main