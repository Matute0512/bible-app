# TECHNICAL AUDIT — bible_app Estado Actual

**Fecha de auditoría:** Noviembre 2026  
**Entorno evaluado:** Flutter 3.x / Dart 3.x sobre Windows (Android Target)  
**Herramientas aplicadas:** `flutter analyze`, `flutter test`, inspección estática de árbol de dependencias y código fuente, `graphify`.

---

## 1. Métricas de Salud del Repositorio

- **Análisis estático (`flutter analyze`)**:  
  `No issues found!` (0 errores, 0 advertencias, 0 sugerencias en 3.4 s).
- **Suite de pruebas automáticas (`flutter test`)**:  
  `28/28 tests passing` distribuidos en 5 archivos:
  - [`data_layer_smoke_test.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/test/data_layer_smoke_test.dart) (4 tests): Parseo de libros y capítulos desde JSON de `bible.helloao.org`, filtro de 73 libros católicos.
  - [`providers_test.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/test/providers_test.dart) (9 tests): `UserPreferencesProvider`, inicialización de `DailyReadingNotifier`, avance de capítulos y manejo de errores.
  - [`regression_test.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/test/regression_test.dart) (9 tests): Opacidad de versículos en [`ReadingScreen`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart), soporte de temas y contrastes, manifest Android.
  - [`router_test.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/test/router_test.dart) (5 tests): Redirección de onboarding vs dashboard por fecha de instalación.
  - [`verse_connections_test.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/test/verse_connections_test.dart) (1 test): Integridad del grafo de conexiones teológicas.

---

## 2. Hallazgos Críticos y Limitaciones Técnicas

### H1. Inexistencia de Caché Persistente en Disco (Severidad: Crítica)
- **Problema**: El documento funcional asume que la app ya dispone de *"Caché de libros por traducción"*. La auditoría constata que **no existe persistencia en disco de libros ni de capítulos**.
- **Evidencia**:
  - [`booksProvider`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/explore_screen.dart#L10-L15) es un `FutureProvider.autoDispose`, lo que significa que el listado de libros se destruye tan pronto como el usuario sale de [`ExploreScreen`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/explore_screen.dart).
  - En [`DailyReadingNotifier`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/providers/reading_plan_provider.dart#L57), `_cachedPlan` reside únicamente en la memoria volátil de la instancia.
  - Al abrir la app en modo avión, `ReadingPlanService.buildPlan` llama a `BibleApiService.fetchBooks` por HTTP, lanzando `BibleApiException` e impidiendo el renderizado del `DashboardScreen` y del lector.

### H2. Discrepancia de Traducciones y Riesgo de Licencias (Severidad: Crítica)
- **Problema**: La interfaz de usuario muestra *"Reina Valera 1909"* y *"Biblia Latinoamericana"*, pero la API `bible.helloao.org` conecta con:
  - `spa_rvg` = **Santa Biblia Reina Valera Gómez** (© 2004–2023 Dr. Humberto Gómez Caballero, eBible.org, sujeta a restricciones de atribución y prohibición de modificación).
  - `spa_blm` = **Santa Biblia libre para el mundo** (© 2022 eBible.org, licencia Creative Commons BY-SA 4.0).
- **Riesgo en Google Play**: Publicar la app atribuyendo erróneamente un texto bíblico contemporáneo protegido como si fuera una traducción histórica de dominio público genera riesgo de reclamos de propiedad intelectual y rechazo de tienda.
- **Inconsistencia tipográfica**: En `spa_blm`, los nombres de los 66 libros protocanónicos vienen en MAYÚSCULAS (`"GÉNESIS"`, `"SAN MATEO"`) y los 7 deuterocanónicos en Title Case (`"Tobit"`, `"Judit"`).

### H3. Progreso Ficticio Basado en Días Calendario (Severidad: Alta)
- **Problema**: En [`DashboardScreen`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/dashboard_screen.dart#L60-L64), el progreso se calcula con `progressFraction = (todayIndex + 1) / totalChapters`.
- **Efecto colateral**: Si un usuario instala la app y no la abre en 6 meses, al reabrirla la barra indica 50% de lectura completada sin haber leído un solo versículo. No existe registro de capítulos leídos ni historial.

### H4. Bloqueo de Interacción de Versículos por el Grafo (Severidad: Alta)
- **Problema**: En [`ReadingScreen`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart#L390-L396), la propiedad `onTap` de [`VerseListItem`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart#L1058) está vinculada directamente a abrir [`GraphExplorerWidget`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/widgets/graph_explorer.dart).
- **Incompatibilidad**: Las conexiones bíblicas en [`VerseConnectionService`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/services/verse_connections_service.dart#L105) están indexadas por **capítulo** (`BOOK:CHAPTER`), no por versículo individual. Este diseño impide seleccionar versículos para resaltados, notas o favoritos.

### H5. Lectura Libre con Navegación Secuencial Rota (Severidad: Alta)
- **Problema**: Al abrir un libro y capítulo específico desde [`ExploreScreen`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/explore_screen.dart), el notifier entra en el estado [`FreeReadingLoaded`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/providers/reading_plan_provider.dart#L29-L39). En dicho estado:
  - `goToChapter(+1/-1)` es un no-op intencional en el código.
  - La barra inferior sustituye los botones de navegación secuencial por *"Lectura de hoy"* y *"Cambiar libro"*. El usuario no puede pasar al siguiente capítulo del libro de forma natural.

### H6. Fuentes No Empaquetadas y Falla en Modo Avión (Severidad: Media)
- **Problema**: El paquete `google_fonts: ^8.2.1` en [`pubspec.yaml`](file:///d:/Dev/Portafolio/Dart/bible_app/pubspec.yaml) solicita las fuentes `Lora` e `Inter` vía HTTP a `fonts.gstatic.com` en tiempo de ejecución.
- **Evidencia en tests**: Durante la ejecución de `flutter test`, la consola arroja repetidas excepciones: `Failed to load font with url: https://fonts.gstatic.com/...`. En un primer arranque sin red, la app degrada a la tipografía del sistema.

### H7. Acoplamiento y Archivos Monolíticos (Severidad: Media)
- **Problema**: Violación de límites de mantenibilidad en módulos de interfaz:
  - [`lib/screens/reading_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart): **1.150 líneas**. Contiene la pantalla del lector, `_ChapterHeader`, `_NavAction`, `SettingsSheet` (líneas 717–1056) y `VerseListItem` (líneas 1058–1150).
  - [`lib/widgets/graph_explorer.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/widgets/graph_explorer.dart): **1.042 líneas** en un solo archivo de widgets y pintores de canvas.
  - [`lib/services/verse_connections_service.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/services/verse_connections_service.dart): **714 líneas** con datos teológicos en código duro e importa `package:flutter/material.dart` en la capa de servicios de dominio.

### H8. Bug de Permisos y Ajustes de Notificación Incompletos (Severidad: Media)
- **Problema**:
  - [`ReadingScreen.initState`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart#L39) ejecuta `_requestNotificationPermission()` en cada montaje de pantalla sin verificar si el usuario tiene `notificationsEnabled == false`.
  - En [`SettingsSheet`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart#L984), el usuario puede configurar la hora de la notificación, pero **no existe un interruptor (Switch)** para encender o apagar las alertas.

---

## 3. Capacidades Reales de la API Remota (`bible.helloao.org`)

Tras auditar las respuestas y metadatos de la API en `test/fixtures/spa_rvg_books.json`:
1. **Ausencia de endpoint de búsqueda**: La API es un CDN estático de archivos JSON. No cuenta con endpoints de búsqueda tipo `/api/search?q=...`.
2. **Endpoints de traducción completa**:
   - `/api/{translation}/complete.simple.json`: archivo consolidado que incluye los 66 o 73 libros en un único JSON simplificado.
3. **Control de integridad mediante hash SHA-256**:
   - Cada libro y traducción cuenta con una clave `"sha256"` y `"translation.sha256"`. Esto habilita invalidación de caché y control de versiones sin descargar datos innecesarios.

