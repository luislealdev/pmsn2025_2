import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pmsn2025_2/firebase/plants_firebase.dart';
import 'package:pmsn2025_2/database/plants_database.dart';
import 'package:pmsn2025_2/services/storage_preferences_service.dart';
import 'package:pmsn2025_2/services/firebase_error_notification_service.dart';

class SimplePlantsService {
  static final SimplePlantsService _instance = SimplePlantsService._internal();
  factory SimplePlantsService() => _instance;
  SimplePlantsService._internal();

  final PlantsFirebase _plantsFirebase = PlantsFirebase();
  final PlantsDatabase _plantsDatabase = PlantsDatabase();
  final StoragePreferencesService _storagePrefs = StoragePreferencesService();
  final FirebaseErrorNotificationService _errorNotification = FirebaseErrorNotificationService();

  StreamController<List<Map<String, dynamic>>> _plantsController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get plantsStream => _plantsController.stream;

  bool _isInitialized = false;
  bool _firebaseHasPermissionError = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Forzar recreación de BD para asegurar estructura correcta
    try {
      print('🔄 Forcing database recreation to ensure correct structure...');
      await _plantsDatabase.recreateDatabase();
      await _plantsDatabase.printTableStructure();
    } catch (e) {
      print('⚠️ Error recreating database: $e');
    }

    // Cargar datos según el modo actual
    await _loadPlants();

    // Escuchar cambios en el modo de almacenamiento
    _storagePrefs.modeStream.listen((mode) {
      _loadPlants();
    });

