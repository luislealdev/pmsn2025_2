import 'dart:async';

class FirebaseErrorNotificationService {
  static final FirebaseErrorNotificationService _instance = 
      FirebaseErrorNotificationService._internal();
  factory FirebaseErrorNotificationService() => _instance;
  FirebaseErrorNotificationService._internal();

  final StreamController<bool> _errorController = 
      StreamController<bool>.broadcast();

  Stream<bool> get errorStream => _errorController.stream;
  
  bool _hasError = false;
  bool get hasError => _hasError;

  void notifyFirebaseError() {
    _hasError = true;
    _errorController.add(true);
  }

  void dismissError() {
    _hasError = false;
    _errorController.add(false);
  }

  void dispose() {
    _errorController.close();
  }
}