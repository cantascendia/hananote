import 'dart:async';
import 'dart:typed_data';

import 'package:sqflite_common/sql.dart' show ConflictAlgorithm, escapeName;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqlite3/common.dart' as sqlite;
import 'package:sqlite3/wasm.dart';

const String _defaultDatabasesPath = '/databases';
const String _indexedDbName = 'hananote_sqlite_vfs';
const String _sqliteWasmAsset = 'sqlite3.wasm';
const String _inMemoryPath = ':memory:';

final _wasmDatabaseFactory = _WasmSqfliteDatabaseFactory();

/// Warms up the WebAssembly-backed database environment.
void initWasmDatabaseFactory() {
  unawaited(
    _wasmDatabaseFactory.ensureInitialized().then<void>(
          (_) {},
          onError: (Object _, StackTrace __) {},
        ),
  );
}

/// Opens a web database using `sqlite3.wasm` directly.
Future<Database> openWasmDatabase(
  String path, {
  int version = 1,
  OnDatabaseCreateFn? onCreate,
  OnDatabaseVersionChangeFn? onUpgrade,
}) {
  return _wasmDatabaseFactory.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: version,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    ),
  );
}

/// Returns the virtual database path used on the web.
Future<String> getWasmDatabasesPath() {
  return _wasmDatabaseFactory.getDatabasesPath();
}

final class _WasmEnvironment {
  _WasmEnvironment({
    required this.sqlite3,
    required this.fileSystem,
  });

  final WasmSqlite3 sqlite3;
  final IndexedDbFileSystem fileSystem;
}

final class _WasmSqfliteDatabaseFactory implements DatabaseFactory {
  Future<_WasmEnvironment>? _environmentFuture;
  final Map<String, _WasmSqfliteDatabase> _singleInstanceDatabases = {};
  String _databasesPath = _defaultDatabasesPath;

  Future<_WasmEnvironment> ensureInitialized() {
    return _environmentFuture ??= _createEnvironment();
  }

  Future<_WasmEnvironment> _createEnvironment() async {
    try {
      final sqlite3 = await WasmSqlite3.loadFromUrl(
        Uri.base.resolve(_sqliteWasmAsset),
      );
      final fileSystem = await IndexedDbFileSystem.open(dbName: _indexedDbName);
      sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
      return _WasmEnvironment(sqlite3: sqlite3, fileSystem: fileSystem);
    } catch (_) {
      _environmentFuture = null;
      rethrow;
    }
  }

  String _normalizePath(String path) {
    final normalized = path.replaceAll(RegExp(r'\\'), '/');
    if (normalized == _inMemoryPath || normalized.startsWith('/')) {
      return normalized;
    }

    final base = _databasesPath.endsWith('/')
        ? _databasesPath.substring(0, _databasesPath.length - 1)
        : _databasesPath;
    return '$base/$normalized';
  }

  void _validateOpenOptions(OpenDatabaseOptions options) {
    if (options.version != null) {
      if (options.version == 0) {
        throw ArgumentError('version cannot be set to 0 in openDatabase');
      }
      return;
    }

    if (options.onCreate != null) {
      throw ArgumentError('onCreate must be null if no version is specified');
    }
    if (options.onUpgrade != null) {
      throw ArgumentError('onUpgrade must be null if no version is specified');
    }
    if (options.onDowngrade != null) {
      throw ArgumentError(
        'onDowngrade must be null if no version is specified',
      );
    }
  }

