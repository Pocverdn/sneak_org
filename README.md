# sneak_org

Este proyecto trata de un simple juego de la serpiente, desarrollado en lneguje ensamblador x86. El juego se ejecuta en consola y permite realizar todas las acciones basicas de un juego de la serpiente, tales como:

  - Moverse con las teclas A, W, S, D
  - Consumir @ para crecer
  - Perder al chocar la serpiente con sigo mismas o los border del tablero
  - Salir del juego con la tecla Esc

Para el juego se recomientda usar el Ensamblador MASM y el emulador DOSbox

## Estructura del codigo

Nuestro codigo cuenta con los siguientes segmentos:

  - .data: Crea el tablero (array), la serpiente (snake), la dirección, longitud y cadenas de texto.
  
  - initialize: Coloca la serpiente de 3 segmentos en el centro del tablero.
  
  - ramdom: Coloca una comida (@) en una posición aleatoria (Asegurandose de que ningun segmento de la serpiente se encuentre presente).
  
  - get_input: Captura la tecla presionada para cambiar la dirección de la serpiente.
  
  - move_player: Mueve la serpiente, detecta colisiones, crece si hay comida y actualiza el tablero.
  
  - tablero: Dibuja el tablero por consola.
  
  - delay_1_sec: Crea una pausa de 1 segundo usando el reloj del BIOS.
  
  - limpiar_pantalla: Limpia la pantalla antes de actualizar.
  
  - game_over: Muestra mensaje de final del juego y espera una tecla.
  
  - print_snake_length: Imprime la longitud actual de la serpiente.

## Aspectos logicos

Para implementar el juego nos basamos en las siguiente logica:

  - Se crea un tablero como un arreglo de 81 celdas 9x9
  - La serpiente se crea como una lista de posisiones, siendo la ultima posición la cabeza de esta.
  - La cabeza se representa como un X, el cuerpo como un o y los espacio vacios con .
  - Si la cabeza de la serpiente se encuentra con una @ antes de volver a dibujar el tablero, esta crece un segmento.
  - Si la serpiente choca con si misma o los bordes del tablero, el juego termina.

## Como ejecutar

Como ya se menciono antes, se recomienda utilizar el ensamblador de microsoft MASM y el emulador DOSbox, para copilar el codigo, se ejcuta las siguientes lineas de comando:

  - ml [ruta del archivo]\main.asm
  - main.exe

### Ejemplo:

![image](https://github.com/user-attachments/assets/d2dae45c-8ef0-40f2-9538-b535c6322ca7)

![image](https://github.com/user-attachments/assets/0ce422d8-1a36-4ce1-8e1b-7a1afbd1ed13)

### Resultado:
![image](https://github.com/user-attachments/assets/51a6f69f-08e8-4c55-b004-cb20cf15bb2c)
