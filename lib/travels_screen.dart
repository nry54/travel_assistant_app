import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_travel_screen.dart';
import 'travel_details_screen.dart';

class TravelsScreen extends StatelessWidget {
  const TravelsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    // Geçerli kullanıcıyı alıyoruz
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Kullanıcı bulunamadı.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seyahatlerim'),
        actions: [
          // Çıkış yapma butonu
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      // StreamBuilder ile Firebase'den veri akışını dinliyoruz
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('travels')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Henüz seyahat planınız yok.'));
          }

          // Veriler geldiğinde, bunları bir ListView'da göster
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final travelData = snapshot.data!.docs[index];
              return Card(
                elevation: 4.0, // Kartlara gölge ekler
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    15.0,
                  ), // Köşeleri yuvarlar
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    child: Icon(
                      Icons.flight,
                      color: Color.fromARGB(255, 78, 190, 226),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => TravelDetailsScreen(
                          travelData: travelData.data() as Map<String, dynamic>,
                          travelId: travelData.id,
                        ),
                      ),
                    );
                  },
                  title: Text(
                    travelData['travelName'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(travelData['destination']),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(travelData['startDate'])} - ${_formatDate(travelData['endDate'])}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;
                      try {
                        final tasks = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('travels')
                            .doc(travelData.id)
                            .collection('tasks')
                            .get();

                        for (var doc in tasks.docs) {
                          await doc.reference.delete();
                        }

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('travels')
                            .doc(travelData.id)
                            .delete();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Hata: ${e.toString()}')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const AddTravelScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
