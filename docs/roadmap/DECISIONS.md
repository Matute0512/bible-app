# ARCHITECTURAL DECISION RECORDS (ADRs) — bible_app 1.0

Registro estructurado de decisiones técnicas y arquitectónicas adoptadas para la evolución hacia `bible_app 1.0`.

---

## ADR-001: Selección de Drift (SQLite) como Motor de Persistencia Relacional y Caché

### Estado
**Aceptado**

### Contexto
La aplicación requiere persistir en disco el catálogo de libros, capítulos leídos, versículos individuales, anotaciones del usuario (favoritos, resaltados, notas), historial de lectura y soporte para búsqueda de texto completo insensible a diacríticos sobre más de 31.000 versículos. Actualmente, la app solo utiliza `SharedPreferences` para almacenar preferencias clave-valor (`UserPreferences`) y mantiene los libros en memoria RAM efímera.

Se evaluaron tres opciones:
1. **Extender `SharedPreferences`**: Inviable; requeriría serializar y deserializar cadenas JSON gigantescas en RAM, sin capacidades de indexación, ordenamiento ni búsqueda eficiente.
2. **Isar / Hive (NoSQL)**: `Isar` ha presentado problemas de mantenimiento en el ecosistema Dart 3 y riesgos de incompatibilidad binaria con las páginas de memoria de 16 KB exigidas en Android 15+.
3. **Drift (`drift` + `sqlite3_flutter_libs`)**: Solución madura, tipada y con soporte nativo para SQLite, tablas virtuales FTS5, transacciones seguras y compatibilidad demostrada con Android 15+.

### Decisión
Adoptar una **arquitectura de persistencia dual**:
1. Conservar `SharedPreferences` exclusivamente para preferencias ligeras del sistema (`UserPreferences`, hora de notificación, flag de onboarding).
2. Incorporar `Drift` (`AppDatabase`) como motor de base de datos local para almacenar libros, capítulos cacheados, versículos, anotaciones personales, historial de lectura y la tabla virtual FTS5 para búsqueda global.

### Consecuencias
- **Positivas**: Búsquedas instantáneas en $<20\text{ ms}$, integridad referencial, soporte para flujos reactivos mediante `StreamProvider` de Riverpod y migraciones de esquema tipadas y testeables.
- **Negativas / Mitigaciones**: Requiere paso de generación de código (`drift_dev` / `build_runner`). Se mitiga aislando la base de datos tras DAOs y repositorios limpios y proveyendo implementaciones en memoria (`NativeDatabase.memory()`) para pruebas unitarias.

---

## ADR-002: Modelo Canónico de Anotaciones e Historial Agnóstico de Traducción

### Estado
**Aceptado**

### Contexto
La aplicación permite al usuario alternar entre dos traducciones bíblicas con cánones distintos: Reina Valera (66 libros) y Santa Biblia libre para el mundo (edición católica de 73 libros). Si las anotaciones (favoritos, colores de resaltado, notas) y el historial de lectura se acoplan al identificador de la traducción en curso, el usuario perdería todas sus marcas al cambiar de traducción.

### Decisión
Indexar todas las anotaciones del usuario y los registros de lectura en base a la coordenada lógica canónica:
$$\text{Clave Canónica} = (\text{book\_id}, \text{chapter\_number}, \text{verse\_number})$$
utilizando los identificadores estándar USFM de 3 letras (`GEN`, `EXO`, `MAT`, `ROM`, etc.).
Adicionalmente, se almacena una instantánea del texto original (`verse_text_snapshot`) y la traducción de origen (`origin_translation_id`) como respaldo histórico.

### Consecuencias
- **Positivas**: Las anotaciones realizadas en un versículo (ej. `JUAN 3:16`) persisten y se visualizan de inmediato al cambiar entre traducciones.
- **Manejo de Casos Borde**: Para los 7 libros deuterocanónicos presentes únicamente en la edición católica (`TOB`, `JDT`, `WIS`, `SIR`, `BAR`, `1MA`, `2MA`), si el usuario cambia a la traducción protestante, las notas y favoritos siguen siendo accesibles en la pestaña de Guardados acompañados de una insignia editorial informativa.

