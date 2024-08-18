TITLE Project 6     (Proj6_rodrigb4.asm)

; Author:	Brenda Rodriguez
; Last Modified:	06-09-2024
; OSU email address:	rodrigb4@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:	6              Due Date:	06-09-2024
; Description: This program receives a signed decimal integer, that must be able to 
; fit in 32 bits, from the user as a string. This string is converted to its numerical
; SDWORD representation, and is stored in an array. These numerical SDWORD values are
; then converted to strings, and are displayed. The sum and truncated average of these 
; values are calculated and displayed. 

INCLUDE Irvine32.inc

; Macro definitions

; -------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays provided string.
;
; Preconditions: Do not use EDX as an argument. 
;
; Receives: 
;		stringAdd = address of string to display
; Returns: none
;
; -------------------------------------------------------------------------------

mDisplayString MACRO stringAdd

	PUSH	EDX						; preserving used register
	MOV		EDX, stringAdd
	CALL	WriteString
	POP		EDX						; restoring used register

ENDM

; -------------------------------------------------------------------------------
; Name: mGetString
;
; Displays provided prompt string, and reads and stores user input string.
;
; Preconditions: Do not use EDX, ECX, or EAX as arguments. mCount contains intended 
; buffer size.
;
; Receives: 
;		promptAdd		= address of prompt to display
;		inputAdd		= address to store user input
;		mCount			= value for max buffer size for ReadString
;		bytesReadAdd	= address to store bytes read
; Returns: User input stored at inputAdd. Bytes read stored at bytesReadAdd.
;
; -------------------------------------------------------------------------------

mGetString MACRO promptAdd, inputAdd, mCount, bytesReadAdd

	; MACRO CALL to display prompt
	mDisplayString promptAdd		

	PUSH	EDX						; preserving used registers
	PUSH	ECX
	PUSH	EAX						

	MOV		EDX, inputAdd
	MOV		ECX, mCount			
	CALL	ReadString	
	MOV		bytesReadAdd, EAX		

	POP		EAX						; restoring used registers			
	POP		ECX
	POP		EDX

ENDM



.data

introStr1		BYTE		"Project 6 - String Primitives and Macros - Brenda Rodriguez",13,10,0
introStr2		BYTE		"You will be providing 10 signed decimal integers. Each must be able to fit in a 32 bit register. If invalid characters are entered or"
				BYTE		" the integer is too large to fit in 32 bits, you will receive an error message and be reprompted to enter the next integer. "
				BYTE		"Once 10 valid signed decimal integers have been entered, they will be displayed in a list, as well as their sum and truncated average.",13,10,0
promptStr		BYTE		"Please enter a signed integer: ",0
inputStr		BYTE		13 DUP(0)
inputArr		SDWORD		10 DUP(0)
count			DWORD		12
bytesRead		DWORD		0
errorMsg		BYTE		"The value entered either contained invalid characters, or was too large.",13,10,0
negative		DWORD		0
tempStr			BYTE		11 DUP(0)
totalSum		SDWORD		0
avg				SDWORD		0
finalStr1		BYTE		12 DUP(0)
finalStr2		BYTE		12 DUP(0)
finalStr3		BYTE		12 DUP(0)
finalStr4		BYTE		12 DUP(0)
finalStr5		BYTE		12 DUP(0)
finalStr6		BYTE		12 DUP(0)
finalStr7		BYTE		12 DUP(0)
finalStr8		BYTE		12 DUP(0)
finalStr9		BYTE		12 DUP(0)
finalStr10		BYTE		12 DUP(0)
listLabel		BYTE		"Valid numbers entered: ",0
sumLabel		BYTE		"Sum: ",0
sumStr			BYTE		12 DUP(0)
avgLabel		BYTE		"Truncated Average: "
avgStr			BYTE		12 DUP(0)
farewellMsg		BYTE		"Thanks for participating!",0


