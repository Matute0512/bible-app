# IMPLEMENTATION PLAN — bible_app 1.0

Este plan sigue los lineamientos de las skills `incremental-implementation` y `test-driven-development`. Cada fase se divide en incrementos verticales delgados y completamente verificables mediante pruebas automatizadas y análisis estático antes de avanzar al siguiente.

---

## Resumen de Fases

```text
Fase 0: Higiene Arquitectónica, Tipografía Offline y Modularización (P0)
  ├── Inc 0.1: Fuentes locales Lora/Inter y normalización de nombres de libros
  └── Inc 0.2: Desacoplamiento de ReadingScreen y SettingsSheet (+ switch notificaciones)

Fase 1: Persistencia Local con Drift y Lectura Offline-First (P0)
  ├── Inc 1.1: Configuración de AppDatabase (Drift SQLite + FTS5)
  └── Inc 1.2: BibleRepository Offline-First y navegación libre Anterior/Siguiente

Fase 2: Historial de Lectura, Racha y Progreso Real por Canon (P0)
  └── Inc 2.1: Registro de capítulos leídos, progreso 66 vs 73 libros y racha diaria

Fase 3: Favoritos, Resaltados y Menú Contextual de Versículo (P0)
  └── Inc 3.1: Interacción con versículos, paleta de 4 colores y notas personales

Fase 4: Búsqueda Global FTS5, Guardados y Navegación Shell (P0)
  ├── Inc 4.1: Pantallas SavedScreen y SearchScreen (búsqueda FTS5 instantánea)
  └── Inc 4.2: AppShellScreen (Bottom Navigation), modo inmersivo y grafo desacoplado

Fase 5: Diferenciadores Editoriales: Compartir Imágenes y Planes Temáticos (P1)
  ├── Inc 5.1: Generador de imágenes de versículos con RepaintBoundary y share_plus
  └── Inc 5.2: Planes temáticos curados y pestaña de estudio/estadísticas

Fase 6: Hardening, Licencias y Release para Google Play Store (P0)
  └── Inc 6.1: Atribuciones legales, backup JSON local y generación de bundle firmado
```

---

## Detalle de Incrementos por Fase

### Fase 0 — Higiene Arquitectónica, Tipografía Offline y Modularización

#### Incremento 0.1: Fuentes locales `Lora`/`Inter` y normalización de nombres de libros
1. **Objetivo**: Garantizar el funcionamiento visual idéntico sin conexión a Internet desde el primer arranque, eliminar excepciones de red en tests y unificar el casing de libros.
2. **Funcionalidades incluidas**:
   - Descarga e inclusión de archivos `.ttf` de `Lora` e `Inter` en `assets/fonts/`.
   - Registro de fuentes en `pubspec.yaml` y desactivación de descargas remotas en `GoogleFonts`.
   - Helper `TextNormalizer` y propiedad `BibleBook.displayName` para convertir nombres en MAYÚSCULAS de `spa_blm` a Title Case editorial.
