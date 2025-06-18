[org 0x0100]
jmp main

;globals
pillarcol: dw 79,80,80
pillarheight: dw 5,6,8
pillargap: dw 10,8,9
pillarspawned: dw 1,0,0
birdrow: dw 11
velocity: dw 1
buffer: times 4000 dw 0x0020 
oldkbisr: dd 0
oldtimerisr: dd 0
ticks: dw 0
loopcount: dd 0
startmessage: db "Press any key to ducc around"
createdbymessage: db "Created By:"
name1: db "1. Shehryar Hassan 23L-0603 3H Fall 2024"
name2: db "2. Meerab Munir 23L-0971 3H Fall 2024"
titlemessage: db "Press any key to continue..." ;28
deathscreenmessage1: db "Press E to return to TitleScreen";32
deathscreenmessage2: db "Press R to play again"
deathscreenmessage3: db "Press Q to quit" ;15
Pausescreenmessage2: db "Press R to resume"
infoscreenmessage1: db "Welcome to the realm of Floppy ducks! We are delighted to have you here :D" ;74
infoscreenmessage2: db "The aim of the game is to avoid the bad pillars" ;47
infoscreenmessage3: db "Press SPACE Key to jump against gravity" ;39
infoscreenmessage4: db "Press ESC key to Pause the game" ;31 
infoscreenmessage5: db "Your Score is displayed on the top-left of the screen" ;53
infoscreenmessage6: db "Press any key to start flopping..." ;34
keypressed: dw 0
TitleBirbRow1: dw 3 
TitleBirbRow2: dw 17
TitleBirbflag: dw 0
DeathFlag: dw 0
PauseFlag: dw 0
Score: dw 0
currentDelay: dw 0xffff
ScoreBuffer: times 10 db 0
DeathMessage: db "Joever.... :("
GameRestart: dw 0
GameStarted: dw 0
GameRetry: dw 0
GameQuit: dw 0
music_length: dw 8428
music_data: incbin "nazi-nor.imf"
currentTask: dw 0
; ax bx cx dx si ip cs flags 
pcb: times 2*8 dw 0

PlayMusic:
	mov si, 0 
	.next_note:
			mov dx, 388h
			mov al, [cs:music_data + si]
			out dx, al
			mov dx, 389h
			mov al, [cs:music_data + si + 1]
			out dx, al
			mov bx, [cs:music_data + si + 2]
			add si, 4
		.repeat_delay:	
			mov cx, 1500
			.delay: 
			nop
			loop .delay
		dec bx
		jg .repeat_delay
	cmp si, [cs:music_length]
	jb .next_note
jmp PlayMusic

TimerISR:	
	push ax
	; push bx
	; push cx
	; push dx
	; push si

	; mov bl, [cs:currentTask]				; read index of current task ... bl = 0
	; mov ax, 16							; space used by one task
	; mul bl								; multiply to get start of task.. 10x0 = 0
	; mov bx, ax							; load start of task in bx....... bx = 0

	; pop word [cs:pcb+bx+8]
	; pop word [cs:pcb+bx+6]
	; pop word [cs:pcb+bx+4]
	; pop word [cs:pcb+bx+2]
	; pop word [cs:pcb+bx+0]
	; pop word [cs:pcb+bx+10]
	; pop word [cs:pcb+bx+12]
	; pop word [cs:pcb+bx+14]
	
	; inc word [cs:currentTask]
	; and word [cs:currentTask],1
	
	; cmp word [currentTask],0
	; jne endtimer
	cmp word [velocity],0
	jne endtimer
	inc word [ticks]
	cmp word [ticks],7
	jne endtimer
	mov word [ticks],0
	mov word [velocity],1
	endtimer:
	
	; mov bl, [cs:currentTask]				; read index of current task
	; mov ax, 16							; space used by one task
	; mul bl								; multiply to get start of task
	; mov bx, ax							; load start of task in bx... 10
	
	mov al, 0x20
	out 0x20, al						; send EOI to PIC
	
	; push word [cs:pcb+bx+14]				; flags of new task... pcb+10+8
	; push word [cs:pcb+bx+12]				; cs of new task ... pcb+10+6
	; push word [cs:pcb+bx+10]				; ip of new task... pcb+10+4
	; mov ax, [cs:pcb+bx+0]				; ax of new task...pcb+10+0
	; mov bx, [cs:pcb+bx+2]				; bx of new task...pcb+10+2
	; mov cx, [cs:pcb+bx+4]
	; mov dx, [cs:pcb+bx+6]
	; mov si, [cs:pcb+bx+8]
	pop ax
	jmp far[cs:oldtimerisr]
		
