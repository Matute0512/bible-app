import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/theme/bible_theme.dart';
import 'package:bible_app/widgets/share/editorial_verse_card_canvas.dart';
import 'package:bible_app/widgets/share/verse_share_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Editorial Verse Card & Share Sheet Tests', () {
    testWidgets(
      'EditorialVerseCardCanvas renders short, medium, and very long verses without overflow',
      (tester) async {
        const shortVerse = 'Jesús lloró.';
        const longVerse =
            'Entonces fueron llamados los escribas del rey en el mismo tiempo, '
            'en el mes tercero, que es Siván, a los veintitrés días del mismo; '
            'y se escribió conforme a todo lo que mandó Mardoqueo a los judíos, '
            'y a los príncipes, y a los capitanes y gobernadores de las provincias '
            'que había desde la India hasta Etiopía, ciento veintisiete provincias; '
            'a cada provincia conforme a su escritura, y a cada pueblo conforme a su lengua, '
            'a los judíos también conforme a su escritura y su lengua.';

        // 1. Short verse in Ivory style
        await tester.pumpWidget(
          MaterialApp(
            theme: BibleTheme.build(Brightness.light),
            home: const Scaffold(
              body: Center(
                child: EditorialVerseCardCanvas(
                  verseText: shortVerse,
                  reference: 'Juan 11:35',
                  style: EditorialCardStyle.ivory,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(shortVerse), findsOneWidget);
        expect(find.text('Juan 11:35'), findsOneWidget);
        expect(find.text('bible_app · Un capítulo al día'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // 2. Extremely long verse (Ester 8:9) in Sepia style
        await tester.pumpWidget(
          MaterialApp(
            theme: BibleTheme.build(Brightness.light),
            home: const Scaffold(
              body: Center(
                child: SingleChildScrollView(
                  child: EditorialVerseCardCanvas(
                    verseText: longVerse,
                    reference: 'Ester 8:9',
                    translationLabel: 'Reina Valera 1909',
                    style: EditorialCardStyle.sepia,
                    showWatermark: false,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(longVerse), findsOneWidget);
        expect(find.text('Ester 8:9'), findsOneWidget);
        expect(find.text('Reina Valera 1909'), findsOneWidget);
        expect(find.text('bible_app · Un capítulo al día'), findsNothing);
        expect(tester.takeException(), isNull);

        // 3. Night style
        await tester.pumpWidget(
          MaterialApp(
            theme: BibleTheme.build(Brightness.dark),
            home: const Scaffold(
              body: Center(
                child: EditorialVerseCardCanvas(
                  verseText:
                      'En el principio creó Dios los cielos y la tierra.',
                  reference: 'Génesis 1:1',
                  style: EditorialCardStyle.night,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Génesis 1:1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'VerseShareSheet displays live preview, style selector, and watermark toggle',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: BibleTheme.build(Brightness.light),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    VerseShareSheet.show(
                      context: context,
                      reference: 'Juan 3:16',
                      verseText: 'Porque de tal manera amó Dios al mundo...',
                      translationLabel: 'Reina Valera 1909',
                    );
                  },
                  child: const Text('Compartir'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Compartir'));
        await tester.pumpAndSettle();

        // Verify sheet elements
        expect(find.text('Compartir Versículo'), findsOneWidget);
        expect(find.byType(EditorialVerseCardCanvas), findsOneWidget);
        expect(find.text('Marfil'), findsOneWidget);
        expect(find.text('Pergamino'), findsOneWidget);
        expect(find.text('Vigilia'), findsOneWidget);

        // Switch style to Pergamino
        await tester.tap(find.text('Pergamino'));
        await tester.pumpAndSettle();

        // Scroll down to make Switch and buttons visible
        final switchFinder = find.byType(Switch);
        await tester.ensureVisible(switchFinder);
        await tester.pumpAndSettle();

        expect(find.text('Incluir marca discreta (bible_app)'), findsOneWidget);
        expect(find.text('Compartir como imagen'), findsOneWidget);
        expect(find.text('Compartir solo texto'), findsOneWidget);

        // Toggle watermark
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
