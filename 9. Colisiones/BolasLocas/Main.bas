' - BolasLocas --------------------------------------------
' https://tinyurl.com/mtykssw3

Main()
STOP


' - Defines -----------------------------------------------
' Número de bolas
#DEFINE MAX_BOLAS 5
' Coordenada X de la bola
#DEFINE BOLA_X 0
' Coordenada Y de la bola
#DEFINE BOLA_Y 1
' Velocidad X de la bola
#DEFINE BOLA_VX 2
' Velocidad Y de la bola
#DEFINE BOLA_VY 3

' Número de minas
#DEFINE MAX_MINAS 5
' Coordenada X de la mina
#DEFINE MINA_X 0
' Coordenada Y de la mina
#DEFINE MINA_Y 1


' - Variables globales ------------------------------------
' Datos de las bolas
DIM Bolas(MAX_BOLAS,3) AS Byte
' Datos de las minas
DIM Minas(MAX_MINAS,1) AS Byte


' - Includes ----------------------------------------------
#INCLUDE <retrace.bas>
#INCLUDE <attr.bas>
#INCLUDE "Graficos.udg.bas"
#INCLUDE "Mapa.bas"


' - Subrutina principal -----------------------------------
SUB Main()    
    ' Copias locales de las coordenadas
    DIM x, y, vx, vy AS Byte
    ' Varios
    DIM n AS UByte

    ' Inicializamos el sistema
    Inicializar()

Iniciar:    
    ' Creamos las bolas aleatorias
    CrearBolas()
    ' Crear las minas
    CrearMinas()
    ' Crear Mapa
    CrearMapa()
    
    ' Dibujamos todas las bolas una primera vez
    DibujarBolas()
    'Dibujamos las minas
    DibujarMinas()
    ' DibujarMapa
    DibujarMapa()
    
    ' Esperamos hasta que no se pulse ninguna tecla
    WHILE INKEY$<>""
    WEND
    
    ' Bucle hasta que pulsemos una tecla
    WHILE INKEY$=""       
        ' Recorremos la matriz bolas
        FOR n = 0 TO MAX_BOLAS
            ' Copiamos los datos de las bolas en local
            x = Bolas(n,BOLA_X)
            y = Bolas(n,BOLA_Y)
            vx = Bolas(n,BOLA_VX)
            vy = Bolas(n,BOLA_VY)
            
            ' Movemos las bolas
            x = x + vx
            y = y + vy      
            
            ' Detectamos las colisiones por mapa
            DetectarColisionesMapa(x,y,vx,vy)

            ' Detectamos las colisiones por atributo
            DetectarColisionesAtributo(x,y,vx,vy)
            
            ' Sincronizamos con el barrido
            waitretrace
            
            ' Borramos la bola actual
            DibujarBola(n)           
            
            ' Reasignamos el valor de las bolas
            Bolas(n,BOLA_X) = x
            Bolas(n,BOLA_Y) = y
            Bolas(n,BOLA_VX) = vx
            Bolas(n,BOLA_VY) = vy
            
            ' Dibujamos la bola en la nueva posición
            DibujarBola(n)
        NEXT n        
    WEND
    
    ' Borramos la pantalla
    CLS
    ' Volvemos a empezar
    GOTO Iniciar
END SUB


' - Inicializa el sistema ---------------------------------
SUB Inicializar()
   ' Establecemos colores y borramos la pantalla
    BORDER 5
    PAPER 7
    INK 0
    CLS
    
    ' Inicializamos los GDUs
    POKE (uinteger 23675, @Graficos)
    
    ' Esperamos a que se pulse una tecla
    PRINT AT 5,10;"Bola locas";
    PRINT AT 10,1;"Pulsa una tecla para empezar!";    
    PAUSE 0
    
    ' Borramos la pantalla
    CLS
    
    ' Semilla del generador de números aleatorios
    RANDOMIZE 0
END SUB


' - Crea las bolas ----------------------------------------
SUB CrearBolas()
    DIM n AS UByte
  
    ' Creamos las bolas
    FOR n = 0 TO MAX_BOLAS
        ' Repetiremos este bucle si vx=0 y vy=0
        DO
            ' Cargamos con datos aleatorios
            Bolas(n,BOLA_X)=(RND * 29) + 1
            Bolas(n,BOLA_Y)=(RND * 21) + 1
            ' La velocidad va de -1 a 1
            Bolas(n,BOLA_VX)=(RND * 2) - 1
            Bolas(n,BOLA_VY)=(RND * 2) - 1            
        LOOP WHILE Bolas(n,BOLA_VX) = 0 AND _
            Bolas(n,BOLA_VY) = 0
    NEXT n
END SUB


' - Dibuja todas las bolas --------------------------------
SUB DibujarBolas()
    DIM n AS UByte
    ' Dibuja todas las bolas
    FOR n = 0 TO MAX_BOLAS
        DibujarBola(n)
    NEXT n
END SUB


' - Dibuja una bola ---------------------------------------
SUB DibujarBola(n AS UByte)
    ' Dibuja una bola con OVER 1 (XOR)
    PRINT AT Bolas(n,BOLA_Y), Bolas(n,BOLA_X);OVER 1; _
        INK n;"\A";
END SUB


