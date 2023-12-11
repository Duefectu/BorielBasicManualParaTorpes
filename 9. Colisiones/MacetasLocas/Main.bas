' - Macetas Locas -----------------------------------------
' https://tinyurl.com/46h93ab8

Main()
STOP


' - Definiciones ------------------------------------------
#DEFINE COSAS_MAX 10
#DEFINE COSA_X 0
#DEFINE COSA_Y 1
#DEFINE COSA_FRAME 2
#DEFINE COSA_TIPO 3


' - Variables globales ------------------------------------
' Coordenada x, y, orientación, paso y subFrame de Ingrid
DIM Ix, Iy, Io, Ip, Isf AS UByte
' Cosas que caen
DIM Cosas(COSAS_MAX,3) AS Byte
' Número de cosas que están cayendo
DIM CosasCayendo AS UByte
' Secuencia de macetas
DIM MacetasSecuencia(7,1) AS UByte
' Dirección de los sprites de las macetas
DIM MacetasDir(4) AS UInteger

' Puntuaciones
DIM Puntos, Record AS ULong
' Nivel y vidas
DIM Nivel, Vidas AS UByte


' - Includes ----------------------------------------------
#INCLUDE <putchars.bas>
#INCLUDE <retrace.bas>
#INCLUDE <winscroll.bas>
#INCLUDE "Ingrid.spr.bas"
#INCLUDE "Cosas.spr.bas"
#INCLUDE "Glow.fnt.bas"
#INCLUDE "Menu.bas"
#INCLUDE "Juego.bas"
#INCLUDE "DoubleSize.bas"
#INCLUDE "Marcador.bas"


' - Subrutina principal -----------------------------------
SUB Main()
    ' Inicializamos el sistema
    Inicializar()

    ' Bucle infinito
    DO
        ' Mostramos el menu
        Menu()
        ' Bucle del juego
        Juego()
    LOOP
END SUB


' - Inicializa el sistema ---------------------------------
SUB Inicializar()
    ' Ajustamos colores y borramos la pantalla
    BORDER 1
    PAPER 7
    INK 0
    CLS
    
    ' Cambiamos la fuente del sistema
    POKE (UInteger 23606, @Glow-256)
    
    ' Definimos la dirección de los sprites de las macetas
    MacetasDir(0) = @Cosas_Maceta1
    MacetasDir(1) = @Cosas_Maceta2
    MacetasDir(2) = @Cosas_Maceta3
    MacetasDir(3) = @Cosas_Regalo
END SUB
