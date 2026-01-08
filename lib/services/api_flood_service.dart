import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; 
import '../models/flood_model.dart';

class ApiFloodService {
  
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:5000/predict"; 
    } else {
      return "http://10.0.2.2:5000/predict";  
    }
  }

  Future<FloodModel> getPrediction(String city) async {
    try {
      print("Connecting to: $baseUrl with city: $city");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*" 
        },
        body: jsonEncode({"city": city}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FloodModel.fromJson(data);
      } else {
        return _getErrorModel("NotFound");
      }
    } catch (e) {
      print("Error connecting to API: $e");
      return _getErrorModel("Error");
    }
  }

  // FIXED: Adjusted to match the new FloodModel constructor
  FloodModel _getErrorModel(String errorType) {
    return FloodModel(
      risk: errorType, // "NotFound" or "Error"
      cityName: "Error",
    );
  }
}