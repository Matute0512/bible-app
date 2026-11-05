# Especificación de Diseño y Activos para Google Play Store · Lectura Bíblica

Este documento describe la arquitectura de diseño, tokens de color, tipografía y especificaciones de exportación para la ficha oficial de **Lectura Bíblica** en Google Play Console y Figma.

---

## 1. Tokens de Identidad y Color (*Contemporary Editorial Codex*)

| Token | Hex | Uso en la Ficha y Activos |
| :--- | :--- | :--- |
| **Deep Liturgical Indigo** | `#1E1A2E` / `#161224` | Fondo de pantallas promocionales, marco del icono y Feature Graphic. |
| **Gilded Amber / Gold** | `#D4A017` / `#F5C542` | Acentos de estrellas (`✦`), cinta marcapáginas, barras de progreso y bordes. |
| **Parchment White** | `#FDFBF7` | Hojas del códice, tarjetas de versículo (modo Marfil) y textos principales. |
| **Sepia Warm Cream** | `#F3EBDD` / `#EBDDC3` | Fondo de lectura en modo Sepia y texturas de papiro. |
| **Olive Green** | `#556B2F` | Resaltador secundario y marcadores teológicos de paz. |
| **Terracotta Warm** | `#C85A32` | Resaltador de versículos y advertencias doctrinales. |
| **Muted Cream** | `#C8BFB0` / `#CFC5B4` | Subtítulos y textos de soporte en fondos oscuros. |

---

## 2. Tipografía Editorial

- **Títulos y Citas Bíblicas**: *Lora* (Serifa editorial inspirada en tipos clásicos de imprenta).
- **Interfaz, Rótulos y Tags**: *Inter* (Sans-serif humanista con excelente legibilidad en pantallas móviles).
- **Emblemas Litúrgicos**: Símbolos geométricos dorados (`✦`, `❖`, `✓`).

---

## 3. Inventario de Activos Generados

Todos los archivos listos para producción se encuentran en el proyecto:

### A. Gráficos Principales (`assets/store_assets/`)
1. **Icono de la Aplicación** (`icon_512.png` y `icon_512.svg`):
   - **Dimensiones**: $512 \times 512$ px (PNG de 32 bits con canal alfa).
   - **Contenido**: Códice iluminado con páginas de pergamino, cinta dorada, estrella litúrgica y borde dorado sobre fondo Deep Indigo.
2. **Gráfico de Funciones / Feature Graphic** (`feature_graphic_1024x500.png` y `feature_graphic_1024x500.svg`):
   - **Dimensiones**: $1024 \times 500$ px exactos (Requisito estricto de Google Play).
   - **Contenido**: Tipografía Lora dorada, propuesta de valor (*«Un capítulo al día · Avanzá a tu ritmo por las Escrituras»*), badges de valor (*100% Desconectada*, *Sin Anuncios*, *Privacidad Total*) y mockup 3D del lector en modo Sepia.

### B. Capturas de Pantalla Promocionales Enmarcadas (`assets/store_assets/framed_screenshots/`)
Resolución nativa: **$1080 \times 2400$ px** (proporción 9:20):
1. `promo_01_dashboard.png`: *«Un Capítulo al Día · Avanzá a tu propio ritmo con racha y planes temáticos»*
2. `promo_02_reader_sepia.png`: *«Lectura Inmersiva · Tipografía clásica, modo sepia y resaltado de versículos»*
3. `promo_03_share_card.png`: *«Compartí la Palabra · Generá tarjetas elegantes para tus redes y mensajes»*
4. `promo_04_plans_catalog.png`: *«Planes Temáticos · Salmos, Juan, Proverbios y fortaleza en la tormenta»*
5. `promo_05_study_graph.png`: *«Grafo de Conexiones · Descubrí relaciones bíblicas, profecías y paralelismos»*

### C. Capturas de Pantalla en Crudo del Emulador (`assets/store_screenshots/`)
Capturas limpias tomadas directamente desde el emulador Android Pixel 7 en español con SystemUI Demo Mode activo:
1. `01_dashboard.png` ($1080 \times 2400$)
2. `02_reader_sepia.png` ($1080 \times 2400$)
3. `03_share_card.png` ($1080 \times 2400$)
4. `04_plans_catalog.png` ($1080 \times 2400$)
5. `05_study_graph.png` ($1080 \times 2400$)

---

## 4. Cómo Importar y Trabajar en Figma

Tu cuenta de Figma (`matitorres@uade.edu.ar`) está conectada a través de Composio:
1. Abrí [Figma](https://www.figma.com/) o la aplicación de escritorio.
2. Arrastrá los archivos vectoriales `assets/store_assets/icon_512.svg` y `feature_graphic_1024x500.svg` directamente a un lienzo nuevo.
3. Se importarán todas las capas vectoriales separadas (trazos del códice, cinta dorada, estrellas, gradientes y tipografías editables).
4. Si creás un archivo de Figma y compartís la URL, el agente puede leer los identificadores de nodos (`FIGMA_GET_FILE_JSON` y `FIGMA_RENDER_IMAGES_OF_FILE_NODES`) para sincronizar cambios directamente.