  Future<void> _runOpenCallbacks(
    _WasmSqfliteDatabase database,
    OpenDatabaseOptions options,
  ) async {
    _validateOpenOptions(options);

    if (options.onConfigure != null) {
      await options.onConfigure!(database);
    }

    final targetVersion = options.version;
    if (targetVersion != null) {
      final oldVersion = database.userVersion;
      if (oldVersion != targetVersion) {
        await database.runManagedTransaction<void>(
          (txn) async {
            final currentVersion = database.userVersion;

            if (currentVersion == 0) {
              if (options.onCreate != null) {
                await options.onCreate!(database, targetVersion);
              } else if (options.onUpgrade != null) {
                await options.onUpgrade!(database, 0, targetVersion);
              }
            } else if (currentVersion < targetVersion) {
              if (options.onUpgrade != null) {
                await options.onUpgrade!(
                  database,
                  currentVersion,
                  targetVersion,
                );
              }
            } else {
              final onDowngrade = options.onDowngrade;
              if (onDowngrade != null) {
                await onDowngrade(database, currentVersion, targetVersion);
              } else {
                await onDatabaseVersionChangeError(
                  database,
                  currentVersion,
                  targetVersion,
                );
              }
            }

            if (database.userVersion != targetVersion) {
              database.userVersion = targetVersion;
            }
          },
          exclusive: true,
        );
      }
    }

    if (options.onOpen != null) {
      await options.onOpen!(database);
    }
  }

  @override
  Future<Database> openDatabase(
    String path, {
    OpenDatabaseOptions? options,
  }) async {
    final openOptions = options ?? OpenDatabaseOptions();
    final resolvedPath = _normalizePath(path);
    final singleInstance =
        openOptions.singleInstance && resolvedPath != _inMemoryPath;

    if (singleInstance) {
      final existing = _singleInstanceDatabases[resolvedPath];
      if (existing != null) {
        if (existing.isOpen) {
          return existing;
        }
        _singleInstanceDatabases.remove(resolvedPath);
      }
    }

    final environment = await ensureInitialized();
    final delegate = resolvedPath == _inMemoryPath
        ? environment.sqlite3.openInMemory()
        : environment.sqlite3.open(
            resolvedPath,
            mode: openOptions.readOnly
                ? sqlite.OpenMode.readOnly
                : sqlite.OpenMode.readWriteCreate,
          );

    late final _WasmSqfliteDatabase database;
    database = _WasmSqfliteDatabase(
      path: resolvedPath,
      delegate: delegate,
      fileSystem: environment.fileSystem,
      onClosed: () => _singleInstanceDatabases.remove(resolvedPath),
    );

    try {
      await _runOpenCallbacks(database, openOptions);
      if (singleInstance) {
        _singleInstanceDatabases[resolvedPath] = database;
      }
      return database;
    } catch (_) {
      await database.close();
      rethrow;
    }
  }

  @override
  Future<String> getDatabasesPath() async => _databasesPath;

  @override
  Future<void> setDatabasesPath(String path) async {
    _databasesPath = path;
  }

  @override
  Future<void> deleteDatabase(String path) async {
    final resolvedPath = _normalizePath(path);
    final existing = _singleInstanceDatabases.remove(resolvedPath);
    if (existing != null && existing.isOpen) {
      await existing.close();
    }

    final environment = await ensureInitialized();
    if (environment.fileSystem.xAccess(resolvedPath, 0) != 0) {
      environment.fileSystem.xDelete(resolvedPath, 0);
      await environment.fileSystem.flush();
    }
  }

  @override
  Future<bool> databaseExists(String path) async {
    final environment = await ensureInitialized();
    return environment.fileSystem.xAccess(_normalizePath(path), 0) != 0;
  }

  @override
  Future<void> writeDatabaseBytes(String path, Uint8List bytes) async {
    final environment = await ensureInitialized();
    final resolvedPath = _normalizePath(path);

    if (environment.fileSystem.xAccess(resolvedPath, 0) != 0) {
      environment.fileSystem.xDelete(resolvedPath, 0);
      await environment.fileSystem.flush();
    }

    final file = environment.fileSystem
        .xOpen(
          sqlite.Sqlite3Filename(resolvedPath),
          sqlite.SqlFlag.SQLITE_OPEN_READWRITE |
              sqlite.SqlFlag.SQLITE_OPEN_CREATE,
        )
        .file;

    try {
      file.xTruncate(0);
      if (bytes.isNotEmpty) {
        file.xWrite(bytes, 0);
      }
      await environment.fileSystem.flush();
    } finally {
      file.xClose();
    }
  }

