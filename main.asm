.model
.stack
.data

    filas equ 5
    columnas equ 7 ;equ -> Constantes (como los # define en C)

    array db '*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*'
          db '*','*','*','*','*','*','*'

.code

    main PROC

        mov ax, @data
        mov ds, ax

    
        .exit
    main ENDP

.end main