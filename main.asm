.model small
.stack 100h

.data
    filas equ 9
    columnas equ 9
    salto db 13, 10, '$'
    gameover_msg db 13, 10, '¡GAME OVER!$'
    puntaje_msg db 13, 10, 'Puntaje:$'

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
    points db 0
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
    call get_input      ; Actualizar direcion
    call move_player    ; Mover el jugador de acuerdo a la dirrecion
    call limpiar_pantalla
    call tablero        ; Dibujar tablero
    ;call print_snake_length
    call delay_1_sec    ; Esperar un segundo para 1 tick
    call get_input 

    ; Revisar si se oprimio una tecla
    mov ah, 01h
    int 16h             ; ah=1 se oprimio
    jz main_loop        ; Si ninguna llave se oprime continuar loop

    ; Get the key pressed
    mov ah, 00h
    int 16h             ; lear la llave
    cmp al, 27          ; si la llave es 'Esc' (ASCII 27)
    je exit_game        ; Salir del juego si se presione

    jmp main_loop       ; De lo contrario seguir normal

exit_game:
    mov ah, 4Ch         ; Exit the program
    int 21h

main ENDP


; Inicializa una serpiente de tres segmentos
initialize PROC
    ; Posicisiones iniciales de la serpiente
    lea si, snake
    mov byte ptr [si], 41
    inc si
    mov byte ptr [si], 40
    inc si
    mov byte ptr [si], 39

    ; Se dibuja la serpiente en el array
    lea di, array
    add di, 39
    mov byte ptr [di], 'o'
    inc di
    mov byte ptr [di], 'o'
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

    mov dx, offset puntaje_msg
    mov ah, 09h
    int 21h

    mov al, points
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
    ; Posicion de cabeza vieja 
    lea si, snake
    mov al, [si]            ; current head pos
    mov old_head, al        ; salvar old head for wrap check
    
    ; Cada vez que la serpiente se mueve, se borra la posción del ultimo segmeto
    lea si, snake
    mov bl, snake_length
    dec bl
    xor bh, bh
    add si, bx              ; Ultimo segmento de la serpiente
    mov bl, [si]            ; Posición del último segmento

    lea di, array
    add di, bx
    mov byte ptr [di], '.'   ; Se cambia el o por un .

    ; Se Mueven todas las posiciones hacia atrás
    mov cl, snake_length
    dec cl
    lea si, snake
    add si, cx
    mov di, si
    inc di

shift_loop:
    mov al, [si-1]          ; posición anterior
    mov [si], al            ; Se mueve hacia atras
    ;Revisar limite superior
    cmp al, 0
    jl game_over          ; Se paso el la raya 

    ; Revisar limite inferior (bottom row)
    cmp al, 80            
    jge game_over         

    dec si
    loop shift_loop

    ; Se actualiza la cabeza segun direccion
    lea si, snake
    mov al, [si]          ; casilla despues de la cabeza
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
    mov bl, al

    ; Detecta si la serpiente se "Mordio" a si misma
    mov bl, al
    lea di, array
    add di, bx
    cmp byte ptr [di], 'o'
    je game_over

    ; Revisar golpe de muro en la derech y izquierda
    cmp direction, 75       ; LEFT
    je check_row_wrap
    cmp direction, 77       ; RIGHT
    je check_row_wrap
    jmp skip_wrap_check

check_row_wrap:
    mov al, [si]
    xor ah, ah

    push bx             ; Salvar BX
    mov bl, columnas
    div bl
    mov cl, al

    mov al, old_head
    xor ah, ah
    div bl
    pop bx              ; Restaurar BX
    cmp cl, al
    jne game_over
    
skip_wrap_check:

    ; Se Dibuja la serpiente en el tablero
    lea si, snake
    mov cl, snake_length

    ; Verifica si hay comida 
    lea di, array
    add di, bx
    cmp byte ptr [di], '@'
    jne no_food

    ; Si hay comida, incrementa la longitud de la serpiente
    inc snake_length
    inc points
    call beep
    call ramdom
    jmp skip_clear

no_food:
    lea si, snake
    mov bl, snake_length
    dec bl
    xor bh, bh
    add si, bx
    mov bl, [si]
    lea di, array
    add di, bx
    mov byte ptr [di], '.'

skip_clear:
    lea si, snake
    mov cl, snake_length
 
draw_loop:
    mov bl, [si]            ; posicion en el tablero
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

; Delay
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
    call beep

    ;mov dx, offset puntaje_msg
    ;mov ah, 09h
    ;int 21h

    ;mov al, points
    ;call print_number


    mov dx, offset gameover_msg
    mov ah, 09h
    int 21h

    ; Esperar tecla para salir
    mov ah, 00h
    int 16h

    mov ah, 4Ch
    int 21h
game_over ENDP

beep PROC
    mov al, 182        ; Configuración del canal
    out 43h, al

    mov ax, 2153       ; Frecuencia del audio

    out 42h, al        ; Configuración del audio
    mov al, ah
    out 42h, al

    in al, 61h
    or al, 3           ; Conecta al altavoz
    out 61h, al

    ; retardo para que se escuche el beep
    mov cx, 0FFFFh

beep_delay:
    loop beep_delay

    in al, 61h
    and al, 0FCh        ; Apaga altavoz
    out 61h, al

    ret
beep ENDP

end main