3. **Justificación de prioridad**: Resuelve H6 y H9; asegura un entorno de test limpio y sin fallos de red.
4. **Dependencias previas**: Ninguna.
5. **Archivos a crear**: `assets/fonts/*.ttf`, `assets/fonts/OFL.txt`, `lib/utils/text_normalizer.dart`, `test/text_normalizer_test.dart`.
6. **Archivos a modificar**: [`pubspec.yaml`](file:///d:/Dev/Portafolio/Dart/bible_app/pubspec.yaml), [`lib/main.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/main.dart), [`lib/models/bible_book.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/models/bible_book.dart).
7. **Cambios en modelos/servicios/providers/UI**: `BibleBook.displayName` expone el nombre normalizado para encabezados y listas.
8. **Impacto en persistencia**: Ninguno.
9. **Pruebas necesarias**: Tests unitarios de normalización de cadenas de libros; verificar que `flutter test` termine con cero errores de carga de fuentes.
10. **Criterios de aceptación**: Todos los tests pasan sin peticiones a `fonts.gstatic.com`; los títulos de libros en `spa_blm` se muestran en formato editorial.
11. **Riesgos y mitigación**: Tamaño del APK/AAB $\rightarrow$ incluir solo pesos utilizados (Regular, SemiBold, Italic) sumando $<600\text{ KB}$.
12. **Complejidad estimada**: **Baja (S)**.

#### Incremento 0.2: Desacoplamiento de `ReadingScreen`, `SettingsSheet` y `VerseConnectionService`
1. **Objetivo**: Reducir [`reading_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart) de 1.150 a $<550$ líneas, separar lógica de UI en servicios y corregir la gestión de permisos de notificaciones.
2. **Funcionalidades incluidas**:
   - Extraer `SettingsSheet`, `VerseListItem` y `ChapterHeader` a archivos independientes.
   - Añadir `SwitchListTile` para activar/desactivar notificaciones dentro de `SettingsSheet`.
   - Condicionar la solicitud de permisos al valor de `notificationsEnabled`.
   - Extraer iconos de UI fuera de [`verse_connections_service.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/services/verse_connections_service.dart).
3. **Justificación de prioridad**: Resuelve H7 y H8 antes de introducir nuevas hojas modales al lector.
4. **Dependencias previas**: Incremento 0.1.
5. **Archivos a crear**: `lib/widgets/reader/settings_sheet.dart`, `lib/widgets/reader/verse_list_item.dart`, `lib/widgets/reader/chapter_header.dart`.
6. **Archivos a modificar**: [`lib/screens/reading_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart), [`lib/screens/dashboard_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/dashboard_screen.dart), [`lib/services/verse_connections_service.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/services/verse_connections_service.dart), [`lib/widgets/graph_explorer.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/widgets/graph_explorer.dart).
7. **Cambios en modelos/servicios/providers/UI**: `SettingsSheet` conmuta `UserPreferencesNotifier.setNotificationsEnabled`.
8. **Impacto en persistencia**: Usa la clave existente `pref_notifications_enabled` en `SharedPreferences`.
9. **Pruebas necesarias**: Widget test verificando interacción con el switch de notificaciones y montaje limpio de `ReadingScreen`.
10. **Criterios de aceptación**: Archivos menores a 600 líneas; `flutter analyze` 0 warnings; tests existentes en verde.
11. **Riesgos y mitigación**: Actualizar rutas de import en [`regression_test.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/test/regression_test.dart).
12. **Complejidad estimada**: **Baja (S)**.

---

### Fase 1 — Persistencia Local con Drift y Lectura Offline-First

#### Incremento 1.1: Configuración de `AppDatabase` (Drift SQLite + FTS5)
1. **Objetivo**: Integrar la base de datos relacional tipada con soporte para tablas de catálogo, contenido bíblico, búsqueda FTS5, notas e historial.
2. **Funcionalidades incluidas**:
   - Esquema inicial con tablas `CachedBooks`, `CachedChapters`, `CachedVerses`, `FtsVerses`, `VerseAnnotations`, `ReadingHistory`, `ReadingProgressState` y `UserReadingPlans`.
   - Generación de código con `drift_dev` y `build_runner`.
3. **Justificación de prioridad**: Base estructural indispensable para todas las funcionalidades posteriores.
4. **Dependencias previas**: Fase 0.
5. **Archivos a crear**: `lib/database/app_database.dart`, `lib/database/app_database.g.dart`, `lib/database/daos/bible_cache_dao.dart`, `lib/providers/database_provider.dart`, `test/database/bible_cache_dao_test.dart`.
6. **Archivos a modificar**: [`pubspec.yaml`](file:///d:/Dev/Portafolio/Dart/bible_app/pubspec.yaml) (agregar `drift`, `sqlite3_flutter_libs`, `path_provider`, `drift_dev`, `build_runner`).
7. **Cambios en modelos/servicios/providers/UI**: `databaseProvider` con soporte para base de datos en memoria en pruebas (`NativeDatabase.memory()`).
8. **Impacto en persistencia**: Creación del archivo `bible_app.sqlite` en el almacenamiento privado del sandbox.
9. **Pruebas necesarias**: Test unitario de inserción y consulta en `BibleCacheDao` en memoria.
10. **Criterios de aceptación**: Inserciones y consultas completan en $<10\text{ ms}$; FTS5 operativo.
11. **Riesgos y mitigación**: Configuración de `sqlite3.dll` en Windows test runner $\rightarrow$ usar `sqlite3_flutter_libs` correctamente configurado.
12. **Complejidad estimada**: **Media (M)**.

#### Incremento 1.2: `BibleRepository` Offline-First y Navegación Secuencial
1. **Objetivo**: Almacenar automáticamente libros y capítulos al ser leídos y habilitar la navegación secuencial `Anterior / Siguiente` en lectura libre.
2. **Funcionalidades incluidas**:
   - `BibleRepository` que consulta primero la base local SQLite antes de ir a la red.
   - Guardado automático de capítulos descargados e indexación en FTS5.
   - Navegación secuencial universal entre capítulos en modo libre (`FreeReadingLoaded`).
   - Distintivo visual de capítulo disponible sin conexión en [`ExploreScreen`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/explore_screen.dart).
3. **Justificación de prioridad**: Resuelve H1 y H5 y entrega la **Feature D**.
4. **Dependencias previas**: Incremento 1.1.
5. **Archivos a crear**: `lib/repositories/bible_repository.dart`, `lib/providers/bible_repository_provider.dart`, `test/repositories/bible_repository_test.dart`.
6. **Archivos a modificar**: [`lib/providers/reading_plan_provider.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/providers/reading_plan_provider.dart), [`lib/screens/explore_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/explore_screen.dart), [`lib/screens/reading_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart).
7. **Cambios en modelos/servicios/providers/UI**: `DailyReadingNotifier` interactúa con el repositorio; `goToChapter` opera con la lista local de libros.
8. **Impacto en persistencia**: Poblado de tablas `CACHED_BOOKS`, `CACHED_CHAPTERS` y `CACHED_VERSES`.
9. **Pruebas necesarias**: Test de lectura offline simulando desconexión de red tras una descarga exitosa; test de avance secuencial de fin de libro (ej. Génesis 50 $\rightarrow$ Éxodo 1).
10. **Criterios de aceptación**: La app navega por capítulos cacheados en modo avión sin arrojar excepciones.
11. **Riesgos y mitigación**: Peticiones duplicadas simultáneas $\rightarrow$ control con mapa de llamadas en vuelo (*in-flight requests*).
12. **Complejidad estimada**: **Media (M)**.

---

### Fase 2 — Historial de Lectura, Racha y Progreso Real por Canon

#### Incremento 2.1: Registro de Lecturas, Cánones 66 vs 73 y Racha Diaria
1. **Objetivo**: Sustituir el cálculo ficticio de progreso por el conteo exacto de capítulos completados, calculando el porcentaje según la traducción activa y manteniendo la racha.
2. **Funcionalidades incluidas**:
   - `HistoryDao` y `ReadingHistoryRepository`.
   - `ChapterCompletionCard` con botón para marcar/desmarcar capítulo leído + auto-registro por scroll y tiempo.
   - Muestra en [`DashboardScreen`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/dashboard_screen.dart) de porcentaje real, racha de días y tarjeta «Continuar última lectura».
3. **Justificación de prioridad**: Resuelve H3 y entrega la **Feature B**.
4. **Dependencias previas**: Fase 1.
5. **Archivos a crear**: `lib/database/daos/history_dao.dart`, `lib/models/reading_history_entry.dart`, `lib/repositories/history_repository.dart`, `lib/providers/history_providers.dart`, `lib/widgets/reader/chapter_completion_card.dart`, `test/repositories/history_repository_test.dart`.
6. **Archivos a modificar**: [`lib/screens/reading_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart), [`lib/screens/dashboard_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/dashboard_screen.dart), [`lib/screens/explore_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/explore_screen.dart).
7. **Cambios en modelos/servicios/providers/UI**: `readingStatsProvider` emite estadísticas calculadas en tiempo real desde SQLite.
8. **Impacto en persistencia**: Registros en `READING_HISTORY` y `READING_PROGRESS_STATE`.
9. **Pruebas necesarias**: Test de avance de días sin leer manteniendo el progreso en 0%; test de conteo canónico exacto: 1.189 capítulos en RVG y 1.326 en BLM; cálculo de rachas continuas y reiniciadas.
10. **Criterios de aceptación**: El usuario puede marcar/desmarcar capítulos y el Dashboard refleja el avance real.
11. **Riesgos y mitigación**: Desfasajes de zona horaria $\rightarrow$ almacenar la fecha en formato ISO local `YYYY-MM-DD`.
12. **Complejidad estimada**: **Media (M)**.

---

### Fase 3 — Favoritos, Resaltados y Menú Contextual de Versículo

#### Incremento 3.1: Interacción con Versículos, Paleta de 4 Colores y Notas
1. **Objetivo**: Permitir seleccionar versículos para resaltar en 4 tonos editoriales, marcar favoritos y redactar notas personales, preservando las marcas al cambiar de traducción.
2. **Funcionalidades incluidas**:
   - Extensión de tema con 4 colores accesibles en [`BibleReadingStyle`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/theme/bible_theme.dart#L11-L97).
   - Menú contextual `VerseActionSheet` y formulario `NoteEditorSheet`.
   - Renderizado de versículos resaltados y marcas de favoritos en `VerseListItem`.
3. **Justificación de prioridad**: Resuelve H4 y entrega el núcleo de las **Features A y F**.
4. **Dependencias previas**: Fase 1.
5. **Archivos a crear**: `lib/database/daos/study_dao.dart`, `lib/models/verse_annotation.dart`, `lib/repositories/study_repository.dart`, `lib/providers/study_providers.dart`, `lib/widgets/reader/verse_action_sheet.dart`, `lib/widgets/reader/note_editor_sheet.dart`, `test/repositories/study_repository_test.dart`.
6. **Archivos a modificar**: [`lib/theme/bible_theme.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/theme/bible_theme.dart), `lib/widgets/reader/verse_list_item.dart`, [`lib/screens/reading_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart).
7. **Cambios en modelos/servicios/providers/UI**: Toque de versículo abre `VerseActionSheet`; el grafo de conexiones se accede desde el encabezado o AppBar.
8. **Impacto en persistencia**: Tabla `VERSE_ANNOTATIONS` indexada por coordenadas bíblicas.
9. **Pruebas necesarias**: Test de persistencia agnóstica de traducción (anotar en RVG y cambiar a BLM); test de contraste WCAG AA en los 4 tonos.
10. **Criterios de aceptación**: Resaltado y guardado instantáneo sin parpadeos en el lector.
11. **Riesgos y mitigación**: Actualizar los tests de regresión que asociaban el toque de versículo al grafo.
12. **Complejidad estimada**: **Media (M)**.

---

### Fase 4 — Búsqueda Global FTS5, Guardados y Navegación Shell

#### Incremento 4.1: Pantallas `SavedScreen` y `SearchScreen` con Descarga Opcional
1. **Objetivo**: Espacio central para consultar y organizar anotaciones personales y motor de búsqueda FTS5 con opción de descarga de traducción completa.
2. **Funcionalidades incluidas**:
   - `SavedScreen` con filtros para favoritos, colores de resaltado y notas.
   - `SearchScreen` con búsqueda instantánea $<50\text{ ms}$, resaltado de coincidencias y salto directo al versículo en el lector.
   - Descarga opcional de `complete.simple.json` ejecutada en un `Isolate`.
3. **Justificación de prioridad**: Entrega la **Feature C** y consolida la colección de estudio.
4. **Dependencias previas**: Fases 1, 2 y 3.
5. **Archivos a crear**: `lib/screens/saved_screen.dart`, `lib/screens/search_screen.dart`, `lib/providers/search_providers.dart`, `test/screens/search_and_saved_test.dart`.
6. **Archivos a modificar**: [`lib/services/bible_api_service.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/services/bible_api_service.dart), [`lib/repositories/bible_repository.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/repositories/bible_repository.dart).
7. **Cambios en modelos/servicios/providers/UI**: `BibleSearchProvider` con debounce de $250\text{ ms}$.
8. **Impacto en persistencia**: Inserción batch en `CACHED_VERSES` y tabla virtual `FtsVerses`.
9. **Pruebas necesarias**: Búsqueda insensible a tildes (`fe`, `espiritu`); navegación desde resultado al versículo.
10. **Criterios de aceptación**: Búsqueda en 31.102 versículos responde en $<50\text{ ms}$ sin tirones de UI.
11. **Riesgos y mitigación**: Bloqueo del hilo UI durante la indexación masiva $\rightarrow$ uso estricto de `Isolate.run()`.
12. **Complejidad estimada**: **Media-Alta (M/L)**.

#### Incremento 4.2: `AppShellScreen` (Bottom Navigation) y Modo Lectura Inmersivo
1. **Objetivo**: Integrar la navegación inferior de 4 destinos editoriales y dotar al lector de pantalla completa inmersiva.
2. **Funcionalidades incluidas**:
   - `StatefulShellRoute` en [`router.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/router.dart) para `Inicio`, `Biblia`, `Guardados` y `Estudio`.
   - Lector bíblico fuera de la barra inferior con ocultamiento automático al hacer scroll.
   - Migración del grafo a `assets/data/verse_connections.json`.
3. **Justificación de prioridad**: Completa las mejoras de UX de la **Sección 4** y desacopla el grafo.
4. **Dependencias previas**: Incremento 4.1.
5. **Archivos a crear**: `lib/screens/app_shell_screen.dart`, `assets/data/verse_connections.json`.
6. **Archivos a modificar**: [`lib/router.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/router.dart), [`lib/screens/reading_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart), [`lib/services/verse_connections_service.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/services/verse_connections_service.dart), [`test/router_test.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/test/router_test.dart).
7. **Cambios en modelos/servicios/providers/UI**: Navegación persistente entre pestañas sin recargas innecesarias.
8. **Impacto en persistencia**: Ninguno.
9. **Pruebas necesarias**: Router tests verificando cambio entre pestañas y aislamiento del lector.
10. **Criterios de aceptación**: Objetivos táctiles $\ge 48\times 48\text{ dp}$; modo inmersivo fluido a 60 fps.
11. **Riesgos y mitigación**: Pérdida de estado al conmutar pestañas $\rightarrow$ `StatefulShellRoute.indexedStack` lo preserva.
12. **Complejidad estimada**: **Media (M)**.

---

### Fase 5 — Diferenciadores Editoriales: Compartir Imágenes y Planes Temáticos

#### Incremento 5.1: Generador de Imágenes de Versículos (`Feature G`)
1. **Objetivo**: Crear y compartir postales tipográficas de versículos con estética *Contemporary Editorial Codex* mediante el menú nativo de Android.
2. **Funcionalidades incluidas**:
   - `VerseShareSheet` con vista previa en vivo y 3 plantillas (Marfil, Pergamino, Noche).
   - Captura en memoria con `RepaintBoundary` y compartición con `share_plus`.
3. **Justificación de prioridad**: Aporta alto valor visual y difusión orgánica.
4. **Dependencias previas**: Fase 3.
5. **Archivos a crear**: `lib/services/verse_image_service.dart`, `lib/widgets/share/verse_share_sheet.dart`, `lib/widgets/share/editorial_verse_card_canvas.dart`, `test/widgets/verse_share_sheet_test.dart`.
6. **Archivos a modificar**: [`pubspec.yaml`](file:///d:/Dev/Portafolio/Dart/bible_app/pubspec.yaml) (agregar `share_plus`), `lib/widgets/reader/verse_action_sheet.dart`.
7. **Cambios en modelos/servicios/providers/UI**: Opción *«Compartir como imagen»* en `VerseActionSheet`.
8. **Impacto en persistencia**: Archivos temporales PNG autolimpiables.
9. **Pruebas necesarias**: Widget test verificando ausencia de overflow tipográfico en textos largos.
10. **Criterios de aceptación**: Imagen generada en $<400\text{ ms}$; integración correcta con el intent de Android.
11. **Riesgos y mitigación**: Versículos muy extensos $\rightarrow$ escalado dinámico de tamaño tipográfico según longitud.
12. **Complejidad estimada**: **Baja-Media (S/M)**.

#### Incremento 5.2: Planes Temáticos Curados y Pestaña de Estudio (`Feature E`)
1. **Objetivo**: Añadir planes de 21 y 30 días con progreso independiente y visualización del historial en la pestaña de Estudio.
2. **Funcionalidades incluidas**:
   - Catálogo `assets/data/reading_plans.json` con 4 planes.
   - Pestaña `PlansScreen` y administración de estados de planes.
3. **Justificación de prioridad**: Entrega la **Feature E** y enriquece la 4.ª pestaña de navegación.
4. **Dependencias previas**: Fases 2 y 4.
5. **Archivos a crear**: `assets/data/reading_plans.json`, `lib/models/reading_plan_definition.dart`, `lib/screens/plans_screen.dart`, `lib/providers/thematic_plans_provider.dart`, `test/providers/thematic_plans_test.dart`.
6. **Archivos a modificar**: `lib/database/daos/history_dao.dart`, [`lib/screens/dashboard_screen.dart`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/dashboard_screen.dart).
7. **Cambios en modelos/servicios/providers/UI**: Visualización de planes activos e historial por fecha.
8. **Impacto en persistencia**: Tabla `USER_READING_PLANS`.
9. **Pruebas necesarias**: Test de avance en plan temático sin alterar el plan diario anual.
10. **Criterios de aceptación**: Progreso e historial persistidos y visualmente claros.
11. **Riesgos y mitigación**: Pasajes de planes no disponibles en un canon $\rightarrow$ usar pasajes de los 66 libros comunes.
12. **Complejidad estimada**: **Media (M)**.

---

### Fase 6 — Hardening, Licencias y Release para Google Play Store

#### Incremento 6.1: Atribuciones Bíblicas, Respaldo Local y Bundle de Producción
1. **Objetivo**: Cumplir todos los requisitos legales, de licencias textuales y técnicos de Google Play para publicar la versión `1.0.0+1`.
2. **Funcionalidades incluidas**:
   - `AboutLicensesScreen` con atribuciones completas de RVG/RV09, BLM (CC BY-SA 4.0), fuentes SIL OFL y política de privacidad.
   - Exportación/Importación de copia de seguridad local en JSON.
   - Configuración de firma release (`key.properties`), icono adaptativo y reglas ProGuard/R8.
3. **Justificación de prioridad**: Resuelve H2 y desbloquea la publicación en Google Play Console.
4. **Dependencias previas**: Fases 0 a 5.
5. **Archivos a crear**: `lib/screens/about_licenses_screen.dart`, `PRIVACY_POLICY.md`.
6. **Archivos a modificar**: [`android/app/build.gradle.kts`](file:///d:/Dev/Portafolio/Dart/bible_app/android/app/build.gradle.kts), [`android/app/src/main/AndroidManifest.xml`](file:///d:/Dev/Portafolio/Dart/bible_app/android/app/src/main/AndroidManifest.xml), [`pubspec.yaml`](file:///d:/Dev/Portafolio/Dart/bible_app/pubspec.yaml), `lib/widgets/reader/settings_sheet.dart`.
7. **Cambios en modelos/servicios/providers/UI**: Opción de exportar/importar datos en Ajustes y pantalla de licencias accesible.
8. **Impacto en persistencia**: Serialización/deserialización JSON de tablas de usuario.
9. **Pruebas necesarias**: Smoke test de export/import de backup; compilación exitosa de `flutter build appbundle --release`.
10. **Criterios de aceptación**: `flutter analyze` 0 issues; tests 100% en verde; archivo `.aab` generado y firmado.
11. **Riesgos y mitigación**: Rechazo en Play Console $\rightarrow$ cumplimiento riguroso del checklist oficial.
12. **Complejidad estimada**: **Baja-Media (S/M)**.

