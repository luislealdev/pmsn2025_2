import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pmsn2025_2/firebase/cart_firebase.dart';
import 'package:pmsn2025_2/database/plants_database.dart';
import 'package:pmsn2025_2/services/storage_preferences_service.dart';
import 'package:pmsn2025_2/services/firebase_error_notification_service.dart';

class SimpleCartService {
  static final SimpleCartService _instance = SimpleCartService._internal();
  factory SimpleCartService() => _instance;
  SimpleCartService._internal();

  final CartFirebase _cartFirebase = CartFirebase();
  final PlantsDatabase _plantsDatabase = PlantsDatabase();
  final StoragePreferencesService _storagePrefs = StoragePreferencesService();
  final FirebaseErrorNotificationService _errorNotification = FirebaseErrorNotificationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamController<List<Map<String, dynamic>>> _cartController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get cartStream => _cartController.stream;

  bool _isInitialized = false;
  bool _firebaseHasPermissionError = false;
  String? _currentUserId;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _currentUserId = _auth.currentUser?.uid;
    if (_currentUserId == null) {
      throw Exception('User must be logged in to use cart service');
    }

    // Cargar datos según el modo actual
    await _loadCartItems();

    // Escuchar cambios en el modo de almacenamiento
    _storagePrefs.modeStream.listen((mode) {
      _loadCartItems();
    });

    _isInitialized = true;
    print('✅ Simple Cart Service initialized');
  }

  Future<void> addToCart(Map<String, dynamic> cartItem) async {
    if (_currentUserId == null) throw Exception('User not logged in');
    
    try {
      cartItem['user_id'] = _currentUserId;
      cartItem['created_at'] = DateTime.now().toIso8601String();
      cartItem['quantity'] = cartItem['quantity'] ?? 1;
      
      if (_storagePrefs.isFirebaseMode && !_firebaseHasPermissionError) {
        try {
          // Guardar en Firebase
          await _cartFirebase.insertCartItem(cartItem);
          print('☁️ Cart item saved to Firebase');
        } on FirebaseException catch (firebaseError) {
          print('🔥 Firebase Error: ${firebaseError.code} - ${firebaseError.message}');
          
          if (firebaseError.code == 'permission-denied' || 
              firebaseError.code == 'unauthenticated') {
            print('⚠️  Firebase permission error detected, switching to local mode');
            _firebaseHasPermissionError = true;
            _storagePrefs.setStorageMode(StorageMode.local);
            _errorNotification.notifyFirebaseError();
            
            // Guardar en SQLite como fallback
            await _plantsDatabase.insertCartItem(cartItem);
            print('📱 Cart item saved locally as fallback');
          } else {
            rethrow;
          }
        }
      } else {
        // Guardar en SQLite local
        await _plantsDatabase.insertCartItem(cartItem);
        print('📱 Cart item saved locally');
      }
      
      await _loadCartItems();
    } catch (e) {
      print('❌ Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> updateCartItem(String cartItemId, Map<String, dynamic> updates) async {
    if (_currentUserId == null) throw Exception('User not logged in');
    
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      if (_storagePrefs.isFirebaseMode) {
        // Actualizar en Firebase
        await _cartFirebase.updateCartItem(cartItemId, updates);
        print('☁️ Cart item updated in Firebase');
      } else {
        // Actualizar en SQLite local
        int? localId = int.tryParse(cartItemId);
        if (localId != null) {
          await _plantsDatabase.updateCartItem(localId, updates);
          print('📱 Cart item updated locally');
        } else {
          throw Exception('Invalid cart item ID for local storage');
        }
      }
      
      await _loadCartItems();
    } catch (e) {
      print('❌ Error updating cart item: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (_currentUserId == null) throw Exception('User not logged in');
    
    try {
      if (_storagePrefs.isFirebaseMode) {
        // Eliminar de Firebase
        await _cartFirebase.deleteCartItem(cartItemId);
        print('☁️ Cart item deleted from Firebase');
      } else {
        // Eliminar de SQLite local
        int? localId = int.tryParse(cartItemId);
        if (localId != null) {
          await _plantsDatabase.deleteCartItem(localId);
          print('📱 Cart item deleted locally');
        } else {
          throw Exception('Invalid cart item ID for local storage');
        }
      }
      
      await _loadCartItems();
    } catch (e) {
      print('❌ Error removing from cart: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    if (_currentUserId == null) throw Exception('User not logged in');
    
    try {
      if (_storagePrefs.isFirebaseMode) {
        // Obtener items de Firebase y eliminar uno por uno
        var snapshot = await _cartFirebase.selectAllCartItems(_currentUserId!).first;
        for (var doc in snapshot.docs) {
          await _cartFirebase.deleteCartItem(doc.id);
        }
      } else {
        // Eliminar de SQLite local
        var cartItems = await _plantsDatabase.getCartItems(_currentUserId!);
        for (var item in cartItems) {
          await _plantsDatabase.deleteCartItem(item['id']);
        }
      }
      
      await _loadCartItems();
      print('🛒 Cart cleared');
    } catch (e) {
      print('❌ Error clearing cart: $e');
      rethrow;
    }
  }

  Future<int> getCartItemsCount() async {
    if (_currentUserId == null) return 0;
    
    try {
      if (_storagePrefs.isFirebaseMode) {
        var snapshot = await _cartFirebase.selectAllCartItems(_currentUserId!).first;
        int total = 0;
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          total += (data['quantity'] as int? ?? 0);
        }
        return total;
      } else {
        var cartItems = await _plantsDatabase.getCartItems(_currentUserId!);
        int total = 0;
        for (var item in cartItems) {
          total += (item['quantity'] as int? ?? 0);
        }
        return total;
      }
    } catch (e) {
      print('❌ Error getting cart items count: $e');
      return 0;
    }
  }

  Future<double> getCartTotal() async {
    if (_currentUserId == null) return 0.0;
    
    try {
      double total = 0.0;
      
      if (_storagePrefs.isFirebaseMode) {
        var snapshot = await _cartFirebase.selectAllCartItems(_currentUserId!).first;
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          double price = data['price']?.toDouble() ?? 0.0;
          int quantity = data['quantity'] ?? 1;
          total += price * quantity;
        }
      } else {
        var cartItems = await _plantsDatabase.getCartItems(_currentUserId!);
        for (var item in cartItems) {
          double price = item['price']?.toDouble() ?? 0.0;
          int quantity = item['quantity'] ?? 1;
          total += price * quantity;
        }
      }
      
      return total;
    } catch (e) {
      print('❌ Error calculating cart total: $e');
      return 0.0;
    }
  }

  Future<void> _loadCartItems() async {
    if (_currentUserId == null) return;
    
    try {
      if (_storagePrefs.isFirebaseMode) {
        // Cargar de Firebase usando stream
        _cartFirebase.selectAllCartItems(_currentUserId!).listen((snapshot) {
          var cartData = snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
          _cartController.add(cartData);
        });
      } else {
        // Cargar de SQLite local
        var cartItems = await _plantsDatabase.getCartItems(_currentUserId!);
        _cartController.add(cartItems);
      }
    } catch (e) {
      print('❌ Error loading cart items: $e');
      _cartController.add([]);
    }
  }

  void dispose() {
    _cartController.close();
  }
}