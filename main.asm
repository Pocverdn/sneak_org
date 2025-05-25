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

    pos db 0      
    oldpos db 0          
    oldpos1 db 0        
    direction db 80

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
    call tablero        ; Draw the updated game board
    call delay_1_sec    ; Wait for 1 second to create the "tick"

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
    lea si, array
    mov si, 39
    mov byte ptr [si], 'x'
    inc si
    mov byte ptr [si], 'x'
    inc si
    mov byte ptr [si], 'X'
    mov pos, 41
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
    cmp al, 72      ; UP arrow (ASCII 72)
    je up
    cmp al, 80      ; DOWN arrow (ASCII 80)
    je down
    cmp al, 75      ; LEFT arrow (ASCII 75)
    je left
    cmp al, 77      ; RIGHT arrow (ASCII 77)
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

move_player PROC
    ; Save tail history
    mov al, oldpos
    mov oldpos1, al        ; oldpos1 = oldpos

    mov al, pos
    mov oldpos, al         ; oldpos = pos

    ; Clear previous head from array
    xor bx, bx
    mov bl, pos            ; zero-extend pos (byte) into bx
    lea si, array
    add si, bx
    mov byte ptr [si], '.' ; clear current head

    ; Update pos based on direction
    mov al, pos
    cmp direction, 77      ; RIGHT
    jne not_right
    inc al
not_right:
    cmp direction, 75      ; LEFT
    jne not_left
    dec al
not_left:
    cmp direction, 72      ; UP
    jne not_up
    mov bl, columnas
    sub al, bl
not_up:
    cmp direction, 80      ; DOWN
    jne not_down
    mov bl, columnas
    add al, bl
not_down:

    mov pos, al

    ; Draw new head
    xor bx, bx
    mov bl, pos
    lea si, array
    add si, bx
    mov byte ptr [si], 'X'

    ; Draw first tail (oldpos)
    xor bx, bx
    mov bl, oldpos
    lea si, array
    add si, bx
    mov byte ptr [si], 'x'

    ; Draw second tail (oldpos1)
    xor bx, bx
    mov bl, oldpos1
    lea si, array
    add si, bx
    mov byte ptr [si], 'x'

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

end main
