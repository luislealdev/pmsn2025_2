import 'dart:async';
import 'dart:io';

/// Servicio de conectividad que NO usa connectivity_plus
/// Alternativa para evitar problemas con plugins nativos
class ConnectivityServiceNative {
  static final ConnectivityServiceNative _instance = ConnectivityServiceNative._internal();
  factory ConnectivityServiceNative() => _instance;
  ConnectivityServiceNative._internal();

  StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  bool _isConnected = true; // Asumir conectado por defecto
  Timer? _checkTimer;

  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool get isConnected => _isConnected;

  void initialize() {
    print('🌐 Using Native Connectivity Service (no plugins)');
    
    // Verificar conectividad inicial
    _checkConnectivity();
    
    // Verificar conectividad cada 5 segundos
    _checkTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    bool wasConnected = _isConnected;
    
    try {
      // Intentar conectar a múltiples servidores DNS confiables
      final futures = [
        InternetAddress.lookup('google.com'),
        InternetAddress.lookup('cloudflare.com'),
        InternetAddress.lookup('firebase.google.com'),
      ];
      
      // Usar Future.any para que el primero que responda determine conectividad
      final result = await Future.any(futures).timeout(Duration(seconds: 4));
      _isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _isConnected = false;
    }

    // Solo notificar si cambió el estado
    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
      print('🌐 Connection status changed: ${_isConnected ? "Connected" : "Disconnected"}');
    }
  }

  /// Verificar conectividad manualmente con timeout específico
  Future<bool> checkConnectivity({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verificar conectividad específicamente con Firebase
  Future<bool> checkFirebaseConnectivity() async {
    try {
      final result = await InternetAddress.lookup('firebase.google.com')
          .timeout(Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _checkTimer?.cancel();
    _connectivityController.close();
  }
}