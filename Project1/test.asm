INCLUDE Irvine32.inc
.data
consoleHandle    DWORD ?
xyInit COORD <9, 9>	; starting coordinate
xyBound COORD <80,25>
xyPos COORD <9, 9>		; position of cursor

main EQU start@0
.code
main PROC

; Get the Console standard output handle:
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov consoleHandle,eax
; set the starting position	
INITIAL:
	mov ax,xyInit.x
	mov xyPos.x,ax
	mov ax,xyInit.y
	mov xyPos.y,ax
START:
	call ClrScr
	INVOKE SetConsoleCursorPosition, consoleHandle, xyPos
	call ReadChar
	.IF ax == 4800h ;UP ARROW
		sub xyPos.y,1
	.ENDIF
	.IF ax == 5000h ;DOWN ARROW
		add xyPos.y,1
	.ENDIF
	.IF ax == 4B00h ;LEFT ARROW
		sub xyPos.x,1
	.ENDIF
	.IF ax == 4d00h ;RIGHT ARROW
		add xyPos.x,1
	.ENDIF
	.IF ax == 011Bh ;ESC
		jmp END_FUNC
	.ENDIF
	
	
	.IF xyPos.x == 0h ;x lowerbound
		add xyPos.x,1
	.ENDIF
	mov ax,xyBound.x
	.IF xyPos.x == ax ;x upperbound
		sub xyPos.x,1
	.ENDIF
	
	.IF xyPos.y == 0h ;y lowerbound
		add xyPos.y,1
	.ENDIF
	mov ax,xyBound.y
	.IF xyPos.y == ax ;y upperbound
		sub xyPos.y,1
	.ENDIF
	
	jmp START
END_FUNC:
	exit
main ENDP

END main
;boyi test