main:	
	; mov ax, 0x8000
	; out 0x40, al
	; mov al, ah
	; out 0x40, al

	mov word [pcb+16+10], PlayMusic	
	mov [pcb+16+12], cs						
	mov word [pcb+16+14], 0x0200		
	mov word [currentTask], 0
	
	call hook
	
	Game:
	call TitleScreen
	call InfoScreen
	mainlabel1:
    call PrintGround
	call PrintBackground
    call PrintBirb                 
    call CopyBuffer
	call PrintStartMessage	

	mov ah,0
	int 0x16
	mov word [GameStarted],1
	
	infloop:
		call CheckDeath
		call PrintBackground
		call PrintPillars
		call PrintBirb
		call ApplyGravity 		
		call MoveGround
		call DisplayScore
		call PausePanel
		call DeathPanel
		call CopyBuffer
		
		cmp word [GameQuit],1
		jne ahead20
		jmp gamequit
			
		ahead20: 
		call delay
		
		cmp word [GameRestart],1
		jne ahead17
		mov ah,0x0C
		mov al,0
		int 21h
		call InitialiseVars
		jmp Game
		
		ahead17:
		cmp word [GameRetry],1
		jne infloop
		mov ah,0x0C
		mov al,0
		int 21h
		call InitialiseVars
		jmp mainlabel1
		
	gamequit:
	call unhook
	call clear
	mov ah,0x0C
	mov al,0
	int 21h
mov ax,0x4c00
int 0x21

InitialiseVars:
	mov word [pillarcol],79
	mov word [pillarcol+2],80
	mov word [pillarcol+4],80
	
	mov word [pillarspawned],1
	mov word [pillarspawned+2],0
	mov word [pillarspawned+4],0
	
	mov word [birdrow],11
	mov word[velocity],1
	mov word [ticks],0
	mov word [loopcount],0
	mov word [loopcount+2],0
	mov word [keypressed],0
	mov word [DeathFlag],0
	mov word [Score],0
	mov word [currentDelay],0xffff
	mov word [GameRestart],0
	mov word [GameStarted],0
	mov word [GameRetry],0
	mov word [PauseFlag],0
	ret

kbisr:
    push ax
	in al, 0x60 
	cmp word [GameStarted],0
	je kbisr_end

	cmp word[DeathFlag],1
	jne morecomp
	cmp word [birdrow],19
	jne kbisr_end
	cmp al,0x10
	jne ahead19
	mov word [GameQuit],1
	jmp kbisr_end
	ahead19:
	cmp al,0x12
	jne ahead16
	mov word[GameRestart],1
    jmp kbisr_end
	ahead16:
	cmp al,0x13
	jne morecomp
	mov word [GameRetry],1
	jmp kbisr_end
	
	morecomp:	
	cmp word[PauseFlag],1
	jne morecomp1
	cmp al,0x10
	jne ahead23
	mov word [GameQuit],1
	jmp kbisr_end
	ahead23:
	cmp al,0x12
	jne ahead21
	mov word[GameRestart],1
    jmp kbisr_end
	ahead21:
	cmp al,0x13
	jne morecomp1
	mov word [PauseFlag],0
	jmp kbisr_end
	
	morecomp1:
	cmp al,0x01
	jne ahead22
	mov word [PauseFlag],1
	jmp kbisr_end
	ahead22:
	cmp al, 0x39        ; Check if space key (make code)
    je key_pressed
    cmp al, 0xb9             ; Check if space key (break code)
    je key_released
	jmp kbisr_end
	             
	key_pressed:
		cmp word [DeathFlag], 1  ; If the game is over, skip
		je kbisr_end
		mov word [ticks], 0
		mov word [velocity], -1  ; Set velocity to -1
		mov word [keypressed], 1 ; Mark key as pressed
		jmp kbisr_end

	key_released:
		cmp word [DeathFlag], 1  ; If the game is over, skip
		je kbisr_end
		mov word [velocity], 0   ; Set velocity to 0
		mov word [keypressed], 0 ; Mark key as released

	kbisr_end:
		mov al, 0x20
		out 0x20, al             ; Send EOI to PIC
		pop ax
		jmp far [cs:oldkbisr]
		
ApplyGravity:
    pusha
	inc word [loopcount]
	cmp word[loopcount],1
	jne no_adjust
	mov word[loopcount],0
	
	cmp word [PauseFlag],1
	je no_adjust
	
    mov ax, [velocity]
    add [birdrow], ax 
	
    cmp word [birdrow], 19
    jle ahead7
    mov word [birdrow], 19
    mov word [velocity], 0 
	jmp no_adjust
	
	ahead7:
	cmp word [birdrow], 1
    jge no_adjust
    mov word [birdrow], 1
	mov word [velocity], 0
	
	no_adjust:
    popa
    ret
	
