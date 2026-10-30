=====================================================================
  AION 2 WINGMAN 1.0                                        by VaLeTecK
  HUD overlay + herramientas de apoyo para AION 2
=====================================================================

QUÉ ES
  Un programa de AutoHotkey v2 que funciona junto a AION 2 y añade:
  - HUD overlay: mira, barras e iconos LOOT / COMBAT que se
    encienden con las señales de tus macros (F9 / F10).
  - Hidden Cube: cuando se abre la ventana de los Hidden Cube lleva el
    ratón a "Open with Key" y lo mantiene ahí.
  - Field Boss: con el mapa abierto muestra un panel con todos los jefes
    (A-Z, colores de grado, activos / inactivos). Eliges un jefe y el
    script te guía paso a paso hasta el Teleport más cercano y luego te
    indica la dirección de vuelo.
  - Ventana de Ajustes completa, presets de resolución, perfiles de
    rendimiento, 12 idiomas de interfaz y 22 temas (8 de clase, 7 festivos)
    y temas propios.

  El script NO hace clic ni pulsa teclas por ti en el juego: solo mueve
  el cursor y te indica qué hacer. Los clics los haces tú.

CONTENIDO DEL PAQUETE
  Setup AION 2 Wingman.bat   instalación del primer arranque (dependencias)
  AION 2 Wingman.ahk         el programa
  OCR.ahk                    librería OCR (la usa Field Boss)
  README\                    estas instrucciones en varios idiomas

REQUISITOS
  - Windows 10 u 11
  - AutoHotkey v2 (lo instala el setup)
  - OCR de Windows en inglés (lo instala el setup)
  - Cliente de AION 2 en inglés (Field Boss lee los nombres en inglés)

INSTALACIÓN
  1. Antes de extraer: clic derecho en el zip > Propiedades > marca
     "Desbloquear" > Aceptar. (Evita avisos de Windows.)
  2. Extrae el zip en una carpeta fija, p. ej. Documentos\AION 2 Wingman.
     NO ejecutes los archivos desde dentro del zip.
  3. Doble clic en "Setup AION 2 Wingman.bat" y acepta la solicitud de
     administrador. Comprueba e instala todo y al final puede crear un
     acceso directo en el escritorio e iniciar Wingman.
     Si aparece "Windows protegió su PC": "Más información" >
     "Ejecutar de todas formas".
     Durante el setup una configuración guiada ajusta idioma,
     resolución, rendimiento y funciones ON/OFF.
  4. Las siguientes veces inicia "AION 2 Wingman.ahk" (o el acceso
     directo). Pide permisos de administrador por sí solo: son necesarios
     para leer las teclas con el juego en primer plano.

PRIMER ARRANQUE: HAZLO PRIMERO
  - Abre los Ajustes: Ctrl+Shift+F12 (o doble clic en el icono verde
    "H" de la barra de tareas).
  - El idioma ya lo eliges en el setup (se cambia en ⚙️ General > Idioma).
  - 📦 Preset: aplica FullHD (1080p), 2K (1440p) o 4K (2160p) según tu
    pantalla, para que el HUD tenga el tamaño correcto.
  - "Guardar y reiniciar" para confirmar. Con "VISTA PREVIA EN VIVO" ves los
    cambios en tiempo real incluso sin el juego abierto.

TECLAS POR DEFECTO (se cambian en Ajustes > ⌨️ Teclas)
  Ctrl+Shift+\      HUD overlay ON/OFF
  Ctrl+Shift+1      Hidden Cube ON/OFF
  Ctrl+Shift+2      Field Boss ON/OFF
  Ctrl+Shift+F12    Ajustes (funciona también fuera del juego)
  Esc               cancela la guía de Field Boss en curso
  M / F             teclas de Mapa y Travel del juego (el script las "escucha")
  F9 / F10          señales de tus macros para el HUD (ver abajo)
  Ctrl+F11, Ctrl+Shift+F6/F7/F8   diagnóstico (solo si algo falla)
  (\ = tecla a la izquierda del 1 en teclado italiano; en otros
   teclados asigna tu propia tecla en Ajustes.)

CÓMO CONECTAR TUS MACROS AL HUD
  - Macro de combate: pon F9 en spam durante toda la macro.
  - Macro de loot: inserta F10 con una espera de 1350 ms.
  Las teclas siguen llegando al juego.

CÓMO USAR FIELD BOSS
  1. Abre el mapa (M). Arriba aparece la leyenda de teclas y a la
     derecha el panel de jefes (filtros de grado/estado, ▲/▼ para
     plegarlo).
  2. Haz clic en un jefe del panel. Empieza la guía por pasos: el ratón
     se coloca (y se bloquea) en el punto correcto y abajo aparece la
     instrucción grande "PASO n". Tú haces clic.
  3. Tras el clic en el Teleport pulsa F dos veces (Travel). El ratón se
     desbloquea y arriba aparece una flecha con la dirección del jefe.
  Esc cancela en cualquier momento.

PROBLEMAS FRECUENTES
  - No pasa nada en el juego: el script solo funciona con AION2.exe en
    primer plano. Comprueba el icono "H" en la barra de tareas.
  - Field Boss "no disponible": falta OCR.ahk en la carpeta o el OCR
    inglés de Windows. Vuelve a ejecutar el setup.
  - HUD demasiado grande/pequeño o desplazado: aplica el preset correcto.
  - Antivirus que bloquea el script: falso positivo habitual con
    AutoHotkey; añade la carpeta a las exclusiones.
  - Si algo se rompe tras un cambio: junto al script está la copia de
    seguridad "AION 2 Wingman.ahk.bak".

ACTUALIZACIONES Y AJUSTES PERSONALES
  Para actualizar basta con sobrescribir el script: tus ajustes
  (también lista de jefes y presets) se guardan en %AppData%\AION 2 Wingman
  y se restauran solos al primer arranque. Para empezar de cero,
  borra esa carpeta.

MANTENIMIENTO Y CIERRE
  Ajustes > 🛠️ Mantenimiento: vuelve a ejecutar la instalación guiada y
  abre la carpeta de Wingman y la de los ajustes personales.
  El botón rojo "⏻ Cerrar Wingman" de arriba cierra todo el programa,
  no solo la ventana de ajustes.
  La casilla 🔍 sobre el menú busca entre todos los ajustes.

DESINSTALAR
  Cierra Wingman ("⏻ Cerrar Wingman" o icono "H" > Exit), borra la carpeta y el acceso
  directo. AutoHotkey se desinstala desde Configuración de Windows >
  Aplicaciones.

CRÉDITOS Y AVISO
  AION 2 Wingman - by VaLeTecK.
  OCR.ahk - by Descolada (github.com/Descolada/OCR)
  AION 2 es una marca de sus respectivos propietarios; este proyecto no
  está afiliado ni aprobado por ellos. Es una herramienta externa:
  úsala bajo tu responsabilidad y respetando los términos del juego.
