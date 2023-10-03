.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc   
extern fopen:proc  
extern fclose:proc                             ;cordXpiece cordYpiece
extern fprintf: proc
includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Space Invaders",0
area_width EQU 500
area_height EQU 500
area DD 0
direction dd 1

formatcif db "Score player :%d",10,0
fisier db "fisiercastig.txt",0
winners dd 10
format_deschis db "a",0

alien struct
alienXarray dd 0
alienYarray dd 0
alienlife dd 0
alien ends

aliens alien {70,100,3},{110,100,3},{150,100,3},{190,100,3},{230,100,3},{270,100,3},{310,100,3},{350,100,3},{390,100,3},{430,100,3},{70,130,2},{110,130,2},{150,130,2},{190,130,2},{230,130,2},{270,130,2},{310,130,2},{350,130,2},{390,130,2},{430,130,2},{70,160,1},{110,160,1},{150,160,1},{190,160,1},{230,160,1},{270,160,1},{310,160,1},{350,160,1},{390,160,1},{430,160,1}

restartgame dd 0
image_height equ 20
image_width equ 28
starship_width equ 28
starship_height equ 17
counter DD 0 ; numara evenimentele de tip timer
format db " ", 0
format1 db "%d", 10,0
arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

bulletXarray dd 0
bulletYarray dd 0
can_shoot dd 1

alienbulletXarray dd 0
alienbulletYarray dd 0
can_shoot2 dd 1

shipXarray dd 200
shipYarray dd 430

symbol_width EQU 10
symbol_height EQU 20
x dw ?
y dw ?
random dd 0

include bullet.inc
include alienbullet.inc
include digits.inc
include letters.inc
include starship.inc
include planet.inc
include alien2.inc
include alien1.inc
include litere.inc
include alien3.inc
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 00ff00h
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 000000h
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

make_textwin proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, litere
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, litere
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 00ff00h
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 000000h
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_textwin endp

make_text2 proc
	push ebp
	mov ebp, esp
	pusha

	lea esi, alien11_0
	
draw_image:
	mov ecx, 20
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, 20
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, 26 ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_text2 endp

; simple macro to call the procedure easier
make_image_macro macro drawArea, x, y
	push y
	push x
	push drawArea
	call make_text2
	add esp, 12
endm

make_text3 proc
	push ebp
	mov ebp, esp
	pusha

	lea esi, ship1_0
	
draw_image:
	mov ecx, starship_height
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, starship_height 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, starship_width ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_text3 endp

; simple macro to call the procedure easier
make_image_macro2 macro drawArea, x, y
	push y
	push x
	push drawArea
	call make_text3
	add esp, 12
endm


make_text4 proc
	push ebp
	mov ebp, esp
	pusha

	lea esi, planet_0
	
draw_image:
	mov ecx, 39
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, 39 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, 40; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_text4 endp

; simple macro to call the procedure easier
make_image_macro3 macro drawArea, x, y
	push y
	push x
	push drawArea
	call make_text4
	add esp, 12
endm

make_text5 proc
	push ebp
	mov ebp, esp
	pusha

	lea esi, bullet2_0
	
draw_image:
	mov ecx, 19
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, 19 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, 10 ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_text5 endp

; simple macro to call the procedure easier
make_image_macro4 macro drawArea, x, y
	push y
	push x
	push drawArea
	call make_text5
	add esp, 12
endm

make_text6 proc
	push ebp
	mov ebp, esp
	pusha

	lea esi, alien2_0
	
draw_image:
	mov ecx, 20
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, 20 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, 27 ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_text6 endp

; simple macro to call the procedure easier
make_image_macro5 macro drawArea, x, y
	push y
	push x
	push drawArea
	call make_text6
	add esp, 12
endm

make_text7 proc
	push ebp
	mov ebp, esp
	pusha

	lea esi, alien3_0
	
draw_image:
	mov ecx, 20
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, 20 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, 25 ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_text7 endp

; simple macro to call the procedure easier
make_image_macro6 macro drawArea, x, y
	push y
	push x
	push drawArea
	call make_text7
	add esp, 12
endm

make_text8 proc
	push ebp
	mov ebp, esp
	pusha

	lea esi, alienbullet_0
	
draw_image:
	mov ecx, 15
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, 15 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, 15 ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_text8 endp

; simple macro to call the procedure easier
make_image_macro7 macro drawArea, x, y
	push y
	push x
	push drawArea
	call make_text8
	add esp, 12
