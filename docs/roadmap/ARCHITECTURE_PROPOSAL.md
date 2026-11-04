# ARCHITECTURE PROPOSAL — bible_app 1.0

## 1. Decisión de Persistencia Local: Drift (SQLite) vs SharedPreferences vs Isar

### Análisis Comparativo

| Dimensión Técnica | SharedPreferences (Actual) | Isar / Hive (NoSQL) | **Drift + sqlite3_flutter_libs (Recomendado)** |
|---|---|---|---|
| **Consultas relacionales complejas** | Inviable (forzaría decodificar miles de JSONs en RAM) | Soporte limitado a índices manuales | **Nativo y tipado en Dart 3** (agrupaciones, joins, conteos canónicos) |
| **Búsqueda de texto completo (FTS)** | Búsqueda secuencial `contains()` (lenta en >31.000 versículos) | Sin soporte FTS estándar | **SQLite FTS5 nativo** (`unicode61 remove_diacritics 2`) con respuestas `<20 ms` |
| **Streams reactivos con Riverpod** | Polling o notificación manual | Streams propios | **Streams nativos `watch()`** que alimentan directamente `StreamProvider` |
| **Compatibilidad Android 15+ (16 KB pages)** | N/A | Problemático en NDK desactualizado de Isar | **Garantizada** mediante `sqlite3_flutter_libs` oficial |
| **Estrategia de migraciones** | Frágil | Compleja entre esquemas | **`MigrationStrategy` tipada** con suite de tests de migración |

### Arquitectura de Persistencia Dual
- **`SharedPreferences`**: Exclusivamente para configuración ligera y de arranque (`UserPreferences`, hora de notificación, ID de traducción activa, flags de onboarding).
- **`Drift` (`AppDatabase`)**: Motor relacional en disco para el catálogo de libros, caché offline de capítulos, versículos, índice FTS5, favoritos, resaltados, notas, historial de lectura y progreso de planes.

---

## 2. Modelo Relacional de Datos

```mermaid
erDiagram
    CACHED_BOOKS {
        string translation_id PK
        string book_id PK
        string name
        string normalized_name
        int chapter_count
        int book_order
        string sha256
        int updated_at_ms
    }

    CACHED_CHAPTERS {
        string translation_id PK
        string book_id PK
        int chapter_number PK
        string book_name
        string sha256
        int fetched_at_ms
    }

    CACHED_VERSES {
        string translation_id PK
        string book_id PK
        int chapter_number PK
        int verse_number PK
        string text_content
        string normalized_text
    }

    VERSE_ANNOTATIONS {
        string id PK
        string book_id
        int chapter_number
        int verse_number
        boolean is_favorite
        string highlight_color "ochre | olive | terracotta | indigo"
        string note_text
        string tags_csv
        string origin_translation_id
        string book_name_snapshot
        string verse_text_snapshot
        int created_at_ms
        int updated_at_ms
    }

    READING_HISTORY {
        int id PK
        string book_id
        int chapter_number
        string translation_id
        string reading_date_iso "YYYY-MM-DD local"
        int read_at_ms
        int duration_seconds
        string source "daily_plan | free_reading | thematic_plan"
        string plan_id
    }

    READING_PROGRESS_STATE {
        string key PK "last_read"
        string translation_id
        string book_id
        int chapter_number
        int verse_scroll_offset
        int updated_at_ms
    }

    USER_READING_PLANS {
        string plan_id PK
        string status "pending | active | completed"
        int started_at_ms
        int completed_at_ms
        string completed_days_json
    }

    CACHED_BOOKS ||--o{ CACHED_CHAPTERS : "contiene"
    CACHED_CHAPTERS ||--|{ CACHED_VERSES : "contiene"
    CACHED_CHAPTERS ||--o{ VERSE_ANNOTATIONS : "anotado en"
    CACHED_CHAPTERS ||--o{ READING_HISTORY : "registrado en"
```

