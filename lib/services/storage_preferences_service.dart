import 'dart:async';

enum StorageMode {
  local,    // Solo SQLite
  firebase, // Solo Firebase
}

class StoragePreferencesService {
  static final StoragePreferencesService _instance = StoragePreferencesService._internal();
  factory StoragePreferencesService() => _instance;
  StoragePreferencesService._internal();

  StorageMode _currentMode = StorageMode.firebase; // Por defecto Firebase
  StreamController<StorageMode> _modeController = StreamController<StorageMode>.broadcast();

  Stream<StorageMode> get modeStream => _modeController.stream;
  StorageMode get currentMode => _currentMode;

  void setStorageMode(StorageMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      _modeController.add(mode);
      print('💾 Storage mode changed to: ${mode == StorageMode.local ? "Local (SQLite)" : "Firebase"}');
    }
  }

  bool get isLocalMode => _currentMode == StorageMode.local;
  bool get isFirebaseMode => _currentMode == StorageMode.firebase;

  String get modeDisplayName {
    switch (_currentMode) {
      case StorageMode.local:
        return "📱 Dispositivo (SQLite)";
      case StorageMode.firebase:
        return "☁️ Firebase (Nube)";
    }
  }

  void dispose() {
    _modeController.close();
  }
}