endm
; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y	
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm
make_text_macrowin macro symbol, drawArea, x, y	
	push y
	push x
	push drawArea
	push symbol
	call make_textwin
	add esp, 16
endm

alien_movement macro x,y,direction
	local moveleft,moveright,finalmovement
	cmp y,420
	jge end_game
	cmp direction,1
	je moveleft
	cmp direction,2
	je moveright
	moveleft:
	sub x,2
	jmp finalmovement
	moveright:
	add x,2
	finalmovement:
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y


draw proc
	push ebp
	mov ebp, esp
	pusha
	;mai jos e codul care intializeaza fereastra cu pixeli negri
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2     ;sunt 4 bytes la fiecare pixel
	push eax
	push 0  
	push area
	call memset
	add esp, 12
	jmp nextt
	
bucla_linii:
	mov eax, [ebp+arg2]
	and eax, 000000h
	; provide a new (random) color
	mul eax
	mul eax
	add eax, ecx
	push ecx
	mov ecx, area_width
bucla_coloane:
	mov [edi], eax
	add edi, 4
	add eax, ebx
	loop bucla_coloane
	pop ecx
	loop bucla_linii
	jmp  nextt
;------------------------------------------------------------
nextt:

;check if alien bullet hit spaceship --------------------------------------------------------------------------------
checkifbullethitspaceship:
mov edx,shipXarray
add edx,18
cmp alienbulletXarray,edx
jg nothit22
sub edx,25
cmp alienbulletXarray,edx
jl nothit22

	mov edx,shipYarray
	add edx,17
	cmp alienbulletYarray,edx
	jg nothit22
	sub edx,34
	cmp alienbulletYarray,edx
	jl nothit22
	
	push offset format_deschis
	push offset fisier
	call fopen
	mov ebx,eax
	add esp,8
	
	push counter
	push offset formatcif
	push eax
	call fprintf
	add esp,12
	
	push ebx
	call fclose
	add esp,4
	
	jmp end_game
nothit22:

;check if bullet hit alien -----------------------------------------------------------------------------------
checkifbullethitalien:
	mov ecx,9
	mov ebx,348
	;first row------------------------------------------------------------------------------------------------
	verifhit1:
	mov edx,[aliens.alienlife+ebx]
cmp edx,0
je nothit
	mov edx,[aliens.alienXarray+ebx]
	add edx,16
	cmp bulletXarray,edx
	jg nothit
	sub edx,32
	cmp bulletXarray,edx 
	jl nothit
	mov edx,[aliens.alienYarray+ebx]
	add edx,10
	cmp bulletYarray,edx
	jg nothit
	sub edx,20
	cmp bulletYarray,edx
	jl nothit
	
	mov eax,[aliens.alienlife+ebx]
	dec eax
	add counter,10
	mov [aliens.alienlife+ebx],eax
	mov can_shoot,1
	mov bulletXarray,430
	mov bulletYarray,10
	nothit:
	dec ecx
	sub ebx,12
	cmp ecx,0
	jge verifhit1
	
	;second row-----------------------------------------------------------------
	mov ecx,9
	verifhit2:
	mov edx,[aliens.alienlife+ebx]
cmp edx,0
je nothit
	mov edx,[aliens.alienXarray+ebx]
	add edx,16
	cmp bulletXarray,edx
	jg nothit2
	sub edx,32
	cmp bulletXarray,edx 
	jl nothit2
	mov edx,[aliens.alienYarray+ebx]
	add edx,10
	cmp bulletYarray,edx
	jg nothit2
	mov edx,[aliens.alienYarray+ebx]
	sub edx,20
	cmp bulletYarray,edx
	jl nothit2
	
	mov eax,[aliens.alienlife+ebx]
	dec eax
	add counter,10
	mov [aliens.alienlife+ebx],eax
	mov can_shoot,1
	mov bulletXarray,430
	mov bulletYarray,10
	nothit2:
	dec ecx
	sub ebx,12
	cmp ecx,0
	jge verifhit2
	
	;third row-------------------------------------------------------------
	mov ecx,9
	verifhit3:
	mov edx,[aliens.alienlife+ebx]
