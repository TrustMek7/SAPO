import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'game.dart';

abstract interface class GameRepository {
  Future<Game?> load();
  Future<void> save(Game game);
  Future<List<String>> history();
}

class LocalRepository extends GeneratedDatabase implements GameRepository {
  LocalRepository(super.executor);
  static Future<LocalRepository> open() async {
    final directory = await getApplicationDocumentsDirectory();
    return LocalRepository(
      NativeDatabase(File('${directory.path}/sapo.sqlite')),
    );
  }

  @override
  int get schemaVersion => 1;
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];
  Future<void> prepare() async {
    await customStatement(
      'CREATE TABLE IF NOT EXISTS saves (id INTEGER PRIMARY KEY, data TEXT NOT NULL)',
    );
    await customStatement(
      'CREATE TABLE IF NOT EXISTS history (content TEXT PRIMARY KEY)',
    );
    await customStatement(
      'CREATE TABLE IF NOT EXISTS metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
    );
  }

  Future<String?> readValue(String key) async {
    final rows = await customSelect(
      'SELECT value FROM metadata WHERE key = ?',
      variables: [Variable.withString(key)],
    ).get();
    return rows.isEmpty ? null : rows.first.read<String>('value');
  }

  Future<void> writeValue(String key, String value) => customStatement(
    'INSERT OR REPLACE INTO metadata VALUES (?, ?)',
    [key, value],
  );
  Future<void> clearHistory() => customStatement('DELETE FROM history');
  @override
  Future<Game?> load() async {
    final rows = await customSelect('SELECT data FROM saves WHERE id=1').get();
    return rows.isEmpty ? null : Game.decode(rows.first.read<String>('data'));
  }

  @override
  Future<void> save(Game game) => transaction(() async {
    await customStatement('INSERT OR REPLACE INTO saves VALUES (1, ?)', [
      game.encode(),
    ]);
    for (final id in game.used.where(
      (id) => !game.historyExcluded.contains(id),
    )) {
      await customStatement('INSERT OR IGNORE INTO history VALUES (?)', [id]);
    }
  });
  @override
  Future<List<String>> history() async => (await customSelect(
    'SELECT content FROM history',
  ).get()).map((r) => r.read<String>('content')).toList();
}
