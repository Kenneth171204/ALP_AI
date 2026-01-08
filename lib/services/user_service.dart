import 'package:flutter/material.dart';

class MockUserService {
  // Singleton Pattern (Agar datanya satu dan bisa diakses dari mana saja)
  static final MockUserService _instance = MockUserService._internal();
  factory MockUserService() => _instance;
  MockUserService._internal();

  // Data User Sementara (Simulasi Database)
  String username = "User_FloodAware";
  int avatarIndex = 0; // Default: Avatar urutan ke-0

  // Daftar Pilihan Avatar (Disimpan di sini agar Home & Profile pakai data yang sama)
  final List<Map<String, dynamic>> avatarList = [
    {'icon': Icons.person, 'color': Colors.grey, 'label': 'Default'},
    {'icon': Icons.pets, 'color': Colors.orangeAccent, 'label': 'Kucing'},
    {'icon': Icons.cruelty_free, 'color': Colors.pinkAccent, 'label': 'Kelinci'},
    {'icon': Icons.bug_report, 'color': Colors.greenAccent, 'label': 'Kumbang'},
    {'icon': Icons.water_drop, 'color': Colors.blueAccent, 'label': 'Hujan'},
    {'icon': Icons.thunderstorm, 'color': Colors.purpleAccent, 'label': 'Badai'},
    {'icon': Icons.beach_access, 'color': Colors.redAccent, 'label': 'Payung'},
    {'icon': Icons.wb_sunny, 'color': Colors.amber, 'label': 'Cerah'},
  ];
}