.model small
.stack 100h

.data
    filas equ 9
    columnas equ 9
    salto db 13, 10, '$'

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


; Initialize the game setup
initialize PROC
    ; Posición inicial de la serpiente (cabeza en 41, cuerpo en 40 y 39)
    lea si, snake
    mov byte ptr [si], 39
    inc si
    mov byte ptr [si], 40
    inc si
    mov byte ptr [si], 41

    ; Dibujar la serpiente en el array
    lea di, array
    add di, 39
    mov byte ptr [di], 'x'
    inc di
    mov byte ptr [di], 'x'
    inc di
    mov byte ptr [di], 'X'

    ret
initialize ENDP

; Random function to place the '@' in the array
ramdom PROC
    mov ah, 00h
    int 1Ah ; Get the current time from the clock (DX contains random value)
    mov ax, dx
    xor dx, dx
    mov cx, 81
    div cx ; Divide by 81 (map to grid size)
    lea si, array
    add si, dx
    mov byte ptr [si], '@'
    ret
ramdom ENDP

; Function to get input from the user
get_input PROC
    mov ah, 01h
    int 16h         ; Check if a key is pressed
    jz no_input     ; If no key is pressed, skip the input handling

    mov ah, 00h     ; Read the pressed key
    int 16h

    ; Arrow key detection
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

up:    mov direction, 72
        ret
down:  mov direction, 80
        ret
left:  mov direction, 75
        ret
right: mov direction, 77
        ret
get_input ENDP

print_snake_length PROC
    mov ah, 02h
    mov dl, 13      ; retorno de carro
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
    ; Primero: Borrar el último segmento de la cola
    lea si, snake
    mov bl, snake_length
    dec bl
    xor bh, bh
    add si, bx              ; Apuntar al último segmento
    mov bl, [si]            ; Obtener posición del último segmento
    lea di, array
    add di, bx
    mov byte ptr [di], '.'   ; Borrar la posición anterior

    ; Segundo: Mover todas las posiciones hacia atrás
    mov cl, snake_length
    dec cl
    lea si, snake
    add si, cx
    mov di, si
    inc di

shift_loop:
    mov al, [si-1]          ; posición anterior
    mov [si], al            ; mover hacia atrás
    dec si
    loop shift_loop

    ; Tercero: Actualizar la cabeza según dirección
    lea si, snake
    mov al, [si+1]          ; posición anterior de la cabeza
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
    sub al, columnas
not_up:
    cmp direction, 80       ; DOWN
    jne not_down
    add al, columnas
not_down:
    mov [si], al            ; guardar nueva cabeza

    ; Cuarto: Dibujar la serpiente en el tablero
    lea si, snake
    mov cl, snake_length
draw_loop:
    mov bl, [si]            ; posición en el tablero
    lea di, array
    add di, bx
    cmp cl, snake_length    ; si es la cabeza
    je draw_head
    mov byte ptr [di], 'o'  ; cuerpo
    jmp next_segment
draw_head:
    mov byte ptr [di], 'X'  ; cabeza
next_segment:
    inc si
    loop draw_loop

    ret
move_player ENDP

; Function to render the board
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

end main