InfoScreen:
	pusha
	push es
	mov ax,0xb800
	mov es,ax
	mov ax,0x3020
	mov cx,2000
	mov di,0
	cld
	rep stosw 
	push word 21
	push word 23
	call PrintCloudTitle
	push word 3
	push word 64
	call PrintCloudTitle
	push word 2
	push word 35
	call PrintCloudTitle
	push word 3
	push word 10
	call PrintCloudTitle
	push word 20
	push word 50
	call PrintCloudTitle
	push word 18
	push word 2
	call PrintCloudTitle
	push word 12
	push word 68
	call PrintCloudTitle
	push word 9
	push word 3
	call PrintCloudTitle
	
	mov ah,0x13
	mov al,0
	mov bh,0
	push ds
	pop es
	
	mov cx,74
	mov bl,0x3E
	mov dh,5
	mov dl,3
	mov bp,infoscreenmessage1
	int 0x10
	
	mov cx,47
	mov bl,0x3C
	mov dh,8
	mov dl,16
	mov bp,infoscreenmessage2
	int 0x10
	
	mov cx,39
	mov bl,0x3E
	mov dh,11
	mov dl,20
	mov bp,infoscreenmessage3
	int 0x10
	
	mov cx,31
	mov bl,0x3C
	mov dh,14
	mov dl,24
	mov bp,infoscreenmessage4
	int 0x10
	
	mov cx,53
	mov bl,0x3E
	mov dh,17
	mov dl,13
	mov bp,infoscreenmessage5
	int 0x10
	
	mov cx,34
	mov bl,0x3F
	mov dh,23
	mov dl,45
	mov bp,infoscreenmessage6
	int 0x10
	
	mov ah,0
	int 0x16
	pop es
	popa
	ret
	
PausePanel:
	pusha
    push es
	push ds
	cmp word [PauseFlag],0
	je NoPause
	push ds
	pop es
    mov di, (80 * 2 + 21) * 2 
	add di,buffer
    mov ah, 0x0e             
    mov al, 0xdb
    mov bx, 14            
	DrawRow1:
		mov cx, 38              
		FillRow1:
			stosw                    
			loop FillRow1           
			add di, (80 - 38) * 2     
			dec bx                   
			jnz DrawRow1        
	mov di, (80 * 2 + 21) * 2 
	add di,buffer
    mov ah, 0x00             
    mov al, 0xdb
    mov cx,38
	cld 
	rep stosw
	mov cx,38
	add di,14*160-76
	cld 
	rep stosw
	
	mov di,(80*4+37)*2
	add di,buffer
	mov cx,4
	mov ah,0x04
	mov al,0xdb
	lop8:
		mov [es:di],ax
		add di,160
		loop lop8
	
	sub di,158
	mov cx,4
	lop9:
		mov [es:di],ax
		sub di,160
		loop lop9
		
	add di,168
	mov cx,4
	lop10:
		mov [es:di],ax
		add di,160
		loop lop10
	
	sub di,158
	mov cx,4
	lop11:
		mov [es:di],ax
		sub di,160
		loop lop11
		
	mov cx,32
	mov si,deathscreenmessage1
	mov di,1968+buffer
	mov ah,00001111b
	cld
	lop6:
		lodsb
		stosw
	loop lop6
	
	mov cx,15
	mov si,deathscreenmessage3
	mov di,2306+buffer
	mov ah,00001111b
	cld
	lop5:
		lodsb
		stosw
	loop lop5
	
	mov cx,17
	mov si,Pausescreenmessage2
	mov di,1664+buffer
	cld
	lop1:
		lodsb
		stosw
	loop lop1
	NoPause:
    pop ds
    pop es
    popa
    ret
	

clear:
pusha
mov ax,0xb800
mov es,ax 
mov di,0
mov cx,2000

mov ah,0x07
mov al,' '
cld

rep stosw

popa
ret

