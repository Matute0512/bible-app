import 'package:bible_app/services/verse_connections_service.dart';
import 'package:bible_app/widgets/graph_explorer.dart';
import 'package:flutter_test/flutter_test.dart';

/// Validates the curated cross-reference catalog that powers the graph
/// explorer: known chapters expose connections and unknown ones are empty.
void main() {
  final service = VerseConnectionService.instance;

  test('Genesis 1 exposes curated connections with the catalog shape', () {
    final connections = service.connectionsFor(bookId: 'GEN', chapterNumber: 1);

    expect(connections, isNotEmpty);
    // Every edge points to a displayable passage.
    for (final connection in connections) {
      expect(connection.target.reference, isNotEmpty);
      expect(connection.target.bookId, isNotEmpty);
      // note is nullable by contract; when present it must be non-empty.
      if (connection.note != null) {
        expect(connection.note, isNotEmpty);
      }
    }
    // A well-known link is present: creation in John 1.
    expect(
      connections.any((c) => c.target.reference == 'Juan 1'),
      isTrue,
      reason: 'Genesis 1 should be linked to the Johannine prologue',
    );
  });

  test('chapters without an entry report empty, not null', () {
    final connections = service.connectionsFor(
      bookId: 'ZZZ',
      chapterNumber: 99,
    );

    expect(connections, isEmpty);
    expect(service.hasConnections(bookId: 'ZZZ', chapterNumber: 99), isFalse);
    expect(service.hasConnections(bookId: 'GEN', chapterNumber: 1), isTrue);
  });

  test('every connection kind has a user-facing label and an icon', () {
    for (final kind in ConnectionKind.values) {
      expect(kind.label, isNotEmpty);
      expect(connectionIconFor(kind), isNotNull);
    }
  });

  test('loadFromJsonString populates new connections dynamically', () {
    const customJson = '''
    {
      "MAT:1": [
        {
          "kind": "fulfillment",
          "target": {
            "bookId": "ISA",
            "bookName": "Isaías",
            "chapterNumber": 7
          },
          "note": "Profecía de Emanuel."
        }
      ]
    }
    ''';

    VerseConnectionService.loadFromJsonString(customJson);
    final conns = service.connectionsFor(bookId: 'MAT', chapterNumber: 1);
    expect(conns, hasLength(1));
    expect(conns.first.kind, ConnectionKind.fulfillment);
    expect(conns.first.target.bookName, 'Isaías');
    expect(conns.first.target.chapterNumber, 7);
    expect(conns.first.note, 'Profecía de Emanuel.');
  });
}