  @override
  Future<Uint8List> readDatabaseBytes(String path) async {
    final environment = await ensureInitialized();
    final resolvedPath = _normalizePath(path);

    await environment.fileSystem.flush();
    final file = environment.fileSystem
        .xOpen(
          sqlite.Sqlite3Filename(resolvedPath),
          sqlite.SqlFlag.SQLITE_OPEN_READONLY,
        )
        .file;

    try {
      final size = file.xFileSize();
      final bytes = Uint8List(size);
      if (size > 0) {
        file.xRead(bytes, 0);
      }
      return bytes;
    } finally {
      file.xClose();
    }
  }
}

final class _WasmSqfliteDatabase implements Database {
  _WasmSqfliteDatabase({
    required this.path,
    required sqlite.CommonDatabase delegate,
    required IndexedDbFileSystem fileSystem,
    required this.onClosed,
  })  : _delegate = delegate,
        _fileSystem = fileSystem;

  final sqlite.CommonDatabase _delegate;
  final IndexedDbFileSystem _fileSystem;
  final void Function() onClosed;

  @override
  final String path;

  bool _isOpen = true;
  int _transactionDepth = 0;
  int _savepointCounter = 0;

  int get userVersion => _delegate.userVersion;
  set userVersion(int value) => _delegate.userVersion = value;

  void _checkOpen() {
    if (!_isOpen) {
      throw StateError('This database has already been closed.');
    }
  }

  Future<void> _flushIfNeeded() async {
    if (_transactionDepth == 0) {
      await _fileSystem.flush();
    }
  }

  static final BigInt _maxSafeInteger = BigInt.from(9007199254740991);
  static final BigInt _minSafeInteger = BigInt.from(-9007199254740991);

