# bible_app

App Android de lectura bíblica diaria (MVP). Recomienda un pasaje por día y
envía un recordatorio local a la hora elegida.

- **API**: [Free Use Bible API](https://bible.helloao.org), formato `*.simple.json`.
  Los ids de libros van en **MAYÚSCULAS** en la URL (ej. `LUK`, no `luk`).
- **Traducciones**: `spa_rvg` (evangélica, 66 libros) y `spa_blm` (católica,
  filtrada a los 73 libros del canon católico).
- **Plan de lectura**: anclado a `installationDate` (UTC). Índice del día =
  `daysElapsed % totalChapters`.

## Comandos útiles

```sh
flutter analyze              # análisis estático
dart run flutter_launcher_icons   # regenera el ícono (config en pubspec.yaml)
python tool/generate_icon.py      # redibuja el PNG del ícono/splash
flutter build apk --debug         # APK de prueba
```

## Build de release (Play Store)

### 1. Generar el keystore (una sola vez, Windows)

Desde `android/`:

```sh
keytool -genkeypair -v -keystore upload-keystore.jks -alias upload ^
  -keyalg RSA -keysize 2048 -validity 10000 -storetype JKS
```

Te pedirá contraseñas (guardalas en un gestor) y datos de identidad. El alias
`upload` y las contraseñas van en `key.properties`. **No subas el `.jks` ni
`key.properties` a git** (ya están en `.gitignore`).

### 2. Crear `android/key.properties`

```properties
storePassword=contraseña-del-keystore
keyPassword=contraseña-de-la-clave
keyAlias=upload
storeFile=upload-keystore.jks
```

> `storeFile` es relativo a `android/`. Referencia: `key.properties.example`.

### 3. Firma en `android/app/build.gradle.kts`

Ya configurado: si `key.properties` existe, `release` se firma con el keystore;
si no, cae a la clave de debug (para desarrollo). No requiere cambios.

### 4. Generar el AAB para Google Play

```sh
flutter build appbundle --release
```

Resultado: `build/app/outputs/bundle/release/app-release.aab`. Subilo a Play
Console → Testing → _Internal testing_ (o _Production_).

## Notificaciones

- Los receivers `ScheduledNotificationReceiver` y
  `ScheduledNotificationBootReceiver` están declarados en `AndroidManifest.xml`
  (requeridos por `flutter_local_notifications` desde v16; sin ellos la
  programación "tiene éxito" pero nada se dispara).
- Se usa `AndroidScheduleMode.inexactAllowWhileIdle` + `DateTimeComponents.time`
  → recordatorio diario a la hora local sin permisos de alarma exacta.
- `debugPrint` con prefijo `[notifications]` muestra en consola si la zona
  horaria se resolvió y si la programación fue aceptada.
