import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service responsible for capturing widget hierarchies into high-resolution
/// PNG image files and dispatching them via the native platform share sheet.
class VerseImageService {
  const VerseImageService();

  /// Captures the widget subtree wrapped by [repaintKey] as PNG bytes.
  static Future<Uint8List> capturePng(
    GlobalKey repaintKey, {
    double pixelRatio = 3.0,
  }) async {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError(
        'No RenderRepaintBoundary found on the provided GlobalKey context.',
      );
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode image data to PNG format.');
    }
    return byteData.buffer.asUint8List();
  }

  /// Exports the canvas image to an ephemeral file in the temporary directory
  /// and triggers the native OS share sheet.
  static Future<void> shareVerseCard({
    required GlobalKey repaintKey,
    required String reference,
    required String verseText,
  }) async {
    final bytes = await capturePng(repaintKey);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanRef = reference.replaceAll(RegExp(r'[^\w\d]'), '_');
    final filePath = '${tempDir.path}/verse_${cleanRef}_$timestamp.png';

    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '«$verseText»\n— $reference',
        title: reference,
      ),
    );
  }
}