cmp edx,0
je nothit3
	mov edx,[aliens.alienXarray+ebx]
	add edx,16
	cmp bulletXarray,edx
	jg nothit3
	sub edx,32
	cmp bulletXarray,edx 
	jl nothit3
	mov edx,[aliens.alienYarray+ebx]
	add edx,10
	cmp bulletYarray,edx
	jg nothit3
	mov edx,[aliens.alienYarray+ebx]
	sub edx,20
	cmp bulletYarray,edx
	jl nothit3
	
	mov eax,[aliens.alienlife+ebx]
	dec eax
	add counter,10
	mov [aliens.alienlife+ebx],eax
	mov can_shoot,1
	mov bulletXarray,430
	mov bulletYarray,10
	nothit3:
	dec ecx
	sub ebx,12
	cmp ecx,0
	jge verifhit3
	
	;alien blast shot------------------------------------------------
	blast_shot2:
	mov edx, 1
	cmp edx, can_shoot2
	je next2
	add alienbulletYarray, 10
	make_image_macro7 area, alienbulletXarray, alienbulletYarray
	mov edx, 480
	cmp alienbulletYarray,edx
	jge reset_blast2
	jmp next2
reset_blast2:
	mov can_shoot2, 1
next2:
	
	;blast shot ---------------------------------------------------
	blast_shot:
	mov edx, 1
	cmp edx, can_shoot
	je next
	sub bulletYarray, 30
	make_image_macro4 area, bulletXarray, bulletYarray
	mov edx, 20
	cmp edx, bulletYarray
	jge reset_blast
	jmp next
reset_blast:
	mov can_shoot, 1
next:

	;--------------------------misc extraterestrii	
movement:
pusha
mov ecx,29
mov ebx,0

movementloop:
mov edx,[aliens.alienlife+ebx]
cmp edx,0
je aliendead
mov eax,[aliens.alienXarray+ebx]
cmp eax,0
jle changedirection1
cmp eax,470
jge changedirection2
aliendead:
dec ecx
add ebx,12
cmp ecx,0
jge movementloop

jmp noneedforchange	
changedirection1:
mov direction,2
jmp changeyaxis
changedirection2:
mov direction,1
	
changeyaxis:
mov ecx,29
mov ebx,0

changelevel:
mov edx,[aliens.alienlife+ebx]
cmp edx,0
je aliendead8
add [aliens.alienYarray+ebx],20
aliendead8:
dec ecx
add ebx,12
cmp ecx,0
jge changelevel

noneedforchange:
	;------------------------------alienmovement
mov ecx,29
mov ebx,0
miscare:
mov edx,[aliens.alienlife+ebx]
cmp edx,0
je aliendead3
alien_movement [aliens.alienXarray+ebx],[aliens.alienYarray+ebx],direction
aliendead3:
dec ecx
add ebx,12
cmp ecx,0
jge miscare
popa	
	
	;verificare taste apasate-----------------------------------------------------------------------------------

	cmp dword ptr[ebp+arg2],'A'
	je leftmovement
	cmp dword ptr[ebp+arg2],'D'
	je rightmovement 
	cmp dword ptr[ebp+arg2],' '
	je spaceshipbullet
	jmp nimic
	
	spaceshipbullet:
	mov eax, 1
	cmp eax, can_shoot
	jne nimic
	mov can_shoot, 0
	mov ecx, shipXarray
	mov bulletXarray, ecx
	add bulletXarray, 10
	mov edx, shipYarray
	mov bulletYarray, edx
	sub bulletYarray, 20
	make_image_macro4 area, bulletXarray, bulletYarray
	jmp nimic
	
	leftmovement:
	cmp shipXarray,0
	jle nimic
	sub shipXarray,10
	jmp nimic
	
	rightmovement:
	cmp shipXarray,470
	jge nimic
	add shipXarray,10
	
	
nimic:

	;show alien ship bullet-------------------------------------------------------------
alienshipbullet:
	mov eax, 1
	cmp eax, can_shoot2
	jne nimic2
	rdtsc
	xor edx,edx
	mov ecx,10
	div ecx
	mov eax,edx
	mov ecx,12
	mul ecx
	mov edx,0
	cmp edx,[aliens.alienlife+eax]
	je nimic2
	mov can_shoot2, 0
	mov ecx, [aliens.alienXarray + eax]
	mov alienbulletXarray, ecx
	add alienbulletXarray, 6
	mov edx, [aliens.alienYarray + eax]
	mov alienbulletYarray, edx
	add alienbulletYarray, 20
	make_image_macro7 area, alienbulletXarray, alienbulletYarray
	
	nimic2:
	;---------------------------------------------------------------------------afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 90,10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 80, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 70, 10
	;scriem un mesaj
	
	make_text_macro 'B', area, 10, 10
	make_text_macro 'C', area, 20, 10
	make_text_macro 'D', area, 30, 10
	make_text_macro 'E', area, 40, 10
	make_text_macro 'F', area, 50, 10
	make_text_macro 'G', area, 60, 10
	
	;--------------------------------------------------------------------------------------desenez extraterestrii
