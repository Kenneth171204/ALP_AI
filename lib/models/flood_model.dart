class FloodModel {
  final String risk;          // "High", "Medium", "Low", "Typo", "NotFound"
  final String weather;
  final List<String> beforeFlood;
  final List<String> duringFlood;
  final List<String> afterFlood;
  
  // FIELD BARU: Untuk menyimpan saran nama kota (misal: "Jakarta")
  final String? suggestedCity;

  FloodModel({
    required this.risk,
    required this.weather,
    required this.beforeFlood,
    required this.duringFlood,
    required this.afterFlood,
    this.suggestedCity, // Boleh kosong
  });

  factory FloodModel.fromJson(Map<String, dynamic> json) {
    return FloodModel(
      risk: json['risk'] ?? 'Unknown',
      weather: json['weather'] ?? '-',
      beforeFlood: List<String>.from(json['before_flood'] ?? []),
      duringFlood: List<String>.from(json['during_flood'] ?? []),
      afterFlood: List<String>.from(json['after_flood'] ?? []),
      suggestedCity: json['suggested_city'], // Ambil dari JSON
    );
  }
}