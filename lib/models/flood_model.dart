class FloodModel {
  final String risk; // "OK", "NotFound", "Error"
  final String cityName;
  final DailyForecast? current;
  final List<DailyForecast> forecast;

  FloodModel({
    required this.risk,
    this.cityName = "",
    this.current,
    this.forecast = const [],
  });

  factory FloodModel.fromJson(Map<String, dynamic> json) {
    if (json['risk'] != 'OK') {
      return FloodModel(risk: json['risk'] ?? "Error", cityName: json['weather'] ?? "");
    }

    var list = json['forecast'] as List;
    List<DailyForecast> forecastList = list.map((i) => DailyForecast.fromJson(i)).toList();

    return FloodModel(
      risk: "OK",
      cityName: json['city_name'] ?? "Unknown",
      current: DailyForecast.fromJson(json['current']),
      forecast: forecastList,
    );
  }
}

class DailyForecast {
  final String date;
  final double temp;
  final String risk;
  final String weather;
  final List<String> beforeFlood;
  final List<String> duringFlood;
  final List<String> afterFlood;

  DailyForecast({
    required this.date,
    required this.temp,
    required this.risk,
    required this.weather,
    required this.beforeFlood,
    required this.duringFlood,
    required this.afterFlood,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] ?? "",
      temp: (json['temp'] as num).toDouble(),
      risk: json['risk'] ?? "Low",
      weather: json['weather'] ?? "-",
      beforeFlood: List<String>.from(json['before_flood'] ?? []),
      duringFlood: List<String>.from(json['during_flood'] ?? []),
      afterFlood: List<String>.from(json['after_flood'] ?? []),
    );
  }
}