' - Macetas Locas -----------------------------------------
' - Módulo de juego ---------------------------------------

' Declaramos la función "DetectarColisiones"
DECLARE FUNCTION DetectarColisiones() AS Byte


' - Módulo principal del juego ----------------------------
SUB Juego()
    ' Variables locales
    DIM c, n, macetado AS UByte
    DIM k AS String
    
    ' Iniciamos la partidas
    Juego_IniciarPartida()
    
    ' Repetiremos mientras nos queden vidas
    WHILE Vidas > 0
        ' Inicializamos el nivel
        Juego_IniciarNivel()
        ' Dibujamos el marcador (elementos fijos)
        Marcador_Dibujar()
        ' Actualizamos el marcador
        Marcador_Actualizar()
        
        ' Imprimimos el texto NIVEL
        INK 2
        DoubleSizeTexto(60,140,"NIVEL "+str(Nivel))
        ' Dibujamos las macetas a recoger
        Marcador_DibujarMacetas()
        ' Actualizamos el estado de las macetas
        Marcador_ActualizarMacetas()

        ' Esperamos a que se pulse una tecla
        PausaTecla()
        ' Movemos el texto Nivel a la izquierda
        FOR n = 0 TO 32
            WinScrollLeft(0,0,31,8)
        NEXT n
        
        ' Bucle infinito
        DO
            ' Sincronizamos con el barrido de pantalla
            waitretrace
            
            ' Impresión y movimiento del sprite
            DibujarYMoverSprite()            
            
            ' Control
            k = INKEY$
            IF k <> "" THEN
                IF k = "p" THEN
                    IF Ix<29 THEN
                        Io = 1
                    END IF
                ELSEIF k = "o" THEN
                    IF Ix>1 THEN
                        Io = 2
                    END IF
                END IF
            END IF
            
            ' Creamos una maceta, si procede
            CrearCosa()
            ' Dibujamos las macetas que caen
            DibujarCosas()
            
            ' Colisiones
            c = DetectarColisiones()           
            ' Si hay colisiones c no es 255...
            IF c <> 255 THEN
              ' Procesar colisión
              macetado = 0
              ' Comprobamos si está en la lista a recoger
              FOR n = 0 TO 7
                ' Si la maceta está en la secuencia...
                IF MacetasSecuencia(n,0) = c THEN
                    ' Si no la hemos recogido...
                    IF MacetasSecuencia(n,1) = 0 THEN
                      ' La marcamos como recogida
                      MacetasSecuencia(n,1) = 1
                      ' Sumamos 1 punto
                      Puntos = Puntos + 1
                      ' Cae una maceta menos
                      CosasCayendo = CosasCayendo - 1
                      ' Actualizamos el marcador
                      Marcador_Actualizar()
                      ' Contamos y actualizamos macetas
                     IF Marcador_ActualizarMacetas()=0 THEN
                          ' Si están todas, sube nivel
                          Nivel = Nivel + 1
                          ' Salimos del bucle infinito
                          EXIT DO
                      END IF
                      ' Si no están todas, seguimos
                      macetado = 1
                      EXIT FOR
                    END IF
                END IF
              NEXT n
              ' Si se nos ha caído una maceta que no debía
              IF macetado = 0 THEN
                  ' Una vida menos
                  Vidas = Vidas - 1
                  ' Si quedan vidas...
                  IF Vidas > 0 THEN
                      ' Imprime Muerto
                      INK 2
                      PRINT AT 5,10;"Muerto!!!";
                      ' Espera una tecla
                      PausaTecla()
                  END IF
                  ' Salimos para reiniciar el nivel
                  EXIT DO
              END IF
            END IF                               
        LOOP             
    WEND
    
    ' Si llegamos aquí es que no nos quedan vidas
    INK 2
    DoubleSizeTexto(50,140,"GAME OVER!")    
    INK 1
    DoubleSizeTexto(50,110,"Puntos:"+str(Puntos))
    ' Comprobamos si has batido el record
    IF Puntos > Record THEN
        Record = Puntos
        INK 3
        DoubleSizeTexto(40,80,"Nuevo Record")
    ELSE
        DoubleSizeTexto(40,80,"Record:"+str(Record))
    END IF
    ' Esperamos una tecla para salir
    PausaTecla()
END SUB


' - Inicializa una partida nueva --------------------------
SUB Juego_IniciarPartida()
    ' Resetea los marcadores
    Puntos = 0
    Vidas = 3
    Nivel = 0
END SUB


