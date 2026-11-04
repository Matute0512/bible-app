# FEATURE SPECIFICATIONS — bible_app 1.0

Este documento contiene las especificaciones funcionales, flujos de usuario, diseño de interacción y reglas de negocio para cada funcionalidad de `bible_app 1.0`.

---

## 1. Feature A: Favoritos, Marcadores y Resaltado de Versículos

### 1.1 Flujo e Interacción de Usuario
- **Selección de Versículo**:
  - Al tocar o mantener presionado un versículo en [`ReadingScreen`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart), el versículo resalta su borde lateral y se despliega suavemente desde la parte inferior la hoja modal `VerseActionSheet`.
  - El usuario puede tocar versículos adicionales para selección múltiple si desea aplicar la misma acción (ej. resaltar 3 versículos seguidos).
- **Acciones Rápidas en `VerseActionSheet`**:
  - **Selector de Color de Resaltado**: Fila horizontal con 4 círculos cromáticos editoriales + botón de borrador (remover resaltado).
  - **Favorito / Marcador**: Icono de cinta de lectura (`bookmark`). Alterna estado con retroalimentación háptica ligera.
  - **Nota Personal**: Abre la hoja de redacción `NoteEditorSheet`.
  - **Copiar Versículo**: Copia al portapapeles en formato limpio:  
    `«Texto del versículo» — Libro Capítulo:Versículo (Traducción)`
  - **Compartir**: Opciones para compartir como texto plano o generar tarjeta de imagen editorial (Feature G).
  - **Ver Conexiones Bíblicas**: Acceso directo al grafo temático del capítulo actual (`GraphExplorerWidget`).