' - Detecta cuando la bola sale de la pantalla ------------
' Los parámetros se modifican dentro de la función
' Parámetros:
'   x (Byte por referencia): Coordenada X
'   y (Byte por referencia): Coordenada Y
'   vx (Byte por referencia): Velocidad X
'   vy (Byte por referencia): Velocidad Y
SUB DetectarColisionArea(BYREF x AS Byte, _
    BYREF y AS Byte, _
    BYREF vx AS Byte, _
    BYREF vy AS Byte)
    ' Si se sale por la izquierda...
    IF x < 0 THEN
        ' La velocidad x es positiva
        vx = 1
        ' Fijamos x al mínimo
        x = 0
    ' Si se sale por la derecha...
    ELSEIF x > 31
        ' La velocidad x es negativa
        vx = -1
        ' Fijamos x al máximo
        x = 31
    END IF

    ' Si se sale por arriba...
    IF y < 0 THEN
        ' La velocidad y es positiva
        vy = 1
        ' Fijamos y al mínimo
        y = 0
        ' Si se sale por abajo...
    ELSEIF y > 23
        ' La velocidad es negativa
        vy = -1
        ' Fijamos y al máximo
        y = 23
    END IF
END SUB


' - Crear minas -------------------------------------------
SUB CrearMinas()
    DIM n AS UByte
    
    FOR n = 0 TO MAX_MINAS
        Minas(n,MINA_X) = (RND * 29) + 1
        Minas(n,MINA_Y) = (RND * 21) + 1
    NEXT n    
END SUB


' - Dibuja las minas --------------------------------------
SUB DibujarMinas()
    DIM n AS UByte
    
    FOR n = 0 TO MAX_MINAS
        PRINT AT Minas(n,MINA_Y),Minas(n,MINA_X); _
            INK 6;"\B";
    NEXT n    
END SUB


' - Detecta colisiones por el atributo de la mina ---------
' Los parámetros se modifican dentro de la función
' Parámetros:
'   x (Byte por referencia): Coordenada X
'   y (Byte por referencia): Coordenada Y
'   vx (Byte por referencia): Velocidad X
'   vy (Byte por referencia): Velocidad Y
SUB DetectarColisionesAtributo(BYREF x AS Byte, _
    BYREF y AS Byte, _
    BYREF vx AS Byte, _
    BYREF vy AS Byte)
    ' Variable temporal
    DIM a AS UByte
    
    ' Leemos el atributo en y, x
    a = attr(y,x)
    ' Si es PAPER 7, INK 6...
    IF a = %00111110 THEN
        ' Paramos la bola
        vx = 0
        vy = 0
    END IF    
END SUB


' - Detecta colisiones por mapa ---------------------------
' Los parámetros se modifican dentro de la función
' Parámetros:
'   x (Byte por referencia): Coordenada X
'   y (Byte por referencia): Coordenada Y
'   vx (Byte por referencia): Velocidad X
'   vy (Byte por referencia): Velocidad Y
SUB DetectarColisionesMapa(BYREF x AS Byte, _
    BYREF y AS Byte, _
    BYREF vx AS Byte, _
    BYREF vy AS Byte)
    ' Variable temporal
    DIM rebote AS UByte
    
    ' Si la posición del mapa actual está vacía
    IF Mapa(x,y) = 0 THEN
        ' No hay colisión, salimos
        RETURN
    END IF
    
    ' Si hay colisión, buscamos como rebotar
    ' Si avanza hacia la derecha
    IF vx = 1 THEN
        ' Si avanza hacia abajo a la derecha
        IF vy = 1 THEN
            ' Pared abajo...
            IF Mapa(x-1,y) <> 0 THEN
                vy = - 1
                y = y + vy
                rebote = 1
            END IF
            ' Pared a la derecha...
            IF Mapa(x,y-1) <> 0 THEN
                vx = -1
                x = x + vx
                rebote = 1
            END IF
            ' Si no hay rebote es un canto
            IF rebote = 0 THEN
                vx = -1
                x = x + vx
                vy = -1
                y = y + vy
            END IF
        ' Si avanza hacia arriba a la derecha
        ELSEIF vy = -1 THEN
            ' Pared arriba...
            IF Mapa(x-1,y) <> 0 THEN
                vy = 1
                y = y + vy
                rebote = 1
            END IF
            ' Pared a la derecha..
            IF Mapa(x,y+1) <> 0 THEN
                vx = -1
                x = x + vx
                rebote = 1
            END IF
            ' Si no hay rebote es un canto
            IF rebote = 0 THEN
                vx = -1
                x = x + vx
                vy = 1
                y = y + vy
            END IF
        ' Si avanza solo horizontalmente
        ELSE
            vx = -1
            x = x + vx
        END IF
    ELSEIF vx = -1 THEN
        ' Si avanza hacia abajo a la izquierda
        IF vy = 1 THEN
            ' Pared abajo...
            IF Mapa(x+1,y) <> 0 THEN
                vy = - 1
                y = y + vy
                rebote = 1
            END IF
            ' Pared a la izquierda
            IF Mapa(x,y-1) <> 0 THEN
                vx = 1
                x = x + vx
                rebote = 1
            END IF
            ' Si no hay rebote es un canto
            IF rebote = 0 THEN
                vx = 1
                x = x + vx
                vy = -1
                y = y + vy
            END IF
        ' Si avanza hacia arriba a la izquierda
        ELSEIF vy = -1 THEN
            ' Pared arriba...
            IF Mapa(x+1,y) <> 0 THEN
                vy = 1
                y = y + vy
                rebote = 1
            END IF
            ' Pared a la izquierda... 
            IF Mapa(x,y+1) <> 0 THEN
                vx = 1
                x = x + vx
                rebote = 1
            END IF
            ' Si no hay rebote es un canto
            IF rebote = 0 THEN
                vx = 1
                x = x + vx
                vy = 1
                y = y + vy
            END IF
        ' Si avanza solo horizontalmente
        ELSE
            vx = 1
            x = x + vx
        END IF
    ' Avanza verticalmente
    ELSE
        vy = vy * -1
        y = y + vy
    END IF
END SUB
