import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_task_screen.dart';
import 'add_expense_screen.dart';
import 'weather_service.dart';

String _formatDate(String dateString) {
  final dateTime = DateTime.parse(dateString);
  final months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
  return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
}

class TravelDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> travelData;
  final String travelId;

  const TravelDetailsScreen({
    super.key,
    required this.travelData,
    required this.travelId,
  });

  @override
  State<TravelDetailsScreen> createState() => _TravelDetailsScreenState();
}

class _TravelDetailsScreenState extends State<TravelDetailsScreen> {
  final WeatherService _weatherService = WeatherService(
    '877c3a7460a3959f6d70de97b67899e0',
  );
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = false;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() async {
    setState(() {
      _isLoadingWeather = true;
    });

    try {
      final data = await _weatherService.getWeather(
        widget.travelData['destination'],
      );
      setState(() {
        _weatherData = data;
      });
    } catch (e) {
      print('Hava durumu verisi çekilirken bir hata oluştu: $e');
    } finally {
      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Kullanıcı bulunamadı.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.travelData['travelName']),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallet, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => AddExpenseScreen(travelId: widget.travelId),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seyahat Detayları',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),

            const Icon(Icons.location_on, color: Colors.blue),
            Text(
              'Gidilecek Yer: ${widget.travelData['destination']}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              'Başlangıç Tarihi: ${_formatDate(widget.travelData['startDate'])}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              'Bitiş Tarihi: ${_formatDate(widget.travelData['endDate'])}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),
            const Text(
              'Hava Durumu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_isLoadingWeather)
              const Center(child: CircularProgressIndicator())
            else if (_weatherData != null)
              Card(
                elevation: 4.0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Hava durumu ikonu
                      Image.network(
                        'http://openweathermap.org/img/wn/${_weatherData!['weather'][0]['icon']}@2x.png',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 16),
                      // Hava durumu bilgileri
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_weatherData!['name']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sıcaklık: ${_weatherData!['main']['temp'].round()}°C',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _weatherData!['weather'][0]['description'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text(
                'Hava durumu verisi alınamadı.',
                style: TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 24),
            const Text(
              'Yapılacaklar Listesi:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('travels')
                    .doc(widget.travelId)
                    .collection('tasks')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Bir hata oluştu: ${snapshot.error}'),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Henüz görev eklenmedi.'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final taskData = snapshot.data!.docs[index];
                      return Card(
                        elevation: 2.0,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(
                              taskData['isCompleted']
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: taskData['isCompleted']
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user!.uid)
                                  .collection('travels')
                                  .doc(widget.travelId)
                                  .collection('tasks')
                                  .doc(taskData.id)
                                  .update({
                                    'isCompleted': !taskData['isCompleted'],
                                  });
                            },
                          ),
                          title: Text(
                            taskData['taskName'],
                            style: TextStyle(
                              decoration: taskData['isCompleted']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) return;

                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('travels')
                                    .doc(widget.travelId)
                                    .collection('tasks')
                                    .doc(taskData.id)
                                    .delete();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Hata: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const Text(
              'Bütçe Durumu:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('travels')
                  .doc(widget.travelId)
                  .collection('expenses')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                int totalSpent = snapshot.data!.docs.fold(
                  0,
                  (sum, doc) => sum + doc['amount'] as int,
                );
                int totalBudget = widget.travelData['budget'] as int;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toplam Bütçe: ₺$totalBudget',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Harcanan: ₺$totalSpent',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: totalSpent / totalBudget,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AddTaskScreen(travelId: widget.travelId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