PrintPillars:
	pusha
	
	cmp word [pillarspawned+2],0
	jne ahead5
	cmp word [pillarcol],53
	jg ahead5
		dec word[pillarcol+2]
		mov word [pillarspawned+2],1
	ahead5:
	cmp word [pillarspawned+4],0
	jne ahead6
	cmp word [pillarcol+2],52
	jg ahead6
		dec word[pillarcol+4]
		mov word [pillarspawned+4],1
	ahead6:
	
	mov cx,1
	cmp word [pillarspawned+2],0
	je ahead3
		inc cx
	ahead3:
	cmp word [pillarspawned+4],0
	je ahead4
		inc cx
	ahead4:
	mov dx,0
	
	PillarsPrinting:
	mov bx,dx
	shl bx,1
	cmp word[pillarcol+bx], -3
	jge ahead2
	mov word[pillarcol+bx],79
	sub sp,2
	push word 5
	call Rand
	pop word[pillarheight+bx]
	add word [pillarheight+bx],2
	sub sp,2
	push word 4
	call Rand
	pop word[pillargap+bx]
	add word [pillargap+bx],7
	
	ahead2:
	push word [pillarcol+bx]
	push word 0
	push word [pillarheight+bx] ;height
	push word 0;direction
	call PrintPillar
	
	push word [pillarcol+bx]
	mov ax,[pillarheight+bx]
	add ax,[pillargap+bx]
	push word ax
	mov ax,20
	sub ax,[pillarheight+bx]
	sub ax,[pillargap+bx]	
	push word ax;height
	push word 1;direction
	call PrintPillar
	cmp word [DeathFlag],1
	je endpillars
	cmp word [PauseFlag],1
	je endpillars
	dec word [pillarcol+bx]
	cmp word [pillarcol+bx],34
	jne endpillars
	inc word [Score]
	sub word [currentDelay],0x200
	cmp word [currentDelay],0x7000
	jae endpillars
	mov word [currentDelay],0x7000
	endpillars:
	inc dx
	cmp dx,cx
	jl PillarsPrinting
	
	popa
	ret 
	
delay:
pusha
mov cx,[currentDelay]
 delayloop:
 loop delayloop
 mov cx,[currentDelay]
 delayloop1:
 loop delayloop1
 mov cx,[currentDelay]
 delayloop2:
 loop delayloop2

popa
ret

DeathPanel:
	pusha
    push es
	push ds
	cmp word [DeathFlag],0
	je NoDeath
	cmp word [birdrow],19
	jne NoDeath
	push ds
	pop es
    mov di, (80 * 2 + 21) * 2 
	add di,buffer
    mov ah, 0x0e             
    mov al, 0xdb
    mov bx, 14            
	DrawRow:
		mov cx, 38              
		FillRow:
			stosw                    
			loop FillRow              
			add di, (80 - 38) * 2     
			dec bx                   
			jnz DrawRow        
	mov di, (80 * 2 + 21) * 2 
	add di,buffer
    mov ah, 0x00             
    mov al, 0xdb
    mov cx,38
	cld 
	rep stosw
	mov cx,38
	add di,14*160-76
	cld 
	rep stosw
	
	mov di, (80 * 4 + 28) * 2 
	add di,buffer
	mov al,0xdb
	mov ah, 00000100b

	mov cx,4
	cld
	rep stosw
	
	add di,158
	mov cx,3
	printO:
		mov [es:di],ax
		add di,160
		loop printO

	mov cx,4
	std
	rep stosw
	
	mov cx,5
	cld
	printO1:
		mov [es:di],ax
		sub di,160
		loop printO1
		
	add di,174
    mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,162
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,162
	
	mov [es:di],ax
	sub di,158
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,158
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	
	add di,6
	mov cx,4
	printE:
		mov [es:di],ax
		add di,160
		loop printE
	
	mov cx,4
	cld
	rep stosw
	
	sub di,326
	
	mov cx,3
	cld
	rep stosw
	
	sub di,326
	mov cx,3
	cld
	rep stosw
	
	add di,6
	mov cx,5
	cld
	rep stosw
	
	add di,158
	mov cx,2
	printR:
		mov [es:di],ax
		add di,160
		loop printR
	sub di,160
	mov cx,5
	std
	rep stosw
	
	sub di,158
	mov [es:di],ax
	
	add di,320
	mov cx,2
	printR2:
		mov [es:di],ax
		add di,160
		loop printR2
		
	sub di,316
	mov cx,2
	printR3:
		mov [es:di],ax
		add di,162
		loop printR3
		
	mov cx,32
	mov si,deathscreenmessage1
	mov di,1968+buffer
	mov ah,00001111b
	cld
	lop3:
		lodsb
		stosw
	loop lop3
	
	mov cx,15
	mov si,deathscreenmessage3
	mov di,2306+buffer
	mov ah,00001111b
	cld
	lop7:
		lodsb
		stosw
	loop lop7
	
	mov cx,21
	mov si,deathscreenmessage2
	mov di,1660+buffer
	cld
	lop4:
		lodsb
		stosw
	loop lop4
	NoDeath:
    pop ds
    pop es
    popa
    ret

