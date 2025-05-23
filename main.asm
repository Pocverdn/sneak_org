.model small
.stack 100h

.data
    filas equ 9
    columnas equ 9 ; equ -> Constantes (como los # define en C)

    salto db 13, 10, '$'

    array db '*','*','*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*','*','*'

.code

main PROC
    mov ax, @data
    mov ds, ax

    call ramdom
    call tablero

    mov ah, 4Ch
    int 21h

main ENDP


ramdom PROC
    mov ah, 00h
    int 1Ah ; tiempo del reloj (Por defecto de DX)

    mov ax, dx
    xor dx, dx
    mov cx, 81 
    div cx ; ax/81 (posición aleatoria)

    lea si, array
    add si, dx
    mov byte ptr [si], '@'

    ret
ramdom ENDP

tablero PROC

    mov cx, filas
    lea si, array

fila_loop:
    push cx ; contador de filas
    mov cx, columnas ; contador de columnas

columna_loop:
    mov dl, [si] ; i arr[i] si [si] / Carga el valor de cada parte de la matriz
    mov ah, 02h  ; funcion para imprimir
    int 21h
    inc si ; Avanza a la siguiente casilla
    loop columna_loop

    ; Imprimir salto de línea
    lea dx, salto
    mov ah, 09h
    int 21h

    pop cx ; cotador de filas
    loop fila_loop

    mov ah, 4Ch
    int 21h

    ret

tablero ENDP

end main
