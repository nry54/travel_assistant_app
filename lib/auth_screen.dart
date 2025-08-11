import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // E-posta ve şifre için metin düzenleme kontrolcüleri
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Loading durumunu yönetmek için
  bool _isLoading = false;

  // Form validasyon durumunu yönetmek için
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için kontrolcüleri dispose ediyoruz
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Giriş ve kayıt ekranları arasında geçiş yapmak için bir değişken
  bool _isLogin = true;

  // ...

  void _submitAuthForm() async {
    final isValid = _formKey.currentState?.validate();
    FocusScope.of(context).unfocus(); // Klavyeyi kapatır

    if (isValid == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          // Giriş yapma işlemi
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          // Başarılı giriş durumunda bir mesaj göster
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Başarıyla giriş yapıldı!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Kayıt olma işlemi
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          // Başarılı kayıt durumunda bir mesaj göster
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Başarıyla kayıt oldunuz!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        print('Firebase Hata Kodu: ${e.code}');

        String message = 'Bir hata oluştu.';
        if (e.message != null) {
          message = e.message!;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } catch (e) {
        print('Firebase Hatası: ${e.toString()}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bilinmeyen bir hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Arka plana renk gradyanı ekliyoruz
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 107, 219, 255), // Açık mavi
              Color.fromARGB(255, 63, 114, 255), // Koyu mavi
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey, // Form key'ini buraya atadık
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Uygulama logosu veya başlığı
                  const Text(
                    'Seyahat Asistanı',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // E-posta giriş alanı
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Geçerli bir e-posta adresi girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Şifre giriş alanı
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Şifre en az 6 karakter olmalıdır.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Giriş yap butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Giriş yapma işlemi
                        _isLoading
                            ? null
                            : _submitAuthForm(); // Loading durumunda butonu devre dışı bırakır
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(
                          255,
                          63,
                          114,
                          255,
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator() // Yüklenirken animasyon gösterir
                          : Text(
                              _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                              style: const TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Kayıt ol / Giriş yap geçiş butonu
                  TextButton(
                    onPressed: () {
                      // Butona basıldığında durumu değiştiriyoruz
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Hesabın yok mu? Kayıt ol'
                          : 'Hesabın var mı? Giriş yap',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