CheckDeath:
	pusha
	
	mov bx,0
	mov cx,3
	cmp word [DeathFlag],1
	jne deathloop
	call delay
	call delay
	jmp deathend
	deathloop:
	mov ax,[pillarheight+bx]
	cmp word [birdrow],ax
	jg enddeath
	cmp word [pillarcol+bx],35
	jl enddeath
	cmp word [pillarcol+bx],42
	jg enddeath
	mov word [DeathFlag],1
	mov word [currentDelay],0x9000
	mov word [velocity],0
	call delay
	call delay
	jmp deathend
	enddeath:
	mov ax,[pillarheight+bx]
	add ax,[pillargap+bx]
	cmp word [birdrow],ax
	jl enddeath2
	cmp word [pillarcol+bx],35
	jl enddeath2
	cmp word [pillarcol+bx],42
	jg enddeath2
	mov word [DeathFlag],1
	mov word [currentDelay],0x9000
	mov word [velocity],0                              
	call delay
	call delay
	jmp deathend
	enddeath2:
	add bx,2
	loop deathloop
		
	deathend:
	popa
	ret

PrintStartMessage:
	pusha
	push es
	mov ah,0x13
	mov al,0
	mov bh,0
	mov bl,0x3C
	mov cx,28
	mov dh, 14
	mov dl, 26
	push ds
	pop es
	mov bp,startmessage
	int 0x10
	pop es
	popa
	ret

hook:
	push ax
	push es
	mov ax,0 ;hooking
	mov es,ax
	mov ax, [es:9*4]
	mov [oldkbisr],ax
	mov ax,[es:9*4+2]
	mov [oldkbisr+2],ax
	mov ax, [es:8*4]
	mov [oldtimerisr],ax
	mov ax,[es:8*4+2]
	mov [oldtimerisr+2],ax
	cli
	mov word [es:9*4],kbisr
	mov word [es:9*4+2],cs
	mov word [es:8*4],TimerISR
	mov word [es:8*4+2],cs
	sti
	pop es
	pop ax
	ret

unhook:
	push ax
	push es
	mov ax,0
	mov es,ax
	mov ax,[oldkbisr]
	mov word [es:9*4],ax ;unhooking
	mov ax,[oldkbisr+2]
	mov word [es:9*4+2],ax
	mov ax,[oldtimerisr]
	mov word [es:8*4],ax ;unhooking
	mov ax,[oldtimerisr+2]
	mov word [es:8*4+2],ax
	pop es
	pop ax
	ret
clscrn:
	pusha
	mov ax,0xb800
	cld 
	mov es, ax
	mov di,0
	mov ax, 0x0020 
	mov cx,2000
	rep stosw
	popa
	ret
PrintGround:
pusha
cld
push ds
pop es
mov di,3200
add di,buffer

	mov cx,6
	mov ax,0x6020
	rep stosw
	mov cx,9
	mov ax,0x622f
	rep stosw
	mov cx,5
	mov ax,0x6020
	rep stosw
	mov cx,10
	mov ax,0x625c
	rep stosw
	mov cx,5
	mov ax,0x6020
	rep stosw
	mov cx,7
	mov ax,0x622f
	rep stosw
	mov cx,10
	mov ax,0x6020
	rep stosw
	mov cx,7
	mov ax,0x622f
	rep stosw
	mov cx,6
	mov ax,0x6020
	rep stosw
	mov cx,11
	mov ax,0x625c
	rep stosw
	mov cx,7
	mov ax,0x6020
	rep stosw
	mov cx,3
	mov ax,0x622f
	rep stosw
	mov cx,6
	mov ax,0x6020
	rep stosw
	mov cx,13
	mov ax,0x6020
	rep stosw
	mov cx,4
	mov ax,0x622f
	rep stosw
	mov cx,7
	mov ax,0x6020
	rep stosw
	mov cx,6
	mov ax,0x625c
	rep stosw
	mov cx,12
	mov ax,0x6020
	rep stosw
	mov cx,13
	mov ax,0x622f
	rep stosw
	mov cx,7
	mov ax,0x6020
	rep stosw
	mov cx,5
	mov ax,0x622f
	rep stosw
	mov cx,8
	mov ax,0x6020
	rep stosw
	mov cx,9
	mov ax,0x625c
	rep stosw
	mov cx,13
	mov ax,0x6020
	rep stosw
	mov cx,9
	mov ax,0x622f
	rep stosw
	mov cx,7
	mov ax,0x6020
	rep stosw
	
	mov cx,6
	mov ax,0x6020
	rep stosw
	mov cx,13
	mov ax,0x6020
	rep stosw
	mov cx,4
	mov ax,0x622f
	rep stosw
	mov cx,7
	mov ax,0x6020
	rep stosw
	mov cx,6
	mov ax,0x625c
	rep stosw
	mov cx,12
	mov ax,0x6020
	rep stosw
	mov cx,13
	mov ax,0x622f
	rep stosw
	mov cx,7
	mov ax,0x6020
	rep stosw
	mov cx,5
	mov ax,0x622f
	rep stosw
	mov cx,8
	mov ax,0x6020
	rep stosw
	
	mov cx,6
	mov ax,0x6020
	rep stosw
	mov cx,9
	mov ax,0x622f
	rep stosw
	mov cx,5
	mov ax,0x6020
	rep stosw
	mov cx,10
	mov ax,0x625c
	rep stosw
	mov cx,5
	mov ax,0x6020
	rep stosw
	mov cx,7
	mov ax,0x622f
	rep stosw
	mov cx,10
	mov ax,0x6020
	rep stosw
	mov cx,7
	mov ax,0x622f
	rep stosw
	mov cx,6
	mov ax,0x6020
	rep stosw
	mov cx,11
	mov ax,0x625c
	rep stosw
	mov cx,7
	mov ax,0x6020
	rep stosw
	mov cx,3
	mov ax,0x622f
	rep stosw
	mov cx,6
	mov ax,0x6020
	rep stosw
	mov cx,13
	mov ax,0x6020
	rep stosw
	mov cx,4
	mov ax,0x622f
	rep stosw
	mov cx,5
	mov ax,0x6220
	rep stosw

