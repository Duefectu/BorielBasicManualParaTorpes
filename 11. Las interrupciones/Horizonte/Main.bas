' - Horizonte ---------------------------------------------
' https://tinyurl.com/32kuypmb

' Declaramos dos variables para usar dentro de IM2CallMyRoutine
' Estas variables deben ser globales
' Contador para perder el tiempo
DIM im2_Contador AS UInteger
' Altura del horizonte
DIM im2_Horizonte AS UInteger = 400

' Llamamos a la subrutina Main
Main()


' - Subrutina principal -----------------------------------
SUB Main()   
    CLS
    
    ' Configuramos y ponemos en marcha las interrupciones
    SetUpIM2()
    
    ' Bucle infinito
    DO
        ' Imprimimos la altura actual del horizonte
        PRINT AT 0,0;im2_Horizonte;"  ";
        ' Si pulsamos "q", subimos el horizonte
        IF INKEY$ = "q" THEN
            ' Lo subimos siempre que no sea 0
            IF im2_Horizonte > 0 THEN
                ' Subir es hacer menos pausa
                im2_Horizonte = im2_Horizonte - 1
            END IF
        ' Si pulsamos "a" bajamos el horizonte
        ELSEIF INKEY$ = "a" THEN
            ' bajar es hacer más pausa
            im2_Horizonte = im2_Horizonte + 1
        END IF
    LOOP   
END SUB


' - Esta es nuestra rutina que se llama cada 20ms ---------
' No podemos hacer muchas cosas dentro
' No definir variables locales, no usar la ROM,
' no entretenerse demasiado...
SUB FASTCALL MyInterruptRoutine()
    ' El cielo es celeste
    BORDER 5
    ' Esperamos para cambiar de cielo a tierra
    FOR im2_Contador=0 to im2_Horizonte
    NEXT im2_Contador
    ' La tierra es verde
    BORDER 4
END SUB


' - Inicializa el sistema de interrupciones ---------------
SUB SetUpIM2()
cls
ASM
IM2_JUMP    EQU     $fefe   ; Dirección de salto intermedio

    di              ; Deshabilitamos las interrupciones
    ; Construimos la tabla de vectores
    ld de,IM2_Table ; Dirección de la tabla
    ld hl,IM2_JUMP  ; Dirección de salto intermedio
    ld a,d          ; Ajustamos el valor de I
    ld i,a
    ld a,l          ; Rellenamos la tabla con 257 bytes
NO_BUC:
    ld (de),a
    inc e
    jr nz,NO_BUC    
    inc d
    ld (de),a
    
    ; En la dirección de salto intermedio colocamos un
    ; JP IM2_JUMP
    ld a,$c3        ; $C3 es el código de JP en assembler
    ld (IM2_JUMP),a
    ld hl,IM2_Tick  ; 2 bytes siguientes para la dirección
    ld (IM2_JUMP+1),hl
    
    im 2            ; Ajustamos el modo de interrupción a 2
    ei              ; Activamos las interrupciones        
    jp IM2_FIN      ; Saltamos al final para salir

    ; Aquí saltará en cada interrupción
IM2_Tick:
    ; Guardamos todos los registros
    push af
    push hl
    push bc
    push de
    push ix
    push iy
    exx
    ex af, af'
    push af
    push hl
    push bc
    push de
    
END ASM

    ' Aquí ponemos nuestra rutina ASM o Basic
    ' En este caso saltamos a una subrutina Basic
    MyInterruptRoutine()    ' Call MyInterruptRoutine
    
ASM
    ; Recuperamos todos los registros que hemos guardado
    pop de
    pop bc
    pop hl
    pop af
    ex af, af'
    exx
    pop iy
    pop ix
    pop de
    pop bc
    pop hl
    pop af
        
    ei              ; Activamos las interrupciones
    reti            ; Salimos de la interrupción

    ; Espacio para la tabla de vectores de interrupción
    ; Debe empezar en una dirección múltiplo de 256
    ALIGN 256       ; Alineamos a 256
IM2_Table:
    defs 257,0      ; Reservamos 257 bytes con el valor 0

IM2_FIN:            ; Salimos de SetUpIM2
    END ASM
END SUB