### 1.2 Paleta de Resaltados Editoriales (Contemporary Editorial Codex)
Los 4 tonos están calibrados en [`BibleReadingStyle`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/theme/bible_theme.dart#L11-L97) para garantizar legibilidad WCAG AA ($\ge 4.5:1$) en temas Claro, Sepia y Oscuro:
1. **Ocre Dorado (`ochre`)**: Promesas divinas, alabanza y sabiduría.
2. **Oliva Salvia (`olive`)**: Crecimiento, paz, consolación y oración.
3. **Terracota Suave (`terracotta`)**: Advertencias, profecías y exhortaciones.
4. **Índigo Códice (`indigo`)**: Doctrina, cristología y versículos fundacionales.

---

## 2. Feature B: Historial de Lectura y Progreso Real

### 2.1 Desacoplamiento de Calendario vs Lectura Real
- **Capítulo del Día (Plan Calendario)**: Determina la lectura recomendada según la fórmula `daysElapsed % totalChapters`. Sugiere el texto de hoy pero **no** modifica el porcentaje de avance de la Biblia.
- **Capítulo Leído (`READING_HISTORY`)**: Evento concreto registrado en base de datos local con fecha ISO `YYYY-MM-DD` y marca de tiempo.

### 2.2 Reglas para Registrar un Capítulo como Leído
Para evitar registros accidentales al hojear rápidamente:
1. **Acción Explícita (Primaria)**: Al final de la lista de versículos de cada capítulo, se muestra la tarjeta editorial `ChapterCompletionCard` con el botón **«Marcar capítulo como leído»**. Al pulsarlo, el botón cambia a **«Capítulo completado ✓»** con opción inmediata de desmarcar.
2. **Asistencia Automática por Scroll y Tiempo**: Si el usuario permanece en la pantalla por al menos **25 segundos**, realiza scroll vertical cubriendo más del **85% del texto** y presiona `Siguiente →`, el capítulo se marca como leído automáticamente y se despliega un `SnackBar` sutil con opción de `Deshacer`.

### 2.3 Cálculo de Progreso por Canon Bíblico
- **Canon Protestante (RVG / RV09)**: $66\text{ libros} = 1.189\text{ capítulos}$.
  $$\text{Progreso} = \frac{|\text{Capítulos únicos leídos en Canon}_{66}|}{1.189} \times 100\%$$
- **Canon Católico (BLM)**: $73\text{ libros} = 1.189 + 137\text{ (deuterocanónicos)} = 1.326\text{ capítulos}$.
  $$\text{Progreso} = \frac{|\text{Capítulos únicos leídos en Canon}_{73}|}{1.326} \times 100\%$$

### 2.4 Cálculo de Racha Diaria (Streak)
- Días calendario locales continuos con al menos 1 capítulo completado.
- Si el usuario completó lecturas ayer y aún no ha leído hoy, la racha se mantiene en espera durante el día en curso sin reiniciarse hasta que expire la medianoche local.

---

## 3. Feature C: Búsqueda Global de la Biblia

### 3.1 Motor FTS5 Local sin Dependencia de Backend
- Al carecer la API de endpoint de búsqueda remota, la búsqueda se ejecuta sobre la tabla virtual SQLite `fts_verses` gestionada por Drift con soporte de normalización `remove_diacritics`.
- Búsquedas insensibles a mayúsculas, minúsculas y tildes (`fe`, `amor`, `espiritu` $\rightarrow$ encuentra `Espíritu`, `espíritu`).

### 3.2 Experiencia de Usuario en `SearchScreen`
- Campo de entrada con retardo de rebote (*debounce*) de $250\text{ ms}$.
- Selector de filtros rápidos: `Todos`, `Antiguo Testamento`, `Nuevo Testamento`, `Deuterocanónicos`.
- Lista virtualizada de resultados con:
  - Referencia bíblica completa (`Juan 1:1`).
  - Fragmento textual con la palabra o frase buscada destacada visualmente con fondo sutil y negrita.
  - Al pulsar un resultado, la app navega a [`ReadingScreen`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/reading_screen.dart) y realiza un scroll automático animado hasta el versículo seleccionado.
- **Banner de Traducción Completa**: Si el usuario no ha descargado la traducción íntegra, se informa: *«Buscando en X capítulos leídos. Descarga la traducción completa (1,5 MB) para buscar en toda la Biblia sin conexión»*.

---

## 4. Feature D: Lectura sin Conexión y Gestión de Caché

### 4.1 Comportamiento Offline
- Todo capítulo visualizado se guarda íntegramente en base de datos local SQLite.
- Cuando no hay señal de red, se presenta un distintivo editorial sobrio en la barra superior: `Sin conexión · Modo lectura local`.
- La cuadrícula de libros en [`ExploreScreen`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/screens/explore_screen.dart) marca con un punto o icono discreto los capítulos que ya están descargados y disponibles.

### 4.2 Gestión de Almacenamiento en Ajustes
- En `SettingsSheet` se incorpora una sección de **Almacenamiento Local**:
  - Muestra el número total de capítulos en disco y el peso en megabytes.
  - Botón: *Descargar traducción completa*.
  - Botón: *Vaciar caché de lectura* (elimina el texto de capítulos no marcados como favoritos, preservando intactos todos los resaltados, notas e historial).

---

## 5. Feature E: Planes de Lectura Temáticos Curados

### 5.1 Catálogo Inicial de Planes
1. **Un Capítulo al Día (Secuencial)**: El plan anual tradicional de Génesis a Apocalipsis.
2. **Conocer a Jesús (30 días)**: Recorrido cronológico por los pasajes clave de los Evangelios.
3. **Salmos para el Alma (30 días)**: Selección lírica y devocional del libro de Salmos.
4. **Fundamentos de la Fe (21 días)**: Epístolas doctrinales (Romanos, Efesios, Santiago).

### 5.2 Independencia de Progreso
- Los planes se definen en un archivo estático local `assets/data/reading_plans.json`.
- Cada plan guarda su estado independiente en la tabla `USER_READING_PLANS` (`pending`, `active`, `completed`).
- Un usuario puede tener activo el plan diario y a la vez avanzar en un plan temático sin que las lecturas de uno alteren la lógica del otro.

---

## 6. Feature F: Cuaderno de Estudio y Notas Personales (Base v1.0)

### 6.1 `NoteEditorSheet`
- Formulario modal limpio, enfocado en la escritura devocional:
  - Encabezado con la cita bíblica y texto del versículo.
  - Área de texto multilínea sin barras de herramientas complejas.
  - Selector de etiquetas rápidas opcionales: `#Oración`, `#Promesa`, `#Reflexión`, `#Estudio`.
  - Botón de guardado y marca de última modificación.

### 6.2 Pestaña de Guardados (`SavedScreen`)
- Espacio centralizado con 3 vistas filtrables:
  1. **Favoritos**: Tarjetas con versículos marcados.
  2. **Resaltados**: Lista filtrable por los 4 colores de subrayado.
  3. **Notas**: Lista de reflexiones con opción de edición rápida, copia y salto al pasaje de origen.

---

## 7. Feature G: Compartir Versículos como Imágenes Editoriales

### 7.1 Generador Visual sin Dependencias Pesadas
- Empleo del widget `RepaintBoundary` nativo de Flutter para renderizar imágenes en memoria con resolución $1080 \times 1350\text{ px}$ (ratio 4:5, ideal para compartir en mensajería y redes móviles).
- Integración con `share_plus` para disparar el diálogo de compartir nativo de Android.

### 7.2 Estilos Tipográficos Códice
1. **Marfil Clásico**: Fondo marfil `#FBF8F2`, filetes dobles en dorado antiguo, tipografía `Lora Italic` y cita en versalitas `Inter`.
2. **Pergamino Sepia**: Fondo sepia cálido `#F3EAD8`, remates florales clásicos y tinta carbón.
3. **Vigilia Nocturna**: Fondo oscuro `#12161F`, texto marfil y acentos dorados.
- Opción configurable: *«Incluir firma discreta bible_app»*.

---

## 8. Feature H: Grafo de Conexiones Bíblicas (Evolución v1.0)

### 8.1 Desacoplamiento de Interacción
- Se remueve la apertura del grafo al tocar el cuerpo del versículo para ceder ese gesto al menú de estudio.
- El grafo se consulta desde:
  - Botón de red teológica en el `AppBar` del lector.
  - Chip con el contador de conexiones en el encabezado del capítulo (`N conexiones`).
  - Botón secundario dentro de `VerseActionSheet`.

### 8.2 Catálogo Estructurado en JSON
- Migración del catálogo hardcoded de [`VerseConnectionService`](file:///d:/Dev/Portafolio/Dart/bible_app/lib/services/verse_connections_service.dart) hacia `assets/data/verse_connections.json`, enriqueciendo cada registro con:
  - `sourceChapter` y `targetChapter`.
  - `sourcePassageRef` y `targetPassageRef` específicos.
  - `connectionKind` (profecía, cumplimiento, cita, paralelo, tema compartido, contraste).
  - `theologicalNote`: Breve explicación exegética del vínculo.

---

## 9. Mejoras de Experiencia Visual y Navegación (Sección 4)

### 9.1 `AppShellScreen` (Barra de Navegación Inferior)
Barra fija en la parte inferior con 4 destinos editoriales mediante `NavigationBar` Material 3:
1. **Inicio** (`/dashboard`): Lectura diaria, reanudar última lectura, racha y acceso a guardados.
2. **Biblia** (`/explore`): Explorador de libros por testamento y acceso a la búsqueda global.
3. **Guardados** (`/saved`): Colección personal de favoritos, versículos resaltados y notas.
4. **Estudio** (`/plans`): Planes temáticos, estadísticas de lectura e historial por fecha.

### 9.2 Modo de Lectura Inmersivo en `ReadingScreen`
- El lector se abre como ruta independiente fuera de la barra de navegación inferior para maximizar el área de lectura.
- Al hacer scroll descendente, el `AppBar` y la barra de navegación entre capítulos se ocultan suavemente mediante animación. Reaparecen de inmediato con scroll ascendente o con un toque en el centro de la pantalla.