popa
ret

PrintPillar:
	push bp
	mov bp,sp
	pusha
	push ds
	pop es
	mov ax,80
	mul word [bp+8]
	add ax,[bp+10]
	shl ax,1
	mov di,ax
	add di,buffer
	mov ax, 0x2020
	cmp word [bp+10],0 
	jl skip
	mov cx,[bp+6]
	LoopPillar:
	mov [es:di],ax
	add di,160
	loop LoopPillar
	mov ax,160
	mul word [bp+6]
	sub di,ax
	mov ax, 0x2020
	skip:
	add di,2
	cmp word [bp+10],-1
	jl skip1
	cmp word [bp+10],78
	jg skip1
	mov cx,[bp+6]
	LoopPillar1:
	mov [es:di],ax
	add di,160
	loop LoopPillar1
	mov ax,160
	mul word [bp+6]
	sub di,ax
	mov ax, 0x2020
	skip1:
	add di,2
	cmp word [bp+10],-2
	jl skip2
	cmp word [bp+10],77
	jg skip2
	mov cx,[bp+6]
	LoopPillar2:
	mov [es:di],ax
	add di,160
	loop LoopPillar2
	mov ax,160
	mul word [bp+6]
	sub di,ax
	mov ax, 0x2020
	skip2:
	add di,2
	cmp word [bp+10],76
	jg skip3
	mov cx,[bp+6]
	LoopPillar3:
	mov [es:di],ax
	add di,160
	loop LoopPillar3
	skip3:
	
	popa
	pop bp
	ret 8
	
PrintClouds:
	push word 4
	push word 4
	call PrintCloud
	
	push word 7
	push word 21
	call PrintCloud
	
	push word 5
	push word 45
	call PrintCloud
	
	push word 3
	push word 67
	call PrintCloud
	ret

PrintCloud:
	push bp
	mov bp,sp
	pusha
	push ds 
	pop es
	mov ax,0
	mov al,80
	mul word [bp+6]
	add ax, [bp+4]
	shl ax,1
	mov di,ax
	add di,buffer
	mov ax,0x0fdb
	mov cx,10
	cld 
	rep stosw
	sub di,166
	mov cx,6
	std
	rep stosw
	popa
	pop bp
	ret 4
	
PrintCloudTitle:
	push bp
	mov bp,sp
	push es
	pusha
	mov ax,0xb800
	mov es,ax
	mov ax,0
	mov al,80
	mul word [bp+6]
	add ax, [bp+4]
	shl ax,1
	mov di,ax
	mov ax,0x0fdb
	mov cx,10
	cld 
	rep stosw
	sub di,166
	mov cx,6
	std
	rep stosw
	popa
	pop es
	pop bp
	ret 4	
	
DisplayScore:
pusha
push es

mov ax,[Score] 
mov cx,0
mov bx,10
mov si,ScoreBuffer
lop2:
mov dx,0 
div bx
add dl,'0'
mov byte [si],dl
inc si
inc cx
cmp ax,0
jg lop2

dec si
push ds
pop es
mov di,buffer
displayscoreloop:
mov ax,[es:di]
or ah,00000000b
std
lodsb
cld
stosw
loop displayscoreloop

pop es
popa
ret

MoveGround:
pusha
push ds
cmp word [DeathFlag],1
je endmoveground
cmp word [PauseFlag],1
je endmoveground
inc word [loopcount+2]
cmp word [loopcount+2],2
jne endmoveground
mov word [loopcount+2],0
push ds
pop es
mov bx,20
	
