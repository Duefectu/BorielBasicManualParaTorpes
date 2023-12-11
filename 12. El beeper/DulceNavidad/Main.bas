' - DulceNavidad ------------------------------------------
' https://tinyurl.com/2a6mjavh

' 49 notas = 49 x 2 = 98 (-1 ya que empieza por 0)
' Utilizamos una línea para cada compás de 4/4
' Primer valor duración, segundo tono (128 pausa)
DIM Navidad(97) AS Integer = { _
    1,22, 1,22, 2,22, _
    1,22, 1,22, 2,22, _
    1,22, 1,25, 1,18, 1,20, _
    4,22, _
    1,23, 1,23, 1,23, 1,23, _
    1,22, 1,22, 1,22, 1,22, _
    1,20, 1,20, 1,20, 1,22, _
    2,20, 1,25, 1,128, _
    1,22, 1,22, 2,22, _
    1,22, 1,22, 2,22, _
    1,22, 1,25, 1,18, 1,20, _
    4,22, _
    1,23, 1,23, 1,23, 1,23, _
    1,22, 1,22, 1,22, 1,22, _
    2,25, 1,23, 1,20, _
    4,18 }

DIM n as UByte          ' Contador
DIM duracion AS Fixed   ' Duración de la nota  
DIM tono AS Byte        ' Tono de la nota
' Definimos un tempo de 0.429 = 60 / 140
DIM tempo AS Fixed = 0.429
' Una variable para la conversión a PAUSE
DIM tempoPausa AS Fixed
' En esta variable guardamos la letra
DIM s AS String

' Borramos la pantalla
CLS

' Imprimimos el título
PRINT "Karaoke: Dulce Navidad"
PRINT "----------------------"
PRINT ""

' Calculamos el tiempo de la pausa
' Una unidad en PAUSE es 0,02 segundos
tempoPausa = tempo / .02

' Colocamos el puntero de READ en la etiqueta Letra
RESTORE Letra

' Bucle para recorrer toda la canción
FOR n = 0 TO 97 STEP 2
    ' Leemos la letra de la canción
    READ s
    ' Imprimimos la letra de la canción
    PRINT s;

    ' Leemos la duración en bruto
    duracion = Navidad(n)
    ' Leemos el tono
    tono = Navidad(n+1) 
    ' Si el tono es 128, es una pausa
    IF tono = 128 THEN        
        ' Utilizamos PAUSE (20 ms por unidad)
        ' 0,020 x 21,45 = 0,429
        PAUSE duracion*tempoPausa
    ' Si no es una pausa
    ELSE
        ' Tocamos la duración * 0,429 y el tono
        BEEP duracion*tempo,tono
    END IF
    
    ' Si se pulsa alguna tecla, se para todo
    IF INKEY$<>"" THEN
        STOP
    END IF
NEXT n


Letra:
' Letra de la canción, un elemento por nota
DATA "Na","vi","dad, "
DATA "Na","vi","dad, "
DATA "dul","ce ","Na","vi"
DATA "dad, "
DATA "a","le","gri","a y "
DATA "buen ", "hu","mor ","lle"
DATA "go ","la ","Na","vi"
' El código 013 es el retorno de carro
DATA "dad. ","Hey!","\#013"
DATA "Na","vi","dad, "
DATA "Na","vi","dad, "
DATA "lle","ga ","Na","vi"
DATA "dad. "
DATA "To","dos ","jun","tos "
DATA "va","mos ","al ","Por"
DATA "tal ","a ","can"
DATA "tar."