---

## ADR-003: Búsqueda Global Híbrida Mediante FTS5 sin Backend Propietario

### Estado
**Aceptado**

### Contexto
La propuesta de valor de `bible_app` rechaza la dependencia de servidores propios para preservar la privacidad y la gratuidad del producto. La API pública utilizada (`https://bible.helloao.org/api`) es un CDN de archivos JSON estáticos y carece de un endpoint de búsqueda remota por palabra clave.

### Decisión
Implementar un motor de búsqueda local basado en la extensión **SQLite FTS5**:
1. Crear una tabla virtual `fts_verses` sincronizada mediante disparadores (*triggers*) con la tabla de versículos cacheados.
2. Normalizar el texto almacenado en el índice mediante minúsculas y remoción de tildes/diacríticos (`remove_diacritics`).
3. Ofrecer en la interfaz la descarga opcional de la traducción completa (`complete.simple.json`, ~1,5 MB comprimido) para indexar en segundo plano la totalidad de los 31.102 versículos dentro de un `Isolate.run()`.

### Consecuencias
- **Positivas**: Búsquedas a toda velocidad ($<50\text{ ms}$), operativas completamente sin conexión y con costo de infraestructura cero.
- **Negativas / Mitigaciones**: El primer proceso de indexación de la Biblia completa toma entre 1,5 y 2 segundos; se ejecuta obligatoriamente en un worker Isolate secundario para no generar caídas de frames en la interfaz.

---

## ADR-004: Desacoplamiento del Gesto de Versículo y el Grafo de Conexiones

### Estado
**Aceptado**

### Contexto
En la implementación actual, tocar cualquier versículo en `ReadingScreen` abre la hoja modal del grafo interactivo `GraphExplorerWidget`. Sin embargo, el grafo contiene conexiones indexadas a nivel de **capítulo**, lo que causa confusión y bloquea por completo la posibilidad de seleccionar versículos para resaltarlos, guardarlos como favoritos o añadirles notas personales.

### Decisión
1. Reasignar el gesto de toque simple y pulsación larga sobre un versículo a la apertura de `VerseActionSheet` (menú de estudio personal: resaltar, favorito, nota, copiar, compartir).
2. Mantener y visibilizar el acceso al grafo interactivo mediante tres puntos de entrada claros:
   - El botón de red teológica en el `AppBar` del lector.
   - El chip con el conteo de conexiones en el encabezado del capítulo (`_ChapterHeader`).
   - Un botón de acción secundaria dentro de `VerseActionSheet` (*«Explorar conexiones del capítulo»*).

### Consecuencias
- **Positivas**: Se habilita la interacción natural de estudio bíblico sin perder el acceso al grafo de conexiones teológicas.

---

## ADR-005: Generación Nativa de Imágenes con `RepaintBoundary` sin Paquetes Externos de Captura

### Estado
**Aceptado**

### Contexto
Para la funcionalidad de compartir versículos como imágenes (Feature G), se evaluó si convenía incorporar dependencias pesadas de captura de pantalla o renderizado HTML/canvas externo.

### Decisión
Utilizar la capacidad nativa de Flutter a través del widget `RepaintBoundary` y su método `RenderRepaintBoundary.toImage(pixelRatio: 3.0)`:
1. Componer la tarjeta editorial mediante widgets convencionales de Flutter respetando el diseño *Contemporary Editorial Codex*.
2. Capturar el mapa de bits como PNG en memoria utilizando `dart:ui`.
3. Guardar el archivo de imagen temporalmente vía `path_provider` y delegar su distribución a `share_plus`.

### Consecuencias
- **Positivas**: Cero dependencias nativas complejas adicionales, control milimétrico de la tipografía y colores de la tarjeta, y excelente fidelidad gráfica a resolución retina ($1080 \times 1350\text{ px}$).

