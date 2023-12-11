' - Conmutator --------------------------------------------

' Declaramos la función GetSlot3
DECLARE FUNCTION GetSlot3() AS UByte

DIM n AS UByte

CLS

' Bucle de 8 bancos de memoria (8 x 16k = 128k)
FOR n = 0 TO 7
    ' Colocamos el banco "n" en el slot 3
    SetSlot3(n)
    ' Escribimos el número "n" al principio del
    ' slot 3 ($c000)
    POKE $c000,n
NEXT n

' Ahora comprobamos si ha ido bien
FOR n = 0 to 7
    ' Colocamos el banco "n" en el slot 3
    SetSlot3(n)
    ' Imprimimos "n"
    PRINT "Banco: ";n;
    ' Imprimimos el banco del slot 3 según BANKM
    PRINT ", BANKM: ";GetSlot3();
    ' Valor de la dirección de memoria $C000
    PRINT ", $C000: ";PEEK($c000)
NEXT n


' - Conmuta el banco indicado en el slot 3 ---------------
' Parámetros:
'   banco (UByte): Banco a colocar en el slot 3 (0-7)
SUB FASTCALL SetSlot3(banco AS UByte)
ASM
    ld d,a          ; Con FASTCALL banco se coloca en A
    ld a,($5b5c)    ; Leemos BANKM
    and %11111000   ; Reseteamos los 3 primeros bits
    or d            ; Ajustamos los 3 primeros bits con el                 
                    ; "banco"
    ld bc,$7ffd     ; Puerto donde haremos el OUT
    di              ; Deshabilitamos las interrupciones
    ld ($5b5c),a    ; Actualizamos BANKM
    out (c),a       ; Hacemos el OUT
    ei              ; Habilitamos las interrupciones
END ASM
END SUB


'- Obtenemos la página del Slot3 desde BANKM -------------
' Salida:
'   UByte: Banco en el slot 3 según BANKM (0-7)
FUNCTION GetSlot3() AS UByte
    RETURN PEEK $5b5c bAND %111
END FUNCTION
