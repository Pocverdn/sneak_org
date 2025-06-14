.model small
.stack 100h

.data
    filas equ 9
    columnas equ 9
    salto db 13, 10, '$'
    gameover_msg db 13, 10, '¡GAME OVER!$'

    array db '.','.','.','.','.','.','.','.','.'
          db '.','.','.','.','.','.','.','.','.'
          db '.','.','.','.','.','.','.','.','.'
          db '.','.','.','.','.','.','.','.','.'
          db '.','.','.','.','.','.','.','.','.'
          db '.','.','.','.','.','.','.','.','.'
          db '.','.','.','.','.','.','.','.','.'
          db '.','.','.','.','.','.','.','.','.'
          db '.','.','.','.','.','.','.','.','.'

    snake db 81 dup(?)  
    snake_length db 3
    direction db 77
    old_head db 0

.code

main PROC
    mov ax, @data
    mov ds, ax

    call initialize
    call ramdom
    call tablero

main_loop:
    ; Check for input and move player
    call get_input      ; This will update direction based on input
    call move_player    ; Moves the player according to the direction
    call limpiar_pantalla
    call tablero        ; Draw the updated game board
    call print_snake_length
    call delay_1_sec    ; Wait for 1 second to create the "tick"
    call get_input 

    ; Check if a key was pressed
    mov ah, 01h
    int 16h             ; Check if any key is pressed (AH = 1 means key pressed)
    jz main_loop        ; If no key is pressed, continue the loop

    ; Get the key pressed
    mov ah, 00h
    int 16h             ; Read the key
    cmp al, 27          ; If the key is 'Esc' (ASCII 27)
    je exit_game        ; Exit the game if 'Esc' is pressed

    jmp main_loop       ; Otherwise, continue looping

exit_game:
    mov ah, 4Ch         ; Exit the program
    int 21h

main ENDP


; Inicializa una serpiente de tres segmentos
initialize PROC
    ; Posicisiones iniciales de la serpiente
    lea si, snake
    mov byte ptr [si], 39
    inc si
    mov byte ptr [si], 40
    inc si
    mov byte ptr [si], 41

    ; Se dibuja la serpiente en el array
    lea di, array
    add di, 39
    mov byte ptr [di], 'x'
    inc di
    mov byte ptr [di], 'x'
    inc di
    mov byte ptr [di], 'X'

    ret
initialize ENDP

; Posiciona una comida '@' en una posición aleatoria
ramdom PROC
generar:
    mov ah, 00h
    int 1Ah ; Se usa el tiempo del reloj para asemejar un comportamiento aleatorio
    mov ax, dx
    xor dx, dx
    mov cx, 81
    div cx ; Divido por el numero de casillas del tablero (81)
    mov bx, dx
    
    ; Revisamos que la posición sea un '.' para evitar que se genere dentro de la serpiente
    lea si, array
    add si, bx
    cmp byte ptr [si], '.'
    jne generar

    mov byte ptr [si], '@'
    ret
ramdom ENDP

; Función para obtener las entradas (Teclas)
get_input PROC
    mov ah, 01h
    int 16h         ; Revisa si una tecla se oprime
    jz no_input     ; En caso de que no se oprima ninguna tecla

    mov ah, 00h     ; Lee la tecla presionada
    int 16h

    cmp al, 'w'
    je up
    cmp al, 's'
    je down
    cmp al, 'a'
    je left
    cmp al, 'd'
    je right

no_input:
    ret

up:     
    mov direction, 72
    ret
down:   
    mov direction, 80
    ret
left:   
    mov direction, 75
    ret
right:  
    mov direction, 77
    ret
get_input ENDP

print_snake_length PROC
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10      ; salto de línea
    int 21h

    mov dl, 'L'
    int 21h
    mov dl, '='
    int 21h

    mov al, snake_length
    call print_number

    ret
print_snake_length ENDP

print_number PROC
    add al, '0'     ; convierte a carácter
    mov dl, al
    mov ah, 02h
    int 21h
    ret
print_number ENDP

