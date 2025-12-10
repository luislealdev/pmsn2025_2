import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pmsn2025_2/firebase_options.dart';
import 'package:pmsn2025_2/screens/flora/account_screen.dart';
import 'package:pmsn2025_2/screens/flora/cart_screen.dart';
import 'package:pmsn2025_2/screens/flora/flora_home_screen.dart';
import 'package:pmsn2025_2/screens/home_screen.dart';
import 'package:pmsn2025_2/screens/login_screen.dart';
import 'package:pmsn2025_2/screens/movies/add_movie_screen.dart';
import 'package:pmsn2025_2/screens/movies/api/list_api_movies.dart';
import 'package:pmsn2025_2/screens/movies/list_movies_screen.dart';
import 'package:pmsn2025_2/screens/register_screen.dart';
import 'package:pmsn2025_2/screens/songs/add_song_screen.dart';
import 'package:pmsn2025_2/screens/songs/list_songs_screen.dart';
import 'package:pmsn2025_2/utils/theme_app.dart';
import 'package:pmsn2025_2/utils/value_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ValueListener.isDark,
      builder: (context, value, _) {
        return MaterialApp(
          theme: value ? ThemeApp.darkTheme() : ThemeApp.lightTheme(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/register': (context) => const RegisterScreen(),
            '/flora': (context) => FloraHomeScreen(),
            '/account': (context) => const AccountScreen(),
            '/cart': (context) => const CartScreen(),
            "/add": (context) => const AddMovieScreen(),
            "/listdb": (context) => const ListMoviesScreen(),
            "/songs": (context) => const ListSongsScreen(),
            "/add-song": (context) => const AddSongScreen(),
            "/api-movies": (context) => const ListApiMovies(),
          },
          debugShowCheckedModeBanner: false,
          home: const LoginScreen(),
        );
      },
    );
  }
}
