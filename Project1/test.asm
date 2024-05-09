INCLUDE Irvine32.inc

PrintCarProc PROTO,
	pos:COORD 
CrashTest PROTO, 
	obstaclePos: COORD,

carWidth = 8
roadWidth = 1
graphWidth = 80

.data
pagePos COORD <20, 3>		; position of cursor
list BYTE ".,,,,,,,,,,.,,,,,,,,,,,,,*,,,**,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
	 BYTE ",,,,.,,,,,,,,,,,,,,,.,,,,,,,,,,,,,,,,**,,,,,,..,..,,,,,,,,,..,..,,,,,,,,,,,,,,,,"
	 BYTE "..........,,,,,,,,,,,,,,...,.,.,,.,,,,,,,,,,,..,..,,,,,,,,,,,.......,,,,,,,,,,,,"
	 BYTE "..................,..,,,,,,,,,,,,...,,.,,,,,...,,,,,,,,,,,,......,,,,,,,,,,,,,,,"
	 BYTE ".... ............ .......,,,,,,,,,,,,*((%%%%(,,,,,,,,,,,,,.......,,,,,,,,,,,,,,,"
	 BYTE ".........................,,.......,(%&%%%%%%%%%,.....,,,........,,..,,,,,,,,,,,,"
	 BYTE "............. .....  ............,%%((/////**/%*,...,,,,,,,....,,,...,,,,,,,,,,,"
	 BYTE "............  ... .......,.,.....,%%((((//(///%,....,,,,,,,,,..,,......,,,,,,,,,"
	 BYTE "......... .................,,,..,,(((((((////*/%.,,,,,,..,,,,,,,,,,.....,,,,,,,,"
	 BYTE "....   .   .........      ...,,,,,((((((((/////,,,,,,......,,,,,,,,.  .....,,,,,"
	 BYTE "   . .......................,,,,,,,,/(((%/%///,,,,,,,,,,,,,,,,,,,,,,,..,,,,,,,,,"
 	 BYTE " .       ..........  .     ..,,,,,,%/%(((/%%%/,,,,............,,,,,,,........,,,"
 	 BYTE "        ......... ....  .....,*(%&&&/%%%%%(%%(%%%,,,,....,....,,,,,,,,,.....,,,,"
	 BYTE " ........................,(%&&&&&&&&&/,(/(%**,,&%&&&&&&,*/****,,,,.,,,,,,,,,,,,,"
	 BYTE " . ..... . ..,,,....,./&&&&&&&&%%&&&&%/*,/(**,,%%&&&&%&%%,,,,..,,,....,,,,,,...."
	 BYTE ". .....  . .,,,,.,..,,%&&&&&&&%/(%&&&&%%/****(&&%&&&&&&&%,,,...,,,.....,,,,,.,.."
	 BYTE "......... .,,,,.....,,%&&&&&&&(%%////&&/****/(&&&&&&&&&&&,,.,,.,,,,...,,,,,,,,.."
	 BYTE "..     ..,,,,,,,,,****(&&&&&&&%%%%(/(&&*****&@&&&&&&&&&&&,,,....,,,,,,,,..,,,,,,"
	 BYTE ".      ..,,,,,.,,,,,,/%%&&&&@&%%%(%&&&&&/(%(%&&&&&&&&&&&&,......,,,,,.,......,,,"
	 BYTE "       ...,,,,,,,,,,/%%&&&&%%&&%%(&&&&&&%%%((@&&&&&&&&&&&,,,,...,,,,...,,,,,,,,,"
	 BYTE "    .  ...,,,,,,,,,,%%%%%&%&&&%%&@&&&&&&%%(&@&&&&&&&&@@&&,,,,,,,,,,....,,,.,,,,,"
	 BYTE ".........,,*,,,,,,,,%&&&&&@@(@&&&@@&&&&&%((&@@&&&&&@&&&%,,,,,,,,,*,,,,,,,,,,,,,,"
	 BYTE "......,.,,,**,,,,,,(&@@&@@@@@@@@@@@@@&&&%%(%@&@&&&@&&&&,,,,,,,,,,,,,,,,,,,,,,,,,"
	 BYTE "...,,,,,,*,*,,,,,,,,*&@&@@@@@@@@@@@@@@&&%%&%@@&&&@&&&&%,,,,,,,,,,,,,,,,,,,,,,,,,"
	 BYTE "                                                                                "
	 BYTE "                                                                                "
	 BYTE "                             Press Any Key To Start                             "
outputHandle    DWORD ?
carInit COORD <74, 20>	; starting coordinate
carUpperBound COORD <75,20>
carLowerBound COORD <45, 20>
carPos COORD <0, 0>		; position of cursor
obstaclePos1 COORD <0, 0>
obstaclePos2 COORD <0, 0>
obstaclePos3 COORD <0, 0>
cursorInfo CONSOLE_CURSOR_INFO <1, TRUE> ; set cursor size to 1 and visibility to FALSE (block cursor)
block1 BYTE " ______ "
	   BYTE	"/==  ==\"
	   BYTE	"|[____]|"
	   BYTE	"||    ||"
	   BYTE	"||____||"
	   BYTE	"!______!"
