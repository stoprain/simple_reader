import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'entry_model.dart';
import 'feed_model.dart';

class DatabaseHelper {
  final String tableFeed = "feed";
  final String tableEntry = "entry";
  final String columnId = "id";
  final String columnTitle = "title";
  final String columnUrl = "url";

  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'test.db');
    print('init db $path');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute('''
          create table $tableFeed (
        $columnUrl text primary key,
        $columnTitle text not null)
    ''');
    await db.execute('''
          create table $tableEntry (
        $columnId text primary key,
        $columnTitle text not null,
        $columnUrl text not null)
    ''');
  }

  Future<List<Feed>> getAllFeeds() async {
    var dbClient = await db;
    var result = await dbClient.query(tableFeed);
    var feeds = List<Feed>();
    for (Map<String, dynamic> item in result) {
      feeds.add(new Feed.fromMap(item));
    }
    return feeds;
  }

  void updateFeed(Feed feed) async {
    var dbClient = await db;
    // await dbClient.transaction((txn) async {
    await dbClient.rawInsert('''
      insert or replace into $tableFeed($columnTitle, $columnUrl)
      values("${feed.title}", "${feed.link}")
      ''');
    // });
  }

  void updateEntry(Entry entry) async {
    var dbClient = await db;
    // await dbClient.transaction((txn) async {
    await dbClient.rawInsert('''
      insert or replace into $tableEntry($columnId, $columnTitle, $columnUrl)
      values(${entry.id}, ${entry.title}, ${entry.link})
      ''');
    // });
  }

  Future<Entry> getEntry(String id) async {
    var dbClient = await db;
    var result = await dbClient
        .query(tableEntry, where: '$columnId = ?', whereArgs: [id]);
    return Entry.fromMap(result.first);
  }

  Future<int> deleteEntry(String id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableEntry, where: "$columnId = ?", whereArgs: [id]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
