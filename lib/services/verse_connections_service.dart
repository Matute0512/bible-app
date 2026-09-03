import 'package:flutter/material.dart';

/// A passage of the Bible addressed the same way the reading API does it
/// (book id + chapter), so it can be matched back against the reading plan.
class PassageRef {
  const PassageRef({
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
  });

  /// Canonical API id of the book (e.g. `GEN`).
  final String bookId;

  /// Display name of the book (e.g. `Génesis`).
  final String bookName;

  /// 1-based chapter number within the book.
  final int chapterNumber;

  /// Short reference for display and semantics, e.g. `Juan 1`.
  String get reference => '$bookName $chapterNumber';
}

/// How two passages relate to each other. The label is user-facing (Spanish).
enum ConnectionKind {
  /// The same event or teaching told in another book (e.g. the gospels).
  parallel('Paralelo'),

  /// The passage announces something fulfilled later.
  prophecy('Profecía'),

  /// The passage records the fulfillment of an earlier announcement.
  fulfillment('Cumplimiento'),

  /// Both passages share a central theme without quoting each other.
  theme('Tema compartido'),

  /// The later passage quotes the earlier one.
  quote('Cita'),

  /// The passage contrasts with its pair (e.g. old vs. new creation).
  contrast('Contraste');

  const ConnectionKind(this.label);

  /// Spanish label rendered on the connection chips.
  final String label;
}

/// One edge of the curated graph: [passage] is related to [target] through
/// [kind]. [note] is an optional, human-readable gloss shown next to the edge.
class VerseConnection {
  const VerseConnection({required this.kind, required this.target, this.note});

  final ConnectionKind kind;

  /// The passage this connection points to.
  final PassageRef target;

  /// Optional short note explaining the link (Spanish, shown in the sheet).
  final String? note;
}

/// Offline catalog of hand-curated cross references.
///
/// These edges follow the same node → edge shape Graphify produces for the
/// source code, but model **biblical** connections (fulfillments, parallels,
/// shared themes and quotes) so a passage can offer semantic navigation to
/// related passages. The catalog is intentionally small and curated; chapters
/// without an entry simply report no connections.
class VerseConnectionService {
  VerseConnectionService._();

  /// Shared instance (the catalog is immutable, so one instance is enough).
  static final VerseConnectionService instance = VerseConnectionService._();

  static PassageRef ref(String bookId, String bookName, int chapter) =>
      PassageRef(bookId: bookId, bookName: bookName, chapterNumber: chapter);

