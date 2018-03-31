; Programa para simular el funcionamiento de un semáforo basado en el micro
; PIC16F84A.
;
; Pablo Salgado
; 
;
; Microcontroladores y Microprocesadores
; Escuela de Ciencias Básicas, Tecnología e Ingeniería
; UNAD

; Se incluye el archivo de definición de registros y otras configuraciones 
; de Microchip Technology
#include "p16f84a.inc"

__CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _CP_OFF
 
; Configuración de registros de uso general para llevar a cabo los ciclos que
; permiten generar los retardos requeridos para el funcionamiento del semáforo
C1  EQU	0x0C
C2  EQU	0x0D
C3  EQU	0x0E
C4  EQU 0x0F
  
RES_VECT  CODE    0x0000            ; Vector de reinicio del procesador
    GOTO    START                   ; Iniciar el programa

MAIN_PROG CODE                      ; let linker place main program

; =============================================================================
; Rutina para esperar 1s
; =============================================================================
DELAY1S
    ; Configura tres registros de uso general para generar un contador de ciclos
    ; anidados de modo que se ejecuten en 1000000 de ciclos de reloj.
    MOVLW 0xAB				; registros de conteo: C1=171, C2=24,     
    MOVWF C1				; C3=6
    MOVLW 0x18
    MOVWF C2
    MOVLW 0x30
    MOVWF C3

; Llevar a cabo la espera de 1s
LOOP1
    ; Primer ciclo 
    DECFSZ C1, 1
    GOTO LOOP1
    
    ; Luego de terminar el primer ciclo, es necesario reiniciar el registro.
    MOVLW 0xAB
    MOVWF C1
    
    DECFSZ C2, 1
    GOTO LOOP1				
    
    ; Luego de terminar el segundo ciclo, es necesario reiniciar el registro.
    MOVLW 0x18
    MOVWF C2

    DECFSZ C3, 1
    GOTO LOOP1				
        
    RETURN
    
; =============================================================================
; Rutina para esperar 2 segundos
; =============================================================================
DELAY2S
    MOVLW 0x2				; registros de conteo de segundos a 2
    MOVWF C4

; Llevar a cabo la espera de 2s
LOOP2
    CALL DELAY1S
    DECFSZ C4, 1
    GOTO LOOP2
    
    RETURN
    
; =============================================================================
; rutina para esperar 3 segundos
; =============================================================================
DELAY3S
    MOVLW 0x3				; registros de conteo de segundos a 3
    MOVWF C4

; Llevar a cabo la espera de 3s
LOOP3
    CALL DELAY1S
    DECFSZ C4, 1
    GOTO LOOP3
    
    RETURN
    
; =============================================================================
; rutina para esperar 4 segundos
; =============================================================================
DELAY4S
    MOVLW 0x4				; registros de conteo de segundos a 4
    MOVWF C4

; Llevar a cabo la espera de 4s
LOOP4
    CALL DELAY1S
    DECFSZ C4, 1
    GOTO LOOP4
    
    RETURN

    
START
    ; ==========================================================================
    ; Configuración de los tres bit de menor peso del puerto B como salida. En
    ; cada uno de ellos se va a conectar un led de la siguiente forma:
    ; PORTB.0 => LED RED
    ; PORTB.1 => LED YELLOW
    ; PORTB.2 => LED GREEN
    ; ==========================================================================
   
    ; Configurar el puerto B.
    BSF STATUS, RP0		    ; Se selecciona el banco 1 para configurar    
    MOVLW   0xF8		    ; el registro TRISB con 0xF8 indicando así
    MOVWF   TRISB		    ; que los tres bits de menor peso son OUT

    ; ==========================================================================
    ; Rutina para simular el funcionamiento del semáforo:
    ; El LED rojo inicia encendido.
    ; El LED amarillo se enciende un segundo después.
    ; El LED rojo y amarillo se apagan dos segundos después.
    ; EL LED verde se enciend y dura 4 segundos encendido.
    ; Vuelve a inicar la secuencia.
    ; ==========================================================================
    BCF STATUS, RP0		    ; Se selecciona el banco 0

BLINK
    ; Todos los LED apagados al inicio
    BCF PORTB, 0
    BCF PORTB, 1
    BCF PORTB, 2
    
    ; Se enciende el LED rojo que está conectado en el PORTB.0. Esto se logra
    ; colocando un 1 en el bit 0 del puerto B
    BSF PORTB, 0		    ; Se coloca 1 en el bit 0 del puerto B
    
    ; Ahora se espera 1s antes de encender el LED amarillo
    CALL DELAY1S
    
    ; Se enciende el LED amarillo que está conectado en el PORTB.1. Esto se logra
    ; colocanco 1 en el bit 1 del puerto B
    BSF PORTB, 1		    ; Se coloca 1 en el bit 0 del puerto B
    
    ; Ahora se espera 2s con los dos LEDs encendidos
    CALL DELAY2S
    
    ; Se apagan los LEDs rojo y amarillo y se enciende el verde.
    BCF PORTB, 0		    ; Y se coloca cero en los bits 0 y 1
    BCF PORTB, 1
    BSF PORTB, 2		    ; Se enciende el LED Verde
    
    ; Se espera 4s con el LED verde encendido y se reinicia la secuencia.
    CALL DELAY4S
        
    GOTO BLINK			    ; loop forever

    END