.code
main PROC
	; call to introduction procedure
	PUSH	OFFSET introStr1
	PUSH	OFFSET introStr2
	CALL	introduction

	; initialize counter and starting array position for readLoop
	MOV		ECX,  10				
	MOV		EBX, OFFSET inputArr	
	
	; call to ReadVal procedure for 10 valid inputs
_readLoop:
									
	PUSH	OFFSET errorMsg
	PUSH	count					
	PUSH	OFFSET bytesRead
	PUSH	OFFSET promptStr 	
	PUSH	EBX					
	PUSH	OFFSET inputStr			
	CALL	ReadVal				

	ADD		EBX, 4					; increment input array address

	LOOP 	_readLoop

	; after get all 10 user inputs

	MOV		EDX, OFFSET listLabel	; display list label
	mDisplayString EDX
	CALL	CrLf

	; initialize counter and relevant addresses for calls to WriteVal
	MOV		ECX, 10					
	MOV		EBX, OFFSET inputArr
	MOV		EDX, OFFSET finalStr1

	; loop to call to WriteVal procedure 10 times
_writeLoop:

	PUSH	negative
	PUSH	EDX						
	PUSH	OFFSET tempstr			
	PUSH	EBX
	CALL	WriteVal	

	ADD		EBX, 4					; increment addresses accordingly
	ADD		EDX, 12
	LOOP	_writeLoop

	; initialize conditions for and perform sum loop
	MOV		ECX, 10					
	MOV		EAX, 0
	MOV		EBX, OFFSET inputArr
_sum:			
	ADD		EAX, [EBX]
	ADD		EBX, 4					; increment address
	LOOP	_sum
	MOV		totalSum, EAX

	; display sum label
	MOV		EDX, OFFSET sumLabel	
	mDisplayString EDX

	; display sum
	PUSH	negative				
	PUSH	OFFSET sumStr
	PUSH	OFFSET tempstr
	PUSH	OFFSET totalSum
	CALL	WriteVal
	
	; calulate truncated average
	MOV		EAX, totalSum			
	CDQ
	MOV		EBX, 10
	IDIV	EBX
	MOV		avg, EAX

	; display average label
	MOV		EDX, OFFSET avgLabel	
	mDisplayString EDX

	; display average
	PUSH	negative				
	PUSH	OFFSET avgStr
	PUSH	OFFSET tempstr
	PUSH	OFFSET avg
	CALL	WriteVal

	; display farewell message
	PUSH	OFFSET farewellMsg	
	CALL	farewell

	Invoke ExitProcess,0			; exit to operating system
main ENDP

; -------------------------------------------------------------------------------
; Name: introduction
;
; Displays program title and description to user.
;
; Preconditions: none
; Postconditions: none
;
; Receives: 
;		[EBP + 12]	= address of first introduction string
;		[EBP + 8]	= address of second introduction string
; Returns: none
;
; -------------------------------------------------------------------------------

introduction PROC

	PUSH	EBP
	MOV		EBP, ESP

	; display introduction strings using macro
	mDisplayString [EBP + 12]
	mDisplayString [EBP + 8]

	POP		EBP
	RET		8

introduction ENDP

; -------------------------------------------------------------------------------
; Name: ReadVal
;
; Displays prompt to user using the macro mDisplayString, and receives a signed 
; decimal integer from the user in the form of a string of ascii digits. Validates 
; and converts this string to its actual numerical SDWORD representation, and stores 
; this value in the provided location. If invalid, an error message is displayed and
; the user is re-prompted. 
;
; Preconditions: none
; Postconditions:  User input string stored in provided location.
;
; Receives: 
;		[EBP + 8]	= address of string to store user input string
;		[EBP + 12]	= location to store numerical SDWORD representation
;		[EBP + 16]	= address of prompt string
;		[EBP + 20]	= to hold bytes read
;		[EBP + 24]	= count for buffer size in mGetString
;		[EBP + 28]	= address of error message string
; 
; Returns: Numerical SDWORD representation from converting input string stored in 
; provided location.
;
; -------------------------------------------------------------------------------