  /// Catalog keyed by `"<bookId>:<chapter>"`. Order inside each list is the
  /// display order of the edges (most meaningful first).
  static const Map<String, List<VerseConnection>> _index = {
    // ------------------------------------------------------------------
    // Génesis — the opening weeks of the plan.
    // ------------------------------------------------------------------
    'GEN:1': [
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(bookId: 'JHN', bookName: 'Juan', chapterNumber: 1),
        note: 'En el principio creó Dios / En el principio era el Verbo.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'PSA',
          bookName: 'Salmos',
          chapterNumber: 104,
        ),
        note: 'El salmo alaba a Dios por su obra creadora.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'HEB',
          bookName: 'Hebreos',
          chapterNumber: 11,
        ),
        note: 'Por la fe entendemos que los mundos fueron formados.',
      ),
      VerseConnection(
        kind: ConnectionKind.contrast,
        target: PassageRef(
          bookId: 'REV',
          bookName: 'Apocalipsis',
          chapterNumber: 21,
        ),
        note: 'La antigua creación da paso a los nuevos cielos y tierra.',
      ),
    ],
    'GEN:3': [
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'ROM',
          bookName: 'Romanos',
          chapterNumber: 5,
        ),
        note: 'Por un hombre entró el pecado; por Cristo, la vida.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'REV',
          bookName: 'Apocalipsis',
          chapterNumber: 12,
        ),
        note: 'La serpiente antigua finalmente es vencida.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 22,
        ),
        note: 'El Hijo de la promesa que Dios mismo provee.',
      ),
    ],
    'GEN:6': [
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(bookId: 'MAT', bookName: 'Mateo', chapterNumber: 24),
        note: 'Jesús compara sus días con los de Noé.',
      ),
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(
          bookId: '1PE',
          bookName: '1 Pedro',
          chapterNumber: 3,
        ),
        note: 'Pedro ve en el arca una figura del bautismo.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'HEB',
          bookName: 'Hebreos',
          chapterNumber: 11,
        ),
        note: 'Noé construyó el arca con temor reverente.',
      ),
    ],
    'GEN:12': [
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'ROM',
          bookName: 'Romanos',
          chapterNumber: 4,
        ),
        note: 'Abraham es el padre de los que creen.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'GAL',
          bookName: 'Gálatas',
          chapterNumber: 3,
        ),
        note: 'En tu descendencia serán benditas todas las naciones.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'HEB',
          bookName: 'Hebreos',
          chapterNumber: 11,
        ),
        note: 'Salió sin saber a dónde iba.',
      ),
    ],
    'GEN:22': [
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'HEB',
          bookName: 'Hebreos',
          chapterNumber: 11,
        ),
        note: 'Abraham ofreció a Isaac, pensando que Dios podía resucitarlo.',
      ),
      VerseConnection(
        kind: ConnectionKind.contrast,
        target: PassageRef(bookId: 'JHN', bookName: 'Juan', chapterNumber: 3),
        note:
            'Dios no retuvo a su propio Hijo. Ya no es un cordero en lugar de Isaac.',
      ),
    ],
    // ------------------------------------------------------------------
    // Salmos e Isaías — profecía y su cumplimiento.
    // ------------------------------------------------------------------
    'PSA:22': [
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(bookId: 'MAT', bookName: 'Mateo', chapterNumber: 27),
        note: 'Dios mío, Dios mío, ¿por qué me has desamparado?',
      ),
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(bookId: 'JHN', bookName: 'Juan', chapterNumber: 19),
        note: 'Repartieron entre sí mis vestidos.',
      ),
    ],
    'PSA:23': [
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(bookId: 'JHN', bookName: 'Juan', chapterNumber: 10),
        note: 'Jesús se presenta como el buen pastor.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'EZK',
          bookName: 'Ezequiel',
          chapterNumber: 34,
        ),
        note: 'Dios mismo promete apacentar a su rebaño.',
      ),
    ],
    'PSA:110': [
      VerseConnection(
        kind: ConnectionKind.quote,
        target: PassageRef(bookId: 'MAT', bookName: 'Mateo', chapterNumber: 22),
        note: 'Jesús pregunta cómo el Mesías es Hijo de David y su Señor.',
      ),
      VerseConnection(
        kind: ConnectionKind.quote,
        target: PassageRef(
          bookId: 'HEB',
          bookName: 'Hebreos',
          chapterNumber: 7,
        ),
        note: 'Sacerdote para siempre según el orden de Melquisedec.',
      ),
    ],
    'ISA:7': [
      VerseConnection(
        kind: ConnectionKind.prophecy,
        target: PassageRef(bookId: 'MAT', bookName: 'Mateo', chapterNumber: 1),
        note: 'La virgen concebirá y llamará su nombre Emanuel.',
      ),
    ],
    'ISA:53': [
      VerseConnection(
        kind: ConnectionKind.prophecy,
        target: PassageRef(bookId: 'ACT', bookName: 'Hechos', chapterNumber: 8),
        note: 'El eunuco lee a Isaías y Felipe le anuncia a Jesús.',
      ),
      VerseConnection(
        kind: ConnectionKind.prophecy,
        target: PassageRef(
          bookId: '1PE',
          bookName: '1 Pedro',
          chapterNumber: 2,
        ),
        note: 'Llevó nuestros pecados en su cuerpo sobre el madero.',
      ),
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(bookId: 'MAT', bookName: 'Mateo', chapterNumber: 8),
        note: 'Tomó nuestras enfermedades y llevó nuestras dolencias.',
      ),
    ],
    'ISA:61': [
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(bookId: 'LUK', bookName: 'Lucas', chapterNumber: 4),
        note: 'Jesús lee el rollo en Nazaret y dice: hoy se cumple.',
      ),
    ],
    // ------------------------------------------------------------------
    // Evangelios — paralelos y citas del Antiguo Testamento.
    // ------------------------------------------------------------------
    'MAT:1': [
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(bookId: 'ISA', bookName: 'Isaías', chapterNumber: 7),
        note: 'Nacimiento virginal anunciado como Emanuel.',
      ),
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(bookId: 'LUK', bookName: 'Lucas', chapterNumber: 2),
        note: 'El otro relato del nacimiento, desde María.',
      ),
    ],
    'MAT:2': [
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(
          bookId: 'MIC',
          bookName: 'Miqueas',
          chapterNumber: 5,
        ),
        note: 'De ti, Belén, saldrá el gobernante de Israel.',
      ),
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(bookId: 'HOS', bookName: 'Oseas', chapterNumber: 11),
        note: 'De Egipto llamé a mi hijo.',
      ),
    ],
    'MAT:4': [
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(bookId: 'LUK', bookName: 'Lucas', chapterNumber: 4),
        note: 'Las tentaciones narradas también por Lucas.',
      ),
      VerseConnection(
        kind: ConnectionKind.quote,
        target: PassageRef(
          bookId: 'DEU',
          bookName: 'Deuteronomio',
          chapterNumber: 8,
        ),
        note: 'No solo de pan vivirá el hombre.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(bookId: 'ISA', bookName: 'Isaías', chapterNumber: 9),
        note: 'El pueblo que andaba en tinieblas vio gran luz.',
      ),
    ],
    'MAT:5': [
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(bookId: 'LUK', bookName: 'Lucas', chapterNumber: 6),
        note: 'El discurso del llano recoge las bienaventuranzas.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'ROM',
          bookName: 'Romanos',
          chapterNumber: 12,
        ),
        note: 'Vivir como ofrenda viva y bendecir a quienes nos persiguen.',
      ),
    ],
    'MAT:24': [
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(
          bookId: 'MRK',
          bookName: 'Marcos',
          chapterNumber: 13,
        ),
        note: 'El mismo discurso en Marcos.',
      ),
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(bookId: 'LUK', bookName: 'Lucas', chapterNumber: 21),
        note: 'El mismo discurso en Lucas.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'DAN',
          bookName: 'Daniel',
          chapterNumber: 12,
        ),
        note: 'Tiempo de angustia y promesa de resurrección.',
      ),
    ],
    'MAT:27': [
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(
          bookId: 'PSA',
          bookName: 'Salmos',
          chapterNumber: 22,
        ),
        note: 'El salmo del Crucificado, citado en la cruz.',
      ),
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(
          bookId: 'ZEC',
          bookName: 'Zacarías',
          chapterNumber: 11,
        ),
        note: 'Pesaron mi salario: treinta piezas de plata.',
      ),
      VerseConnection(
        kind: ConnectionKind.prophecy,
        target: PassageRef(
          bookId: 'ISA',
          bookName: 'Isaías',
          chapterNumber: 53,
        ),
        note: 'Herido fue por nuestras rebeliones.',
      ),
    ],
    'MAT:28': [
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(
          bookId: 'MRK',
          bookName: 'Marcos',
          chapterNumber: 16,
        ),
        note: 'La resurrección anunciada a las mujeres.',
      ),
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(bookId: 'LUK', bookName: 'Lucas', chapterNumber: 24),
        note: 'El relato de Emaús y la gran comisión.',
      ),
    ],
    'LUK:1': [
      VerseConnection(
        kind: ConnectionKind.prophecy,
        target: PassageRef(
          bookId: 'MAL',
          bookName: 'Malaquías',
          chapterNumber: 3,
        ),
        note: 'El mensajero preparará el camino del Señor.',
      ),
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(
          bookId: 'ISA',
          bookName: 'Isaías',
          chapterNumber: 40,
        ),
        note: 'Voz que clama en el desierto.',
      ),
    ],
    'LUK:2': [
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(
          bookId: 'MIC',
          bookName: 'Miqueas',
          chapterNumber: 5,
        ),
        note: 'El Mesías nace en Belén, la ciudad de David.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(bookId: 'PSA', bookName: 'Salmos', chapterNumber: 2),
        note: 'Hoy te he engendrado: el Hijo prometido al rey.',
      ),
    ],
    'LUK:15': [
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(bookId: 'MAT', bookName: 'Mateo', chapterNumber: 18),
        note: 'La parábola de la oveja perdida, también en Mateo.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'MIC',
          bookName: 'Miqueas',
          chapterNumber: 7,
        ),
        note: 'Él volverá a tener misericordia de nosotros.',
      ),
    ],
    'JHN:1': [
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 1,
        ),
        note: 'Ambos comienzan en el principio, con la creación.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'COL',
          bookName: 'Colosenses',
          chapterNumber: 1,
        ),
        note: 'Todo fue creado por él y para él.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'HEB',
          bookName: 'Hebreos',
          chapterNumber: 1,
        ),
        note: 'El resplandor de su gloria y la imagen de su sustancia.',
      ),
    ],
    'JHN:3': [
      VerseConnection(
        kind: ConnectionKind.quote,
        target: PassageRef(
          bookId: 'NUM',
          bookName: 'Números',
          chapterNumber: 21,
        ),
        note: 'Como Moisés levantó la serpiente en el desierto.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'EZK',
          bookName: 'Ezequiel',
          chapterNumber: 36,
        ),
        note: 'Os rociaré con agua limpia y os daré un corazón nuevo.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 22,
        ),
        note: 'De tal manera amó Dios, que dio a su Hijo unigénito.',
      ),
    ],
    'JHN:10': [
      VerseConnection(
        kind: ConnectionKind.quote,
        target: PassageRef(
          bookId: 'PSA',
          bookName: 'Salmos',
          chapterNumber: 23,
        ),
        note: 'El buen pastor: Jehová es mi pastor.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'EZK',
          bookName: 'Ezequiel',
          chapterNumber: 34,
        ),
        note: 'Yo mismo apacentaré mis ovejas, dice el Señor.',
      ),
    ],
    'JHN:19': [
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(
          bookId: 'PSA',
          bookName: 'Salmos',
          chapterNumber: 22,
        ),
        note: 'El relato del salmo se cumple en la crucifixión.',
      ),
      VerseConnection(
        kind: ConnectionKind.fulfillment,
        target: PassageRef(
          bookId: 'ZEC',
          bookName: 'Zacarías',
          chapterNumber: 12,
        ),
        note: 'Mirarán a mí, a quien traspasaron.',
      ),
      VerseConnection(
        kind: ConnectionKind.prophecy,
        target: PassageRef(
          bookId: 'ISA',
          bookName: 'Isaías',
          chapterNumber: 53,
        ),
        note: 'Como cordero llevado al matadero.',
      ),
    ],
    // ------------------------------------------------------------------
    // Hechos y cartas.
    // ------------------------------------------------------------------
    'ACT:2': [
      VerseConnection(
        kind: ConnectionKind.quote,
        target: PassageRef(bookId: 'JOE', bookName: 'Joel', chapterNumber: 2),
        note: 'Derramaré de mi Espíritu sobre toda carne.',
      ),
      VerseConnection(
        kind: ConnectionKind.contrast,
        target: PassageRef(
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 11,
        ),
        note:
            'En Babel las lenguas se confunden; en Pentecostés, se entienden.',
      ),
    ],
    'ROM:5': [
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 3,
        ),
        note:
            'Por la desobediencia de un hombre, todos fueron hechos pecadores.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'ISA',
          bookName: 'Isaías',
          chapterNumber: 53,
        ),
        note: 'El Justo justifica a muchos, cargando sus iniquidades.',
      ),
    ],
    'HEB:11': [
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 1,
        ),
        note: 'Por la fe entendemos que los mundos fueron formados.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 12,
        ),
        note: 'Abraham obedeció y salió sin saber a dónde iba.',
      ),
    ],
    'REV:21': [
      VerseConnection(
        kind: ConnectionKind.contrast,
        target: PassageRef(
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 1,
        ),
        note: 'La nueva creación reemplaza a la primera.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'ISA',
          bookName: 'Isaías',
          chapterNumber: 65,
        ),
        note: 'Creo nuevos cielos y nueva tierra.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(
          bookId: 'EZK',
          bookName: 'Ezequiel',
          chapterNumber: 47,
        ),
        note: 'Del templo brota el río de aguas vivas.',
      ),
    ],
  };

  /// Returns the curated connections leaving [bookId]·[chapterNumber].
  ///
  /// Chapters without an entry return an empty (not null) list so callers can
  /// render an honest "no connections yet" state without special-casing null.
  List<VerseConnection> connectionsFor({
    required String bookId,
    required int chapterNumber,
  }) => _index['$bookId:$chapterNumber'] ?? const [];

  /// Whether the catalog has at least one edge for [bookId]·[chapterNumber].
  bool hasConnections({required String bookId, required int chapterNumber}) =>
      _index.containsKey('$bookId:$chapterNumber');
}

/// Material icon that best conveys [kind] on a connection chip.
IconData connectionIconFor(ConnectionKind kind) => switch (kind) {
  ConnectionKind.parallel => Icons.sync_alt,
  ConnectionKind.prophecy => Icons.record_voice_over_outlined,
  ConnectionKind.fulfillment => Icons.task_alt,
  ConnectionKind.theme => Icons.bubble_chart_outlined,
  ConnectionKind.quote => Icons.format_quote,
  ConnectionKind.contrast => Icons.balance,
};
