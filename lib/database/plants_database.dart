import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pmsn2025_2/models/plant_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PlantsDatabase {
  static final nameDB = "PLANTSDB";
  static final versionDB = 3; // Incrementar versión para forzar recreación completa

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    return _database = await _initDatabase();
  }

  Future<Database?> _initDatabase() async {
    Directory folder = await getApplicationDocumentsDirectory();
    String pathDB = join(folder.path, nameDB);
    
    // Forzar eliminación de BD para recrear estructura
    try {
      File dbFile = File(pathDB);
      if (await dbFile.exists()) {
        await dbFile.delete();
        print('🗑️ Forcing database deletion for clean recreation');
      }
    } catch (e) {
      print('⚠️ Error deleting old database: $e');
    }
    
    return openDatabase(
      pathDB, 
      version: versionDB, 
      onCreate: createTables,
      onUpgrade: upgradeTables,
    );
  }

  FutureOr<void> createTables(Database db, int version) {
    // Tabla de plantas con campos de sincronización
    String plantQuery = '''
    CREATE TABLE plant(
        id INTEGER PRIMARY KEY,
        firebase_id TEXT UNIQUE,
        name VARCHAR(100),
        price REAL,
        category VARCHAR(50),
        description TEXT,
        care_instructions TEXT,
        image_url TEXT,
        image TEXT,
        rating REAL DEFAULT 0.0,
        reviews INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        needs_sync INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0
    )
''';
    
    // Tabla de carrito con campos de sincronización
    String cartQuery = '''
    CREATE TABLE cart(
        id INTEGER PRIMARY KEY,
        firebase_id TEXT UNIQUE,
        plant_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        quantity INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        needs_sync INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0
    )
''';
    
    db.execute(plantQuery);
    return db.execute(cartQuery);
  }

  FutureOr<void> upgradeTables(Database db, int oldVersion, int newVersion) {
    print('🔄 Upgrading database from version $oldVersion to $newVersion');
    
    // Migración de versión 1 a 2: agregar campos faltantes a la tabla plant
    if (oldVersion < 2) {
      try {
        // Usar IF NOT EXISTS para evitar errores si la columna ya existe
        db.execute('ALTER TABLE plant ADD COLUMN image TEXT');
        print('✅ Added image column');
      } catch (e) {
        print('⚠️ Image column might already exist: $e');
      }
      
      try {
        db.execute('ALTER TABLE plant ADD COLUMN rating REAL DEFAULT 0.0');
        print('✅ Added rating column');
      } catch (e) {
        print('⚠️ Rating column might already exist: $e');
      }
      
      try {
        db.execute('ALTER TABLE plant ADD COLUMN reviews INTEGER DEFAULT 0');
        print('✅ Added reviews column');
      } catch (e) {
        print('⚠️ Reviews column might already exist: $e');
      }
      
      print('✅ Database upgrade completed');
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    var conn = await database;
    return conn!.insert(table, data);
  }

  Future<int> update(String table, Map<String, dynamic> data) async {
    var conn = await database;
    return conn!.update(table, data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<int> delete(String table, int id) async {
    var conn = await database;
    return conn!.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PlantDTO>> select() async {
    var conn = await database;
    var result = await conn!.query("plant", where: 'is_deleted = ?', whereArgs: [0]);
    return result.map((e) => PlantDTO.fromJson(e)).toList();
  }

  // =============== MÉTODOS ESPECÍFICOS PARA PLANTAS ===============
  
  Future<int> insertPlant(Map<String, dynamic> plant) async {
    var conn = await database;
    
    print('📝 Original plant data: ${plant.keys.toList()}');
    
    // Mapear los datos al formato correcto para la base de datos
    Map<String, dynamic> dbPlant = {
      'name': plant['name'],
      'price': plant['price'],
      'category': plant['category'],
      'description': plant['description'],
      'care_instructions': plant['care_instructions'],
      'image_url': plant['image_url'] ?? plant['imageUrl'],
      'image': plant['image'], // Campo adicional para compatibilidad
      'rating': plant['rating'] ?? 0.0,
      'reviews': plant['reviews'] ?? 0,
      'created_at': plant['created_at'] ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'needs_sync': 1, // Marcar para sincronización
    };
    
    // Remover claves con valores nulos
    dbPlant.removeWhere((key, value) => value == null);
    
    print('📱 Mapped plant data for DB: ${dbPlant.keys.toList()}');
    print('📱 Plant values: $dbPlant');
    
    try {
      // Verificar estructura de tabla antes de insertar
      var tableInfo = await conn!.rawQuery("PRAGMA table_info(plant)");
      var columnNames = tableInfo.map((col) => col['name']).toList();
      print('📊 Available columns in plant table: $columnNames');
      
      // Verificar que todas las claves existen en la tabla
      var missingColumns = dbPlant.keys.where((key) => !columnNames.contains(key)).toList();
      if (missingColumns.isNotEmpty) {
        print('⚠️ Missing columns: $missingColumns');
        // Remover columnas que no existen
        missingColumns.forEach((col) => dbPlant.remove(col));
        print('📱 Cleaned plant data: ${dbPlant.keys.toList()}');
      }
      
      return conn.insert("plant", dbPlant);
    } catch (e) {
      print('❌ Error during insert: $e');
      print('🔍 Attempted to insert: $dbPlant');
      rethrow;
    }
  }

  Future<int> updatePlant(int id, Map<String, dynamic> plant) async {
    var conn = await database;
    
    // Mapear los datos al formato correcto para la base de datos
    Map<String, dynamic> dbPlant = {
      'name': plant['name'],
      'price': plant['price'], 
      'category': plant['category'],
      'description': plant['description'],
      'care_instructions': plant['care_instructions'],
      'image_url': plant['image_url'] ?? plant['imageUrl'],
      'image': plant['image'],
      'rating': plant['rating'],
      'reviews': plant['reviews'],
      'updated_at': DateTime.now().toIso8601String(),
      'needs_sync': 1,
    };
    
    // Remover claves con valores nulos
    dbPlant.removeWhere((key, value) => value == null);
    
    return conn!.update("plant", dbPlant, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePlant(int id) async {
    var conn = await database;
    Map<String, dynamic> data = {
      'is_deleted': 1,
      'needs_sync': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };
    return conn!.update("plant", data, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getPlantsNeedingSync() async {
    var conn = await database;
    return conn!.query("plant", where: 'needs_sync = ?', whereArgs: [1]);
  }

  Future<void> markPlantAsSynced(int id, String firebaseId) async {
    var conn = await database;
    await conn!.update(
      "plant",
      {'firebase_id': firebaseId, 'needs_sync': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getPlantByFirebaseId(String firebaseId) async {
    var conn = await database;
    var result = await conn!.query(
      "plant",
      where: 'firebase_id = ?',
      whereArgs: [firebaseId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // =============== MÉTODOS DE DEBUGGING ===============
  
  Future<void> printTableStructure() async {
    var conn = await database;
    var tableInfo = await conn!.rawQuery("PRAGMA table_info(plant)");
    print('📊 Plant table structure:');
    for (var column in tableInfo) {
      print('  - ${column['name']}: ${column['type']} (${column['dflt_value'] ?? 'no default'})');
    }
  }

  Future<void> recreateDatabase() async {
    print('🔄 Force recreating database...');
    
    // Obtener path de la BD
    Directory folder = await getApplicationDocumentsDirectory();
    String pathDB = join(folder.path, nameDB);
    
    // Cerrar conexión actual si existe
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    // Eliminar archivo de BD
    try {
      File dbFile = File(pathDB);
      if (await dbFile.exists()) {
        await dbFile.delete();
        print('🗑️ Old database deleted');
      }
    } catch (e) {
      print('⚠️ Error deleting database: $e');
    }
    
    // Recrear BD
    _database = await _initDatabase();
    print('✅ Database recreated successfully');
  }

  // =============== MÉTODOS ESPECÍFICOS PARA CARRITO ===============
  
  Future<int> insertCartItem(Map<String, dynamic> cartItem) async {
    var conn = await database;
    cartItem['updated_at'] = DateTime.now().toIso8601String();
    cartItem['needs_sync'] = 1;
    return conn!.insert("cart", cartItem);
  }

  Future<int> updateCartItem(int id, Map<String, dynamic> cartItem) async {
    var conn = await database;
    cartItem['updated_at'] = DateTime.now().toIso8601String();
    cartItem['needs_sync'] = 1;
    return conn!.update("cart", cartItem, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCartItem(int id) async {
    var conn = await database;
    Map<String, dynamic> data = {
      'is_deleted': 1,
      'needs_sync': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };
    return conn!.update("cart", data, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    var conn = await database;
    return conn!.query(
      "cart",
      where: 'user_id = ? AND is_deleted = ?',
      whereArgs: [userId, 0],
    );
  }

  Future<List<Map<String, dynamic>>> getCartItemsNeedingSync() async {
    var conn = await database;
    return conn!.query("cart", where: 'needs_sync = ?', whereArgs: [1]);
  }

  Future<void> markCartItemAsSynced(int id, String firebaseId) async {
    var conn = await database;
    await conn!.update(
      "cart",
      {'firebase_id': firebaseId, 'needs_sync': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getCartItemByFirebaseId(String firebaseId) async {
    var conn = await database;
    var result = await conn!.query(
      "cart",
      where: 'firebase_id = ?',
      whereArgs: [firebaseId],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
