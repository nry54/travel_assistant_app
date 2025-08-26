import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_task_screen.dart';

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

class TravelDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> travelData;
  final String travelId; // travelId'yi alabilmek için bu özelliği ekledik

  const TravelDetailsScreen({
    super.key,
    required this.travelData,
    required this.travelId,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Kullanıcı bulunamadı.'));
    }

    return Scaffold(
      appBar: AppBar(title: Text(travelData['travelName'])),
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
              'Gidilecek Yer: ${travelData['destination']}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              'Başlangıç Tarihi: ${_formatDate(travelData['startDate'])}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              'Bitiş Tarihi: ${_formatDate(travelData['endDate'])}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            const Text(
              'Yapılacaklar Listesi:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('travels')
                    .doc(travelId)
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
                                  .doc(travelId)
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
                                    .doc(travelId)
                                    .collection('tasks')
                                    .doc(
                                      taskData.id,
                                    ) // Belirli görevi seç ve sil
                                    .delete();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Hata: ${e.toString()}'),
                                  ),
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AddTaskScreen(travelId: travelId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