  static Object? _normalizeArgument(Object? value) {
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is Uint8List) {
      return value;
    }
    if (value is List<int>) {
      return Uint8List.fromList(value);
    }
    return value;
  }

  static List<Object?> _normalizeArguments(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) {
      return const <Object?>[];
    }
    return arguments.map(_normalizeArgument).toList(growable: false);
  }

  static Object? _normalizeRowValue(Object? value) {
    if (value is BigInt &&
        value <= _maxSafeInteger &&
        value >= _minSafeInteger) {
      return value.toInt();
    }
    return value;
  }

  static Map<String, Object?> _rowToMap(Map<String, Object?> row) {
    return <String, Object?>{
      for (final entry in row.entries)
        entry.key: _normalizeRowValue(entry.value),
    };
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    _checkOpen();
    _delegate.execute(sql, _normalizeArguments(arguments));
    await _flushIfNeeded();
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    _checkOpen();
    _delegate.execute(sql, _normalizeArguments(arguments));
    await _flushIfNeeded();
    return _delegate.lastInsertRowId;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    final statement = _SqlStatement.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
    return rawInsert(statement.sql, statement.arguments);
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    final statement = _SqlStatement.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return rawQuery(statement.sql, statement.arguments);
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    _checkOpen();
    final result = _delegate.select(sql, _normalizeArguments(arguments));
    return result
        .map((row) => _rowToMap(Map<String, Object?>.from(row)))
        .toList();
  }

  @override
  Future<QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) async {
    final rows = await rawQuery(sql, arguments);
    return _InMemoryQueryCursor(rows);
  }

  @override
  Future<QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) async {
    final rows = await query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return _InMemoryQueryCursor(rows);
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    _checkOpen();
    _delegate.execute(sql, _normalizeArguments(arguments));
    await _flushIfNeeded();
    return _delegate.updatedRows;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    final statement = _SqlStatement.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
    return rawUpdate(statement.sql, statement.arguments);
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    _checkOpen();
    _delegate.execute(sql, _normalizeArguments(arguments));
    await _flushIfNeeded();
    return _delegate.updatedRows;
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    final statement = _SqlStatement.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
    return rawDelete(statement.sql, statement.arguments);
  }

  @override
  Batch batch() =>
      _WasmSqfliteBatch(executor: this, createdInTransaction: false);

  Future<T> runManagedTransaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool exclusive = false,
    bool rollbackOnSuccess = false,
    bool readOnly = false,
  }) async {
    _checkOpen();

    final isTopLevel = _transactionDepth == 0;
    final savepointName = 'sqflite_txn_${++_savepointCounter}';

    if (isTopLevel) {
      final beginSql = readOnly
          ? 'BEGIN'
          : exclusive
              ? 'BEGIN EXCLUSIVE'
              : 'BEGIN IMMEDIATE';
      _delegate.execute(beginSql);
    } else {
      _delegate.execute('SAVEPOINT $savepointName');
    }

    _transactionDepth += 1;
    final transaction = _WasmSqfliteTransaction(this);

    try {
      final result = await action(transaction);
      transaction.close();

      if (rollbackOnSuccess) {
        if (isTopLevel) {
          _delegate.execute('ROLLBACK');
        } else {
          _delegate
            ..execute('ROLLBACK TO SAVEPOINT $savepointName')
            ..execute('RELEASE SAVEPOINT $savepointName');
        }
      } else {
        if (isTopLevel) {
          _delegate.execute('COMMIT');
        } else {
          _delegate.execute('RELEASE SAVEPOINT $savepointName');
        }
        if (isTopLevel) {
          await _fileSystem.flush();
        }
      }

      return result;
    } catch (_) {
      transaction.close();
      try {
        if (isTopLevel) {
          _delegate.execute('ROLLBACK');
        } else {
          _delegate
            ..execute('ROLLBACK TO SAVEPOINT $savepointName')
            ..execute('RELEASE SAVEPOINT $savepointName');
        }
      } catch (_) {}
      rethrow;
    } finally {
      _transactionDepth -= 1;
    }
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) {
    return runManagedTransaction<T>(action, exclusive: exclusive ?? false);
  }

  @override
  Future<T> readTransaction<T>(Future<T> Function(Transaction txn) action) {
    return runManagedTransaction<T>(
      action,
      rollbackOnSuccess: true,
      readOnly: true,
    );
  }

  @override
  bool get isOpen => _isOpen;

  @override
  Future<void> close() async {
    if (!_isOpen) {
      return;
    }

    _isOpen = false;
    try {
      if (_transactionDepth == 0) {
        await _fileSystem.flush();
      }
    } finally {
      _delegate.close();
      onClosed();
    }
  }

  @override
  Future<T> devInvokeMethod<T>(String method, [Object? arguments]) {
    throw UnsupportedError(
      'devInvokeMethod is not supported on the web database',
    );
  }

  @override
  Future<T> devInvokeSqlMethod<T>(
    String method,
    String sql, [
    List<Object?>? arguments,
  ]) {
    throw UnsupportedError(
      'devInvokeSqlMethod is not supported on the web database',
    );
  }

  @override
  Database get database => this;
}

final class _WasmSqfliteTransaction implements Transaction {
  _WasmSqfliteTransaction(this._database);

  final _WasmSqfliteDatabase _database;
  bool _isOpen = true;

  void _checkOpen() {
    if (!_isOpen) {
      throw StateError('Transaction is no longer active.');
    }
  }

  void close() {
    _isOpen = false;
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) {
    _checkOpen();
    return _database.execute(sql, arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) {
    _checkOpen();
    return _database.rawInsert(sql, arguments);
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    _checkOpen();
    return _database.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    _checkOpen();
    return _database.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) {
    _checkOpen();
    return _database.rawQuery(sql, arguments);
  }

  @override
  Future<QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) {
    _checkOpen();
    return _database.rawQueryCursor(sql, arguments, bufferSize: bufferSize);
  }

  @override
  Future<QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) {
    _checkOpen();
    return _database.queryCursor(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
      bufferSize: bufferSize,
    );
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) {
    _checkOpen();
    return _database.rawUpdate(sql, arguments);
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    _checkOpen();
    return _database.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) {
    _checkOpen();
    return _database.rawDelete(sql, arguments);
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    _checkOpen();
    return _database.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Batch batch() =>
      _WasmSqfliteBatch(executor: this, createdInTransaction: true);

  @override
  Database get database => _database;
}

