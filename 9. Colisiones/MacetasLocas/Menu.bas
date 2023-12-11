' - Macetas Locas -----------------------------------------
' - Menú del juego ----------------------------------------


' - Menú principal ----------------------------------------
SUB Menu()
    ' Variables locales
    DIM txt AS String
    DIM x AS UByte
    
    ' Borramos la pantalla
    BORDER 1
    PAPER 7
    INK 0
    CLS
    
    ' Imprimimos el título a tamaño doble
    DoubleSizeTexto(20,140,"MACETAS LOCAS")
    ' Imprimimos cuatro macetas grandes
    INK 1
    DoubleSizeSprite(10,100,@Cosas_Maceta1)
    INK 2
    DoubleSizeSprite(75,100,@Cosas_Maceta2)
    INK 3
    DoubleSizeSprite(135,100,@Cosas_Maceta3)
    INK 4
    DoubleSizeSprite(204,100,@Cosas_Regalo)
    
    ' Imprimimos el record
    INK 1
    txt = "Record: " + STR(Record)
    x = 128 - ((LEN(txt) * 16) / 2)
    DoubleSizeTexto(x,60,txt)
    
    ' Pedimos que se pulse una tecla
    INK 0
    PRINT AT 20,2;"Pulsa una tecla para empezar";
    ' Esperamos a que se pulse una tecla
    PausaTecla()
END SUB


' - Imprime un sprite de maceta al doble de su tamaño -----
SUB DoubleSizeSprite(x AS UByte, y AS UByte, _
    dir AS Integer)
    ' Primer carácter: arriba-izquierda
    DoubleSize8x8(x,y+16,dir)
    ' Abajo-izquierda
    DoubleSize8x8(x,y,dir + 8)
    ' Arriba-derecha
    DoubleSize8x8(x+16,y+16,dir + 24)
    ' Abajo-derecha
    DoubleSize8x8(x+16,y,dir + 32)
END SUB


' - Espera a que se pulse una tecla -----------------------
' Si se está pulsando una tecla al entrar, se espera a
' que se suelte, y entonces se espera a que se pulse otra
' vez una tecla
SUB PausaTecla()
    ' Esperamos mientras se esté pulsando una tecla
    WHILE INKEY$<>""
    WEND
    ' Esperamos mientras no se pulse una tecla 
    WHILE INKEY$=""
    WEND
END SUB
