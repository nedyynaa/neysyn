import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/splash_page.dart';
import 'pages/auth_choice_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/topic_selection_page.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/notifications_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neysyn',
      theme: ThemeData(
        textTheme: GoogleFonts.loraTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/auth-choice': (context) => const AuthChoicePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/topic-selection': (context) => const TopicSelectionPage(),
        '/home': (context) => const HomePage(),
        '/search': (context) => const SearchPage(),
        '/edit': (context) => const RegisterPage(), // Sesuaikan jika ada halaman edit khusus
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}