import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddTravelScreen extends StatefulWidget {
  const AddTravelScreen({super.key});

  @override
  State<AddTravelScreen> createState() => _AddTravelScreenState();
}

class _AddTravelScreenState extends State<AddTravelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _travelNameController = TextEditingController();
  final _destinationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _travelNameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  // Tarih seçiciyi açan fonksiyon
  void _presentDatePicker(bool isStartDate) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final lastDate = DateTime(now.year + 5, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? now : _endDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    setState(() {
      if (isStartDate) {
        _startDate = pickedDate;
      } else {
        _endDate = pickedDate;
      }
    });
  }

  // Formu doğrulayan ve kaydeden fonksiyon
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen başlangıç ve bitiş tarihlerini seçin.'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Kullanıcı oturum açmamışsa
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen önce oturum açın.')));
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('travels')
          .add({
            'travelName': _travelNameController.text,
            'destination': _destinationController.text,
            'startDate': _startDate!.toIso8601String(),
            'endDate': _endDate!.toIso8601String(),
            'createdAt': Timestamp.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seyahat başarıyla kaydedildi!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata oluştu: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Seyahat Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _travelNameController,
                decoration: const InputDecoration(labelText: 'Seyahat Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir seyahat adı girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(labelText: 'Gidilecek Yer'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen gidilecek yeri girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _startDate == null
                          ? 'Başlangıç Tarihi'
                          : 'Başlangıç: ${MaterialLocalizations.of(context).formatShortDate(_startDate!)}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _presentDatePicker(true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _endDate == null
                          ? 'Bitiş Tarihi'
                          : 'Bitiş: ${MaterialLocalizations.of(context).formatShortDate(_endDate!)}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _presentDatePicker(false),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Seyahati Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
