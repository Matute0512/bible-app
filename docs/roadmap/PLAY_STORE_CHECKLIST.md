# PLAY STORE CHECKLIST — bible_app 1.0

Guía técnica y regulatoria exhaustiva para la publicación exitosa de `bible_app` en Google Play Console, distinguiendo entre requisitos de cumplimiento obligatorio y recomendaciones de calidad de producto.

---

## 1. Requisitos Obligatorios (Bloqueantes para Publicación)

### 1.1 Identificador de Aplicación y Firma de Release
- [ ] **`applicationId` definitivo**:
  - Actualmente establecido en `dev.matute.bible_app` ([`android/app/build.gradle.kts:34`](file:///d:/Dev/Portafolio/Dart/bible_app/android/app/build.gradle.kts#L34)).
  - Debe confirmarse antes de la primera subida a Play Console. Una vez creado el registro en la consola, no puede ser modificado.
- [ ] **Configuración de Firma de Producción (Play App Signing)**:
  - Reemplazar la firma de depuración por defecto (`signingConfig = signingConfigs.getByName("debug")` en [`build.gradle.kts:46`](file:///d:/Dev/Portafolio/Dart/bible_app/android/app/build.gradle.kts#L46)).
  - Crear un almacén de claves `upload-keystore.jks` fuera del árbol de control de versiones o referenciado mediante un archivo local `android/key.properties` (ignorado en `.gitignore`).

### 1.2 SDK Objetivo y Arquitectura de 16 KB (Android 15+)
- [ ] **Target SDK**:
  - Asegurar `compileSdk = 35` y `targetSdk = 35` (Android 15) en [`build.gradle.kts`](file:///d:/Dev/Portafolio/Dart/bible_app/android/app/build.gradle.kts).
- [ ] **Compatibilidad con páginas de memoria de 16 KB**:
  - Google Play exige que los binarios nativos sean compatibles con páginas de 16 KB para dispositivos con Android 15+.
  - La dependencia recomendada `sqlite3_flutter_libs` ya incorpora binarios compilados con soporte de alineación ELF de 16 KB en sus versiones recientes.

### 1.3 Permisos de Sistema en `AndroidManifest.xml`
- [ ] **Auditoría de Permisos Declarados** ([`android/app/src/main/AndroidManifest.xml`](file:///d:/Dev/Portafolio/Dart/bible_app/android/app/src/main/AndroidManifest.xml)):
  - `android.permission.INTERNET`: Necesario para descargar capítulos desde el CDN de `bible.helloao.org`.
  - `android.permission.POST_NOTIFICATIONS`: Requerido a partir de Android 13 (API 33) para los recordatorios diarios.
  - `android.permission.RECEIVE_BOOT_COMPLETED`: Necesario para reprogramar las notificaciones locales al reiniciar el dispositivo.
  - `android.permission.VIBRATE`: Permite respuesta háptica en recordatorios y selección de versículos.
  - **Revisar `WAKE_LOCK`**: Evaluar si puede suprimirse si `flutter_local_notifications` no lo requiere de forma indispensable en modo `inexactAllowWhileIdle`.
  - **No declarar `SCHEDULE_EXACT_ALARM`**: La aplicación emplea alarmas no exactas tolerantes al modo reposo (*inexact inexactAllowWhileIdle*), evitando la necesidad de justificar un permiso de alta sensibilidad ante Google Play.

### 1.4 Atribución Legal y Licencias de Textos Bíblicos (Crítico)
- [ ] **Santa Biblia Reina Valera Gómez (`spa_rvg`)**:
  - Texto protegido por derechos de autor (© 2004–2023 Dr. Humberto Gómez Caballero / eBible.org).
  - La licencia prohíbe modificaciones del texto y exige inclusión de la nota de copyright explícita en la pantalla de información de la aplicación.
  - *Alternativa*: Si se requiere texto de dominio público absoluto, migrar al identificador `spa_r09` (*Reina Valera 1909*).
- [ ] **Santa Biblia libre para el mundo (`spa_blm`)**:
  - Licencia **Creative Commons Atribución-CompartirIgual 4.0 Internacional (CC BY-SA 4.0)**.
  - Exige atribuir a eBible.org y proveer enlace a la licencia dentro de la app.
- [ ] **Licencias de Fuentes Tipográficas**:
  - `Lora` e `Inter` se distribuyen bajo la licencia **SIL Open Font License 1.1 (OFL)**. Debe incluirse el texto de la licencia en la sección de créditos o assets de la app.

### 1.5 Privacidad y Declaración de Seguridad de los Datos (Data Safety)
- [ ] **URL pública de Política de Privacidad (HTTPS)**:
  - Google Play exige un enlace público accesible a la Política de Privacidad, tanto en la ficha de la tienda como dentro de la aplicación.
- [ ] **Formulario de Seguridad de los Datos en Play Console**:
  - Declarar que **la aplicación no recopila ni comparte datos personales con terceros**.
  - No hay inicio de sesión, ni almacenamiento en servidores remotos, ni seguimiento analítico publicitario. Toda la información personal (anotaciones, historial de lectura, planes) reside de forma local en el dispositivo del usuario.

### 1.6 Activos Gráficos Obligatorios para la Ficha de la Tienda
- [ ] **Icono de la aplicación en alta resolución**:
  - $512 \times 512\text{ px}$, formato PNG de 32 bits, peso máximo de 1024 KB.
- [ ] **Icono adaptativo de Android**:
  - Implementación en `res/mipmap-anydpi-v26/` con capas separadas de `foreground` y `background` respetando la estética *Contemporary Editorial Codex*.
- [ ] **Gráfico de funciones (*Feature Graphic*)**:
  - $1024 \times 500\text{ px}$, formato JPG o PNG de 24 bits sin transparencia.
- [ ] **Capturas de pantalla para teléfonos**:
  - Mínimo 4 capturas de pantalla con resolución mínima de $1080 \times 1920\text{ px}$ (ratio 16:9 o 9:16) mostrando las pantallas principales:
    1. Dashboard devocional con lectura del día y progreso real.
    2. Lector bíblico con versículo resaltado en tema Marfil / Sepia.
    3. Hoja modal de estudio y notas personales.
    4. Grafo de conexiones teológicas o explorador de libros.

---

## 2. Requisitos Recomendados (Calidad de Producción y Retención)

### 2.1 Rendimiento y Experiencia de Usuario
- [ ] **Empaquetado offline de fuentes (`assets/fonts/`)**:
  - Evita parpadeos tipográficos o fallas de renderizado si el usuario abre la app por primera vez sin conectividad.
- [ ] **Pruebas de accesibilidad y escalado de texto**:
  - Verificar que con el tamaño de fuente interno en `1.3x` sumado al escalado de texto de accesibilidad del sistema Android al `130%`, no se produzcan desbordamientos (`RenderFlex overflowed`) en títulos ni en la barra de navegación.
- [ ] **Optimización del peso del paquete con R8**:
  - Configurar reglas de ofuscación y reducción de código en `android/app/proguard-rules.pro` para mantener el bundle final por debajo de $18\text{ MB}$.

### 2.2 Preservación de Datos del Usuario
- [ ] **Copia de seguridad local (JSON Backup)**:
  - Al no utilizar cuentas en la nube, incluir en Ajustes un botón para exportar e importar las notas, favoritos e historial en un archivo JSON legible para transferirlo fácilmente a otro teléfono.
- [ ] **Prueba de ciclo de vida de la aplicación**:
  - Verificar que al cerrar la app desde la multitarea o tras un reinicio del sistema, el último versículo visualizado y el estado de la racha permanezcan intactos.

### 2.3 Proceso de Publicación en Play Console
- [ ] **Cuestionario de Clasificación de Contenido (IARC)**:
  - Completar el cuestionario indicando ausencia de violencia, lenguaje explícito o contenido inapropiado (apto para todo público / PEGI 3 / Everyone).
- [ ] **Declaración sobre Ausencia de Publicidad**:
  - Marcar en la consola que la aplicación **no contiene anuncios publicitarios**.
- [ ] **Prueba Cerrada (Closed Testing)**:
  - Para cuentas personales de desarrollador registradas con posterioridad a noviembre de 2023, cumplir con el requisito de someter la aplicación a una prueba cerrada con al menos 12 evaluadores durante 14 días consecutivos antes de solicitar el pase a producción.

