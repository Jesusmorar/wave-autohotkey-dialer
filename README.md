# 📞 AutoMarcarWave: Marcador Automatizado para Grandstream Wave desde Excel Online

Un script en **AutoHotkey v2** diseñado para optimizar el flujo de llamadas telefónicas a estudiantes y contactos desde bases de datos en Excel Online hacia el softphone **Grandstream Wave Desktop**, agregando automáticamente el prefijo de país (`+57`) y gestionando el foco de la interfaz.

---

## 👨‍🏫 Contexto y Motivación

En mi labor como docente en una **Institución de Educación Superior (IES)**, una de las actividades clave y más recurrentes es el seguimiento académico y contacto directo con los estudiantes. Frecuentemente gestionamos estas listas a través de hojas de cálculo colaborativas en **Excel Online**.

El proceso tradicional requería:
1. Buscar al estudiante en la base de datos de Excel Online.
2. Copiar manualmente su número de teléfono.
3. Abrir la ventana de **Grandstream Wave Desktop**.
4. Escribir manualmente el indicativo de país (`57` para Colombia), ya que la troncal SIP lo exige para llamadas salientes.
5. Pegar o digitar el resto del número y presionar el botón de llamada.

Repetir esta rutina decenas de veces al día no solo consumía tiempo valioso de tutoría y docencia, sino que incrementaba el cansancio visual y la posibilidad de errores de digitación. Por esta necesidad nació **AutoMarcarWave**: una solución ágil que permite realizar la marcación completa con solo posicionarse en la celda del estudiante y pulsar **`F2`**.

---

## ⚡ ¿Cómo funciona?

1. Te ubicas en cualquier celda de **Excel Online** que contenga el teléfono del estudiante.
2. Presionas la tecla **`F2`**.
3. El script automáticamente:
   - Espera a que sueltes la tecla para evitar colisiones en el navegador.
   - Copia el contenido de la celda al portapapeles.
   - Limpia caracteres no numéricos (espacios, guiones, paréntesis).
   - Valida si el número ya tiene el indicativo; si le falta, le antepone el `57`.
   - Activa y restaura la ventana de **Wave Desktop**.
   - Ejecuta una **secuencia de estabilización de foco** para posicionar el cursor exactamente en el campo *"Enter name or number"*.
   - Sobrescribe cualquier número previo, pega el nuevo teléfono y presiona `Enter` para iniciar la llamada de audio inmediatamente.

---

## 🛠️ Retos Técnicos y Soluciones Durante el Desarrollo

Automatizar la interacción entre una aplicación web en el navegador (Excel Online) y un softphone moderno de escritorio (Wave Desktop, desarrollado en Electron/Chromium) presentó desafíos interesantes que requirieron un análisis minucioso:

### 1. El conflicto de copiado en Excel Online (Bloqueo del Portapapeles)
* **El reto:** En las primeras versiones, Excel Online arrojaba el error: *"Hubo un error al momento de copiar el texto"*, o el script reportaba que el portapapeles estaba vacío.
* **La causa:** Al presionar `F2`, el dedo del usuario mantenía presionada la tecla física durante 50 a 150 ms. Al disparar `Ctrl+C` sintético en ese instante, Windows interpretaba una colisión de teclas (`Ctrl + F2 + C`), bloqueando el evento de JavaScript del navegador. Además, limpiar el portapapeles (`A_Clipboard := ""`) inmediatamente antes de copiar creaba una condición de carrera con la API del navegador.
* **La solución:** 
  - Uso del prefijo `$F2::` junto con `KeyWait "F2"`, que detiene la ejecución hasta que la tecla física ha sido completamente liberada.
  - Liberación preventiva de modificadores (`Send "{Ctrl up}{Alt up}{Shift up}"`) y tiempos de espera controlados (`ClipWait(2)`).

### 2. Regla Inteligente para el Indicativo Internacional (`57`)
* **El reto:** Evitar duplicar el prefijo si el número ya venía con formato internacional (por ejemplo `573001234567`), pero asegurar que números fijos o celulares de diferentes longitudes recibieran el indicativo sin excepción.
* **La solución:** Se diseñó una validación matemática clara:
  ```autohotkey
  if !(SubStr(num, 1, 2) = "57" && StrLen(num) >= 12)
      num := "57" . num
  ```
  Solo se considera que el indicativo ya existe si el número comienza por `57` **y** tiene 12 o más dígitos (`57` + 10 dígitos del celular). De lo contrario, se garantiza la adición del `57`.

### 3. El reto del foco en Wave: El fenómeno de la lista resaltada en azul
* **El reto:** El script funcionaba en la primera llamada, pero al desplazarse al siguiente estudiante en la lista, Wave abría la ventana y **subrayaba en azul toda la lista de llamadas recientes** sin marcar el número.
* **La causa:** Wave es una aplicación basada en Chromium/Electron. Al finalizar una llamada, la interfaz retira automáticamente el foco del campo de marcación y lo traslada al contenedor del historial (*Recent Calls*). Cuando el script enviaba `Send "^a"` para limpiar el campo anterior, Chromium interpretaba un *"Seleccionar todo"* de la página web, iluminando en azul todo el historial y dejando el campo de marcación vacío e inactivo.
* **La solución (Secuencia de Preparación del Foco):**
  Desarrollamos una secuencia ordenada para garantizar que el foco regrese al marcador antes de escribir:
  1. `Send "{Esc}"`: Cancela cualquier selección activa que haya quedado resaltada en el historial.
  2. `Send "^3"`: Atajo interno de Wave para forzar la navegación al módulo de llamadas (`/recentCalls`).
  3. `Send "^+f"` (`Ctrl + Shift + F`): Atajo nativo de Wave Desktop que emite el evento interno `openSearch`, el cual ejecuta directamente `focus()` sobre el campo `<input class="number-input">` (*Enter name or number*).
  4. Una vez garantizado el cursor en el campo de texto, `Send "^a"` selecciona limpiamente el número anterior, `Send "^v"` pega el nuevo y `Send "{Enter}"` dispara la llamada de audio.

---

## 📋 Requisitos

* **Sistema Operativo:** Windows 10 o Windows 11.
* **AutoHotkey:** Versión **v2.0** o superior ([Descargar AutoHotkey](https://www.autohotkey.com/)).
* **Grandstream Wave Desktop:** Instalado y en ejecución con sesión iniciada.
* **Navegador Web:** Edge, Chrome o Firefox con la hoja de Excel Online abierta.

---

## 🚀 Instalación y Uso

1. Clona este repositorio o descarga el archivo [`AutoMarcarWave.ahk`](./AutoMarcarWave.ahk):
   ```bash
   git clone https://github.com/Jesusmorar/wave-autohotkey-dialer.git
   ```
2. Haz doble clic sobre `AutoMarcarWave.ahk` para iniciar el script (aparecerá el icono verde de AutoHotkey en la bandeja del sistema).
3. Abre tu base de datos en Excel Online.
4. Haz clic en la celda que contiene el número de teléfono del estudiante y presiona **`F2`**.
5. ¡Listo! Wave tomará el foco y comenzará la llamada con el prefijo `57` automáticamente.

---

## 📄 Licencia

Este proyecto está distribuido bajo la licencia MIT. Siéntete libre de adaptarlo o mejorarlo para las necesidades de marcación de tu propia institución o empresa.
