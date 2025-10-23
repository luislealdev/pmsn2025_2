import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pmsn2025_2/models/movie_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MoviesDatabase {
  static final nameDB = "MOVIESDB";
  static final versionDB = 1;

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    return _database = await _initDatabase();
  }

  Future<Database?> _initDatabase() async {
    Directory folder = await getApplicationDocumentsDirectory();
    String pathDB = join(folder.path, nameDB); //"$folder/$nameDB";
    return openDatabase(pathDB, version: versionDB, onCreate: createTables);
  }

  FutureOr<void> createTables(Database db, int version) {
    String query = '''
    CREATE TABLE movie(
        id INTEGER PRIMARY KEY,
        name VARCHAR(50),
        time CHAR(3),
        released CHAR(10)
    )
''';
    return db.execute(query);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    var conn = await database;
    return conn!.insert("movie", data);
  }

  Future<int> update(String table, Map<String, dynamic> data) async {
    var conn = await database;
    return conn!.update(table, data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<int> delete(String table, int id) async {
    var conn = await database;
    return conn!.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MovieDTO>> select() async {
    var conn = await database;
    var result = await conn!.query("movie");
    return result.map((e) => MovieDTO.fromJson(e)).toList();
  }
}