Rotate:
	mov ax,80
	mul bx
	add ax,79
	shl ax,1
	mov si,ax
	add si,buffer
	push word [ds:si]
	mov di,si 
	sub si,2
	mov cx,79
	std
	rep movsw
	pop word[es:di]
inc bx
cmp bx,25
jl Rotate
endmoveground:
pop ds
popa
ret

PrintBackground: 
	pusha
	cld 
	push ds
	pop es
	mov di,buffer
	mov ax, 0x3020 
	mov cx,1600
	;cyan bg
	rep stosw 
	call PrintClouds
	popa
	ret
	
Rand:
	push bp
	mov bp,sp
	pusha

    mov ah,00h 
    int 1ah         
    mov ax, dx
    mov dx, 0    
    div word [bp+4]
    mov [bp+6],dx
  
	popa
	pop bp
	ret 2
	
CopyBuffer:
	pusha       
	push ds
	mov si, buffer    
	mov di, 0         
	mov cx, 2000   
	mov bx,0xb800
	mov es,bx
	cld 
	rep movsw
	pop ds
	popa
	ret
	
PrintBirbTitle:
	push bp
	mov bp,sp
	pusha
	mov ax,0
	mov al,80
	mul word [bp+6]
	add ax, [bp+4]
	shl ax,1
	mov di,ax
	
	mov ax,0xb800
	mov es,ax
	mov ax,[es:di]
	mov al,'='
	mov word [es:di],ax
	add di,2
	mov ax,[es:di]
	mov al,'='
	mov word [es:di],ax
	add di,2
	mov word [es:di],0x0edb
	sub di,160
	mov word [es:di],0x0edb
	add di,2
	mov word [es:di],0x0edb
	add di,160
	mov word [es:di],0x0edb
	add di,2
	mov word [es:di],0x0edb
	sub di,160
	mov word [es:di],0x0edb
	add di,2
	mov word [es:di],0x785e
	add di,160
	mov word [es:di],0x4f3d
	add di,2
	mov word [es:di],0x4f3d
	popa
	pop bp
	ret 4
	
ClearBirbTitle:
	push bp
	mov bp,sp
	pusha
	mov ax,0
	mov al,80
	mul word [bp+6]
	add ax, [bp+4]
	shl ax,1
	mov di,ax
	
	mov ax,0xb800
	mov es,ax
	mov ax,0x3020
	push di
	cld 
	mov cx,7
	rep stosw
	pop di
	sub di,160
	mov cx,7
	rep stosw
	popa
	pop bp
	ret 4
	
PrintBirb:
	pusha
	mov ax,0
	mov al,80
	mul word [birdrow]
	add ax, 36
	shl ax,1
	mov di,ax
	add di,buffer
	
	push ds
	pop es
	mov ax,[es:di]
	mov al,'='
	mov word [es:di],ax
	add di,2
	mov ax,[es:di]
	mov al,'='
	mov word [es:di],ax
	add di,2
	mov word [es:di],0x0edb
	sub di,160
	mov word [es:di],0x0edb
	add di,2
	mov word [es:di],0x0edb
	add di,160
	mov word [es:di],0x0edb
	add di,2
	mov word [es:di],0x0edb
	sub di,160
	mov word [es:di],0x0edb
	add di,2
	cmp word [DeathFlag],0
	jne ahead13
	mov word [es:di],0x785e
	jmp ahead14
	ahead13:
	mov word [es:di],0x7878
	ahead14:
	add di,160
	mov word [es:di],0x4f3d
	add di,2
	mov word [es:di],0x4f3d
	
	popa
	ret 