### Principio de Coordenadas Agnósticas de Traducción
Las anotaciones del usuario y el historial se indexan por la tripleta lógica canónica:
$$\text{Clave Canónica} = (\text{book\_id}, \text{chapter\_number}, \text{verse\_number})$$
utilizando los códigos estándar USFM (`GEN`, `PSA`, `MAT`, `ROM`, etc.).
- Si el usuario resalta `JUAN 3:16` leyendo en `spa_rvg` y luego cambia a `spa_blm`, el resaltado permanece visible en el texto de la nueva traducción.
- En caso de libros deuterocanónicos exclusivos de `spa_blm` (`TOB`, `JDT`, etc.), al cambiar a `spa_rvg` la anotación se conserva intacta en la pantalla de Guardados con su `verse_text_snapshot` y una insignia editorial *"Disponible en edición católica"*.

---

## 3. Arquitectura en Capas y Flujo Reactivo

```mermaid
flowchart TD
    subgraph UI["Capa de Presentación (Contemporary Editorial Codex)"]
        Shell["AppShellScaffold (Barra Inferior 4 Destinos)"]
        Dashboard["DashboardScreen (Capítulo del día, Progreso real, Racha)"]
        Explore["ExploreScreen + SearchScreen (Búsqueda FTS5)"]
        Saved["SavedScreen (Favoritos, Resaltados, Notas)"]
        Plans["PlansScreen (Planes temáticos & Estadísticas)"]
        Reader["ReadingScreen (Lector Inmersivo Desacoplado)"]
    end

    subgraph State["Capa de Estado (Riverpod 3)"]
        ReaderCtrl["ReadingController"]
        HistoryNotifier["ReadingHistoryNotifier"]
        StudyNotifier["VerseAnnotationsNotifier"]
        SearchNotifier["BibleSearchNotifier"]
        ThematicPlansNotifier["ThematicPlansNotifier"]
    end

    subgraph Domain["Capa de Repositorios y Servicios"]
        BibleRepo["BibleRepository (Offline-First)"]
        HistoryRepo["ReadingHistoryRepository"]
        StudyRepo["StudyRepository"]
        SearchSvc["BibleSearchService (FTS5 + Isolate)"]
        ImageSvc["VerseImageComposerService (RepaintBoundary)"]
    end

    subgraph Data["Capa de Datos y Almacenamiento"]
        DriftDB[("AppDatabase (Drift SQLite + FTS5)")]
        ApiClient["BibleApiService (bible.helloao.org)"]
        PrefsStorage["SharedPreferences (UserPreferences)"]
        BundledAssets["Assets Locales (Fuentes TTF, Planes JSON, Grafo JSON)"]
    end

    UI --> State
    State --> Domain
    BibleRepo --> DriftDB
    BibleRepo --> ApiClient
    HistoryRepo --> DriftDB
    StudyRepo --> DriftDB
    SearchSvc --> DriftDB
    ImageSvc --> BundledAssets
    State --> PrefsStorage
```

---

## 4. Política Cache-First y Recuperación sin Conexión

1. **Consulta de Catálogo de Libros**:
   - `BibleRepository.fetchBooks(translationId)` lee de la tabla `CACHED_BOOKS`.
   - Si existen registros, devuelve los libros en tiempo de ejecución de $0\text{ ms}$.
   - En segundo plano, si hay conexión y pasaron $>7\text{ días}$, verifica `translation.sha256` para detectar posibles actualizaciones del texto.
2. **Consulta de Capítulos**:
   - `BibleRepository.fetchChapter(translationId, bookId, chapterNumber)` busca en `CACHED_CHAPTERS` y `CACHED_VERSES`.
   - Si existe en SQLite, lo entrega sin tocar la red.
   - Si no existe, descarga desde `BibleApiService`, ejecuta una inserción en lote en SQLite e indexa automáticamente en la tabla virtual FTS5.
   - **Pre-fetch proactivo**: Al abrir un capítulo con conexión activa, encola en segundo plano la descarga del capítulo siguiente ($N+1$).
3. **Descarga en Lote Opcional**:
   - Para usuarios que desean garantizar funcionamiento total sin conexión o búsqueda instantánea en los 66/73 libros, la pantalla de Ajustes y Búsqueda ofrece la opción *"Descargar traducción completa (~1,5 MB comprimido)"*.
   - El archivo `complete.simple.json` se procesa dentro de un `Isolate.run()` para no bloquear la interfaz y se persiste en una sola transacción SQLite.

