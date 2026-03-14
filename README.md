# BorielBasicManualParaTorpes
Código fuente de los listados publicados en el libro "Boriel Basic para ZX Spectrum - Manual para torpes...y para los que no lo son tanto"

El libro se puede adquirir en Amazon en formato digital, tapa dura o tapa blanda: https://www.amazon.es/Boriel-Basic-para-ZX-Spectrum/dp/B0CQD65FXZ

Los mecenas tienen derecho a la versión en PDF y EPUB: https://www.patreon.com/DuefectuCorp


# ZX Basic Studio
Las versiones descargables de ZX Basic Studio se han movido al GitHub de Boriel en https://github.com/boriel-basic/ZXBasicStudio/releases

Gracias por vuestro apoyo!


# Cambios en versiones nuevas del compilador
Aquí comento los cambios críticos del compilador que pueden hacer que algún ejemplo no funcione.
*Versión 1.18.3 y superiores**
- El direccionamiento de los arrays y matrices ha cambiado, ahora el prefijo @ devuelve la dirección de la variable, no de los datos, por lo que para referirse al primer valor del array hay que usar "@miArray(0)" en vez de "@miArray"

  
# Fe de erratas (tapa blanda)
En esta sección iré añadiendo los fallos o aclaraciones que vayan surgiendo. Gracias por informar de ellos.
- Capítulo 12. El Beeper: En este capítulo se reporta erróneamente que el DO central tiene el valor de 12 para el tono, cuando en realidad debería ser 0, por lo que en los ejemplos del comando BEEP deberían restarse 12 unidades al valor del tono.
- Listado DBAdventure: En el fichero Main.bas la línea "#INCLUDE <retrace.bas>" debe moverse a la línea 14. Se ha actualizado el listado: https://github.com/Duefectu/BorielBasicManualParaTorpes/blob/main/7.%20La%20pantalla%20en%20el%20ZX%20Spectrum/DBAdventure/Main.bas
- Página 102: En el consejo del tito Duefectu le sobra la tilde al "porqué". La forma correcta es "Lo vuelvo a recalcar porque es muy importante"
- Página 180: Error ortográfico en "Optimization: “3”, para que se **optimice** bien el código"
- Página 180: Error ortográfico en "Ahora ya tenemos nuestro proyecto creado y configurado, **así** que vamos a empezar definiendo nuestros sprites."
- Página 185: Error tipográfico en el punto "Example of usage"
- Página 599: Hay tres "qué" que deberían llevar tilde:
```
[...] es decir, qué
pasa cuando un enemigo “me toca”, qué pasa si ataco y le doy con mi
espada a un enemigo, o qué pasa si una flecha le da a un enemigo o a un
interruptor, etc.
```
- Página 599: El primer párrafo de la sección **El mapa de memoria de nuestro juego** está cortado, debería ser:
```
Como ya he mencionado, es fundamental tener un mapa de memoria para
saber dónde tenemos cada cosa, principalmente si son recursos
externos a ZX Boriel Basic.
```
