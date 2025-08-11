import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase başlatılırken bir hata oluştu: $e');
  }
  runApp(TravelAssistantApp(firebaseReady: firebaseReady));
}

class TravelAssistantApp extends StatelessWidget {
  const TravelAssistantApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seyahat Asistanı',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: firebaseReady
          ? const AuthScreen()
          : const _UnsupportedFirebaseScreen(),
    );
  }
}

class _UnsupportedFirebaseScreen extends StatelessWidget {
  const _UnsupportedFirebaseScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.info_outline, size: 48),
              SizedBox(height: 16),
              Text(
                'Bu platformda Firebase yapılandırılmadı.\nLütfen Android üzerinde çalıştırın veya Firebase yapılandırmasını bu platform için ekleyin.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popüler Destinasyonlar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: const [
                DestinationCard(
                  name: 'İstanbul',
                  image: 'https://picsum.photos/200/200?random=1',
                ),
                DestinationCard(
                  name: 'Antalya',
                  image: 'https://picsum.photos/200/200?random=2',
                ),
                DestinationCard(
                  name: 'Kapadokya',
                  image: 'https://picsum.photos/200/200?random=3',
                ),
                DestinationCard(
                  name: 'Pamukkale',
                  image: 'https://picsum.photos/200/200?random=4',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String name;
  final String image;

  const DestinationCard({super.key, required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seyahatlerim',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                TripCard(
                  destination: 'İstanbul',
                  date: '15-20 Mart 2024',
                  status: 'Planlanıyor',
                ),
                TripCard(
                  destination: 'Antalya',
                  date: '5-10 Nisan 2024',
                  status: 'Onaylandı',
                ),
                TripCard(
                  destination: 'Kapadokya',
                  date: '25-30 Mayıs 2024',
                  status: 'Tamamlandı',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final String destination;
  final String date;
  final String status;

  const TripCard({
    super.key,
    required this.destination,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'Planlanıyor':
        statusColor = Colors.orange;
        break;
      case 'Onaylandı':
        statusColor = Colors.green;
        break;
      case 'Tamamlandı':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.flight, size: 40),
        title: Text(
          destination,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://picsum.photos/200/200?random=5',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ahmet Yılmaz',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'ahmet@email.com',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Ayarlar'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const ListTile(
            leading: Icon(Icons.help),
            title: Text('Yardım'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Hakkında'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
