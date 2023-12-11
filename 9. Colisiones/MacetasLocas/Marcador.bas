' - Macetas Locas -----------------------------------------
' - Módulo de marcadores ----------------------------------


' - Dibuja los elementos fijos del marcador ---------------
SUB Marcador_Dibujar()
    INK 1
    PRINT AT 18,1;"PUNTOS:";
    PRINT AT 18,22;"NIVEL:";     
END SUB


' - Actualiza los valores del marcador --------------------
SUB Marcador_Actualizar()
    ' Variables locales
    DIM n AS UByte
    
    ' Puntos y nivel
    INK 1
    PRINT AT 18,9;Puntos;
    PRINT AT 18,29;Nivel;
    
    ' Vidas
    ' Imprimiremos los corazones en 18,14
    PRINT AT 18,14;"";
    FOR n = 1 TO 3
        ' Si el contador es más pequeño que las vidas...
        IF Vidas >= n THEN
            ' Corazon rojo
            PRINT INK 2;chr(92);
        ' Si el contador es más grande que las vidas...
        ELSE
            ' Corazon vacío
            PRINT INK 1;chr(91);
        END IF
    NEXT n       
END SUB


' - Dibujamos la macetas a recoger ------------------------
SUB Marcador_DibujarMacetas()
    ' Variables locales
    DIM x,n AS UByte
    
    ' Imprimimos en magenta
    INK 3
    ' A partir del pixel 0
    x = 0
    ' 8 macetas
    FOR n = 0 TO 7
        ' Imprimimos el sprite de la maceta
        DoubleSizeSprite(x,4,_
            MacetasDir(MacetasSecuencia(n,0)))
        ' La siguiente maceta dentro de 32 pixels
        x = x + 32
    NEXT n
END SUB


' - Actualizamos el estado de las macetas a recoger -------
' Devuelve:
'   UByte: Macetas pendientes de recoger
FUNCTION Marcador_ActualizarMacetas() AS UByte
    ' variables locales
    DIM x, n, restantes AS UByte
    
    ' Empezamos desde la izquierda
    x = 0 
    ' Contador de macetas restantes
    restantes = 0
    ' Recorremos toda la secuencia de macetas a recoger
    FOR n = 0 TO 7
        ' Si la maceta no se ha recogido...
        IF MacetasSecuencia(n,1) = 0 THEN
            ' La coloreamos con PAPER 7 e INK 3
            paint(x,19,4,5,%111011)
            ' Nos queda una maceta más que recoger
            restantes = restantes + 1
        ' Si la maceta se ha recogido...
        ELSE
            ' Coloreamos con BRIGHT 1, PAPER 7 e INK 1
            paint(x,19,4,5,%1111001)
        END IF
        ' La siguiente maceta está 4 celdas a la derecha
        x = x + 4
    NEXT n
    ' Devuelve el número de macetas restantes
    RETURN restantes
END FUNCTION
