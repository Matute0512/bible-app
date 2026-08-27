import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/bible_book.dart';
import '../models/bible_chapter.dart';

/// A failure produced by [BibleApiService].
///
/// [message] is already localized (Spanish) and is safe to show directly to
/// the user.
class BibleApiException implements Exception {
  const BibleApiException(this.message);

  /// Human-readable description intended to be displayed verbatim.
  final String message;

  @override
  String toString() => message;
}

/// Thin HTTP client over the Free Use Bible API (https://bible.helloao.org).
///
/// Every failure — no connectivity, timeout, HTTP error or malformed payload —
/// surfaces as a [BibleApiException] carrying a Spanish message the UI can
/// render together with a retry action.
class BibleApiService {
  BibleApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Base URL of the public API.
  static const String baseUrl = 'https://bible.helloao.org/api';

  /// Maximum time to wait for a response before giving up.
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// Fetches the books of [translationId] in canon order.
  ///
  /// The response is `{ "translation": {...}, "books": [...] }`; only the
  /// `books` list is parsed and returned.
  Future<List<BibleBook>> fetchBooks(String translationId) async {
    final json =
        await _getJson(Uri.parse('$baseUrl/$translationId/books.json'));
    final books = (json is Map<String, dynamic>) ? json['books'] : null;
    if (books is! List) {
      throw const BibleApiException(
        'Recibimos una respuesta inválida del servidor.',
      );
    }
    try {
      return books
          .map((item) => BibleBook.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on TypeError {
      throw const BibleApiException(
        'Recibimos una respuesta inválida del servidor.',
      );
    }
  }

  /// Fetches one chapter in the simplified (`*.simple.json`) format.
  Future<BibleChapter> fetchChapter({
    required String translationId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/$translationId/$bookId/$chapterNumber.simple.json',
    );
    final json = await _getJson(uri);
    if (json is! Map<String, dynamic>) {
      throw const BibleApiException(
        'Recibimos una respuesta inválida del servidor.',
      );
    }
    try {
      return BibleChapter.fromSimpleJson(
        json,
        bookId: bookId,
        bookName: bookName,
        chapterNumber: chapterNumber,
      );
    } on TypeError {
      throw const BibleApiException(
        'Recibimos una respuesta inválida del servidor.',
      );
    }
  }

  /// Performs a GET on [uri] and decodes the body, mapping every failure to a
  /// [BibleApiException].
  ///
  /// The body is decoded as UTF-8 from the raw bytes so Spanish characters
  /// survive regardless of the charset declared in the response headers.
  Future<dynamic> _getJson(Uri uri) async {
    http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const BibleApiException(
        'La conexión tardó demasiado. Revisá tu conexión a internet.',
      );
    } on SocketException {
      throw const BibleApiException(
        'No pudimos conectarnos. Revisá tu conexión a internet.',
      );
    } on http.ClientException {
      throw const BibleApiException(
        'No pudimos conectarnos. Revisá tu conexión a internet.',
      );
    }

    if (response.statusCode != 200) {
      throw BibleApiException(
        'El servidor respondió con un error (${response.statusCode}).',
      );
    }

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const BibleApiException(
        'Recibimos una respuesta inválida del servidor.',
      );
    }
  }
}