road BYTE "#"
count DWORD 0
rightRoadPos COORD <83, 0>
leftRoadPos COORD <44, 0>
dwSize COORD <150, 100>
timer word 100;
checkForOb byte 0
counter byte 0
score DWORD 0

sysTime SYSTEMTIME <>   ; SYSTEMTIME structure to hold system time
check byte 0

main EQU start@0
.code
main PROC

; Get the Console standard output handle:
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	
	; Set the cursor size and visibility


; Set the start page
	mov ecx, 27
Start_Page: 
	push ecx
	mov esi, 27
	sub esi, ecx
	imul esi, graphWidth
	mov eax, offset list
	add eax, esi
	INVOKE WriteConsoleOutputCharacter,
	   outputHandle,	; console output handle
	   eax,	; pointer to the top box line
	   graphWidth ,	; size of box line
	   PagePos,	; coordinates of first char
	   addr count	; output count
	add PagePos.y, 1
	pop ecx 
	loop Start_Page
	Invoke Sleep, 1000
	call ReadChar
	
; set the starting position	
INITIAL:
	mov ax, carInit.x
	mov carPos.x, ax
	mov ax, carInit.y
	mov carPos.y, ax
	INVOKE SetConsoleScreenBufferSize,
		outputHandle, ; handle to screen buffer
		dwSize; new screen buffer size

	Obstacle:
		call Randomize
		call SetObstacle1
		call SetObstacle2
		call SetObstacle3

timeline:
	INVOKE GetLocalTime, ADDR sysTime   ; Get the current system time
	movzx eax, sysTime.wMilliseconds  ; Load milliseconds part of the time
	mov edx,0
	div timer
	cmp edx, 50         ; Check if milliseconds >= 50
	;mov eax, edx
	;call WriteInt
	jl timeline        ; Jump back if less than 50

START:
	call ClrScr

	;print Road================================================
	push ecx
	mov ecx, 0
	mov cx, dwSize.y
	mov rightRoadPos.y, 0
	mov leftRoadPos.y, 0
PrintRoad:
	push ecx

	INVOKE WriteConsoleOutputCharacter,
	   outputHandle,	; console output handle
	   addr road,	; pointer to the top box line
	   roadWidth ,	; size of box line
	   rightRoadPos,	; coordinates of first char
	   addr count	; output count
	INVOKE WriteConsoleOutputCharacter,
	   outputHandle,	; console output handle
	   addr road,	; pointer to the top box line
	   roadWidth ,	; size of box line
	   leftRoadPos,	; coordinates of first char
	   addr count	; output count
	pop ecx
	inc rightRoadPos.y  ; Increment the y-coordinate for the road
	inc leftRoadPos.y  ; Increment the y-coordinate for the road
	loop PrintRoad
	pop ecx
	;print Road==============================================================

	
PrintCar:
	INVOKE PrintCarProc,
		carPos
	
PrintObstacle1:
	INVOKE PrintCarProc,
		obstaclePos1
	
PrintObstacle2:
	INVOKE PrintCarProc,
		obstaclePos2
	
PrintObstacle3:
	INVOKE PrintCarProc,
		obstaclePos3
	

Speed:
	mov al, counter
	inc al
	mov counter, al
	.IF counter == 2
		mov counter, 0
		add obstaclePos1.y, 1
		add obstaclePos2.y, 1
		add obstaclePos3.y, 1
	.ENDIF

CheckObstacle:
	.IF obstaclePos1.y == 25
		call SetObstacle1
	.ENDIF
	.IF obstaclePos2.y == 25
		call SetObstacle2
	.ENDIF
	.IF obstaclePos3.y == 25
		call SetObstacle3
	.ENDIF

TestCar:
	INVOKE CrashTest, obstaclePos1
	.IF ax == 1
		jmp END_Page
	.ENDIF
	INVOKE CrashTest, obstaclePos2
	.IF ax == 1
		jmp END_Page
	.ENDIF
	Invoke CrashTest, obstaclePos3
	.IF ax == 1
		jmp END_Page
	.ENDIF
	

KBCheck:
	;detect move==============================================================
	.if check==0
		call ReadKey
		.IF ax == 4B00h ;LEFT ARROW
			mov check, 1
			sub carPos.x, 1
		.ENDIF
		.IF ax == 4d00h ;RIGHT ARROW
			mov check, 1
			add carPos.x, 1
		.ENDIF
		.IF ax == 011Bh ;ESC
			jmp END_FUNC
		.ENDIF
	
		mov ax, carLowerBound.x
		.IF carPos.x == ax ; x lowerbound
			add carPos.x, 1
		.ENDIF
		mov ax, carUpperBound.x
		.IF carPos.x == ax ; x upperbound
			sub carPos.x, 1
		.ENDIF
		.IF check==1
			jmp START
		.ENDIF
	.ENDIF
	;detect move===============================================================


