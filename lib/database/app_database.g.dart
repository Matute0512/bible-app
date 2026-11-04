// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedBooksTable extends CachedBooks
    with TableInfo<$CachedBooksTable, CachedBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _translationIdMeta = const VerificationMeta(
    'translationId',
  );
  @override
  late final GeneratedColumn<String> translationId = GeneratedColumn<String>(
    'translation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterCountMeta = const VerificationMeta(
    'chapterCount',
  );
  @override
  late final GeneratedColumn<int> chapterCount = GeneratedColumn<int>(
    'chapter_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookOrderMeta = const VerificationMeta(
    'bookOrder',
  );
  @override
  late final GeneratedColumn<int> bookOrder = GeneratedColumn<int>(
    'book_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    translationId,
    bookId,
    name,
    normalizedName,
    chapterCount,
    bookOrder,
    sha256,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('translation_id')) {
      context.handle(
        _translationIdMeta,
        translationId.isAcceptableOrUnknown(
          data['translation_id']!,
          _translationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('chapter_count')) {
      context.handle(
        _chapterCountMeta,
        chapterCount.isAcceptableOrUnknown(
          data['chapter_count']!,
          _chapterCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterCountMeta);
    }
    if (data.containsKey('book_order')) {
      context.handle(
        _bookOrderMeta,
        bookOrder.isAcceptableOrUnknown(data['book_order']!, _bookOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_bookOrderMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {translationId, bookId};
  @override
  CachedBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBook(
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      chapterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_count'],
      )!,
      bookOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_order'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $CachedBooksTable createAlias(String alias) {
    return $CachedBooksTable(attachedDatabase, alias);
  }
}

class CachedBook extends DataClass implements Insertable<CachedBook> {
  final String translationId;
  final String bookId;
  final String name;
  final String normalizedName;
  final int chapterCount;
  final int bookOrder;
  final String? sha256;
  final int updatedAtMs;
  const CachedBook({
    required this.translationId,
    required this.bookId,
    required this.name,
    required this.normalizedName,
    required this.chapterCount,
    required this.bookOrder,
    this.sha256,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['translation_id'] = Variable<String>(translationId);
    map['book_id'] = Variable<String>(bookId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['chapter_count'] = Variable<int>(chapterCount);
    map['book_order'] = Variable<int>(bookOrder);
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  CachedBooksCompanion toCompanion(bool nullToAbsent) {
    return CachedBooksCompanion(
      translationId: Value(translationId),
      bookId: Value(bookId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      chapterCount: Value(chapterCount),
      bookOrder: Value(bookOrder),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory CachedBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBook(
      translationId: serializer.fromJson<String>(json['translationId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      chapterCount: serializer.fromJson<int>(json['chapterCount']),
      bookOrder: serializer.fromJson<int>(json['bookOrder']),
      sha256: serializer.fromJson<String?>(json['sha256']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'translationId': serializer.toJson<String>(translationId),
      'bookId': serializer.toJson<String>(bookId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'chapterCount': serializer.toJson<int>(chapterCount),
      'bookOrder': serializer.toJson<int>(bookOrder),
      'sha256': serializer.toJson<String?>(sha256),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  CachedBook copyWith({
    String? translationId,
    String? bookId,
    String? name,
    String? normalizedName,
    int? chapterCount,
    int? bookOrder,
    Value<String?> sha256 = const Value.absent(),
    int? updatedAtMs,
  }) => CachedBook(
    translationId: translationId ?? this.translationId,
    bookId: bookId ?? this.bookId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    chapterCount: chapterCount ?? this.chapterCount,
    bookOrder: bookOrder ?? this.bookOrder,
    sha256: sha256.present ? sha256.value : this.sha256,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  CachedBook copyWithCompanion(CachedBooksCompanion data) {
    return CachedBook(
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      chapterCount: data.chapterCount.present
          ? data.chapterCount.value
          : this.chapterCount,
      bookOrder: data.bookOrder.present ? data.bookOrder.value : this.bookOrder,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBook(')
          ..write('translationId: $translationId, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('bookOrder: $bookOrder, ')
          ..write('sha256: $sha256, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    translationId,
    bookId,
    name,
    normalizedName,
    chapterCount,
    bookOrder,
    sha256,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBook &&
          other.translationId == this.translationId &&
          other.bookId == this.bookId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.chapterCount == this.chapterCount &&
          other.bookOrder == this.bookOrder &&
          other.sha256 == this.sha256 &&
          other.updatedAtMs == this.updatedAtMs);
}

class CachedBooksCompanion extends UpdateCompanion<CachedBook> {
  final Value<String> translationId;
  final Value<String> bookId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<int> chapterCount;
  final Value<int> bookOrder;
  final Value<String?> sha256;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const CachedBooksCompanion({
    this.translationId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.chapterCount = const Value.absent(),
    this.bookOrder = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBooksCompanion.insert({
    required String translationId,
    required String bookId,
    required String name,
    required String normalizedName,
    required int chapterCount,
    required int bookOrder,
    this.sha256 = const Value.absent(),
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : translationId = Value(translationId),
       bookId = Value(bookId),
       name = Value(name),
       normalizedName = Value(normalizedName),
       chapterCount = Value(chapterCount),
       bookOrder = Value(bookOrder),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<CachedBook> custom({
    Expression<String>? translationId,
    Expression<String>? bookId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<int>? chapterCount,
    Expression<int>? bookOrder,
    Expression<String>? sha256,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (translationId != null) 'translation_id': translationId,
      if (bookId != null) 'book_id': bookId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (chapterCount != null) 'chapter_count': chapterCount,
      if (bookOrder != null) 'book_order': bookOrder,
      if (sha256 != null) 'sha256': sha256,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBooksCompanion copyWith({
    Value<String>? translationId,
    Value<String>? bookId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<int>? chapterCount,
    Value<int>? bookOrder,
    Value<String?>? sha256,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return CachedBooksCompanion(
      translationId: translationId ?? this.translationId,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      chapterCount: chapterCount ?? this.chapterCount,
      bookOrder: bookOrder ?? this.bookOrder,
      sha256: sha256 ?? this.sha256,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (translationId.present) {
      map['translation_id'] = Variable<String>(translationId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (chapterCount.present) {
      map['chapter_count'] = Variable<int>(chapterCount.value);
    }
    if (bookOrder.present) {
      map['book_order'] = Variable<int>(bookOrder.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBooksCompanion(')
          ..write('translationId: $translationId, ')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('bookOrder: $bookOrder, ')
          ..write('sha256: $sha256, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedChaptersTable extends CachedChapters
    with TableInfo<$CachedChaptersTable, CachedChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _translationIdMeta = const VerificationMeta(
    'translationId',
  );
  @override
  late final GeneratedColumn<String> translationId = GeneratedColumn<String>(
    'translation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterNumberMeta = const VerificationMeta(
    'chapterNumber',
  );
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
    'chapter_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookNameMeta = const VerificationMeta(
    'bookName',
  );
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
    'book_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMsMeta = const VerificationMeta(
    'fetchedAtMs',
  );
  @override
  late final GeneratedColumn<int> fetchedAtMs = GeneratedColumn<int>(
    'fetched_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    translationId,
    bookId,
    chapterNumber,
    bookName,
    sha256,
    fetchedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedChapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('translation_id')) {
      context.handle(
        _translationIdMeta,
        translationId.isAcceptableOrUnknown(
          data['translation_id']!,
          _translationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
        _chapterNumberMeta,
        chapterNumber.isAcceptableOrUnknown(
          data['chapter_number']!,
          _chapterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('book_name')) {
      context.handle(
        _bookNameMeta,
        bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    if (data.containsKey('fetched_at_ms')) {
      context.handle(
        _fetchedAtMsMeta,
        fetchedAtMs.isAcceptableOrUnknown(
          data['fetched_at_ms']!,
          _fetchedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    translationId,
    bookId,
    chapterNumber,
  };
  @override
  CachedChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedChapter(
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_number'],
      )!,
      bookName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_name'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
      fetchedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at_ms'],
      )!,
    );
  }

  @override
  $CachedChaptersTable createAlias(String alias) {
    return $CachedChaptersTable(attachedDatabase, alias);
  }
}

class CachedChapter extends DataClass implements Insertable<CachedChapter> {
  final String translationId;
  final String bookId;
  final int chapterNumber;
  final String bookName;
  final String? sha256;
  final int fetchedAtMs;
  const CachedChapter({
    required this.translationId,
    required this.bookId,
    required this.chapterNumber,
    required this.bookName,
    this.sha256,
    required this.fetchedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['translation_id'] = Variable<String>(translationId);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['book_name'] = Variable<String>(bookName);
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    map['fetched_at_ms'] = Variable<int>(fetchedAtMs);
    return map;
  }

  CachedChaptersCompanion toCompanion(bool nullToAbsent) {
    return CachedChaptersCompanion(
      translationId: Value(translationId),
      bookId: Value(bookId),
      chapterNumber: Value(chapterNumber),
      bookName: Value(bookName),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
      fetchedAtMs: Value(fetchedAtMs),
    );
  }

  factory CachedChapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedChapter(
      translationId: serializer.fromJson<String>(json['translationId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      bookName: serializer.fromJson<String>(json['bookName']),
      sha256: serializer.fromJson<String?>(json['sha256']),
      fetchedAtMs: serializer.fromJson<int>(json['fetchedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'translationId': serializer.toJson<String>(translationId),
      'bookId': serializer.toJson<String>(bookId),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'bookName': serializer.toJson<String>(bookName),
      'sha256': serializer.toJson<String?>(sha256),
      'fetchedAtMs': serializer.toJson<int>(fetchedAtMs),
    };
  }

  CachedChapter copyWith({
    String? translationId,
    String? bookId,
    int? chapterNumber,
    String? bookName,
    Value<String?> sha256 = const Value.absent(),
    int? fetchedAtMs,
  }) => CachedChapter(
    translationId: translationId ?? this.translationId,
    bookId: bookId ?? this.bookId,
    chapterNumber: chapterNumber ?? this.chapterNumber,
    bookName: bookName ?? this.bookName,
    sha256: sha256.present ? sha256.value : this.sha256,
    fetchedAtMs: fetchedAtMs ?? this.fetchedAtMs,
  );
  CachedChapter copyWithCompanion(CachedChaptersCompanion data) {
    return CachedChapter(
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      fetchedAtMs: data.fetchedAtMs.present
          ? data.fetchedAtMs.value
          : this.fetchedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedChapter(')
          ..write('translationId: $translationId, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('bookName: $bookName, ')
          ..write('sha256: $sha256, ')
          ..write('fetchedAtMs: $fetchedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    translationId,
    bookId,
    chapterNumber,
    bookName,
    sha256,
    fetchedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedChapter &&
          other.translationId == this.translationId &&
          other.bookId == this.bookId &&
          other.chapterNumber == this.chapterNumber &&
          other.bookName == this.bookName &&
          other.sha256 == this.sha256 &&
          other.fetchedAtMs == this.fetchedAtMs);
}

class CachedChaptersCompanion extends UpdateCompanion<CachedChapter> {
  final Value<String> translationId;
  final Value<String> bookId;
  final Value<int> chapterNumber;
  final Value<String> bookName;
  final Value<String?> sha256;
  final Value<int> fetchedAtMs;
  final Value<int> rowid;
  const CachedChaptersCompanion({
    this.translationId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.bookName = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.fetchedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedChaptersCompanion.insert({
    required String translationId,
    required String bookId,
    required int chapterNumber,
    required String bookName,
    this.sha256 = const Value.absent(),
    required int fetchedAtMs,
    this.rowid = const Value.absent(),
  }) : translationId = Value(translationId),
       bookId = Value(bookId),
       chapterNumber = Value(chapterNumber),
       bookName = Value(bookName),
       fetchedAtMs = Value(fetchedAtMs);
  static Insertable<CachedChapter> custom({
    Expression<String>? translationId,
    Expression<String>? bookId,
    Expression<int>? chapterNumber,
    Expression<String>? bookName,
    Expression<String>? sha256,
    Expression<int>? fetchedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (translationId != null) 'translation_id': translationId,
      if (bookId != null) 'book_id': bookId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (bookName != null) 'book_name': bookName,
      if (sha256 != null) 'sha256': sha256,
      if (fetchedAtMs != null) 'fetched_at_ms': fetchedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedChaptersCompanion copyWith({
    Value<String>? translationId,
    Value<String>? bookId,
    Value<int>? chapterNumber,
    Value<String>? bookName,
    Value<String?>? sha256,
    Value<int>? fetchedAtMs,
    Value<int>? rowid,
  }) {
    return CachedChaptersCompanion(
      translationId: translationId ?? this.translationId,
      bookId: bookId ?? this.bookId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      bookName: bookName ?? this.bookName,
      sha256: sha256 ?? this.sha256,
      fetchedAtMs: fetchedAtMs ?? this.fetchedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (translationId.present) {
      map['translation_id'] = Variable<String>(translationId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (fetchedAtMs.present) {
      map['fetched_at_ms'] = Variable<int>(fetchedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedChaptersCompanion(')
          ..write('translationId: $translationId, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('bookName: $bookName, ')
          ..write('sha256: $sha256, ')
          ..write('fetchedAtMs: $fetchedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedVersesTable extends CachedVerses
    with TableInfo<$CachedVersesTable, CachedVerse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedVersesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _translationIdMeta = const VerificationMeta(
    'translationId',
  );
  @override
  late final GeneratedColumn<String> translationId = GeneratedColumn<String>(
    'translation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterNumberMeta = const VerificationMeta(
    'chapterNumber',
  );
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
    'chapter_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseNumberMeta = const VerificationMeta(
    'verseNumber',
  );
  @override
  late final GeneratedColumn<int> verseNumber = GeneratedColumn<int>(
    'verse_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedTextMeta = const VerificationMeta(
    'normalizedText',
  );
  @override
  late final GeneratedColumn<String> normalizedText = GeneratedColumn<String>(
    'normalized_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    translationId,
    bookId,
    chapterNumber,
    verseNumber,
    textContent,
    normalizedText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_verses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedVerse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('translation_id')) {
      context.handle(
        _translationIdMeta,
        translationId.isAcceptableOrUnknown(
          data['translation_id']!,
          _translationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
        _chapterNumberMeta,
        chapterNumber.isAcceptableOrUnknown(
          data['chapter_number']!,
          _chapterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('verse_number')) {
      context.handle(
        _verseNumberMeta,
        verseNumber.isAcceptableOrUnknown(
          data['verse_number']!,
          _verseNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verseNumberMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('normalized_text')) {
      context.handle(
        _normalizedTextMeta,
        normalizedText.isAcceptableOrUnknown(
          data['normalized_text']!,
          _normalizedTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    translationId,
    bookId,
    chapterNumber,
    verseNumber,
  };
  @override
  CachedVerse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedVerse(
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_number'],
      )!,
      verseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_number'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      )!,
      normalizedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_text'],
      )!,
    );
  }

  @override
  $CachedVersesTable createAlias(String alias) {
    return $CachedVersesTable(attachedDatabase, alias);
  }
}

class CachedVerse extends DataClass implements Insertable<CachedVerse> {
  final String translationId;
  final String bookId;
  final int chapterNumber;
  final int verseNumber;
  final String textContent;
  final String normalizedText;
  const CachedVerse({
    required this.translationId,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.textContent,
    required this.normalizedText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['translation_id'] = Variable<String>(translationId);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['verse_number'] = Variable<int>(verseNumber);
    map['text_content'] = Variable<String>(textContent);
    map['normalized_text'] = Variable<String>(normalizedText);
    return map;
  }

  CachedVersesCompanion toCompanion(bool nullToAbsent) {
    return CachedVersesCompanion(
      translationId: Value(translationId),
      bookId: Value(bookId),
      chapterNumber: Value(chapterNumber),
      verseNumber: Value(verseNumber),
      textContent: Value(textContent),
      normalizedText: Value(normalizedText),
    );
  }

  factory CachedVerse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedVerse(
      translationId: serializer.fromJson<String>(json['translationId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      verseNumber: serializer.fromJson<int>(json['verseNumber']),
      textContent: serializer.fromJson<String>(json['textContent']),
      normalizedText: serializer.fromJson<String>(json['normalizedText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'translationId': serializer.toJson<String>(translationId),
      'bookId': serializer.toJson<String>(bookId),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'verseNumber': serializer.toJson<int>(verseNumber),
      'textContent': serializer.toJson<String>(textContent),
      'normalizedText': serializer.toJson<String>(normalizedText),
    };
  }

  CachedVerse copyWith({
    String? translationId,
    String? bookId,
    int? chapterNumber,
    int? verseNumber,
    String? textContent,
    String? normalizedText,
  }) => CachedVerse(
    translationId: translationId ?? this.translationId,
    bookId: bookId ?? this.bookId,
    chapterNumber: chapterNumber ?? this.chapterNumber,
    verseNumber: verseNumber ?? this.verseNumber,
    textContent: textContent ?? this.textContent,
    normalizedText: normalizedText ?? this.normalizedText,
  );
  CachedVerse copyWithCompanion(CachedVersesCompanion data) {
    return CachedVerse(
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      verseNumber: data.verseNumber.present
          ? data.verseNumber.value
          : this.verseNumber,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      normalizedText: data.normalizedText.present
          ? data.normalizedText.value
          : this.normalizedText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedVerse(')
          ..write('translationId: $translationId, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('textContent: $textContent, ')
          ..write('normalizedText: $normalizedText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    translationId,
    bookId,
    chapterNumber,
    verseNumber,
    textContent,
    normalizedText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedVerse &&
          other.translationId == this.translationId &&
          other.bookId == this.bookId &&
          other.chapterNumber == this.chapterNumber &&
          other.verseNumber == this.verseNumber &&
          other.textContent == this.textContent &&
          other.normalizedText == this.normalizedText);
}

class CachedVersesCompanion extends UpdateCompanion<CachedVerse> {
  final Value<String> translationId;
  final Value<String> bookId;
  final Value<int> chapterNumber;
  final Value<int> verseNumber;
  final Value<String> textContent;
  final Value<String> normalizedText;
  final Value<int> rowid;
  const CachedVersesCompanion({
    this.translationId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.verseNumber = const Value.absent(),
    this.textContent = const Value.absent(),
    this.normalizedText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedVersesCompanion.insert({
    required String translationId,
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
    required String textContent,
    required String normalizedText,
    this.rowid = const Value.absent(),
  }) : translationId = Value(translationId),
       bookId = Value(bookId),
       chapterNumber = Value(chapterNumber),
       verseNumber = Value(verseNumber),
       textContent = Value(textContent),
       normalizedText = Value(normalizedText);
  static Insertable<CachedVerse> custom({
    Expression<String>? translationId,
    Expression<String>? bookId,
    Expression<int>? chapterNumber,
    Expression<int>? verseNumber,
    Expression<String>? textContent,
    Expression<String>? normalizedText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (translationId != null) 'translation_id': translationId,
      if (bookId != null) 'book_id': bookId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (verseNumber != null) 'verse_number': verseNumber,
      if (textContent != null) 'text_content': textContent,
      if (normalizedText != null) 'normalized_text': normalizedText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedVersesCompanion copyWith({
    Value<String>? translationId,
    Value<String>? bookId,
    Value<int>? chapterNumber,
    Value<int>? verseNumber,
    Value<String>? textContent,
    Value<String>? normalizedText,
    Value<int>? rowid,
  }) {
    return CachedVersesCompanion(
      translationId: translationId ?? this.translationId,
      bookId: bookId ?? this.bookId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      textContent: textContent ?? this.textContent,
      normalizedText: normalizedText ?? this.normalizedText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (translationId.present) {
      map['translation_id'] = Variable<String>(translationId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (verseNumber.present) {
      map['verse_number'] = Variable<int>(verseNumber.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (normalizedText.present) {
      map['normalized_text'] = Variable<String>(normalizedText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedVersesCompanion(')
          ..write('translationId: $translationId, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('textContent: $textContent, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VerseAnnotationsTable extends VerseAnnotations
    with TableInfo<$VerseAnnotationsTable, VerseAnnotationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VerseAnnotationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterNumberMeta = const VerificationMeta(
    'chapterNumber',
  );
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
    'chapter_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseNumberMeta = const VerificationMeta(
    'verseNumber',
  );
  @override
  late final GeneratedColumn<int> verseNumber = GeneratedColumn<int>(
    'verse_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _highlightColorMeta = const VerificationMeta(
    'highlightColor',
  );
  @override
  late final GeneratedColumn<String> highlightColor = GeneratedColumn<String>(
    'highlight_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteTextMeta = const VerificationMeta(
    'noteText',
  );
  @override
  late final GeneratedColumn<String> noteText = GeneratedColumn<String>(
    'note_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsCsvMeta = const VerificationMeta(
    'tagsCsv',
  );
  @override
  late final GeneratedColumn<String> tagsCsv = GeneratedColumn<String>(
    'tags_csv',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originTranslationIdMeta =
      const VerificationMeta('originTranslationId');
  @override
  late final GeneratedColumn<String> originTranslationId =
      GeneratedColumn<String>(
        'origin_translation_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _bookNameSnapshotMeta = const VerificationMeta(
    'bookNameSnapshot',
  );
  @override
  late final GeneratedColumn<String> bookNameSnapshot = GeneratedColumn<String>(
    'book_name_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseTextSnapshotMeta = const VerificationMeta(
    'verseTextSnapshot',
  );
  @override
  late final GeneratedColumn<String> verseTextSnapshot =
      GeneratedColumn<String>(
        'verse_text_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapterNumber,
    verseNumber,
    isFavorite,
    highlightColor,
    noteText,
    tagsCsv,
    originTranslationId,
    bookNameSnapshot,
    verseTextSnapshot,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verse_annotations';
  @override
  VerificationContext validateIntegrity(
    Insertable<VerseAnnotationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
        _chapterNumberMeta,
        chapterNumber.isAcceptableOrUnknown(
          data['chapter_number']!,
          _chapterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('verse_number')) {
      context.handle(
        _verseNumberMeta,
        verseNumber.isAcceptableOrUnknown(
          data['verse_number']!,
          _verseNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verseNumberMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('highlight_color')) {
      context.handle(
        _highlightColorMeta,
        highlightColor.isAcceptableOrUnknown(
          data['highlight_color']!,
          _highlightColorMeta,
        ),
      );
    }
    if (data.containsKey('note_text')) {
      context.handle(
        _noteTextMeta,
        noteText.isAcceptableOrUnknown(data['note_text']!, _noteTextMeta),
      );
    }
    if (data.containsKey('tags_csv')) {
      context.handle(
        _tagsCsvMeta,
        tagsCsv.isAcceptableOrUnknown(data['tags_csv']!, _tagsCsvMeta),
      );
    }
    if (data.containsKey('origin_translation_id')) {
      context.handle(
        _originTranslationIdMeta,
        originTranslationId.isAcceptableOrUnknown(
          data['origin_translation_id']!,
          _originTranslationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originTranslationIdMeta);
    }
    if (data.containsKey('book_name_snapshot')) {
      context.handle(
        _bookNameSnapshotMeta,
        bookNameSnapshot.isAcceptableOrUnknown(
          data['book_name_snapshot']!,
          _bookNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bookNameSnapshotMeta);
    }
    if (data.containsKey('verse_text_snapshot')) {
      context.handle(
        _verseTextSnapshotMeta,
        verseTextSnapshot.isAcceptableOrUnknown(
          data['verse_text_snapshot']!,
          _verseTextSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verseTextSnapshotMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VerseAnnotationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseAnnotationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_number'],
      )!,
      verseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_number'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      highlightColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}highlight_color'],
      ),
      noteText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_text'],
      ),
      tagsCsv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_csv'],
      ),
      originTranslationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_translation_id'],
      )!,
      bookNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_name_snapshot'],
      )!,
      verseTextSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verse_text_snapshot'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $VerseAnnotationsTable createAlias(String alias) {
    return $VerseAnnotationsTable(attachedDatabase, alias);
  }
}

class VerseAnnotationRow extends DataClass
    implements Insertable<VerseAnnotationRow> {
  final String id;
  final String bookId;
  final int chapterNumber;
  final int verseNumber;
  final bool isFavorite;
  final String? highlightColor;
  final String? noteText;
  final String? tagsCsv;
  final String originTranslationId;
  final String bookNameSnapshot;
  final String verseTextSnapshot;
  final int createdAtMs;
  final int updatedAtMs;
  const VerseAnnotationRow({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.isFavorite,
    this.highlightColor,
    this.noteText,
    this.tagsCsv,
    required this.originTranslationId,
    required this.bookNameSnapshot,
    required this.verseTextSnapshot,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['verse_number'] = Variable<int>(verseNumber);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || highlightColor != null) {
      map['highlight_color'] = Variable<String>(highlightColor);
    }
    if (!nullToAbsent || noteText != null) {
      map['note_text'] = Variable<String>(noteText);
    }
    if (!nullToAbsent || tagsCsv != null) {
      map['tags_csv'] = Variable<String>(tagsCsv);
    }
    map['origin_translation_id'] = Variable<String>(originTranslationId);
    map['book_name_snapshot'] = Variable<String>(bookNameSnapshot);
    map['verse_text_snapshot'] = Variable<String>(verseTextSnapshot);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  VerseAnnotationsCompanion toCompanion(bool nullToAbsent) {
    return VerseAnnotationsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterNumber: Value(chapterNumber),
      verseNumber: Value(verseNumber),
      isFavorite: Value(isFavorite),
      highlightColor: highlightColor == null && nullToAbsent
          ? const Value.absent()
          : Value(highlightColor),
      noteText: noteText == null && nullToAbsent
          ? const Value.absent()
          : Value(noteText),
      tagsCsv: tagsCsv == null && nullToAbsent
          ? const Value.absent()
          : Value(tagsCsv),
      originTranslationId: Value(originTranslationId),
      bookNameSnapshot: Value(bookNameSnapshot),
      verseTextSnapshot: Value(verseTextSnapshot),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory VerseAnnotationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseAnnotationRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      verseNumber: serializer.fromJson<int>(json['verseNumber']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      highlightColor: serializer.fromJson<String?>(json['highlightColor']),
      noteText: serializer.fromJson<String?>(json['noteText']),
      tagsCsv: serializer.fromJson<String?>(json['tagsCsv']),
      originTranslationId: serializer.fromJson<String>(
        json['originTranslationId'],
      ),
      bookNameSnapshot: serializer.fromJson<String>(json['bookNameSnapshot']),
      verseTextSnapshot: serializer.fromJson<String>(json['verseTextSnapshot']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'verseNumber': serializer.toJson<int>(verseNumber),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'highlightColor': serializer.toJson<String?>(highlightColor),
      'noteText': serializer.toJson<String?>(noteText),
      'tagsCsv': serializer.toJson<String?>(tagsCsv),
      'originTranslationId': serializer.toJson<String>(originTranslationId),
      'bookNameSnapshot': serializer.toJson<String>(bookNameSnapshot),
      'verseTextSnapshot': serializer.toJson<String>(verseTextSnapshot),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  VerseAnnotationRow copyWith({
    String? id,
    String? bookId,
    int? chapterNumber,
    int? verseNumber,
    bool? isFavorite,
    Value<String?> highlightColor = const Value.absent(),
    Value<String?> noteText = const Value.absent(),
    Value<String?> tagsCsv = const Value.absent(),
    String? originTranslationId,
    String? bookNameSnapshot,
    String? verseTextSnapshot,
    int? createdAtMs,
    int? updatedAtMs,
  }) => VerseAnnotationRow(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapterNumber: chapterNumber ?? this.chapterNumber,
    verseNumber: verseNumber ?? this.verseNumber,
    isFavorite: isFavorite ?? this.isFavorite,
    highlightColor: highlightColor.present
        ? highlightColor.value
        : this.highlightColor,
    noteText: noteText.present ? noteText.value : this.noteText,
    tagsCsv: tagsCsv.present ? tagsCsv.value : this.tagsCsv,
    originTranslationId: originTranslationId ?? this.originTranslationId,
    bookNameSnapshot: bookNameSnapshot ?? this.bookNameSnapshot,
    verseTextSnapshot: verseTextSnapshot ?? this.verseTextSnapshot,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  VerseAnnotationRow copyWithCompanion(VerseAnnotationsCompanion data) {
    return VerseAnnotationRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      verseNumber: data.verseNumber.present
          ? data.verseNumber.value
          : this.verseNumber,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      highlightColor: data.highlightColor.present
          ? data.highlightColor.value
          : this.highlightColor,
      noteText: data.noteText.present ? data.noteText.value : this.noteText,
      tagsCsv: data.tagsCsv.present ? data.tagsCsv.value : this.tagsCsv,
      originTranslationId: data.originTranslationId.present
          ? data.originTranslationId.value
          : this.originTranslationId,
      bookNameSnapshot: data.bookNameSnapshot.present
          ? data.bookNameSnapshot.value
          : this.bookNameSnapshot,
      verseTextSnapshot: data.verseTextSnapshot.present
          ? data.verseTextSnapshot.value
          : this.verseTextSnapshot,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseAnnotationRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('highlightColor: $highlightColor, ')
          ..write('noteText: $noteText, ')
          ..write('tagsCsv: $tagsCsv, ')
          ..write('originTranslationId: $originTranslationId, ')
          ..write('bookNameSnapshot: $bookNameSnapshot, ')
          ..write('verseTextSnapshot: $verseTextSnapshot, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    chapterNumber,
    verseNumber,
    isFavorite,
    highlightColor,
    noteText,
    tagsCsv,
    originTranslationId,
    bookNameSnapshot,
    verseTextSnapshot,
    createdAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseAnnotationRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterNumber == this.chapterNumber &&
          other.verseNumber == this.verseNumber &&
          other.isFavorite == this.isFavorite &&
          other.highlightColor == this.highlightColor &&
          other.noteText == this.noteText &&
          other.tagsCsv == this.tagsCsv &&
          other.originTranslationId == this.originTranslationId &&
          other.bookNameSnapshot == this.bookNameSnapshot &&
          other.verseTextSnapshot == this.verseTextSnapshot &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class VerseAnnotationsCompanion extends UpdateCompanion<VerseAnnotationRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> chapterNumber;
  final Value<int> verseNumber;
  final Value<bool> isFavorite;
  final Value<String?> highlightColor;
  final Value<String?> noteText;
  final Value<String?> tagsCsv;
  final Value<String> originTranslationId;
  final Value<String> bookNameSnapshot;
  final Value<String> verseTextSnapshot;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const VerseAnnotationsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.verseNumber = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.highlightColor = const Value.absent(),
    this.noteText = const Value.absent(),
    this.tagsCsv = const Value.absent(),
    this.originTranslationId = const Value.absent(),
    this.bookNameSnapshot = const Value.absent(),
    this.verseTextSnapshot = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VerseAnnotationsCompanion.insert({
    required String id,
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
    this.isFavorite = const Value.absent(),
    this.highlightColor = const Value.absent(),
    this.noteText = const Value.absent(),
    this.tagsCsv = const Value.absent(),
    required String originTranslationId,
    required String bookNameSnapshot,
    required String verseTextSnapshot,
    required int createdAtMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       chapterNumber = Value(chapterNumber),
       verseNumber = Value(verseNumber),
       originTranslationId = Value(originTranslationId),
       bookNameSnapshot = Value(bookNameSnapshot),
       verseTextSnapshot = Value(verseTextSnapshot),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<VerseAnnotationRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? chapterNumber,
    Expression<int>? verseNumber,
    Expression<bool>? isFavorite,
    Expression<String>? highlightColor,
    Expression<String>? noteText,
    Expression<String>? tagsCsv,
    Expression<String>? originTranslationId,
    Expression<String>? bookNameSnapshot,
    Expression<String>? verseTextSnapshot,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (verseNumber != null) 'verse_number': verseNumber,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (highlightColor != null) 'highlight_color': highlightColor,
      if (noteText != null) 'note_text': noteText,
      if (tagsCsv != null) 'tags_csv': tagsCsv,
      if (originTranslationId != null)
        'origin_translation_id': originTranslationId,
      if (bookNameSnapshot != null) 'book_name_snapshot': bookNameSnapshot,
      if (verseTextSnapshot != null) 'verse_text_snapshot': verseTextSnapshot,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VerseAnnotationsCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<int>? chapterNumber,
    Value<int>? verseNumber,
    Value<bool>? isFavorite,
    Value<String?>? highlightColor,
    Value<String?>? noteText,
    Value<String?>? tagsCsv,
    Value<String>? originTranslationId,
    Value<String>? bookNameSnapshot,
    Value<String>? verseTextSnapshot,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return VerseAnnotationsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      isFavorite: isFavorite ?? this.isFavorite,
      highlightColor: highlightColor ?? this.highlightColor,
      noteText: noteText ?? this.noteText,
      tagsCsv: tagsCsv ?? this.tagsCsv,
      originTranslationId: originTranslationId ?? this.originTranslationId,
      bookNameSnapshot: bookNameSnapshot ?? this.bookNameSnapshot,
      verseTextSnapshot: verseTextSnapshot ?? this.verseTextSnapshot,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (verseNumber.present) {
      map['verse_number'] = Variable<int>(verseNumber.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (highlightColor.present) {
      map['highlight_color'] = Variable<String>(highlightColor.value);
    }
    if (noteText.present) {
      map['note_text'] = Variable<String>(noteText.value);
    }
    if (tagsCsv.present) {
      map['tags_csv'] = Variable<String>(tagsCsv.value);
    }
    if (originTranslationId.present) {
      map['origin_translation_id'] = Variable<String>(
        originTranslationId.value,
      );
    }
    if (bookNameSnapshot.present) {
      map['book_name_snapshot'] = Variable<String>(bookNameSnapshot.value);
    }
    if (verseTextSnapshot.present) {
      map['verse_text_snapshot'] = Variable<String>(verseTextSnapshot.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VerseAnnotationsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('highlightColor: $highlightColor, ')
          ..write('noteText: $noteText, ')
          ..write('tagsCsv: $tagsCsv, ')
          ..write('originTranslationId: $originTranslationId, ')
          ..write('bookNameSnapshot: $bookNameSnapshot, ')
          ..write('verseTextSnapshot: $verseTextSnapshot, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingHistoryTable extends ReadingHistory
    with TableInfo<$ReadingHistoryTable, ReadingHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterNumberMeta = const VerificationMeta(
    'chapterNumber',
  );
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
    'chapter_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationIdMeta = const VerificationMeta(
    'translationId',
  );
  @override
  late final GeneratedColumn<String> translationId = GeneratedColumn<String>(
    'translation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingDateIsoMeta = const VerificationMeta(
    'readingDateIso',
  );
  @override
  late final GeneratedColumn<String> readingDateIso = GeneratedColumn<String>(
    'reading_date_iso',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMsMeta = const VerificationMeta(
    'readAtMs',
  );
  @override
  late final GeneratedColumn<int> readAtMs = GeneratedColumn<int>(
    'read_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('daily_plan'),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapterNumber,
    translationId,
    readingDateIso,
    readAtMs,
    durationSeconds,
    source,
    planId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
        _chapterNumberMeta,
        chapterNumber.isAcceptableOrUnknown(
          data['chapter_number']!,
          _chapterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('translation_id')) {
      context.handle(
        _translationIdMeta,
        translationId.isAcceptableOrUnknown(
          data['translation_id']!,
          _translationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationIdMeta);
    }
    if (data.containsKey('reading_date_iso')) {
      context.handle(
        _readingDateIsoMeta,
        readingDateIso.isAcceptableOrUnknown(
          data['reading_date_iso']!,
          _readingDateIsoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readingDateIsoMeta);
    }
    if (data.containsKey('read_at_ms')) {
      context.handle(
        _readAtMsMeta,
        readAtMs.isAcceptableOrUnknown(data['read_at_ms']!, _readAtMsMeta),
      );
    } else if (isInserting) {
      context.missing(_readAtMsMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_number'],
      )!,
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_id'],
      )!,
      readingDateIso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_date_iso'],
      )!,
      readAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}read_at_ms'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      ),
    );
  }

  @override
  $ReadingHistoryTable createAlias(String alias) {
    return $ReadingHistoryTable(attachedDatabase, alias);
  }
}

class ReadingHistoryData extends DataClass
    implements Insertable<ReadingHistoryData> {
  final int id;
  final String bookId;
  final int chapterNumber;
  final String translationId;
  final String readingDateIso;
  final int readAtMs;
  final int durationSeconds;
  final String source;
  final String? planId;
  const ReadingHistoryData({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.translationId,
    required this.readingDateIso,
    required this.readAtMs,
    required this.durationSeconds,
    required this.source,
    this.planId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['translation_id'] = Variable<String>(translationId);
    map['reading_date_iso'] = Variable<String>(readingDateIso);
    map['read_at_ms'] = Variable<int>(readAtMs);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<String>(planId);
    }
    return map;
  }

  ReadingHistoryCompanion toCompanion(bool nullToAbsent) {
    return ReadingHistoryCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterNumber: Value(chapterNumber),
      translationId: Value(translationId),
      readingDateIso: Value(readingDateIso),
      readAtMs: Value(readAtMs),
      durationSeconds: Value(durationSeconds),
      source: Value(source),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
    );
  }

  factory ReadingHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingHistoryData(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      translationId: serializer.fromJson<String>(json['translationId']),
      readingDateIso: serializer.fromJson<String>(json['readingDateIso']),
      readAtMs: serializer.fromJson<int>(json['readAtMs']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      source: serializer.fromJson<String>(json['source']),
      planId: serializer.fromJson<String?>(json['planId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<String>(bookId),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'translationId': serializer.toJson<String>(translationId),
      'readingDateIso': serializer.toJson<String>(readingDateIso),
      'readAtMs': serializer.toJson<int>(readAtMs),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'source': serializer.toJson<String>(source),
      'planId': serializer.toJson<String?>(planId),
    };
  }

  ReadingHistoryData copyWith({
    int? id,
    String? bookId,
    int? chapterNumber,
    String? translationId,
    String? readingDateIso,
    int? readAtMs,
    int? durationSeconds,
    String? source,
    Value<String?> planId = const Value.absent(),
  }) => ReadingHistoryData(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapterNumber: chapterNumber ?? this.chapterNumber,
    translationId: translationId ?? this.translationId,
    readingDateIso: readingDateIso ?? this.readingDateIso,
    readAtMs: readAtMs ?? this.readAtMs,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    source: source ?? this.source,
    planId: planId.present ? planId.value : this.planId,
  );
  ReadingHistoryData copyWithCompanion(ReadingHistoryCompanion data) {
    return ReadingHistoryData(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      readingDateIso: data.readingDateIso.present
          ? data.readingDateIso.value
          : this.readingDateIso,
      readAtMs: data.readAtMs.present ? data.readAtMs.value : this.readAtMs,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      source: data.source.present ? data.source.value : this.source,
      planId: data.planId.present ? data.planId.value : this.planId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingHistoryData(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('translationId: $translationId, ')
          ..write('readingDateIso: $readingDateIso, ')
          ..write('readAtMs: $readAtMs, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('source: $source, ')
          ..write('planId: $planId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    chapterNumber,
    translationId,
    readingDateIso,
    readAtMs,
    durationSeconds,
    source,
    planId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingHistoryData &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterNumber == this.chapterNumber &&
          other.translationId == this.translationId &&
          other.readingDateIso == this.readingDateIso &&
          other.readAtMs == this.readAtMs &&
          other.durationSeconds == this.durationSeconds &&
          other.source == this.source &&
          other.planId == this.planId);
}

class ReadingHistoryCompanion extends UpdateCompanion<ReadingHistoryData> {
  final Value<int> id;
  final Value<String> bookId;
  final Value<int> chapterNumber;
  final Value<String> translationId;
  final Value<String> readingDateIso;
  final Value<int> readAtMs;
  final Value<int> durationSeconds;
  final Value<String> source;
  final Value<String?> planId;
  const ReadingHistoryCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.translationId = const Value.absent(),
    this.readingDateIso = const Value.absent(),
    this.readAtMs = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.source = const Value.absent(),
    this.planId = const Value.absent(),
  });
  ReadingHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String bookId,
    required int chapterNumber,
    required String translationId,
    required String readingDateIso,
    required int readAtMs,
    this.durationSeconds = const Value.absent(),
    this.source = const Value.absent(),
    this.planId = const Value.absent(),
  }) : bookId = Value(bookId),
       chapterNumber = Value(chapterNumber),
       translationId = Value(translationId),
       readingDateIso = Value(readingDateIso),
       readAtMs = Value(readAtMs);
  static Insertable<ReadingHistoryData> custom({
    Expression<int>? id,
    Expression<String>? bookId,
    Expression<int>? chapterNumber,
    Expression<String>? translationId,
    Expression<String>? readingDateIso,
    Expression<int>? readAtMs,
    Expression<int>? durationSeconds,
    Expression<String>? source,
    Expression<String>? planId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (translationId != null) 'translation_id': translationId,
      if (readingDateIso != null) 'reading_date_iso': readingDateIso,
      if (readAtMs != null) 'read_at_ms': readAtMs,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (source != null) 'source': source,
      if (planId != null) 'plan_id': planId,
    });
  }

  ReadingHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? bookId,
    Value<int>? chapterNumber,
    Value<String>? translationId,
    Value<String>? readingDateIso,
    Value<int>? readAtMs,
    Value<int>? durationSeconds,
    Value<String>? source,
    Value<String?>? planId,
  }) {
    return ReadingHistoryCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      translationId: translationId ?? this.translationId,
      readingDateIso: readingDateIso ?? this.readingDateIso,
      readAtMs: readAtMs ?? this.readAtMs,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      source: source ?? this.source,
      planId: planId ?? this.planId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (translationId.present) {
      map['translation_id'] = Variable<String>(translationId.value);
    }
    if (readingDateIso.present) {
      map['reading_date_iso'] = Variable<String>(readingDateIso.value);
    }
    if (readAtMs.present) {
      map['read_at_ms'] = Variable<int>(readAtMs.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingHistoryCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('translationId: $translationId, ')
          ..write('readingDateIso: $readingDateIso, ')
          ..write('readAtMs: $readAtMs, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('source: $source, ')
          ..write('planId: $planId')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressStateTable extends ReadingProgressState
    with TableInfo<$ReadingProgressStateTable, ReadingProgressStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationIdMeta = const VerificationMeta(
    'translationId',
  );
  @override
  late final GeneratedColumn<String> translationId = GeneratedColumn<String>(
    'translation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterNumberMeta = const VerificationMeta(
    'chapterNumber',
  );
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
    'chapter_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseScrollOffsetMeta = const VerificationMeta(
    'verseScrollOffset',
  );
  @override
  late final GeneratedColumn<int> verseScrollOffset = GeneratedColumn<int>(
    'verse_scroll_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    translationId,
    bookId,
    chapterNumber,
    verseScrollOffset,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('translation_id')) {
      context.handle(
        _translationIdMeta,
        translationId.isAcceptableOrUnknown(
          data['translation_id']!,
          _translationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
        _chapterNumberMeta,
        chapterNumber.isAcceptableOrUnknown(
          data['chapter_number']!,
          _chapterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('verse_scroll_offset')) {
      context.handle(
        _verseScrollOffsetMeta,
        verseScrollOffset.isAcceptableOrUnknown(
          data['verse_scroll_offset']!,
          _verseScrollOffsetMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ReadingProgressStateData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressStateData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      chapterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_number'],
      )!,
      verseScrollOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_scroll_offset'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $ReadingProgressStateTable createAlias(String alias) {
    return $ReadingProgressStateTable(attachedDatabase, alias);
  }
}

class ReadingProgressStateData extends DataClass
    implements Insertable<ReadingProgressStateData> {
  final String key;
  final String translationId;
  final String bookId;
  final int chapterNumber;
  final int verseScrollOffset;
  final int updatedAtMs;
  const ReadingProgressStateData({
    required this.key,
    required this.translationId,
    required this.bookId,
    required this.chapterNumber,
    required this.verseScrollOffset,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['translation_id'] = Variable<String>(translationId);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['verse_scroll_offset'] = Variable<int>(verseScrollOffset);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  ReadingProgressStateCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressStateCompanion(
      key: Value(key),
      translationId: Value(translationId),
      bookId: Value(bookId),
      chapterNumber: Value(chapterNumber),
      verseScrollOffset: Value(verseScrollOffset),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory ReadingProgressStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressStateData(
      key: serializer.fromJson<String>(json['key']),
      translationId: serializer.fromJson<String>(json['translationId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      verseScrollOffset: serializer.fromJson<int>(json['verseScrollOffset']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'translationId': serializer.toJson<String>(translationId),
      'bookId': serializer.toJson<String>(bookId),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'verseScrollOffset': serializer.toJson<int>(verseScrollOffset),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  ReadingProgressStateData copyWith({
    String? key,
    String? translationId,
    String? bookId,
    int? chapterNumber,
    int? verseScrollOffset,
    int? updatedAtMs,
  }) => ReadingProgressStateData(
    key: key ?? this.key,
    translationId: translationId ?? this.translationId,
    bookId: bookId ?? this.bookId,
    chapterNumber: chapterNumber ?? this.chapterNumber,
    verseScrollOffset: verseScrollOffset ?? this.verseScrollOffset,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  ReadingProgressStateData copyWithCompanion(
    ReadingProgressStateCompanion data,
  ) {
    return ReadingProgressStateData(
      key: data.key.present ? data.key.value : this.key,
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      verseScrollOffset: data.verseScrollOffset.present
          ? data.verseScrollOffset.value
          : this.verseScrollOffset,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressStateData(')
          ..write('key: $key, ')
          ..write('translationId: $translationId, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('verseScrollOffset: $verseScrollOffset, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    translationId,
    bookId,
    chapterNumber,
    verseScrollOffset,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressStateData &&
          other.key == this.key &&
          other.translationId == this.translationId &&
          other.bookId == this.bookId &&
          other.chapterNumber == this.chapterNumber &&
          other.verseScrollOffset == this.verseScrollOffset &&
          other.updatedAtMs == this.updatedAtMs);
}

class ReadingProgressStateCompanion
    extends UpdateCompanion<ReadingProgressStateData> {
  final Value<String> key;
  final Value<String> translationId;
  final Value<String> bookId;
  final Value<int> chapterNumber;
  final Value<int> verseScrollOffset;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const ReadingProgressStateCompanion({
    this.key = const Value.absent(),
    this.translationId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.verseScrollOffset = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressStateCompanion.insert({
    required String key,
    required String translationId,
    required String bookId,
    required int chapterNumber,
    this.verseScrollOffset = const Value.absent(),
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       translationId = Value(translationId),
       bookId = Value(bookId),
       chapterNumber = Value(chapterNumber),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<ReadingProgressStateData> custom({
    Expression<String>? key,
    Expression<String>? translationId,
    Expression<String>? bookId,
    Expression<int>? chapterNumber,
    Expression<int>? verseScrollOffset,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (translationId != null) 'translation_id': translationId,
      if (bookId != null) 'book_id': bookId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (verseScrollOffset != null) 'verse_scroll_offset': verseScrollOffset,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressStateCompanion copyWith({
    Value<String>? key,
    Value<String>? translationId,
    Value<String>? bookId,
    Value<int>? chapterNumber,
    Value<int>? verseScrollOffset,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return ReadingProgressStateCompanion(
      key: key ?? this.key,
      translationId: translationId ?? this.translationId,
      bookId: bookId ?? this.bookId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      verseScrollOffset: verseScrollOffset ?? this.verseScrollOffset,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (translationId.present) {
      map['translation_id'] = Variable<String>(translationId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (verseScrollOffset.present) {
      map['verse_scroll_offset'] = Variable<int>(verseScrollOffset.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressStateCompanion(')
          ..write('key: $key, ')
          ..write('translationId: $translationId, ')
          ..write('bookId: $bookId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('verseScrollOffset: $verseScrollOffset, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserReadingPlansTable extends UserReadingPlans
    with TableInfo<$UserReadingPlansTable, UserReadingPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserReadingPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMsMeta = const VerificationMeta(
    'startedAtMs',
  );
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
    'started_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMsMeta = const VerificationMeta(
    'completedAtMs',
  );
  @override
  late final GeneratedColumn<int> completedAtMs = GeneratedColumn<int>(
    'completed_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedDaysJsonMeta = const VerificationMeta(
    'completedDaysJson',
  );
  @override
  late final GeneratedColumn<String> completedDaysJson =
      GeneratedColumn<String>(
        'completed_days_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    planId,
    status,
    startedAtMs,
    completedAtMs,
    completedDaysJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_reading_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserReadingPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
        _startedAtMsMeta,
        startedAtMs.isAcceptableOrUnknown(
          data['started_at_ms']!,
          _startedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('completed_at_ms')) {
      context.handle(
        _completedAtMsMeta,
        completedAtMs.isAcceptableOrUnknown(
          data['completed_at_ms']!,
          _completedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('completed_days_json')) {
      context.handle(
        _completedDaysJsonMeta,
        completedDaysJson.isAcceptableOrUnknown(
          data['completed_days_json']!,
          _completedDaysJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {planId};
  @override
  UserReadingPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserReadingPlan(
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_ms'],
      )!,
      completedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_ms'],
      ),
      completedDaysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_days_json'],
      )!,
    );
  }

  @override
  $UserReadingPlansTable createAlias(String alias) {
    return $UserReadingPlansTable(attachedDatabase, alias);
  }
}

class UserReadingPlan extends DataClass implements Insertable<UserReadingPlan> {
  final String planId;
  final String status;
  final int startedAtMs;
  final int? completedAtMs;
  final String completedDaysJson;
  const UserReadingPlan({
    required this.planId,
    required this.status,
    required this.startedAtMs,
    this.completedAtMs,
    required this.completedDaysJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plan_id'] = Variable<String>(planId);
    map['status'] = Variable<String>(status);
    map['started_at_ms'] = Variable<int>(startedAtMs);
    if (!nullToAbsent || completedAtMs != null) {
      map['completed_at_ms'] = Variable<int>(completedAtMs);
    }
    map['completed_days_json'] = Variable<String>(completedDaysJson);
    return map;
  }

  UserReadingPlansCompanion toCompanion(bool nullToAbsent) {
    return UserReadingPlansCompanion(
      planId: Value(planId),
      status: Value(status),
      startedAtMs: Value(startedAtMs),
      completedAtMs: completedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtMs),
      completedDaysJson: Value(completedDaysJson),
    );
  }

  factory UserReadingPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserReadingPlan(
      planId: serializer.fromJson<String>(json['planId']),
      status: serializer.fromJson<String>(json['status']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      completedAtMs: serializer.fromJson<int?>(json['completedAtMs']),
      completedDaysJson: serializer.fromJson<String>(json['completedDaysJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'planId': serializer.toJson<String>(planId),
      'status': serializer.toJson<String>(status),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'completedAtMs': serializer.toJson<int?>(completedAtMs),
      'completedDaysJson': serializer.toJson<String>(completedDaysJson),
    };
  }

  UserReadingPlan copyWith({
    String? planId,
    String? status,
    int? startedAtMs,
    Value<int?> completedAtMs = const Value.absent(),
    String? completedDaysJson,
  }) => UserReadingPlan(
    planId: planId ?? this.planId,
    status: status ?? this.status,
    startedAtMs: startedAtMs ?? this.startedAtMs,
    completedAtMs: completedAtMs.present
        ? completedAtMs.value
        : this.completedAtMs,
    completedDaysJson: completedDaysJson ?? this.completedDaysJson,
  );
  UserReadingPlan copyWithCompanion(UserReadingPlansCompanion data) {
    return UserReadingPlan(
      planId: data.planId.present ? data.planId.value : this.planId,
      status: data.status.present ? data.status.value : this.status,
      startedAtMs: data.startedAtMs.present
          ? data.startedAtMs.value
          : this.startedAtMs,
      completedAtMs: data.completedAtMs.present
          ? data.completedAtMs.value
          : this.completedAtMs,
      completedDaysJson: data.completedDaysJson.present
          ? data.completedDaysJson.value
          : this.completedDaysJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserReadingPlan(')
          ..write('planId: $planId, ')
          ..write('status: $status, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('completedAtMs: $completedAtMs, ')
          ..write('completedDaysJson: $completedDaysJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    planId,
    status,
    startedAtMs,
    completedAtMs,
    completedDaysJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserReadingPlan &&
          other.planId == this.planId &&
          other.status == this.status &&
          other.startedAtMs == this.startedAtMs &&
          other.completedAtMs == this.completedAtMs &&
          other.completedDaysJson == this.completedDaysJson);
}

class UserReadingPlansCompanion extends UpdateCompanion<UserReadingPlan> {
  final Value<String> planId;
  final Value<String> status;
  final Value<int> startedAtMs;
  final Value<int?> completedAtMs;
  final Value<String> completedDaysJson;
  final Value<int> rowid;
  const UserReadingPlansCompanion({
    this.planId = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.completedAtMs = const Value.absent(),
    this.completedDaysJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserReadingPlansCompanion.insert({
    required String planId,
    required String status,
    required int startedAtMs,
    this.completedAtMs = const Value.absent(),
    this.completedDaysJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : planId = Value(planId),
       status = Value(status),
       startedAtMs = Value(startedAtMs);
  static Insertable<UserReadingPlan> custom({
    Expression<String>? planId,
    Expression<String>? status,
    Expression<int>? startedAtMs,
    Expression<int>? completedAtMs,
    Expression<String>? completedDaysJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (planId != null) 'plan_id': planId,
      if (status != null) 'status': status,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (completedAtMs != null) 'completed_at_ms': completedAtMs,
      if (completedDaysJson != null) 'completed_days_json': completedDaysJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserReadingPlansCompanion copyWith({
    Value<String>? planId,
    Value<String>? status,
    Value<int>? startedAtMs,
    Value<int?>? completedAtMs,
    Value<String>? completedDaysJson,
    Value<int>? rowid,
  }) {
    return UserReadingPlansCompanion(
      planId: planId ?? this.planId,
      status: status ?? this.status,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      completedAtMs: completedAtMs ?? this.completedAtMs,
      completedDaysJson: completedDaysJson ?? this.completedDaysJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (completedAtMs.present) {
      map['completed_at_ms'] = Variable<int>(completedAtMs.value);
    }
    if (completedDaysJson.present) {
      map['completed_days_json'] = Variable<String>(completedDaysJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserReadingPlansCompanion(')
          ..write('planId: $planId, ')
          ..write('status: $status, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('completedAtMs: $completedAtMs, ')
          ..write('completedDaysJson: $completedDaysJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedBooksTable cachedBooks = $CachedBooksTable(this);
  late final $CachedChaptersTable cachedChapters = $CachedChaptersTable(this);
  late final $CachedVersesTable cachedVerses = $CachedVersesTable(this);
  late final $VerseAnnotationsTable verseAnnotations = $VerseAnnotationsTable(
    this,
  );
  late final $ReadingHistoryTable readingHistory = $ReadingHistoryTable(this);
  late final $ReadingProgressStateTable readingProgressState =
      $ReadingProgressStateTable(this);
  late final $UserReadingPlansTable userReadingPlans = $UserReadingPlansTable(
    this,
  );
  late final BibleCacheDao bibleCacheDao = BibleCacheDao(this as AppDatabase);
  late final HistoryDao historyDao = HistoryDao(this as AppDatabase);
  late final StudyDao studyDao = StudyDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedBooks,
    cachedChapters,
    cachedVerses,
    verseAnnotations,
    readingHistory,
    readingProgressState,
    userReadingPlans,
  ];
}

typedef $$CachedBooksTableCreateCompanionBuilder =
    CachedBooksCompanion Function({
      required String translationId,
      required String bookId,
      required String name,
      required String normalizedName,
      required int chapterCount,
      required int bookOrder,
      Value<String?> sha256,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$CachedBooksTableUpdateCompanionBuilder =
    CachedBooksCompanion Function({
      Value<String> translationId,
      Value<String> bookId,
      Value<String> name,
      Value<String> normalizedName,
      Value<int> chapterCount,
      Value<int> bookOrder,
      Value<String?> sha256,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$CachedBooksTableFilterComposer
    extends Composer<_$AppDatabase, $CachedBooksTable> {
  $$CachedBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookOrder => $composableBuilder(
    column: $table.bookOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedBooksTable> {
  $$CachedBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookOrder => $composableBuilder(
    column: $table.bookOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedBooksTable> {
  $$CachedBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bookOrder =>
      $composableBuilder(column: $table.bookOrder, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$CachedBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedBooksTable,
          CachedBook,
          $$CachedBooksTableFilterComposer,
          $$CachedBooksTableOrderingComposer,
          $$CachedBooksTableAnnotationComposer,
          $$CachedBooksTableCreateCompanionBuilder,
          $$CachedBooksTableUpdateCompanionBuilder,
          (
            CachedBook,
            BaseReferences<_$AppDatabase, $CachedBooksTable, CachedBook>,
          ),
          CachedBook,
          PrefetchHooks Function()
        > {
  $$CachedBooksTableTableManager(_$AppDatabase db, $CachedBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> translationId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<int> chapterCount = const Value.absent(),
                Value<int> bookOrder = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedBooksCompanion(
                translationId: translationId,
                bookId: bookId,
                name: name,
                normalizedName: normalizedName,
                chapterCount: chapterCount,
                bookOrder: bookOrder,
                sha256: sha256,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String translationId,
                required String bookId,
                required String name,
                required String normalizedName,
                required int chapterCount,
                required int bookOrder,
                Value<String?> sha256 = const Value.absent(),
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => CachedBooksCompanion.insert(
                translationId: translationId,
                bookId: bookId,
                name: name,
                normalizedName: normalizedName,
                chapterCount: chapterCount,
                bookOrder: bookOrder,
                sha256: sha256,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedBooksTable, CachedBook>(table),
                  BaseReferences<_$AppDatabase, $CachedBooksTable, CachedBook>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedBooksTable,
      CachedBook,
      $$CachedBooksTableFilterComposer,
      $$CachedBooksTableOrderingComposer,
      $$CachedBooksTableAnnotationComposer,
      $$CachedBooksTableCreateCompanionBuilder,
      $$CachedBooksTableUpdateCompanionBuilder,
      (
        CachedBook,
        BaseReferences<_$AppDatabase, $CachedBooksTable, CachedBook>,
      ),
      CachedBook,
      PrefetchHooks Function()
    >;
typedef $$CachedChaptersTableCreateCompanionBuilder =
    CachedChaptersCompanion Function({
      required String translationId,
      required String bookId,
      required int chapterNumber,
      required String bookName,
      Value<String?> sha256,
      required int fetchedAtMs,
      Value<int> rowid,
    });
typedef $$CachedChaptersTableUpdateCompanionBuilder =
    CachedChaptersCompanion Function({
      Value<String> translationId,
      Value<String> bookId,
      Value<int> chapterNumber,
      Value<String> bookName,
      Value<String?> sha256,
      Value<int> fetchedAtMs,
      Value<int> rowid,
    });

class $$CachedChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedChaptersTable> {
  $$CachedChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAtMs => $composableBuilder(
    column: $table.fetchedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedChaptersTable> {
  $$CachedChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAtMs => $composableBuilder(
    column: $table.fetchedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedChaptersTable> {
  $$CachedChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get fetchedAtMs => $composableBuilder(
    column: $table.fetchedAtMs,
    builder: (column) => column,
  );
}

class $$CachedChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedChaptersTable,
          CachedChapter,
          $$CachedChaptersTableFilterComposer,
          $$CachedChaptersTableOrderingComposer,
          $$CachedChaptersTableAnnotationComposer,
          $$CachedChaptersTableCreateCompanionBuilder,
          $$CachedChaptersTableUpdateCompanionBuilder,
          (
            CachedChapter,
            BaseReferences<_$AppDatabase, $CachedChaptersTable, CachedChapter>,
          ),
          CachedChapter,
          PrefetchHooks Function()
        > {
  $$CachedChaptersTableTableManager(
    _$AppDatabase db,
    $CachedChaptersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> translationId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> chapterNumber = const Value.absent(),
                Value<String> bookName = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<int> fetchedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedChaptersCompanion(
                translationId: translationId,
                bookId: bookId,
                chapterNumber: chapterNumber,
                bookName: bookName,
                sha256: sha256,
                fetchedAtMs: fetchedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String translationId,
                required String bookId,
                required int chapterNumber,
                required String bookName,
                Value<String?> sha256 = const Value.absent(),
                required int fetchedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => CachedChaptersCompanion.insert(
                translationId: translationId,
                bookId: bookId,
                chapterNumber: chapterNumber,
                bookName: bookName,
                sha256: sha256,
                fetchedAtMs: fetchedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedChaptersTable, CachedChapter>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedChaptersTable,
                    CachedChapter
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedChaptersTable,
      CachedChapter,
      $$CachedChaptersTableFilterComposer,
      $$CachedChaptersTableOrderingComposer,
      $$CachedChaptersTableAnnotationComposer,
      $$CachedChaptersTableCreateCompanionBuilder,
      $$CachedChaptersTableUpdateCompanionBuilder,
      (
        CachedChapter,
        BaseReferences<_$AppDatabase, $CachedChaptersTable, CachedChapter>,
      ),
      CachedChapter,
      PrefetchHooks Function()
    >;
typedef $$CachedVersesTableCreateCompanionBuilder =
    CachedVersesCompanion Function({
      required String translationId,
      required String bookId,
      required int chapterNumber,
      required int verseNumber,
      required String textContent,
      required String normalizedText,
      Value<int> rowid,
    });
typedef $$CachedVersesTableUpdateCompanionBuilder =
    CachedVersesCompanion Function({
      Value<String> translationId,
      Value<String> bookId,
      Value<int> chapterNumber,
      Value<int> verseNumber,
      Value<String> textContent,
      Value<String> normalizedText,
      Value<int> rowid,
    });

class $$CachedVersesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedVersesTable> {
  $$CachedVersesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedVersesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedVersesTable> {
  $$CachedVersesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedVersesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedVersesTable> {
  $$CachedVersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => column,
  );
}

class $$CachedVersesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedVersesTable,
          CachedVerse,
          $$CachedVersesTableFilterComposer,
          $$CachedVersesTableOrderingComposer,
          $$CachedVersesTableAnnotationComposer,
          $$CachedVersesTableCreateCompanionBuilder,
          $$CachedVersesTableUpdateCompanionBuilder,
          (
            CachedVerse,
            BaseReferences<_$AppDatabase, $CachedVersesTable, CachedVerse>,
          ),
          CachedVerse,
          PrefetchHooks Function()
        > {
  $$CachedVersesTableTableManager(_$AppDatabase db, $CachedVersesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedVersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedVersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedVersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> translationId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> chapterNumber = const Value.absent(),
                Value<int> verseNumber = const Value.absent(),
                Value<String> textContent = const Value.absent(),
                Value<String> normalizedText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedVersesCompanion(
                translationId: translationId,
                bookId: bookId,
                chapterNumber: chapterNumber,
                verseNumber: verseNumber,
                textContent: textContent,
                normalizedText: normalizedText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String translationId,
                required String bookId,
                required int chapterNumber,
                required int verseNumber,
                required String textContent,
                required String normalizedText,
                Value<int> rowid = const Value.absent(),
              }) => CachedVersesCompanion.insert(
                translationId: translationId,
                bookId: bookId,
                chapterNumber: chapterNumber,
                verseNumber: verseNumber,
                textContent: textContent,
                normalizedText: normalizedText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedVersesTable, CachedVerse>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedVersesTable,
                    CachedVerse
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedVersesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedVersesTable,
      CachedVerse,
      $$CachedVersesTableFilterComposer,
      $$CachedVersesTableOrderingComposer,
      $$CachedVersesTableAnnotationComposer,
      $$CachedVersesTableCreateCompanionBuilder,
      $$CachedVersesTableUpdateCompanionBuilder,
      (
        CachedVerse,
        BaseReferences<_$AppDatabase, $CachedVersesTable, CachedVerse>,
      ),
      CachedVerse,
      PrefetchHooks Function()
    >;
typedef $$VerseAnnotationsTableCreateCompanionBuilder =
    VerseAnnotationsCompanion Function({
      required String id,
      required String bookId,
      required int chapterNumber,
      required int verseNumber,
      Value<bool> isFavorite,
      Value<String?> highlightColor,
      Value<String?> noteText,
      Value<String?> tagsCsv,
      required String originTranslationId,
      required String bookNameSnapshot,
      required String verseTextSnapshot,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$VerseAnnotationsTableUpdateCompanionBuilder =
    VerseAnnotationsCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<int> chapterNumber,
      Value<int> verseNumber,
      Value<bool> isFavorite,
      Value<String?> highlightColor,
      Value<String?> noteText,
      Value<String?> tagsCsv,
      Value<String> originTranslationId,
      Value<String> bookNameSnapshot,
      Value<String> verseTextSnapshot,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$VerseAnnotationsTableFilterComposer
    extends Composer<_$AppDatabase, $VerseAnnotationsTable> {
  $$VerseAnnotationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get highlightColor => $composableBuilder(
    column: $table.highlightColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsCsv => $composableBuilder(
    column: $table.tagsCsv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originTranslationId => $composableBuilder(
    column: $table.originTranslationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookNameSnapshot => $composableBuilder(
    column: $table.bookNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseTextSnapshot => $composableBuilder(
    column: $table.verseTextSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VerseAnnotationsTableOrderingComposer
    extends Composer<_$AppDatabase, $VerseAnnotationsTable> {
  $$VerseAnnotationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get highlightColor => $composableBuilder(
    column: $table.highlightColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsCsv => $composableBuilder(
    column: $table.tagsCsv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originTranslationId => $composableBuilder(
    column: $table.originTranslationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookNameSnapshot => $composableBuilder(
    column: $table.bookNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseTextSnapshot => $composableBuilder(
    column: $table.verseTextSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VerseAnnotationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VerseAnnotationsTable> {
  $$VerseAnnotationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get highlightColor => $composableBuilder(
    column: $table.highlightColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteText =>
      $composableBuilder(column: $table.noteText, builder: (column) => column);

  GeneratedColumn<String> get tagsCsv =>
      $composableBuilder(column: $table.tagsCsv, builder: (column) => column);

  GeneratedColumn<String> get originTranslationId => $composableBuilder(
    column: $table.originTranslationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookNameSnapshot => $composableBuilder(
    column: $table.bookNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get verseTextSnapshot => $composableBuilder(
    column: $table.verseTextSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$VerseAnnotationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VerseAnnotationsTable,
          VerseAnnotationRow,
          $$VerseAnnotationsTableFilterComposer,
          $$VerseAnnotationsTableOrderingComposer,
          $$VerseAnnotationsTableAnnotationComposer,
          $$VerseAnnotationsTableCreateCompanionBuilder,
          $$VerseAnnotationsTableUpdateCompanionBuilder,
          (
            VerseAnnotationRow,
            BaseReferences<
              _$AppDatabase,
              $VerseAnnotationsTable,
              VerseAnnotationRow
            >,
          ),
          VerseAnnotationRow,
          PrefetchHooks Function()
        > {
  $$VerseAnnotationsTableTableManager(
    _$AppDatabase db,
    $VerseAnnotationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VerseAnnotationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VerseAnnotationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VerseAnnotationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> chapterNumber = const Value.absent(),
                Value<int> verseNumber = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> highlightColor = const Value.absent(),
                Value<String?> noteText = const Value.absent(),
                Value<String?> tagsCsv = const Value.absent(),
                Value<String> originTranslationId = const Value.absent(),
                Value<String> bookNameSnapshot = const Value.absent(),
                Value<String> verseTextSnapshot = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VerseAnnotationsCompanion(
                id: id,
                bookId: bookId,
                chapterNumber: chapterNumber,
                verseNumber: verseNumber,
                isFavorite: isFavorite,
                highlightColor: highlightColor,
                noteText: noteText,
                tagsCsv: tagsCsv,
                originTranslationId: originTranslationId,
                bookNameSnapshot: bookNameSnapshot,
                verseTextSnapshot: verseTextSnapshot,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required int chapterNumber,
                required int verseNumber,
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> highlightColor = const Value.absent(),
                Value<String?> noteText = const Value.absent(),
                Value<String?> tagsCsv = const Value.absent(),
                required String originTranslationId,
                required String bookNameSnapshot,
                required String verseTextSnapshot,
                required int createdAtMs,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => VerseAnnotationsCompanion.insert(
                id: id,
                bookId: bookId,
                chapterNumber: chapterNumber,
                verseNumber: verseNumber,
                isFavorite: isFavorite,
                highlightColor: highlightColor,
                noteText: noteText,
                tagsCsv: tagsCsv,
                originTranslationId: originTranslationId,
                bookNameSnapshot: bookNameSnapshot,
                verseTextSnapshot: verseTextSnapshot,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VerseAnnotationsTable, VerseAnnotationRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $VerseAnnotationsTable,
                    VerseAnnotationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VerseAnnotationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VerseAnnotationsTable,
      VerseAnnotationRow,
      $$VerseAnnotationsTableFilterComposer,
      $$VerseAnnotationsTableOrderingComposer,
      $$VerseAnnotationsTableAnnotationComposer,
      $$VerseAnnotationsTableCreateCompanionBuilder,
      $$VerseAnnotationsTableUpdateCompanionBuilder,
      (
        VerseAnnotationRow,
        BaseReferences<
          _$AppDatabase,
          $VerseAnnotationsTable,
          VerseAnnotationRow
        >,
      ),
      VerseAnnotationRow,
      PrefetchHooks Function()
    >;
typedef $$ReadingHistoryTableCreateCompanionBuilder =
    ReadingHistoryCompanion Function({
      Value<int> id,
      required String bookId,
      required int chapterNumber,
      required String translationId,
      required String readingDateIso,
      required int readAtMs,
      Value<int> durationSeconds,
      Value<String> source,
      Value<String?> planId,
    });
typedef $$ReadingHistoryTableUpdateCompanionBuilder =
    ReadingHistoryCompanion Function({
      Value<int> id,
      Value<String> bookId,
      Value<int> chapterNumber,
      Value<String> translationId,
      Value<String> readingDateIso,
      Value<int> readAtMs,
      Value<int> durationSeconds,
      Value<String> source,
      Value<String?> planId,
    });

class $$ReadingHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingHistoryTable> {
  $$ReadingHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readingDateIso => $composableBuilder(
    column: $table.readingDateIso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readAtMs => $composableBuilder(
    column: $table.readAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingHistoryTable> {
  $$ReadingHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readingDateIso => $composableBuilder(
    column: $table.readingDateIso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readAtMs => $composableBuilder(
    column: $table.readAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingHistoryTable> {
  $$ReadingHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get readingDateIso => $composableBuilder(
    column: $table.readingDateIso,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readAtMs =>
      $composableBuilder(column: $table.readAtMs, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);
}

class $$ReadingHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingHistoryTable,
          ReadingHistoryData,
          $$ReadingHistoryTableFilterComposer,
          $$ReadingHistoryTableOrderingComposer,
          $$ReadingHistoryTableAnnotationComposer,
          $$ReadingHistoryTableCreateCompanionBuilder,
          $$ReadingHistoryTableUpdateCompanionBuilder,
          (
            ReadingHistoryData,
            BaseReferences<
              _$AppDatabase,
              $ReadingHistoryTable,
              ReadingHistoryData
            >,
          ),
          ReadingHistoryData,
          PrefetchHooks Function()
        > {
  $$ReadingHistoryTableTableManager(
    _$AppDatabase db,
    $ReadingHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> chapterNumber = const Value.absent(),
                Value<String> translationId = const Value.absent(),
                Value<String> readingDateIso = const Value.absent(),
                Value<int> readAtMs = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> planId = const Value.absent(),
              }) => ReadingHistoryCompanion(
                id: id,
                bookId: bookId,
                chapterNumber: chapterNumber,
                translationId: translationId,
                readingDateIso: readingDateIso,
                readAtMs: readAtMs,
                durationSeconds: durationSeconds,
                source: source,
                planId: planId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bookId,
                required int chapterNumber,
                required String translationId,
                required String readingDateIso,
                required int readAtMs,
                Value<int> durationSeconds = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> planId = const Value.absent(),
              }) => ReadingHistoryCompanion.insert(
                id: id,
                bookId: bookId,
                chapterNumber: chapterNumber,
                translationId: translationId,
                readingDateIso: readingDateIso,
                readAtMs: readAtMs,
                durationSeconds: durationSeconds,
                source: source,
                planId: planId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingHistoryTable, ReadingHistoryData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReadingHistoryTable,
                    ReadingHistoryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingHistoryTable,
      ReadingHistoryData,
      $$ReadingHistoryTableFilterComposer,
      $$ReadingHistoryTableOrderingComposer,
      $$ReadingHistoryTableAnnotationComposer,
      $$ReadingHistoryTableCreateCompanionBuilder,
      $$ReadingHistoryTableUpdateCompanionBuilder,
      (
        ReadingHistoryData,
        BaseReferences<_$AppDatabase, $ReadingHistoryTable, ReadingHistoryData>,
      ),
      ReadingHistoryData,
      PrefetchHooks Function()
    >;
typedef $$ReadingProgressStateTableCreateCompanionBuilder =
    ReadingProgressStateCompanion Function({
      required String key,
      required String translationId,
      required String bookId,
      required int chapterNumber,
      Value<int> verseScrollOffset,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$ReadingProgressStateTableUpdateCompanionBuilder =
    ReadingProgressStateCompanion Function({
      Value<String> key,
      Value<String> translationId,
      Value<String> bookId,
      Value<int> chapterNumber,
      Value<int> verseScrollOffset,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$ReadingProgressStateTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressStateTable> {
  $$ReadingProgressStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseScrollOffset => $composableBuilder(
    column: $table.verseScrollOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingProgressStateTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressStateTable> {
  $$ReadingProgressStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseScrollOffset => $composableBuilder(
    column: $table.verseScrollOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingProgressStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressStateTable> {
  $$ReadingProgressStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get verseScrollOffset => $composableBuilder(
    column: $table.verseScrollOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$ReadingProgressStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingProgressStateTable,
          ReadingProgressStateData,
          $$ReadingProgressStateTableFilterComposer,
          $$ReadingProgressStateTableOrderingComposer,
          $$ReadingProgressStateTableAnnotationComposer,
          $$ReadingProgressStateTableCreateCompanionBuilder,
          $$ReadingProgressStateTableUpdateCompanionBuilder,
          (
            ReadingProgressStateData,
            BaseReferences<
              _$AppDatabase,
              $ReadingProgressStateTable,
              ReadingProgressStateData
            >,
          ),
          ReadingProgressStateData,
          PrefetchHooks Function()
        > {
  $$ReadingProgressStateTableTableManager(
    _$AppDatabase db,
    $ReadingProgressStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressStateTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReadingProgressStateTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> translationId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> chapterNumber = const Value.absent(),
                Value<int> verseScrollOffset = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressStateCompanion(
                key: key,
                translationId: translationId,
                bookId: bookId,
                chapterNumber: chapterNumber,
                verseScrollOffset: verseScrollOffset,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String translationId,
                required String bookId,
                required int chapterNumber,
                Value<int> verseScrollOffset = const Value.absent(),
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressStateCompanion.insert(
                key: key,
                translationId: translationId,
                bookId: bookId,
                chapterNumber: chapterNumber,
                verseScrollOffset: verseScrollOffset,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ReadingProgressStateTable,
                    ReadingProgressStateData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReadingProgressStateTable,
                    ReadingProgressStateData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingProgressStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingProgressStateTable,
      ReadingProgressStateData,
      $$ReadingProgressStateTableFilterComposer,
      $$ReadingProgressStateTableOrderingComposer,
      $$ReadingProgressStateTableAnnotationComposer,
      $$ReadingProgressStateTableCreateCompanionBuilder,
      $$ReadingProgressStateTableUpdateCompanionBuilder,
      (
        ReadingProgressStateData,
        BaseReferences<
          _$AppDatabase,
          $ReadingProgressStateTable,
          ReadingProgressStateData
        >,
      ),
      ReadingProgressStateData,
      PrefetchHooks Function()
    >;
typedef $$UserReadingPlansTableCreateCompanionBuilder =
    UserReadingPlansCompanion Function({
      required String planId,
      required String status,
      required int startedAtMs,
      Value<int?> completedAtMs,
      Value<String> completedDaysJson,
      Value<int> rowid,
    });
typedef $$UserReadingPlansTableUpdateCompanionBuilder =
    UserReadingPlansCompanion Function({
      Value<String> planId,
      Value<String> status,
      Value<int> startedAtMs,
      Value<int?> completedAtMs,
      Value<String> completedDaysJson,
      Value<int> rowid,
    });

class $$UserReadingPlansTableFilterComposer
    extends Composer<_$AppDatabase, $UserReadingPlansTable> {
  $$UserReadingPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedDaysJson => $composableBuilder(
    column: $table.completedDaysJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserReadingPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $UserReadingPlansTable> {
  $$UserReadingPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedDaysJson => $composableBuilder(
    column: $table.completedDaysJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserReadingPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserReadingPlansTable> {
  $$UserReadingPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAtMs => $composableBuilder(
    column: $table.completedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completedDaysJson => $composableBuilder(
    column: $table.completedDaysJson,
    builder: (column) => column,
  );
}

class $$UserReadingPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserReadingPlansTable,
          UserReadingPlan,
          $$UserReadingPlansTableFilterComposer,
          $$UserReadingPlansTableOrderingComposer,
          $$UserReadingPlansTableAnnotationComposer,
          $$UserReadingPlansTableCreateCompanionBuilder,
          $$UserReadingPlansTableUpdateCompanionBuilder,
          (
            UserReadingPlan,
            BaseReferences<
              _$AppDatabase,
              $UserReadingPlansTable,
              UserReadingPlan
            >,
          ),
          UserReadingPlan,
          PrefetchHooks Function()
        > {
  $$UserReadingPlansTableTableManager(
    _$AppDatabase db,
    $UserReadingPlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserReadingPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserReadingPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserReadingPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> planId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startedAtMs = const Value.absent(),
                Value<int?> completedAtMs = const Value.absent(),
                Value<String> completedDaysJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserReadingPlansCompanion(
                planId: planId,
                status: status,
                startedAtMs: startedAtMs,
                completedAtMs: completedAtMs,
                completedDaysJson: completedDaysJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String planId,
                required String status,
                required int startedAtMs,
                Value<int?> completedAtMs = const Value.absent(),
                Value<String> completedDaysJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserReadingPlansCompanion.insert(
                planId: planId,
                status: status,
                startedAtMs: startedAtMs,
                completedAtMs: completedAtMs,
                completedDaysJson: completedDaysJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserReadingPlansTable, UserReadingPlan>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserReadingPlansTable,
                    UserReadingPlan
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserReadingPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserReadingPlansTable,
      UserReadingPlan,
      $$UserReadingPlansTableFilterComposer,
      $$UserReadingPlansTableOrderingComposer,
      $$UserReadingPlansTableAnnotationComposer,
      $$UserReadingPlansTableCreateCompanionBuilder,
      $$UserReadingPlansTableUpdateCompanionBuilder,
      (
        UserReadingPlan,
        BaseReferences<_$AppDatabase, $UserReadingPlansTable, UserReadingPlan>,
      ),
      UserReadingPlan,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedBooksTableTableManager get cachedBooks =>
      $$CachedBooksTableTableManager(_db, _db.cachedBooks);
  $$CachedChaptersTableTableManager get cachedChapters =>
      $$CachedChaptersTableTableManager(_db, _db.cachedChapters);
  $$CachedVersesTableTableManager get cachedVerses =>
      $$CachedVersesTableTableManager(_db, _db.cachedVerses);
  $$VerseAnnotationsTableTableManager get verseAnnotations =>
      $$VerseAnnotationsTableTableManager(_db, _db.verseAnnotations);
  $$ReadingHistoryTableTableManager get readingHistory =>
      $$ReadingHistoryTableTableManager(_db, _db.readingHistory);
  $$ReadingProgressStateTableTableManager get readingProgressState =>
      $$ReadingProgressStateTableTableManager(_db, _db.readingProgressState);
  $$UserReadingPlansTableTableManager get userReadingPlans =>
      $$UserReadingPlansTableTableManager(_db, _db.userReadingPlans);
}
