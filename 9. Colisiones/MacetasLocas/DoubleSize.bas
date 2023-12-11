' - Double Size -------------------------------------------
' - Librería para la ampliación de caracteres y sprites


' - Imprime un carácter o gráfico a doble tamañoa ---------
' Parámetros:
'   x (UByte): coordenada X en pixels
'   y (UByte): coordenada Y en pixels
'   dir (UInteger): Dirección del memoria del carácter
SUB DoubleSize8x8(x AS UBYTE, y AS UByte, dir AS UINTEGER)
    ' Variables locales
    DIM xx, yy, nx, ny, b, a AS UByte
    
    ' En pixels 0,0 está abajo a la izquierda, así que
    ' invertimos el valor de y
    yy = y + 14
    ' 8 filas (8 bytes)
    FOR ny = 0 TO 7
        ' Invertimos x
        xx = x + 14
        ' Leemos el valor del byte
        b = PEEK(dir)
        ' Procesamos el carácter (1 byte)
        FOR nx = 0 TO 7
            ' Cogemos el bit 0
            a = b bAND %1
            ' Desplazamos el byte a la derecha
            b = b >> 1
            ' Si el bit 0 es 0
            IF a = 0 THEN
                ' Modo borrar = 1
                INVERSE 1
            ELSE
                ' Modo borrar = 0
                INVERSE 0
            END IF
            ' Dibujamos 4 puntos (2x2)
            PLOT xx,yy
            PLOT xx+1,yy
            PLOT xx,yy+1
            PLOT xx+1,yy+1
            ' Desplazamos "x" 2 pixels
            xx = xx - 2
        NEXT nx
        ' Siguiente byte
        dir = dir + 1
        ' Desplazamos "y" 2 pixels
        yy = yy - 2
    NEXT ny
    ' Reseteamos el inverse
    INVERSE 0
END SUB


' - Imprime un texto a doble tamaño -----------------------
' Parámetros:
'   x (UByte): coordenada x en pixels
'   y (UByte): coordenada y en pixels
'   texto (String): texto a imprimir
SUB DoubleSizeTexto(x AS UByte, y AS UByte, texto AS String)
    DIM dir AS UInteger
    DIM n, c, xx AS UByte
    
    ' Sacamos una copia de x
    xx = x
    ' Recorremos la cadena letra a letra
    FOR n = 0 TO LEN(texto)-1
        ' Dirección del carácter
        dir = PEEK(UInteger, 23606)
        ' Código ASCII del carácter
        c = CODE texto(n)  
        ' Calculamos la dirección del carácter en memoria
        dir = dir + (CAST(UInteger,c) * 8)
        ' Imprimimos el carácter a doble tamaño
        DoubleSize8x8(xx,y,dir)
        ' Incrementamos c en 16 pixels
        xx = xx + 16
    NEXT n
END SUB