time_buffer:
	INVOKE GetLocalTime, ADDR                                             sysTime   ; Get the current system time
	movzx eax, sysTime.wMilliseconds  ; Load milliseconds part of the time
	mov edx,0
	div timer
	cmp edx, 50         ; Check if milliseconds >= 49
	jge KBCheck
	mov check, 0
	jmp timeline      ; Repeat 'count' times

END_Page:
	call ClrScr
	sub PagePos.y, 28
	mov ecx, 27
	jmp Start_Page
END_FUNC:
	exit

SetObstacle1 PROC
	xor bx, bx
SetObstacle1X:
	mov ax, 24
	call RandomRange
	add bx, ax
	cmp	bx, 50
	jb SetObstacle1X
	mov obstaclePos1.x, bx
SetObstacle1Y:
	xor bx, bx
	mov bx, obstaclePos3.y
	sub bx, 15
	mov obstaclePos1.y, bx

	ret
SetObstacle1 ENDP

SetObstacle2 PROC
	xor bx, bx
SetObstacle2X:
	mov ax, 30
	call RandomRange
	add bx, ax
	cmp	bx, 45
	jb SetObstacle2X
	mov obstaclePos2.x, bx
SetObstacle2Y:
	xor bx, bx
	mov bx, obstaclePos1.y
	sub bx, 20
	mov obstaclePos2.y, bx

	ret
SetObstacle2 ENDP

SetObstacle3 PROC
	xor bx, bx
SetObstacle3X:
	mov ax, 30
	call RandomRange
	add bx, ax
	cmp	bx, 45
	jb SetObstacle3X
	mov obstaclePos3.x, bx
SetObstacle3Y:
	xor bx, bx
	mov bx, obstaclePos2.y
	sub bx, 20
	mov obstaclePos3.y, bx

	ret
SetObstacle3 ENDP


main ENDP

PrintCarProc PROC USES eax esi ecx,
    pos:COORD
    
	mov ecx, 6

Print:
    push ecx
    mov esi, 6
    sub esi, ecx
    imul esi, carWidth
    mov eax, offset block1
    add eax, esi
    INVOKE WriteConsoleOutputCharacter,
       outputHandle,    ; console output handle
       eax,             ; pointer to the top box line
       carWidth,        ; size of box line
       pos,             ; coordinates of first char
       addr count       ; output count

    add pos.y , 1
    pop ecx
    loop Print

    sub pos.y , 6 ; Adjust the y-coordinate
    ret
PrintCarProc ENDP

CrashTest PROC USES esi ebx,
    obstaclePos :COORD,

	mov ax, obstaclePos.y
	add ax, 5
	.IF ax == carPos.y
		mov ax, obstaclePos.x
		mov bx, carPos.x
		add bx, 7
	.IF ax <= bx
		add ax, 7
	.IF ax >= bx
		mov ax, 1
		ret
	.ENDIF
	.ENDIF
	.ENDIF

	mov ax, obstaclePos.y
	add ax, 5
	.IF ax == carPos.y
		mov ax, obstaclePos.x
	.IF ax <= carPos.x
		add ax, 7
	.IF ax >= carPos.x
		mov ax, 1
		ret
	.ENDIF
	.ENDIF
	.ENDIF

	mov ax, obstaclePos.x
	add ax, 7
	.IF ax == carPos.x
		mov ax, obstaclePos.y
	.IF ax <= carPos.y
		add ax, 5
	.IF ax >= carPos.y
		mov ax, 1
		ret
	.ENDIF
	.ENDIF
	.ENDIF

	mov ax, carPos.x
	add ax, 7
	.IF ax == obstaclePos.x
		mov ax, carPos.y
	.IF ax >= obstaclePos.y
		mov bx, obstaclePos.y
		add bx, 5
	.IF ax <= bx
		mov ax, 1
		ret
	.ENDIF
	.ENDIF
	.ENDIF

	mov ax, obstaclePos.x
	add ax, 7
	.IF ax == carPos.x
		mov ax, obstaclePos.y
		mov bx, carPos.y
		add bx, 5
	.IF ax <= bx
		add ax, 5
	.IF ax >= bx
		mov ax, 1
		ret
	.ENDIF
	.ENDIF
	.ENDIF

	mov ax, carPos.x
	add ax, 7
	.IF ax == obstaclePos.x
		mov ax, carPos.y
		add ax, 5
	.IF ax >= obstaclePos.y
		mov bx, obstaclePos.y
		add bx, 5
	.IF ax <= bx
		mov ax, 1
		ret
	.ENDIF
	.ENDIF
	.ENDIF

	ret
CrashTest ENDP

END main