' - Inicializa un nuevo nivel -----------------------------
SUB Juego_IniciarNivel()
    ' Variable local
    DIM n AS UByte
    
    ' Inicializa la semilla del generador de num.aleatorios
    RANDOMIZE 0
    
    ' Resetea el estado de Ingrid
    Ix = 15
    Iy = 15
    Io = 0
    Ip = 0
    Isf = 0
    
    ' Colores por defecto
    PAPER 7
    INK 0
    CLS
    
    ' Dibujamos el suelo
    FOR n = 0 TO 30 STEP 2
        putChars(n,17,2,2,@Cosas_Suelo(0))
    NEXT n
    
    ' Reseteamos las macetas que caen
    FOR n = 0 TO COSAS_MAX
        Cosas(n,COSA_TIPO) = 0
    NEXT n
    ' Al empezar no cae nada
    CosasCayendo = 0
    
    ' Creamos una secuencia de 8 macetas a recoger
    FOR n = 0 TO 7
        ' Tipo de maceta (0 a 3)
        MacetasSecuencia(n,0) = RND * 4
        ' 0 si está pendiente de recoger, 1 recogida 
        MacetasSecuencia(n,1) = 0
    NEXT n
END SUB


' - Dibujamos y movemos el sprite de Ingrid, si procede
SUB DibujarYMoverSprite()
    ' Si estamos parados...
    IF Io = 0 THEN
        ' Dibujamos a Indgrid parada
        putChars(Ix,Iy,2,2,@Ingrid_Stand(Ip,0)) 
        ' Rellenamos con color negro
        paint(Ix,Iy,2,2,%111000)
        ' Si el contador de subframes es 10...
        IF Isf = 10 THEN
            ' Reseteamos el contador
            Isf = 0
            ' Si el frame es 0...
            IF Ip = 0 THEN
                ' Ajustamos el frame a 1
                Ip = 1
            ' Si el frame no es 0...
            ELSE
                ' Ajustamos el frame a 0
                Ip = 0
            END IF
        ' Si el contador de subframes no es 10...
        ELSE
            ' Incrementamos el contador de subFrames
            Isf = Isf +1
        END IF
    ' Si estamos caminando hacia la derecha...        
    ELSEIF Io = 1
        ' Dibujamos a Ingrid caminando a la derecha
        putChars(Ix,Iy,3,2,@Ingrid_Walk_right(Ip,0))
        ' Rellenamos con color negro
        paint(Ix,Iy,3,2,%111000)
        ' Si el frame es igual a 3...
        IF Ip = 3 THEN
            ' Reseteamos el contador de frames
            Ip = 0
            ' Detenemos el movimiento (miramos al frente)
            Io = 0
            ' Incrementamos la posición x del sprite
            Ix = Ix + 1
        ' Si el frame no es igual a 3...
        ELSE
            ' Incrementamos el contador de frames
            Ip = Ip + 1
        END IF
    ' Si estamos caminando hacia la izquierda
    ELSE
        ' Si el contador de frames es 0
        IF Ip = 0 THEN
            ' Decrementamos x
            Ix = Ix -1
        END IF
        ' Dibujamos a Ingrid caminando hacia la izquierda
        putChars(Ix,Iy,3,2,@Ingrid_Walk_left(Ip,0))
        ' Rellenamos con color negro
        paint(Ix,Iy,3,2,%111000)
        ' Si el frame es 3...
        IF Ip = 3 THEN
            ' Reseteamos el contador de frames
            Ip = 0
            ' Detenemos el movimiento (miramos al frente)
            Io = 0
        ' Si el frame no es 3...
        ELSE
            ' Incrementamos el contador de frames
            Ip = Ip + 1
        END IF
    END IF
END SUB


' - Crear una maceta nueva, si le da la gana --------------
SUB CrearCosa()
    ' Variables locales
    DIM r, n AS UByte
    
    ' El nivel determina la cantidad de macetas que
    ' caen al mismo tiempo
    ' Si puede crear una maceta...
    IF CosasCayendo <= Nivel THEN
        ' Tiramos un dado de 100 números
        r = RND * 100
        ' Si el número que ha salido es mayor de 95...
        IF r > 95 THEN
            ' Buscamos un hueco donde crear la maceta
            FOR n = 0 TO COSAS_MAX
                ' Podemos usar el elemento de la matriz si
                ' COSA_TIPO es igual a 0...
                IF Cosas(n,COSA_TIPO) = 0 THEN
                    ' Coordenada X de la maceta
                    Cosas(n,COSA_X) = (RND * 29) + 1
                    ' Coordenada Y de la maceta
                    Cosas(n,COSA_Y) = 0
                    ' Frame de la meceta a cero
                    Cosas(n,COSA_FRAME) = 0
                    ' Tipo de maceta, de 1 a 4
                    Cosas(n,COSA_TIPO) = (RND * 4) + 1
                    ' Añadimos 1 al contador de macetas
                    CosasCayendo = CosasCayendo + 1
                    RETURN
                END IF
            NEXT n
        END IF
    END IF
END SUB


