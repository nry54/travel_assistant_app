import 'package:flutter/material.dart';

class TravelDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> travelData;

  const TravelDetailsScreen({super.key, required this.travelData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(travelData['travelName'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seyahat Detayları:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Gidilecek Yer: ${travelData['destination']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Başlangıç Tarihi: ${travelData['startDate']}', // Tarih formatı daha sonra düzenlenecek
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Bitiş Tarihi: ${travelData['endDate']}', // Tarih formatı daha sonra düzenlenecek
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
