import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<DataPoint>> fetchData() async {
    const apiUrl = 'https://api.thingspeak.com/channels/2832843/feeds.json?api_key=K1ZP0B2KTR4UKRAG';
    final url = Uri.parse(apiUrl);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> feeds = jsonData['feeds'];
        return feeds.map((item) => DataPoint.fromJson(item)).toList();
      } else {
        throw Exception('Erreur de chargement des données: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}

class DataPoint {
  final String timestamp;
  final double temperature;
  final double humidity;
  final double temperatureDS18B20_1;
  final double temperatureDS18B20_2;
  final double temperatureDS18B20_3;

  DataPoint({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.temperatureDS18B20_1,
    required this.temperatureDS18B20_2,
    required this.temperatureDS18B20_3,
  });

  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      timestamp: json['created_at'] ?? 'Inconnu',
      temperature: double.tryParse(json['field1'] ?? '0') ?? 0.0,
      humidity: double.tryParse(json['field2'] ?? '0') ?? 0.0,
      temperatureDS18B20_1: double.tryParse(json['field3'] ?? '0') ?? 0.0,
      temperatureDS18B20_2: double.tryParse(json['field4'] ?? '0') ?? 0.0,
      temperatureDS18B20_3: double.tryParse(json['field5'] ?? '0') ?? 0.0,
    );
  }
}