move_player PROC
    ; Save old head position
    lea si, snake
    mov al, [si]            ; current head pos
    mov old_head, al        ; save old head for wrap check

    ; Erase last segment on board
    mov bl, snake_length
    dec bl
    xor bh, bh
    lea si, snake
    add si, bx              ; point to last segment position
    mov bl, [si]            ; last segment pos

    lea di, array
    add di, bx
    mov byte ptr [di], '.'  ; erase last segment from board

    ; Shift snake positions backward (tail follows head)
    mov cl, snake_length
    dec cl
    lea si, snake
    add si, cx              ; point to last segment
    mov di, si
    inc di

shift_loop:
    mov al, [si-1]          ; previous segment pos
    mov [si], al            ; move segment forward
    cmp al, 0
    jl game_over          ; If new head < 0, snake went off the top

    ; Check lower boundary (bottom row)
    cmp al, 81            ; 81 = total cells in 9x9 board
    jge game_over         ; If new head >= 81, snake went off the bottom
    dec si
    loop shift_loop

    ; Update head position according to direction
    lea si, snake
    mov al, [si+1]          ; old head + 1 position (next to head)
    cmp direction, 77       ; RIGHT
    jne not_right
    inc al
not_right:
    cmp direction, 75       ; LEFT
    jne not_left
    dec al
not_left:
    cmp direction, 72       ; UP
    jne not_up
    sub al, columnas        ; move up one row
not_up:
    cmp direction, 80       ; DOWN
    jne not_down
    add al, columnas        ; move down one row
not_down:
    mov [si], al            ; update new head position
    mov bl, al              ; save new head pos to BL

    ; Check self-collision
    lea di, array
    add di, bx
    cmp byte ptr [di], 'o'  ; collision with body?
    je game_over

    ; Check lateral wrap only if moving left or right
    cmp direction, 75       ; LEFT
    je check_row_wrap
    cmp direction, 77       ; RIGHT
    je check_row_wrap
    jmp skip_wrap_check

check_row_wrap:
    mov al, [si]            ; new head
    xor ah, ah
    mov bl, columnas
    div bl                  ; AL = row, AH = column (remainder)
    mov cl, al              ; new head row

    mov al, old_head
    xor ah, ah
    div bl                  ; AL = old head row

    cmp cl, al              ; if rows differ → wrap → game over
    jne game_over

skip_wrap_check:
    ; Check for food '@' at new head position
    lea di, array
    add di, bx
    cmp byte ptr [di], '@'
    jne no_food

    ; Food found - increase snake length and generate new food
    inc snake_length
    call ramdom             ; generate new food
    jmp redraw_snake

no_food:
    ; Erase last segment again (already done, but safe)
    lea si, snake
    mov bl, snake_length
    dec bl
    xor bh, bh
    add si, bx
    mov bl, [si]
    lea di, array
    add di, bx
    mov byte ptr [di], '.'

redraw_snake:
    ; Draw the snake on the board
    lea si, snake
    mov cl, snake_length

draw_loop:
    mov bl, [si]
    lea di, array
    add di, bx
    cmp cl, snake_length
    je draw_head
    mov byte ptr [di], 'o'  ; body segment
    jmp next_segment

draw_head:
    mov byte ptr [di], 'X'  ; head segment

next_segment:
    inc si
    loop draw_loop

    ret
move_player ENDP

; Función para imprimir el tablero
tablero PROC
    mov cx, filas
    lea si, array

fila_loop:
    push cx
    mov cx, columnas

columna_loop:
    mov dl, [si]
    mov ah, 02h
    int 21h
    inc si
    loop columna_loop

    lea dx, salto
    mov ah, 09h
    int 21h

    pop cx
    loop fila_loop

    ret
tablero ENDP

; Delay function for 1 second
delay_1_sec PROC
    mov ah, 00h
    int 1Ah
    mov bx, dx
wait_tick:
    mov ah, 00h
    int 1Ah
    sub dx, bx
    cmp dx, 18
    jl wait_tick
    ret
delay_1_sec ENDP

; Función para limpiar pantalla
limpiar_pantalla PROC
    mov ah, 0
    mov al, 3
    int 10h
    ret
limpiar_pantalla ENDP

game_over PROC
    call limpiar_pantalla

    mov dx, offset gameover_msg
    mov ah, 09h
    int 21h

    ; Esperar tecla para salir
    mov ah, 00h
    int 16h

    mov ah, 4Ch
    int 21h
game_over ENDP

end main