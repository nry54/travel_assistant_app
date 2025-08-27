import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  WeatherService(this.apiKey);

  Future<Map<String, dynamic>?> getWeather(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric&lang=tr'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Hava durumu verisi alınamadı. Durum kodu: ${response.statusCode}');
      return null;
    }
  }
}
