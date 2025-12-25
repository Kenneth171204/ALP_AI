import '../models/flood_model.dart';

class MockFloodService {
  // 1. KITA BUAT DATABASE KOTA YANG KITA KENAL
  final Map<String, String> _knownCities = {
    // HIGH RISK
    "jakarta": "High", "semarang": "High", "bekasi": "High", 
    "tangerang": "High", "gorontalo": "High", "samarinda": "High",
    
    // MEDIUM RISK
    "surabaya": "Medium", "bandung": "Medium", "medan": "Medium", 
    "palembang": "Medium", "bogor": "Medium", "depok": "Medium",
    
    // LOW RISK
    "bali": "Low", "denpasar": "Low", "jogja": "Low", "yogyakarta": "Low",
    "malang": "Low", "papua": "Low", "lombok": "Low"
  };

  Future<FloodModel> getPrediction(String inputCity) async {
    await Future.delayed(const Duration(seconds: 1)); // Loading cepat
    
    final input = inputCity.toLowerCase().trim();

    // A. CEK APAKAH ADA MATCH TEPAT (EXACT MATCH)
    if (_knownCities.containsKey(input)) {
      return _getDataByRisk(_knownCities[input]!);
    }

    // B. CEK TYPO (FUZZY MATCH)
    // Mencari kota yang mirip tulisannya
    String? bestMatch;
    int closestDistance = 100;

    for (var city in _knownCities.keys) {
      int dist = _calculateLevenshtein(input, city);
      // Jika beda hurufnya sedikit (kurang dari 3 huruf), kita anggap typo
      if (dist < 3 && dist < closestDistance) {
        closestDistance = dist;
        bestMatch = city;
      }
    }

    // Jika ketemu yang mirip (Misal input "jatarta", ketemu "jakarta")
    if (bestMatch != null) {
      return FloodModel(
        risk: "Typo", // Status Khusus
        weather: "-",
        beforeFlood: [], duringFlood: [], afterFlood: [],
        suggestedCity: bestMatch, // Kirim saran perbaikan
      );
    }

    // C. JIKA TIDAK ADA YANG MIRIP SAMA SEKALI
    return FloodModel(
      risk: "NotFound", // Status Tidak Ditemukan
      weather: "-",
      beforeFlood: [], duringFlood: [], afterFlood: [],
    );
  }

  // --- FUNGSI ALGORITMA JARAK HURUF (LEVENSHTEIN) ---
  // Menghitung berapa huruf yang beda antar 2 kata
  int _calculateLevenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> v0 = List<int>.filled(b.length + 1, 0);
    List<int> v1 = List<int>.filled(b.length + 1, 0);

    for (int i = 0; i < b.length + 1; i++) v0[i] = i;

    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        int cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost]
            .reduce((curr, next) => curr < next ? curr : next);
      }
      for (int j = 0; j < b.length + 1; j++) v0[j] = v1[j];
    }
    return v1[b.length];
  }

  // --- DATABASE DATA BERDASARKAN RISIKO ---
  FloodModel _getDataByRisk(String riskLevel) {
    if (riskLevel == "High") {
      return FloodModel(
        risk: "High",
        weather: "Hujan Badai & Petir",
        beforeFlood: ["Matikan Listrik", "Amankan Dokumen", "Siapkan Tas Siaga"],
        duringFlood: ["EVAKUASI DIRI", "Jangan sentuh tiang listrik", "Hubungi SAR"],
        afterFlood: ["Cek pondasi rumah", "Bersihkan lumpur", "Waspada penyakit"],
      );
    } else if (riskLevel == "Medium") {
      return FloodModel(
        risk: "Medium",
        weather: "Hujan Deras Awet",
        beforeFlood: ["Bersihkan selokan", "Angkat barang elektronik", "Cek atap bocor"],
        duringFlood: ["Kurangi keluar rumah", "Pantau parit", "Hati-hati licin"],
        afterFlood: ["Serok genangan", "Cek mesin motor", "Kuras bak mandi"],
      );
    } else {
      return FloodModel(
        risk: "Low",
        weather: "Cerah Berawan",
        beforeFlood: ["Kerja bakti rutin", "Buang sampah pada tempatnya", "Tanam pohon"],
        duringFlood: ["Sedia payung", "Minum vitamin", "Hati-hati di jalan"],
        afterFlood: ["Lanjut aktivitas", "Bantu korban lain", "Bersyukur aman"],
      );
    }
  }
}