' - Dibujas las macetas que van cayendo -------------------
SUB DibujarCosas()
    ' Variables locales
    DIM n, t, f, x, y AS UByte
    DIM dir AS UInteger
    
    ' Recorremos todos los elementos de la matriz "Cosas"
    FOR n = 0 TO COSAS_MAX
        ' Tipo de maceta
        t = Cosas(n,COSA_TIPO)
        ' Si el tipo es 0, no hay maceta...
        IF t <> 0 THEN
            ' Frame de la maceta
            f = Cosas(n,COSA_FRAME)
            ' Dirección del sprite a imprimir
            dir = MacetasDir(t-1) + (CAST(UInteger,f) * 48)
            ' Coordenada X
            x = Cosas(n,COSA_X)
            ' Coordenada Y
            y = Cosas(n,COSA_Y)
            ' Dibujamos la maceta
            putChars(x,y,2,3,dir)
            ' Rellenamos con el color de la maceta
            paint(x,y,2,3,t bOR %111000)
                        
            ' Si el frame de la maceta es 7...
            IF f = 7 THEN
                ' Reseteamos al frame 0
                Cosas(n,COSA_FRAME) = 0
                ' Si ha tocado el suelo...
                IF y = 14 THEN
                    ' Marcamos la maceta como libre
                    Cosas(n,COSA_TIPO) = 0
                    ' Hay una cosa cayendo menos
                    CosasCayendo = CosasCayendo -1
                    ' Borramos la maceta
                    putChars(x,13,2,2,@Cosas_Blanco)
                    putChars(x,15,2,2,@Cosas_Blanco)
                ' Si no ha tocado el suelo...
                ELSE
                    ' Incrementamos y, solo se incrementa
                    ' cada 8 frames (pixels)
                    Cosas(n,COSA_Y) = y + 1
                END IF
            ' Si el frame de la maceta no es 7...
            ELSE
                ' Incrementamos el frame de la maceta
                Cosas(n,COSA_FRAME) = f + 1
            END IF            
        END IF
    NEXT n
END SUB


' - Detectamos colisiones con las macetas -----------------
' Devuelve:
'   UByte: COSA_TIPO de la maceta que colisiona con Ingrid
FUNCTION DetectarColisiones() AS Byte
    ' Variables locales
    DIM n, t, xc1, xc2, xs1, xs2 AS UByte
    
    ' Creamos una zona de colisión para Ingrid de xs1 a xs2
    ' Pasamos de caracteres a pixels
    xs1 = Ix * 8
    ' Si estamos parados...
    IF Io = 0 THEN
        ' La zona de colisión empieza en +2
        xs1 = xs1 + 2
        ' Y termina en +11
        xs2 = xs1 + 11
    ' Si caminamos hacia la derecha...
    ELSEIF Io = 1 THEN
        ' La zona de colisión empieza en +4 + el frame x 2
        xs1 = xs1 + 4 + (Ip * 2)
        ' Y termina en +10 pixels
        xs2 = xs1 + 10
    ' Si caminamos hacia la izquierda...
    ELSE
        ' Si el frame es 0...
        IF Ip = 0 THEN
            ' La zona empieza en +1 - el frame x 2
            xs1 = xs1 + 1 - (Ip * 2)
        ' Si el frame no es 0...
        ELSE
            ' La zona empieza en +9 - el frame x 2
            xs1 = xs1 + 9 - (Ip * 2)
        END IF
        ' Y termina en +10
        xs2 = xs1 + 10
    END IF
    
    ' Examinamos todas las macetas que caen
    FOR n = 0 TO COSAS_MAX
        ' Tipo de maceta
        t = Cosas(n,COSA_TIPO)
        ' Si no es 0, está cayendo...
        IF t <> 0 THEN
            ' Si la coordenada y es mayor de 12...
            IF Cosas(n,COSA_Y) > 12 THEN
                ' Creamos un área de colisión de la maceta
                ' Pasamos COSA_X de caracteres a pixels
                xc1 = Cosas(n,COSA_X) * 8
                ' La zona de colisión termina en +16
                xc2 = xc1 + 16
                ' Si la maceta termina antes del inicio
                ' del personaje, lo descartamos
                IF xc2 < xs1 THEN CONTINUE FOR
                ' Si la maceta empieza después del final
                ' del personaje, lo descartamos
                IF xc1 > xs2 THEN CONTINUE FOR
                ' Si llegamos aquí, es que ha colisionado
                ' Paramos la caída de la maceta 
                Cosas(n,COSA_TIPO) = 0
                ' Borramos la maceta
                putChars(Cosas(n,COSA_X), _
                    Iy,2,2,@Cosas_Blanco)
                putChars(Cosas(n,COSA_X), _
                    Iy-2,2,2,@Cosas_Blanco)
                ' Dibujamos a Ingrid
                putChars(Ix,Iy,2,2,@Ingrid_Stand(0,0))
                ' Salimos con el código de la maceta-1
                RETURN t-1
            END IF
        END IF
    NEXT n
    
    ' No se ha colisionado con ninguna maceta
    RETURN 255
END FUNCTION
