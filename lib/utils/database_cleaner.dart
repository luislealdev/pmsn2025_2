import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseCleaner {
  static Future<void> clearDatabase() async {
    try {
      Directory folder = await getApplicationDocumentsDirectory();
      String pathDB = join(folder.path, "PLANTSDB");
      
      File dbFile = File(pathDB);
      if (await dbFile.exists()) {
        await dbFile.delete();
        print('🗑️ Old database deleted successfully');
      }
    } catch (e) {
      print('⚠️ Error deleting database: $e');
    }
  }
}