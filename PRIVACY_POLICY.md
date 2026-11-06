# Política de Privacidad — bible_app (Un capítulo al día)

*Última actualización: Noviembre 2026*

La presente Política de Privacidad describe cómo **bible_app («Un capítulo al día»)** trata la información y privacidad de sus usuarios.

---

## 1. Compromiso de Privacidad Absoluta

Creemos firmemente en el derecho a una lectura personal, reflexiva y privada de las Sagradas Escrituras. Por esta razón:

- **No recopilamos información personal**: La aplicación no solicita nombres, correos electrónicos, números de teléfono ni datos de identificación.
- **Sin creación de cuentas obligatoria**: Todas las funciones de la aplicación están disponibles de manera local sin necesidad de registrarse.
- **Sin publicidad ni rastreadores**: La aplicación no incluye bibliotecas de anuncios (AdMob, etc.), servicios de rastreo comercial ni analíticas invasivas.

---

## 2. Almacenamiento Local de Datos

Toda tu actividad devocional y de estudio permanece exclusivamente en tu dispositivo móvil:

- **Notas personales, resaltados y favoritos**: Se almacenan en la base de datos local SQLite del dispositivo mediante la biblioteca Drift.
- **Historial y planes de lectura**: El registro de capítulos leídos, rachas consecutivas y progreso de planes temáticos reside únicamente en el almacenamiento interno de tu teléfono.
- **Copia de seguridad personal**: La exportación e importación de copias de seguridad en formato JSON es una acción manual iniciada por el usuario y transferida mediante los mecanismos estándar del sistema operativo (guardar archivo, compartir por correo, etc.).

---

## 3. Conexión a Internet y Servicios Externos

La aplicación está diseñada con una arquitectura *Offline-First* (desconectada por defecto):

- **Descarga y almacenamiento en caché de textos bíblicos**: Los textos de la Biblia provienen del servicio de código abierto `bible.helloao.org` (eBible.org). Cuando abres un capítulo no descargado previamente, la aplicación realiza una petición HTTPS directa para descargar el JSON del texto bíblico y guardarlo en la caché local para siempre.
- No se envían identificadores del usuario ni del dispositivo durante estas consultas.

---

## 4. Permisos Solicitados

La aplicación solicita únicamente los permisos indispensables para su funcionamiento local:

1. **Notificaciones (`POST_NOTIFICATIONS`)**: Para enviar el recordatorio diario de lectura en el horario que configures voluntariamente.
2. **Inicio del sistema (`RECEIVE_BOOT_COMPLETED`)**: Para reprogramar tus recordatorios locales en el dispositivo tras un reinicio.
3. **Respuesta háptica (`VIBRATE`)**: Para confirmación táctil sutil al interactuar con versículos y notas.
4. **Acceso a red (`INTERNET`)**: Exclusivamente para descargar bajo demanda el texto bíblico de los capítulos solicitados desde `bible.helloao.org` (eBible.org) y guardarlos en caché local permanente.

---

## 5. Licencias y Fuentes de Textos Bíblicos

- **Santa Biblia Reina Valera Gómez (RVG)**: Publicada por la Iglesia Bautista Libertad.
- **Santa Biblia Libre para el Mundo (BLM)**: Edición Católica de 73 libros, con licencia Creative Commons Atribución-CompartirIgual 4.0 Internacional (CC BY-SA 4.0), cortesía de eBible.org.
- **Tipografías Lora e Inter**: Licenciadas bajo la SIL Open Font License (OFL).

---

## 6. Contacto y Consultas

Para cualquier duda, sugerencia o consulta sobre esta política de privacidad o sobre el funcionamiento de la aplicación, puedes abrir un issue o comunicarte a través del repositorio oficial de código abierto del proyecto.

