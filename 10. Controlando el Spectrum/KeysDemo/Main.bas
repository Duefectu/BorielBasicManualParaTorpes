' - KeysDemo ----------------------------------------------
'

' - Includes ----------------------------------------------
#INCLUDE <Keys.bas>


' - Declaraciones -----------------------------------------
' Declaramos dos funciones
DECLARE FUNCTION Menu AS UByte
DECLARE FUNCTION LeerTecla AS UInteger


' - Variables globales ------------------------------------
' Guardaremos los códigos de las teclas en un array
DIM Teclas(4) AS UInteger => _
    { KEYO, KEYP, KEYQ, KEYA, KEYSPACE }
' Y el nombre del comando para cada tecla en otro
DIM TeclasS(4) AS String


' - Definiciones ------------------------------------------
' Estos defines nos ayudan a no liarnos con los índices
#DEFINE IZQUIERDA 0
#DEFINE DERECHA 1
#DEFINE ARRIBA 2
#DEFINE ABAJO 3
#DEFINE DISPARO 4


' Llamamos a la subrutina Main para empezar
Main()


' - Subrutina principal del programa ----------------------
SUB Main()
    DIM opcion AS UByte
    
    ' Inicializamos el sistema
    Inicializar()

    ' Bucle infinito
    DO    
        CLS
        ' Imprimimos el menú y recogemos la opción seleccionada
        opcion = Menu()
        
        IF opcion = 1 THEN
            ' La opción 1 es para probar
            Probar()
        ELSE IF opcion = 2 THEN
            ' La opción 2 es para redefinir
            RedefinirTeclas()            
        END IF
    LOOP
END SUB


' - Inicializa el sistema ---------------------------------
SUB Inicializar()
    ' Establecemos los colores por defecto
    BORDER 0
    PAPER 0
    INK 6
    CLS

    ' Definimos los textos de las teclas
    TeclasS(IZQUIERDA) = "Izquierda"
    TeclasS(DERECHA)   = " Derecha "
    TeclasS(ARRIBA)    = " Arriba  "
    TeclasS(ABAJO)     = "  Abajo  "
    TeclasS(DISPARO)   = " Disparo "
END SUB


' - Muestra el menú principal y devuelve la opción seleccionada
' Devuelve:
'   UByte: Opción seleccionada: 1=Redefinir, 2=Probar
FUNCTION Menu() AS UByte    
    DIM a AS UByte
    
    CLS
    ' Imprimimos las etiquetas
    INK 5
    PRINT AT  8,5;"    Menu principal"
    PRINT AT 14,5;"Selecciona una opcion"
    ' Imprimimos las opciones
    INK 6
    
    PRINT AT 10,5;" 1. Probar"
    PRINT AT 12,5;" 2. Redefinir teclas"
    
    ' Damos vueltas hasta que se selecciona algo correcto
    DO
        IF INKEY$ <> "" THEN
            ' Convertimos la tecla en un número
            a = VAL(INKEY$)
            IF a <> 0 THEN
                ' Si es un número, lo devolvemos
                RETURN a
            END IF
        END IF
    LOOP
END FUNCTION


' - Opción "Redefinir teclas" -----------------------------
SUB RedefinirTeclas()
    DIM n AS UByte
    DIM k AS UInteger
    
    CLS
    ' Imprimimos la cabecera
    INK 5
    PRINT AT 10,5;"Pulsa una tecla para:";
    INK 6
    
    ' Para cada una de las 5 teclas
    FOR n=0 TO 4
        ' Imprimimos el nombre de la tecla
        PRINT AT 14,10;TeclasS(n);
        ' Leemos y guardamos el código de la tecla
        Teclas(n) = LeerTecla()
    NEXT n
END SUB


' - Devuelve el código de la tela pulsada -----------------
' Devuelve:
'   UInteger: Código de la tecla pulsada
FUNCTION LeerTecla() AS UInteger
    ' Declaramos k con el valor 0 por defecto
    DIM k AS UInteger = 0
    
    ' Esperamos hasta que no se pulse nada
    WHILE GetKeyScanCode() <> 0
    WEND
    
    ' Repetimos mientras no se haya pulsado una tecla
    WHILE k = 0
        ' Leemos la tecla pulsada
        k = GetKeyScanCode()        
    WEND
    
    ' Devolvemos el código de la tecla pulsada
    RETURN k
END FUNCTION


' - Opción probar teclas ----------------------------------
SUB Probar()
    DIM n AS UByte
    
    ' Imprimimos el título
    CLS
    INK 5
    PRINT AT 5,5;"Probar: ENTER para salir..."
    
    ' Bucle infinito...
    DO
        ' Escaneamos todas las teclas
        FOR n = 0 TO 4
            ' Comprobamos si la tecla del índice se ha pulsado
            IF Multikeys(Teclas(n)) THEN
                ' Si se ha pulsado, imprimimos su nombre
                PRINT AT 7+n,13;INK n+2;TeclasS(n);
            ' Si no se ha pulsado la tecla...
            ELSE
                ' Borramos el texto
                PRINT AT 7+n,13;"          ";
            END IF
        NEXT n 
        
        ' Si la tecla pulsada es la de salir, salimos
        IF MultiKeys(KEYENTER) THEN
            RETURN
        END IF
    LOOP
END SUB