final class _WasmSqfliteBatch implements Batch {
  _WasmSqfliteBatch({
    required DatabaseExecutor executor,
    required bool createdInTransaction,
  })  : _executor = executor,
        _createdInTransaction = createdInTransaction;

  final DatabaseExecutor _executor;
  final bool _createdInTransaction;
  final List<Future<Object?> Function(DatabaseExecutor executor)> _operations =
      [];

  Future<List<Object?>> _runOperations({
    required DatabaseExecutor executor,
    bool? noResult,
    bool? continueOnError,
  }) async {
    final results = <Object?>[];
    final includeResults = !(noResult ?? false);

    for (final operation in _operations) {
      try {
        final result = await operation(executor);
        if (includeResults) {
          results.add(result);
        }
      } catch (error) {
        if (continueOnError ?? false) {
          if (includeResults) {
            results.add(error);
          }
          continue;
        }
        rethrow;
      }
    }

    return includeResults ? results : <Object?>[];
  }

  @override
  Future<List<Object?>> commit({
    bool? exclusive,
    bool? noResult,
    bool? continueOnError,
  }) {
    if (_createdInTransaction) {
      if (exclusive != null) {
        throw ArgumentError.value(
          exclusive,
          'exclusive',
          'must not be set when committing a batch in a transaction',
        );
      }
      return apply(noResult: noResult, continueOnError: continueOnError);
    }

    final database = _executor as Database;
    return database.transaction<List<Object?>>(
      (txn) => _runOperations(
        executor: txn,
        noResult: noResult,
        continueOnError: continueOnError,
      ),
      exclusive: exclusive,
    );
  }

  @override
  Future<List<Object?>> apply({bool? noResult, bool? continueOnError}) {
    return _runOperations(
      executor: _executor,
      noResult: noResult,
      continueOnError: continueOnError,
    );
  }

  @override
  void rawInsert(String sql, [List<Object?>? arguments]) {
    _operations.add((executor) => executor.rawInsert(sql, arguments));
  }

  @override
  void insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    _operations.add(
      (executor) => executor.insert(
        table,
        values,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm,
      ),
    );
  }

  @override
  void rawUpdate(String sql, [List<Object?>? arguments]) {
    _operations.add((executor) => executor.rawUpdate(sql, arguments));
  }

  @override
  void update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    _operations.add(
      (executor) => executor.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm,
      ),
    );
  }

  @override
  void rawDelete(String sql, [List<Object?>? arguments]) {
    _operations.add((executor) => executor.rawDelete(sql, arguments));
  }

  @override
  void delete(String table, {String? where, List<Object?>? whereArgs}) {
    _operations.add(
      (executor) => executor.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      ),
    );
  }

  @override
  void execute(String sql, [List<Object?>? arguments]) {
    _operations.add((executor) async {
      await executor.execute(sql, arguments);
      return null;
    });
  }

  @override
  void query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    _operations.add(
      (executor) => executor.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  void rawQuery(String sql, [List<Object?>? arguments]) {
    _operations.add((executor) => executor.rawQuery(sql, arguments));
  }

  @override
  int get length => _operations.length;
}

final class _InMemoryQueryCursor implements QueryCursor {
  _InMemoryQueryCursor(this._rows);

  final List<Map<String, Object?>> _rows;
  int _index = -1;
  bool _closed = false;

  @override
  Future<bool> moveNext() async {
    if (_closed) {
      return false;
    }

    _index += 1;
    if (_index >= _rows.length) {
      _closed = true;
      return false;
    }
    return true;
  }

  @override
  Map<String, Object?> get current {
    if (_closed || _index < 0 || _index >= _rows.length) {
      throw StateError('Cursor is not positioned on a row.');
    }
    return _rows[_index];
  }

  @override
  Future<void> close() async {
    _closed = true;
  }
}

final class _SqlStatement {
  _SqlStatement(this.sql, this.arguments);

  final String sql;
  final List<Object?>? arguments;

  static _SqlStatement query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    if (groupBy == null && having != null) {
      throw ArgumentError(
        'HAVING clauses are only permitted when using a groupBy clause',
      );
    }

