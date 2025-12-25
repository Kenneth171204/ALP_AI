import 'package:flutter/material.dart';
import 'pages/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FloodAware',
      // Kita set tema gelap sebagai basis
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4A00E0), // Ungu seperti di gambar
        scaffoldBackgroundColor: const Color(0xFF1E1E2C), // Warna cadangan
        useMaterial3: true,
        fontFamily: 'Roboto', // Font standar yang bersih
      ),
      home: const LandingPage(),
    );
  }
}