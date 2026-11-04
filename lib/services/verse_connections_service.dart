import 'dart:convert';
import 'package:flutter/services.dart';

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
/// Externalized to assets/data/verse_connections.json for maintainability,
/// with built-in in-memory fallback for offline test environments.
class VerseConnectionService {
  VerseConnectionService._();

  /// Shared instance (the catalog is immutable, so one instance is enough).
  static final VerseConnectionService instance = VerseConnectionService._();

  static PassageRef ref(String bookId, String bookName, int chapter) =>
      PassageRef(bookId: bookId, bookName: bookName, chapterNumber: chapter);

  static Map<String, List<VerseConnection>> _index = _fallbackIndex;

  /// Loads connections from assets/data/verse_connections.json.
  static Future<void> loadFromAsset([AssetBundle? bundle]) async {
    final assetBundle = bundle ?? rootBundle;
    try {
      final jsonString =
          await assetBundle.loadString('assets/data/verse_connections.json');
      loadFromJsonString(jsonString);
    } catch (_) {
      // Keep existing index
    }
  }

  /// Parses and populates connection index from JSON string.
  static void loadFromJsonString(String jsonString) {
    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    final map = <String, List<VerseConnection>>{};
    for (final entry in decoded.entries) {
      final list = entry.value as List? ?? [];
      final connections = <VerseConnection>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final kindStr = item['kind'] as String? ?? 'theme';
          final kind = ConnectionKind.values.firstWhere(
            (k) => k.name == kindStr,
            orElse: () => ConnectionKind.theme,
          );
          final targetMap = item['target'] as Map<String, dynamic>? ?? {};
          final target = PassageRef(
            bookId: targetMap['bookId'] as String? ?? '',
            bookName: targetMap['bookName'] as String? ?? '',
            chapterNumber: (targetMap['chapterNumber'] as num?)?.toInt() ?? 1,
          );
          connections.add(
            VerseConnection(
              kind: kind,
              target: target,
              note: item['note'] as String?,
            ),
          );
        }
      }
      map[entry.key] = connections;
    }
    _index = map;
  }

  /// Returns the curated connections leaving [bookId]·[chapterNumber].
  List<VerseConnection> connectionsFor({
    required String bookId,
    required int chapterNumber,
  }) =>
      _index['$bookId:$chapterNumber'] ?? const [];

  /// Whether the catalog has at least one edge for [bookId]·[chapterNumber].
  bool hasConnections({required String bookId, required int chapterNumber}) =>
      _index.containsKey('$bookId:$chapterNumber');

  /// Fallback entries for testing environments where assets are not loaded.
  static const Map<String, List<VerseConnection>> _fallbackIndex = {
    'GEN:1': [
      VerseConnection(
        kind: ConnectionKind.parallel,
        target: PassageRef(bookId: 'JHN', bookName: 'Juan', chapterNumber: 1),
        note: 'En el principio creó Dios / En el principio era el Verbo.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(bookId: 'PSA', bookName: 'Salmos', chapterNumber: 104),
        note: 'El salmo alaba a Dios por su obra creadora.',
      ),
      VerseConnection(
        kind: ConnectionKind.theme,
        target: PassageRef(bookId: 'HEB', bookName: 'Hebreos', chapterNumber: 11),
        note: 'Por la fe entendemos que los mundos fueron formados.',
      ),
      VerseConnection(
        kind: ConnectionKind.contrast,
        target: PassageRef(bookId: 'REV', bookName: 'Apocalipsis', chapterNumber: 21),
        note: 'La antigua creación da paso a los nuevos cielos y tierra.',
      ),
    ],
  };
}