    final buffer = StringBuffer('SELECT ');
    if (distinct ?? false) {
      buffer.write('DISTINCT ');
    }

    if (columns != null && columns.isNotEmpty) {
      for (var i = 0; i < columns.length; i++) {
        if (i > 0) {
          buffer.write(', ');
        }
        buffer.write(escapeName(columns[i]));
      }
      buffer.write(' ');
    } else {
      buffer.write('* ');
    }

    buffer
      ..write('FROM ')
      ..write(escapeName(table));

    _appendClause(buffer, ' WHERE ', where);
    _appendClause(buffer, ' GROUP BY ', groupBy);
    _appendClause(buffer, ' HAVING ', having);
    _appendClause(buffer, ' ORDER BY ', orderBy);

    if (limit != null || offset != null) {
      _appendClause(buffer, ' LIMIT ', (limit ?? -1).toString());
    }
    if (offset != null) {
      _appendClause(buffer, ' OFFSET ', offset.toString());
    }

    return _SqlStatement(
      buffer.toString(),
      whereArgs == null ? null : List<Object?>.from(whereArgs),
    );
  }

  static _SqlStatement insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    final buffer = StringBuffer('INSERT');
    if (conflictAlgorithm != null) {
      buffer.write(' ${_conflictValue(conflictAlgorithm)}');
    }
    buffer
      ..write(' INTO ')
      ..write(escapeName(table))
      ..write(' (');

    List<Object?>? arguments;

    if (values.isNotEmpty) {
      final valueBuffer = StringBuffer(') VALUES (');
      arguments = <Object?>[];
      var index = 0;

      values.forEach((column, value) {
        if (index++ > 0) {
          buffer.write(', ');
          valueBuffer.write(', ');
        }

        buffer.write(escapeName(column));
        if (value == null) {
          valueBuffer.write('NULL');
        } else {
          arguments!.add(value);
          valueBuffer.write('?');
        }
      });

      buffer.write(valueBuffer);
    } else {
      if (nullColumnHack == null) {
        throw ArgumentError('nullColumnHack required when inserting no data');
      }
      buffer.write('$nullColumnHack) VALUES (NULL');
    }

    buffer.write(')');
    return _SqlStatement(buffer.toString(), arguments);
  }

  static _SqlStatement update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) {
    if (values.isEmpty) {
      throw ArgumentError('Empty values');
    }

    final buffer = StringBuffer('UPDATE');
    if (conflictAlgorithm != null) {
      buffer.write(' ${_conflictValue(conflictAlgorithm)}');
    }

    buffer
      ..write(' ')
      ..write(escapeName(table))
      ..write(' SET ');

    final arguments = <Object?>[];
    var index = 0;

    values.forEach((column, value) {
      if (index++ > 0) {
        buffer.write(', ');
      }
      buffer.write(escapeName(column));

      if (value == null) {
        buffer.write(' = NULL');
      } else {
        arguments.add(value);
        buffer.write(' = ?');
      }
    });

    if (whereArgs != null) {
      arguments.addAll(whereArgs);
    }
    _appendClause(buffer, ' WHERE ', where);

    return _SqlStatement(buffer.toString(), arguments);
  }

  static _SqlStatement delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) {
    final buffer = StringBuffer()
      ..write('DELETE FROM ')
      ..write(escapeName(table));
    _appendClause(buffer, ' WHERE ', where);
    return _SqlStatement(
      buffer.toString(),
      whereArgs == null ? null : List<Object?>.from(whereArgs),
    );
  }

  static void _appendClause(StringBuffer buffer, String prefix, String? value) {
    if (value != null) {
      buffer
        ..write(prefix)
        ..write(value);
    }
  }

  static String _conflictValue(ConflictAlgorithm algorithm) {
    return switch (algorithm) {
      ConflictAlgorithm.rollback => 'OR ROLLBACK',
      ConflictAlgorithm.abort => 'OR ABORT',
      ConflictAlgorithm.fail => 'OR FAIL',
      ConflictAlgorithm.ignore => 'OR IGNORE',
      ConflictAlgorithm.replace => 'OR REPLACE',
    };
  }
}