ReadVal	PROC

	PUSH	EBP
	MOV 	EBP, ESP

	PUSH	ECX						; preserve used registers
	PUSH	EDX
	PUSH	EAX
	PUSH	ESI
	PUSH	EDI

_start:
	; MACRO CALL to get user input in form of string
	mGetString [EBP + 16], [EBP + 8], [EBP + 24], [EBP + 20]

	; initialize conditions for checking ascii digits
	CLD
	MOV		ESI, [EBP + 8]			; inputStr address

	LODSB
	CMP		AL, 45					; check if first character is negative sign
	JNE		_notNeg

	; if negative, set up loop to check and convert each subsequent character

	MOV		ECX, [EBP + 20]			; bytesRead - 1 used for loop counter
	SUB		ECX, 1				

	MOV		EDI, [EBP + 12]			; address of spot in SDWORD array 

_negative:					
	; test if character is a valid ascii digit
	LODSB		
	CMP		AL, 48				
	JL		_invalid		
	CMP		AL, 57				
	JG		_invalid			

	; if valid, continue with conversion
	SUB		AL, 48		
	MOVSX	EDX, AL

	CMP		ECX, 1					; if last iteration, adjust by 1 to prevent overflow
	JNE		_noAdjust		
	SUB		EDX, 1

_noAdjust:

	PUSH	EDX
	PUSH	EBX						; Use as part of loop in main

	; multiply by 10
	MOV		EAX, [EDI]			
	MOV		EBX, 10				
	IMUL	EBX					

	POP		EBX
	POP		EDX

	; if overflow from either operation, then invalid input
	JO		_invalid	
	ADD		EAX, EDX		
	JO		_invalid

	; otherwise, store into array
	MOV		[EDI], EAX			

	LOOP	_negative

	; flip value to negative
	MOV		EDX, [EDI]		
	SUB		[EDI], EDX		
	SUB		[EDI], EDX
	SUB		DWORD PTR [EDI], 1		; final adjustment for negative conversion
	JO		_invalid

	JMP		_end					; when loop done successfully

_notNeg:
	CMP		AL, 43					; check if first character is positive sign
	JNE		_noSignSetUp		
												
	; if positive sign, set up loop to check and convert each subsequent character
	
	MOV		ECX, [EBP + 20]			; bytesRead - 1 for loop counter
	SUB		ECX, 1				

	LODSB							; to move past positive sign

	JMP		_positive

_noSignSetUp:
	; no sign
	MOV		ECX, [EBP + 20]			; bytesRead for loop counter

_positive:					
	MOV		EDI, [EBP + 12]			; address of spot in input array 

	; test if character is a valid ascii digit
	CMP		AL, 48			
	JL		_invalid			
	CMP		AL, 57				
	JG		_invalid

	; if valid, continue with conversion
	SUB		AL, 48				
	MOVSX	EDX, AL

	PUSH	EDX
	PUSH	EBX						; Use as part of loop in main

	; multiply by 10
	MOV		EAX, [EDI]		
	MOV		EBX, 10			
	IMUL	EBX					

	POP		EBX
	POP		EDX

	; if overflow from either operation, then invalid input
	JO		_invalid				
	ADD		EAX, EDX			
	JO		_invalid

	; otherwise, store into array
	MOV		[EDI], EAX						

	LODSB		

	LOOP	_positive				
	JMP		_end					; return out of ReadVal when loop done successfully

_invalid:							
	; if invalid, print error message, discard number, and reprompt
	mDisplayString [EBP + 28]

	MOV		DWORD PTR [EDI], 0	
	JMP		_start					

_end:
	POP		EDI						; restore used registers
	POP		ESI
	POP		EAX
	POP		EDX
	POP		ECX					
	POP		EBP
	RET		24	