mov ecx,9
mov ebx,0

showalienrow1:
mov eax,[aliens.alienlife+ebx]
cmp eax,0
je dead1
make_image_macro6 area, [aliens.alienXarray+ebx],[aliens.alienYarray+ebx]
jmp notdead1
dead1:
mov [aliens.alienXarray+ebx],430
mov [aliens.alienYarray+ebx],10
notdead1:
dec ecx
add ebx,12
cmp ecx,0
jge showalienrow1

mov ecx,9
showalienrow2:
mov eax,[aliens.alienlife+ebx]
cmp eax,0
je dead2
make_image_macro5 area, [aliens.alienXarray+ebx],[aliens.alienYarray+ebx]
dead2:
dec ecx
add ebx,12
cmp ecx,0
jge showalienrow2

mov ecx,9
showalienrow3:
mov eax,[aliens.alienlife+ebx]
cmp eax,0
je dead3
make_image_macro area, [aliens.alienXarray+ebx],[aliens.alienYarray+ebx]
dead3:
dec ecx
add ebx,12
cmp ecx,0
jge showalienrow3

;----------------------------------------------------------------------desenez nava spatiala si planeta
make_image_macro3 area, 430, 10
make_image_macro2 area, shipXarray, shipYarray
cmp counter,600
je end_game2

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

drawendmessage proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2     ;sunt 4 bytes la fiecare pixel
	push eax
	push 0  
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
	
bucla_linii:
	mov eax, [ebp+arg2]
	and eax, 000000h
	; provide a new (random) color
	mul eax
	mul eax
	add eax, ecx
	push ecx
	mov ecx, area_width
bucla_coloane:
	mov [edi], eax
	add edi, 4
	add eax, ebx
	loop bucla_coloane
	pop ecx
	loop bucla_linii
	jmp  afisare_litere

	afisare_litere:
	make_text_macro 'H', area, 150, 210
	make_text_macro 'H', area, 160, 210
	make_text_macro 'H', area, 170, 210       
	make_text_macro 'I', area, 180, 210
	make_text_macro 'J', area, 190, 210
	make_text_macro 'K', area, 200, 210
	make_text_macro 'L', area, 210, 210
	make_text_macro 'M', area, 230, 210
	make_text_macro 'N', area, 240, 210          
	make_text_macro 'O', area, 250, 210
	make_text_macro 'P', area, 260, 210
	make_text_macro 'H', area, 270, 210
	make_text_macro 'H', area, 280, 210
	make_text_macro 'H', area, 290, 210
	;scriem un mesaj

	final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
drawendmessage endp

drawendmessage2 proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2     ;sunt 4 bytes la fiecare pixel
	push eax
	push 0  
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
	
bucla_linii:
	mov eax, [ebp+arg2]
	and eax, 000000h
	; provide a new (random) color
	mul eax
	mul eax
	add eax, ecx
	push ecx
	mov ecx, area_width
bucla_coloane:
	mov [edi], eax
	add edi, 4
	add eax, ebx
	loop bucla_coloane
	pop ecx
	loop bucla_linii
	jmp  afisare_litere
	
	push offset format_deschis
	push offset fisier
	call fopen
	mov ebx,eax
	add esp,8
	

	push counter
	push offset formatcif
	push ebx
	call fprintf
	add esp,12
	;scriem un mesaj
	afisare_litere:
	make_text_macro 'A', area, 150, 210
	make_text_macro 'A', area, 160, 210
	make_text_macro 'A', area, 170, 210       
	make_text_macrowin 'Y', area, 180, 210
	make_text_macrowin 'O', area, 190, 210
	make_text_macrowin 'U', area, 200, 210
	make_text_macrowin 'W', area, 230, 210
	make_text_macrowin 'I', area, 240, 210
	make_text_macrowin 'N', area, 250, 210          
	make_text_macro 'A', area, 260, 210
	make_text_macro 'A', area, 270, 210
	make_text_macro 'A', area, 280, 210
	final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
drawendmessage2 endp

start:


	
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	end_game:
	push offset drawendmessage
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	jmp final
	
	end_game2:
	push offset drawendmessage2
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	final:
	;terminarea programului
	push 0
	call exit
end start