TitleScreen:
	pusha
	push es
	mov ax,0xb800
	mov es,ax
	mov ax,0x3020
	mov cx,2000
	mov di,0
	cld
	rep stosw 
	push word 15
	push word 23
	call PrintCloudTitle
	push word 4
	push word 65
	call PrintCloudTitle
	push word 1
	push word 30
	call PrintCloudTitle
	push word 20
	push word 50
	call PrintCloudTitle
	push word 18
	push word 2
	call PrintCloudTitle
	push word 12
	push word 68
	call PrintCloudTitle
	push word 5
	push word 4
	call PrintCloudTitle
	cld
	mov ah,01101110b
	mov al,0xdb
	mov di,500
	mov cx,5
	rep stosw
	mov di,660
	mov cx,2
	rep stosw
	mov di,820
	mov cx,5
	rep stosw
	mov di,980
	mov cx,2
	rep stosw
	mov di,1140
	mov cx,2
	rep stosw
	mov di,670
	call delay
	call delay
	call delay
	call delay
	mov ah,00001100b
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov di,672
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,2
	mov cx,4
	rep stosw
	sub di,164
	push di
	call delay
	call delay
	call delay
	call delay
	mov ah,00001110b
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	pop di
	add di,2
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	mov cx,4
	rep stosw
	push di
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	pop di
	add di,2
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	mov cx,5
	std
	rep stosw
	mov di,692
	push di
	call delay
	call delay
	call delay
	call delay
	mov ah,00001100b
	mov cx,5
	cld
	rep stosw
	add di,158
	stosw
	add di,158
	stosw
	pop di
	add di,160
	push di
	mov cx,2
	rep stosw
	pop di
	add di,160
	push di
	mov cx,5
	cld
	rep stosw
	pop di
	add di,160
	push di
	mov cx,2
	rep stosw
	pop di
	add di,160
	mov cx,2
	rep stosw
	mov di,542
	push di
	call delay
	call delay
	call delay
	call delay
	mov ah,00001110b
	mov cx,5
	cld
	rep stosw
	add di,158
	stosw
	add di,158
	stosw
	pop di
	add di,160
	push di
	mov cx,2
	rep stosw
	pop di
	add di,160
	push di
	mov cx,5
	cld
	rep stosw
	pop di
	add di,160
	push di
	mov cx,2
	rep stosw
	pop di
	add di,160
	mov cx,2
	rep stosw
	mov di,712
	call delay
	call delay
	call delay
	call delay
	mov ah,00001100b
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	mov di,714
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,2
	push di
	stosw
	push di
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	pop di
	add di,2
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	pop di
	add di,160
	stosw
	add di,158
	stosw
	mov di,2314
	push di
	call delay
	call delay
	call delay
	call delay
	mov ah,00001110b
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	pop di
	add di,2
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	mov cx,4
	rep stosw	
	push di
	mov word [es:di],0x3020
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov word [es:di],0x3020
	pop di
	add di,2
	mov word [es:di],0x3020
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov word [es:di],0x3020
	sub di,4
	mov cx,3
	std
	rep stosw
	call delay
	call delay
	call delay
	call delay
	mov ah,00001100b
	mov di,1848
	push di
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	pop di
	add di,2
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	mov cx,4
	cld
	rep stosw
	push di
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	pop di
	add di,2
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,160
	mov [es:di],ax
	sub di,158
	push di
	mov cx,5
	call delay
	call delay
	call delay
	call delay
	mov ah,00001110b
	cld
	push di
	rep stosw
	pop di
	push di
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	pop di
	add di,162
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,2
	mov cx,3
	rep stosw
	pop di
	add di,170
	mov cx,5
	call delay
	call delay
	call delay
	call delay
	mov ah,00001100b
	cld
	push di
	rep stosw
	pop di
	push di
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	pop di
	add di,162
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,160
	mov [es:di],ax
	add di,2
	mov cx,3
	rep stosw
	call delay
	call delay
	call delay
	call delay
	mov ah,0x13
	mov al,0
	mov bh,0
	mov bl,0x30
	mov cx,11
	mov dh, 21
	mov dl, 0
	push ds
	pop es
	mov bp,createdbymessage
	int 0x10
	mov bl,0x3E
	mov cx,40
	mov dh, 22
	mov dl, 0
	mov bp,name1
	int 0x10
	mov bl,0x34
	mov cx,37
	mov dh, 23
	mov dl, 0
	mov bp,name2
	int 0x10
	mov bl,0x3F
	mov cx,28
	mov dh, 23
	mov dl, 51
	mov bp,titlemessage
	int 0x10
	LoopTitleBird:
	push word [TitleBirbRow1]
	push word 55
	call ClearBirbTitle
	push word [TitleBirbRow2]
	push word 15
	call ClearBirbTitle
	cmp word [TitleBirbRow1],8
	jne ahead11
	mov word [TitleBirbflag],1	
	ahead11:
	cmp word [TitleBirbRow1],3
	jne ahead12
	mov word [TitleBirbflag],0	
	ahead12:
	cmp word [TitleBirbflag],1
	jne ahead9
	dec word [TitleBirbRow1]
	inc word [TitleBirbRow2]
	jmp ahead10
	ahead9:
	dec word [TitleBirbRow2]
	inc word [TitleBirbRow1]
	ahead10:
	push word [TitleBirbRow1]
	push word 55
	call PrintBirbTitle
	push word [TitleBirbRow2]
	push word 15
	call PrintBirbTitle
	call delay
	call delay
	call delay
	mov ah,1
	int 0x16
    jz LoopTitleBird
	mov ah,0
	int 0x16
	pop es
	popa
	ret