ReadVal ENDP

; -------------------------------------------------------------------------------
; Name: WriteVal
;
; Converts a numerical SDWORD value to string form, and displays this string using
; the macro mDisplayString. 
;
; Preconditions: Address of numerical SWORD value contains accurate, intended value.
;
; Postconditions: Temporary string is altered.
;
; Receives: 
;		[EBP + 8]	= address of numerical SDWORD value to convert to string
;		[EBP + 12]	= address of temporary string to first copy characters into
;		[EBP + 16]	= address of final string to copy characters into and display
;		[EBP + 20]	= holds value of negative indicator
;
; Returns: The provided final string contains string representation of numerical
; SDWORD value.
;
; -------------------------------------------------------------------------------

WriteVal PROC

	PUSH	EBP
	MOV		EBP, ESP

	PUSH	ECX						; preserving used registers
	PUSH	EBX
	PUSH	EDX
	PUSH	EAX
	PUSH	EDI
	PUSH	ESI

	MOV		EBX, [EBP + 8]			; initialize first value to divide
	MOV		EAX, [EBX]				

	MOV		EDI, [EBP + 12]			; initialize temporary string to copy into
	MOV		ECX, 0					; initialize counter to keep track of digits in number
	CMP		EAX, 0				
	JS		_neg					; if negative
	JMP		_repeat		

_neg:
	; if negative, first division set up to make subsequent values positive
	INC		DWORD PTR [EBP + 20]	; set negative indicator
	INC		ECX						; count digit
	MOV		EDX, 0					
	CDQ
	MOV		EBX, 10
	NEG		EBX						; divide by -10
	IDIV	EBX

	NEG		EDX						; to make remainder positive
	ADD		EDX, 48
	PUSH	EAX						; preserve quotient b/c changing AL
	MOV		AL, DL
	STOSB
	POP		EAX
	CMP		EAX, 0
	JE		_zeroQuotient			; continue/repeat if quotient not 0

_repeat:							
	; count digit, and convert to ascii string
	INC		ECX
	MOV		EDX, 0					
	CDQ
	MOV		EBX, 10					; divide by 10
	IDIV	EBX						

	ADD		EDX, 48					; convert to ascii digit
	PUSH	EAX						
	MOV		AL, DL					
	STOSB				

	POP		EAX						; restore quotient, might use for next iteration

	CMP		EAX, 0					; repeat until quotient is 0 
	JNE		_repeat				

_zeroQuotient:
	; initialize conditions for reversing string
	MOV		EDI, [EBP + 16]			; initialize final string to copy into
	MOV		ESI, [EBP + 12]			; initialize temp string to read from
	ADD		ESI, ECX				; adjust ESI to starting end of temp string
	SUB		ESI, 1

	; if negative, add negative sign to string
	CMP		DWORD PTR [EBP + 20], 1
	JNE		_reverse
	CLD								
	MOV		AL, 45
	STOSB

	; reverse into final string
_reverse:							; ECX already set 
	STD
	LODSB

	CLD
	STOSB
	LOOP	_reverse

_display:
	; display "number" string
	mDisplayString [EBP + 16]	
	CALL	CrLf	

	POP		ESI						; restore used registers
	POP		EDI
	POP		EAX
	POP		EDX						
	POP		EBX
	POP		ECX

	POP		EBP
	RET		16						

WriteVal ENDP

; -------------------------------------------------------------------------------
; Name: farewell
;
; Displays farewell message to user.
;
; Preconditions: none
;
; Postconditions: none
;
; Receives: 
;		[EBP + 8]	= address of farewell message
;
; Returns: none
;
; -------------------------------------------------------------------------------

farewell PROC

	PUSH	EBP
	MOV		EBP, ESP

	; display farewell string using macro
	mDisplayString [EBP + 8]

	POP		EBP
	RET		4

farewell ENDP



END main
