import 'package:flutter/material.dart';
import '../theme/bible_theme.dart';

/// Screen detailing biblical copyright attributions, font licenses, open-source
/// dependencies, and local-first privacy commitments.
class AboutLicensesScreen extends StatelessWidget {
  const AboutLicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    return Scaffold(
      backgroundColor: readingStyle.surfaceColor,
      appBar: AppBar(
        backgroundColor: readingStyle.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Acerca de y Licencias',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
            color: readingStyle.textColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // -----------------------------------------------------------------
          // 1. App Identity Header
          // -----------------------------------------------------------------
          Center(
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: ReadingPalette.indigo.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ReadingPalette.amber.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    size: 32,
                    color: ReadingPalette.indigo,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'bible_app',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.bold,
                    color: readingStyle.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Un capítulo al día · Versión 1.0.0+1',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: 'Inter',
                    color: readingStyle.metaColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lector bíblico devocional con estética de códice editorial contemporáneo, arquitectura 100% desconectada y respeto absoluto por tu privacidad.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Inter',
                    color: readingStyle.textColor.withValues(alpha: 0.85),
                    height: 1.45,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // -----------------------------------------------------------------
          // 2. Biblical Texts & Copyright
          // -----------------------------------------------------------------
          _buildSectionHeader(context, 'Traducciones Bíblicas'),
          const SizedBox(height: 12),
          _buildLicenseCard(
            context,
            title: 'Santa Biblia Reina Valera Gómez (RVG)',
            badge: 'PROTESTANTE · 66 LIBROS',
            description:
                'Revisión meticulosa en español basada en el Textus Receptus griego y el Texto Masorético hebreo. '
                'Cortesía de la Iglesia Bautista Libertad y distribuida para libre estudio a través de eBible.org y bible.helloao.org.',
          ),
          const SizedBox(height: 12),
          _buildLicenseCard(
            context,
            title: 'Santa Biblia Libre para el Mundo (BLM)',
            badge: 'CATÓLICA · 73 LIBROS (CON DEUTEROCANÓNICOS)',
            description:
                'Traducción de dominio abierto en lenguaje contemporáneo que incluye los 73 libros del canon católico. '
                'Distribuida bajo Licencia Creative Commons Atribución-CompartirIgual 4.0 Internacional (CC BY-SA 4.0), cortesía de eBible.org.',
          ),
          const SizedBox(height: 24),

          // -----------------------------------------------------------------
          // 3. Typographic Heritage
          // -----------------------------------------------------------------
          _buildSectionHeader(context, 'Tipografías Editoriales'),
          const SizedBox(height: 12),
          _buildLicenseCard(
            context,
            title: 'Lora (Serif para lectura inmersiva)',
            badge: 'SIL OPEN FONT LICENSE (OFL)',
            description:
                'Diseñada por Olga Karpushina y Alexei Vanyashin (Cyreal). '
                'Tipografía con raíces caligráficas optimizada para párrafos extensos de prosa bíblica.',
          ),
          const SizedBox(height: 12),
          _buildLicenseCard(
            context,
            title: 'Inter (Sans-serif para interfaz y versalitas)',
            badge: 'SIL OPEN FONT LICENSE (OFL)',
            description:
                'Diseñada por Rasmus Andersson. '
                'Familia geométrica de alta legibilidad en pantallas digitales, empleada en títulos, referencias y notas.',
          ),
          const SizedBox(height: 24),

          // -----------------------------------------------------------------
          // 4. Privacy Commitment
          // -----------------------------------------------------------------
          _buildSectionHeader(context, 'Privacidad y Filosofía Local-First'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: readingStyle.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.security_outlined,
                      color: ReadingPalette.indigo,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tus reflexiones son tuyas',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                        color: readingStyle.textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta aplicación no recopila información personal, no contiene publicidad comercial ni SDKs de rastreo o analítica invasiva. '
                  'Tus notas, favoritos, colores de resaltado y planes residen únicamente en la base de datos local SQLite de tu teléfono.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Inter',
                    color: readingStyle.textColor.withValues(alpha: 0.85),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // -----------------------------------------------------------------
          // 5. Open Source Packages
          // -----------------------------------------------------------------
          OutlinedButton.icon(
            onPressed: () {
              showLicensePage(
                context: context,
                applicationName: 'bible_app · Un capítulo al día',
                applicationVersion: '1.0.0+1',
                applicationIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.auto_stories, size: 36),
                ),
              );
            },
            icon: const Icon(Icons.description_outlined, size: 18),
            label: const Text(
              'Ver licencias de bibliotecas de código abierto',
              style: TextStyle(fontFamily: 'Inter'),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontFamily: 'Lora',
        fontWeight: FontWeight.bold,
        color: readingStyle.textColor,
      ),
    );
  }

  Widget _buildLicenseCard(
    BuildContext context, {
    required String title,
    required String badge,
    required String description,
  }) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: readingStyle.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ReadingPalette.indigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'Inter',
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                    color: ReadingPalette.indigo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Lora',
              fontWeight: FontWeight.bold,
              color: readingStyle.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'Inter',
              color: readingStyle.metaColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

