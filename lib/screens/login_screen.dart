import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pmsn2025_2/firebase/fire_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController conUser = TextEditingController();
  TextEditingController conPwd = TextEditingController();
  bool isValidating = false;
  FireAuth? auth;

  @override
  void initState() {
    super.initState();
    auth = FireAuth();
  }

  void _login() async {
    // Validar que los campos no estén vacíos
    if (conUser.text.trim().isEmpty || conPwd.text.trim().isEmpty) {
      _showErrorMessage('❌ Por favor completa todos los campos');
      return;
    }

    // Validar formato de email básico
    if (!conUser.text.contains('@') || !conUser.text.contains('.')) {
      _showErrorMessage('📧 Por favor ingresa un correo electrónico válido');
      return;
    }

    setState(() {
      isValidating = true;
    });

    try {
      // Intentar iniciar sesión con Firebase Auth
      var user = await auth!.signInWithEmailAndPassword(
        conUser.text.trim(),
        conPwd.text,
      );

      setState(() {
        isValidating = false;
      });

      if (user != null && user.uid.isNotEmpty) {
        // Login exitoso
        print('Login exitoso: ${user.uid}');
        
        _showSuccessMessage('¡Bienvenido de vuelta!');
        
        // Navegar a la pantalla principal
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorMessage('Error al iniciar sesión. Intenta nuevamente.');
      }
    } catch (e) {
      setState(() {
        isValidating = false;
      });

      print('Error capturado en login: $e');
      print('Tipo de error: ${e.runtimeType}');

      // Manejar todos los tipos de error de manera uniforme
      String errorMessage;
      
      if (e is FirebaseAuthException) {
        errorMessage = _getFirebaseErrorMessage(e.code);
      } else {
        // Para cualquier otro tipo de error (PlatformException, TypeError, etc.)
        errorMessage = '❌ Credenciales incorrectas.\nVerifica tu correo electrónico y contraseña.';
      }
      
      _showErrorMessage(errorMessage);
    }
  }

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return '❌ No existe una cuenta con este correo electrónico.\n¿Quieres registrarte?';
      case 'wrong-password':
        return '🔒 Contraseña incorrecta.\nRevisa tu contraseña e intenta nuevamente.';
      case 'invalid-email':
        return '📧 El formato del correo electrónico no es válido.\nVerifica que esté escrito correctamente.';
      case 'invalid-credential':
        return '❌ Credenciales incorrectas.\nVerifica tu correo electrónico y contraseña.';
      case 'user-disabled':
        return '🚫 Esta cuenta ha sido deshabilitada.\nContacta al administrador.';
      case 'too-many-requests':
        return '⏱️ Demasiados intentos fallidos.\nEspera un momento antes de intentar nuevamente.';
      case 'network-request-failed':
        return '🌐 Error de conexión.\nVerifica tu conexión a internet.';
      case 'invalid-input':
        return '⚠️ Por favor completa todos los campos correctamente.';
      case 'unknown-error':
        return '⚠️ Error inesperado.\nPor favor intenta nuevamente.';
      default:
        return '⚠️ Error al iniciar sesión: $errorCode\nPor favor intenta nuevamente.';
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txtUser = TextField(
      keyboardType: TextInputType.emailAddress,
      controller: conUser,
      decoration: InputDecoration(
        hintText: "Correo Electrónico",
        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );

    final txtPwd = TextField(
      obscureText: true,
      controller: conPwd,
      decoration: InputDecoration(
        hintText: "Contraseña",
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );

    return Scaffold(
      // endDrawer: Drawer(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/bg.jpg"),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text(
                    "GOOGLE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(25),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      // color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    txtUser,
                    SizedBox(height: 20),
                    txtPwd,
                    SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _login();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          elevation: 3,
                          // shadowColor: Colors.blue.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Iniciar Sesión",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        "¿No tienes una cuenta? Regístrate",
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/flora');
                      },
                      child: Text(
                        "Ingresa a Flora",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child:
                  isValidating
                      ? Center(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                // color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset('assets/loading.json', height: 150),
                              SizedBox(height: 15),
                              Text(
                                "Validando credenciales...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