    _isInitialized = true;
    print('✅ Simple Plants Service initialized');
  }

  Future<void> insertPlant(Map<String, dynamic> plant) async {
    try {
      plant['created_at'] = DateTime.now().toIso8601String();
      
      if (_storagePrefs.isFirebaseMode && !_firebaseHasPermissionError) {
        try {
          // Guardar en Firebase
          await _plantsFirebase.insertPlant(plant);
          print('☁️ Plant saved to Firebase');
        } on FirebaseException catch (firebaseError) {
          print('🔥 Firebase Error: ${firebaseError.code} - ${firebaseError.message}');
          
          if (firebaseError.code == 'permission-denied' || 
              firebaseError.code == 'unauthenticated') {
            print('⚠️  Firebase permission error detected, switching to local mode');
            _firebaseHasPermissionError = true;
            _storagePrefs.setStorageMode(StorageMode.local);
            _errorNotification.notifyFirebaseError();
            
            // Guardar en SQLite como fallback
            await _plantsDatabase.insertPlant(plant);
            print('📱 Plant saved locally as fallback');
          } else {
            rethrow;
          }
        }
      } else {
        // Guardar en SQLite local
        await _plantsDatabase.insertPlant(plant);
        print('📱 Plant saved locally');
      }
      
      await _loadPlants();
    } catch (e) {
      print('❌ Error inserting plant: $e');
      rethrow;
    }
  }

  Future<void> updatePlant(String plantId, Map<String, dynamic> plant) async {
    try {
      plant['updated_at'] = DateTime.now().toIso8601String();
      
      if (_storagePrefs.isFirebaseMode) {
        // Actualizar en Firebase
        await _plantsFirebase.updatePlant(plantId, plant);
        print('☁️ Plant updated in Firebase');
      } else {
        // Actualizar en SQLite local
        // Necesitamos convertir el plantId a int para SQLite
        int? localId = int.tryParse(plantId);
        if (localId != null) {
          await _plantsDatabase.updatePlant(localId, plant);
          print('📱 Plant updated locally');
        } else {
          throw Exception('Invalid plant ID for local storage');
        }
      }
      
      await _loadPlants();
    } catch (e) {
      print('❌ Error updating plant: $e');
      rethrow;
    }
  }

  Future<void> deletePlant(String plantId) async {
    try {
      if (_storagePrefs.isFirebaseMode) {
        // Eliminar de Firebase
        await _plantsFirebase.deletePlant(plantId);
        print('☁️ Plant deleted from Firebase');
      } else {
        // Eliminar de SQLite local
        int? localId = int.tryParse(plantId);
        if (localId != null) {
          await _plantsDatabase.deletePlant(localId);
          print('📱 Plant deleted locally');
        } else {
          throw Exception('Invalid plant ID for local storage');
        }
      }
      
      await _loadPlants();
    } catch (e) {
      print('❌ Error deleting plant: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getPlantById(String plantId) async {
    try {
      if (_storagePrefs.isFirebaseMode) {
        // Obtener de Firebase
        var firebaseDoc = await _plantsFirebase.selectPlantById(plantId);
        if (firebaseDoc.exists) {
          var data = firebaseDoc.data() as Map<String, dynamic>;
          data['id'] = firebaseDoc.id;
          return data;
        }
      } else {
        // Obtener de SQLite local
        var localPlants = await _plantsDatabase.select();
        int? localId = int.tryParse(plantId);
        if (localId != null) {
          var plant = localPlants.where((p) => p.toJson()['id'] == localId).firstOrNull;
          return plant?.toJson();
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting plant by ID: $e');
      return null;
    }
  }

  Future<void> _loadPlants() async {
    try {
      if (_storagePrefs.isFirebaseMode && !_firebaseHasPermissionError) {
        try {
          // Cargar de Firebase usando stream
          _plantsFirebase.selectAllPlants().listen(
            (snapshot) {
              var plantsData = snapshot.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              }).toList();
              _plantsController.add(plantsData);
            },
            onError: (error) {
              print('🔥 Firebase stream error: $error');
              if (error is FirebaseException && 
                  (error.code == 'permission-denied' || error.code == 'unauthenticated')) {
                print('⚠️  Firebase permission error in stream, switching to local mode');
                _firebaseHasPermissionError = true;
                _storagePrefs.setStorageMode(StorageMode.local);
                _errorNotification.notifyFirebaseError();
                _loadPlantsFromLocal();
              }
            },
          );
        } on FirebaseException catch (firebaseError) {
          print('🔥 Firebase Error during load: ${firebaseError.code}');
          if (firebaseError.code == 'permission-denied' || 
              firebaseError.code == 'unauthenticated') {
            _firebaseHasPermissionError = true;
            _storagePrefs.setStorageMode(StorageMode.local);
            _errorNotification.notifyFirebaseError();
            await _loadPlantsFromLocal();
          }
        }
      } else {
        await _loadPlantsFromLocal();
      }
    } catch (e) {
      print('❌ Error loading plants: $e');
      // Como último recurso, cargar de local
      await _loadPlantsFromLocal();
    }
  }

  Future<void> _loadPlantsFromLocal() async {
    try {
      var localPlants = await _plantsDatabase.select();
      var plantsData = localPlants.map((plant) => plant.toJson()).toList();
      _plantsController.add(plantsData);
      print('📱 Plants loaded from local database');
    } catch (e) {
      print('❌ Error loading from local: $e');
      _plantsController.add([]);
    }
  }

  /// Sincronizar datos entre Firebase y Local (función manual)
  Future<void> syncFromFirebaseToLocal() async {
    if (_storagePrefs.isFirebaseMode) {
      throw Exception('Cannot sync to local while in Firebase mode');
    }
    
    try {
      print('🔄 Syncing plants from Firebase to Local...');
      var snapshot = await _plantsFirebase.selectAllPlants().first;
      
      for (var doc in snapshot.docs) {
        var firebaseData = doc.data() as Map<String, dynamic>;
        firebaseData.remove('id'); // Remover el ID de Firebase para SQLite
        await _plantsDatabase.insertPlant(firebaseData);
      }
      
      await _loadPlants();
      print('✅ Plants synced from Firebase to Local');
    } catch (e) {
      print('❌ Error syncing from Firebase to Local: $e');
      rethrow;
    }
  }

  /// Sincronizar datos desde Local a Firebase (función manual)
  Future<void> syncFromLocalToFirebase() async {
    if (_storagePrefs.isLocalMode) {
      throw Exception('Cannot sync to Firebase while in Local mode');
    }
    
    try {
      print('🔄 Syncing plants from Local to Firebase...');
      var localPlants = await _plantsDatabase.select();
      
      for (var plant in localPlants) {
        var plantData = plant.toJson();
        plantData.remove('id'); // Remover el ID local para Firebase
        await _plantsFirebase.insertPlant(plantData);
      }
      
      await _loadPlants();
      print('✅ Plants synced from Local to Firebase');
    } catch (e) {
      print('❌ Error syncing from Local to Firebase: $e');
      rethrow;
    }
  }

  void dispose() {
    _plantsController.close();
  }
}