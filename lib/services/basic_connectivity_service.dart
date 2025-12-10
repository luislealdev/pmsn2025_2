import 'dart:async';
import 'dart:io';

/// Servicio de conectividad ultra-simple
/// Solo verifica cuando se le solicita explícitamente
class BasicConnectivityService {
  static final BasicConnectivityService _instance = BasicConnectivityService._internal();
  factory BasicConnectivityService() => _instance;
  BasicConnectivityService._internal();

  StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  bool _isConnected = true; // Asumir conectado por defecto

  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool get isConnected => _isConnected;

  void initialize() {
    print('🌐 Using Basic Connectivity Service (manual checks only)');
    // No hacer verificaciones automáticas para evitar problemas
  }

  /// Verificar conectividad manualmente
  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 3));
      bool newStatus = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (_isConnected != newStatus) {
        _isConnected = newStatus;
        _connectivityController.add(newStatus);
        print('🌐 Connection status: ${newStatus ? "Connected" : "Disconnected"}');
      }
      
      return newStatus;
    } catch (e) {
      if (_isConnected) {
        _isConnected = false;
        _connectivityController.add(false);
        print('🌐 Connection lost');
      }
      return false;
    }
  }

  void dispose() {
    _connectivityController.close();
  }
}