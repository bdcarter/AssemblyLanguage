




.data
MIN = 10
MAX = 200
LO = 100
HIGH = 999
request 	dword	200
array		dword	request	DUP(?)
intro1		byte	"Random Number List by Brianna Carter",0
intro2		byte	"Produces random numbers between 100-999,",0
intro3		byte	" displays the numbers, sorts them, displays ",0
intro4		byte	"the median, and displays the sorted lsit.",0
directions	byte	"Please enter a number between 10-200",0
invalid		byte	"Invalid number",0
median		byte	"The median is: ",0
original	byte	"The numbers are: ",0
sorted		byte	"The sorted numbers are: ",0
space		byte	"   ",0


.code

;-----------------------------------------------
;Introduction: Alters edx. Displays the introduction.;
;-----------------------------------------------
PROC Introduction
	mov edx, OFFSET intro1		;display the title and author
	call writestring
	call crld 
	mov edx, OFFSET intro2
	call writestring
	mov edx, OFFSET intro3
	call writestring
	mov edx, OFFSET intro4
	call writestring
	ret

 Introduction ENDP

;-----------------------------------------
;GetData: alters edp, esp, edx, eax
;	parameters: request
;	gets the size of the array from the user, makes sure 
;	it is in the proper range [10-200]
;------------------------------------------

PROC GetData
	get:
		push ebp				
		mov ebp, esp
		mov edx, OFFSET directions	;have the user insert number
		call writestring
		call ReadDec				;get the number from the user
		mov [ebp + 8], eax			;store the user input in request
		cmp eax, min
		JB error					;jump to error if below min
		cmp eax, max
		JA error					;jump to error if above max
		JMP finish					;finish if in range

	error:
		mov edx, OFFSET invalid
		call writestring			;display error message
		jmp get

	finish:
		pop ebp
		ret 4						;remove variable from stack
GetData ENDP

;------------------------------------------
;FillArray: fills the array with random numbers between 100-999.
; parameters: @array, request
; alters: ecx, ebx, eax
; ------------------------------------------
PROC FillArray

		push ebp
		mov ebp, esp
		mov ecx, [ebp + 12]			;request, number of elements
		mov ebx, [ebp + 8]			; @ array

	fill:
		mov eax, HIGH				;generate random numbers
		call RandomRange			
		sub eax, LOW				;subtract 100 from number
		mov [ebx], eax				;move the random num to the array
		add ebx, TYPE DWORD
		loop fill

		pop ebp
		ret 8
FillArray ENDP

;-----------------------------------------------
; Sort: sorts the numbers in the array in descending order
; Parameters: @array, request
; Alters: ecx, esi, eax
;--------------------------------------------------
PROC Sort
		push ebp
		mov ebp, esp
		mov ecx, [ebp + 8]				;store request in counter
		dec ecx							;decrease counter since array starts at 0

	outer:
		push ecx						;save outer loop
		mov esi, [ebp + 12]				; point to array

	compare:
		mov eax, [esi]					;move @ element to eax
		cmp eax, [esi+4]				;compare value in eax to value in next element
		JG	next						;if first element is greater, don't switch
	exchange:
		xchg eax, [esi+4]				;exchange elements
		mov [esi + 4], eax	

	next:
		add esi, 4						;move to next element
		loop compare					;loop

		pop ecx							;restore out loop
		loop outer

	finish:
		pop ebp
		ret 8

Sort ENDP

;---------------------------------------------
; Median: Calculates and displays the median value in the array 
; Alters: esi, edx, eax, ecx
; Variables: @array, request
;--------------------------------------------------
PROC Median
		push ebp
		mov ebp, esp
		mov esi, [ebp +12]			; move @ array to esi
		mov edx, 0
		mov eax, [ebp + 8]			;move request to eax
		div 2
		cmp edx, 0					;if remainder is 0, request is even
		JE even						;jump to calculate average mean
		inc eax				
		add esi, eax				;move array to median value
		mov edx, OFFSET median
		call writestring
		mov eax, [esi]				;move value in esi to eax
		call writedec
		call cldr
		jmp finish

	even:
		add esi, eax
		mov ecx, [esi]
		add esi, 4					;add the to middle values
		add ecx, [esi]
		mov eax, ecx
		div 2 						
		mov edx, OFFSET median
		call writestring
		call writedec
		call cldr

	finish:
		pop ebp
		ret 8
Median ENDP

;----------------------------------------------------------
; Display: Displays the values in the array, 10 in a row
; Alters: ecx, edx, esi, eax, edi
; Variables: @array, request, title
;----------------------------------------------------------
PROC Display
		push ebp
		mov ebp, esp
		mov ecx, [ebp + 8]			;display counter
		mov edx, [ebp + 16]			;Title
		call writestring
		call crld
		mov esi, [ebp + 12]			;@ array
		mov edi, 0					;counter for number display
	L1:
		inc edi						;increase display counter
		mov eax, [esi]				
		call writedec				;display value in array
		mov edx, OFFSET space
		call writestring
		add esi, 4					;move to next array element
		mov edx, 0
		mov eax, edi
		div 10 						;test how many numbers have been displayed
		cmp edx, 0
		je line						;if 10, print newline
		loop L1						;loop
		jmp finish

	line:
		call crld
		loop L1
	finish:
		pop ebp
		ret 12

;---------------------------------
; Main
;---------------------------------
PROC main
	call Randomize

	call Introduction

	push OFFSET request
	call GetData

	push request
	push OFFSET array
	call FillArray

	push OFFSET original
	push OFFSET array
	push request
	call Sort

	push OFFSET array
	push request
	call Sort

	push OFFSET array
	push request
	call Median

	push OFFSET sorted
	push OFFSET array
	push request
	call Sort

	main ENDP

end
ENDP












