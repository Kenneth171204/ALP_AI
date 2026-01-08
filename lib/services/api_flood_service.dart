import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // 1. Needed to detect Web vs Mobile
import '../models/flood_model.dart';

class ApiFloodService {
  
  // 2. SMART URL LOGIC
  // This automatically switches the address based on the device
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:5000/predict"; // Address for Chrome/Web
    } else {
      return "http://10.0.2.2:5000/predict";  // Address for Android Emulator
    }
  }

  Future<FloodModel> getPrediction(String city) async {
    try {
      print("Connecting to: $baseUrl with city: $city"); // Debug print

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*" // Good practice for Web requests
        },
        body: jsonEncode({"city": city}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FloodModel.fromJson(data);
      } else {
        // Handle error (e.g. City not found returns 404)
        return _getErrorModel("Kota tidak ditemukan atau Server Error");
      }
    } catch (e) {
      print("Error connecting to API: $e");
      return _getErrorModel("Gagal koneksi ke Server (Cek Terminal Python)");
    }
  }

  // Helper function to create an Error Model cleanly
  FloodModel _getErrorModel(String msg) {
    return FloodModel(
      risk: "NotFound",
      weather: msg,
      beforeFlood: [],
      duringFlood: [],
      afterFlood: [],
    );
  }
}