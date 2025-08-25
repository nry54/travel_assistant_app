import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_travel_screen.dart';

class TravelsScreen extends StatelessWidget {
  const TravelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: const Center(child: Text('Seyahatlerin burada listelenecek!')),
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
