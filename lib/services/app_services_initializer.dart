import 'package:pmsn2025_2/services/simple_plants_service.dart';
import 'package:pmsn2025_2/services/simple_cart_service.dart';

class AppServicesInitializer {
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Inicializar servicios
      final plantsService = SimplePlantsService();
      final cartService = SimpleCartService();
      
      await plantsService.initialize();
      await cartService.initialize();
      
      _initialized = true;
      print('🚀 App Services initialized successfully');
    } catch (e) {
      print('❌ Error initializing App Services: $e');
      // No hacer throw para que la app pueda continuar
    }
  }
  
  static bool get isInitialized => _initialized;
}