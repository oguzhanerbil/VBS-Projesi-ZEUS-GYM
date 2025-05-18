import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          image: DecorationImage(
            image: const AssetImage(
              'assets/images/background.jpeg',
            ), // Varsayılan arka plan
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo veya uygulama adı
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                // Giriş formu
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white30,
                              width: 1,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.white70,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen e-posta adresinizi girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white30,
                              width: 1,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white70,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen şifrenizi girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (authProvider.error != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    authProvider.error!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ElevatedButton(
                                onPressed:
                                    authProvider.isLoading
                                        ? null
                                        : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final success = await authProvider
                                                .login(
                                                  _emailController.text.trim(),
                                                  _passwordController.text,
                                                );
                                            if (success && mounted) {
                                              if (authProvider.isAdmin) {
                                                Navigator.of(
                                                  context,
                                                ).pushReplacementNamed(
                                                  Routes.adminHome,
                                                );
                                              } else if (authProvider
                                                  .isTrainer) {
                                                Navigator.of(
                                                  context,
                                                ).pushReplacementNamed(
                                                  Routes.trainerHome,
                                                );
                                              } else if (authProvider
                                                  .isMember) {
                                                Navigator.of(
                                                  context,
                                                ).pushReplacementNamed(
                                                  Routes.memberHome,
                                                );
                                              } else {}
                                            }
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    authProvider.isLoading
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'GİRİŞ YAP',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                              255,
                                              23,
                                              25,
                                              53,
                                            ),
                                          ),
                                        ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.register);
                        },
                        child: const Text(
                          'Hesabınız yok mu? Kayıt olun',
                          style: TextStyle(
                            color: Color.fromARGB(255, 171, 172, 177),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Yönetici ve Eğitmen Girişi',
                        style: TextStyle(
                          color: Color.fromARGB(255, 171, 172, 177),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushNamed(Routes.registerTrainer);
                            },
                            icon: const Icon(Icons.sports),
                            label: const Text('Eğitmen Kaydı'),
                            style: TextButton.styleFrom(
                              foregroundColor: Color.fromARGB(
                                255,
                                171,
                                172,
                                177,
                              ),
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final adminKey = await _showAdminKeyDialog(
                                context,
                              );
                              if (adminKey == 'admin123' && mounted) {
                                Navigator.of(
                                  context,
                                ).pushNamed(Routes.registerAdmin);
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Geçersiz admin anahtarı'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.admin_panel_settings),
                            label: const Text('Admin Kaydı'),
                            style: TextButton.styleFrom(
                              foregroundColor: Color.fromARGB(
                                255,
                                171,
                                172,
                                177,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Admin anahtarı dialog metodu
Future<String?> _showAdminKeyDialog(BuildContext context) {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Admin Anahtarı Gerekli'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Admin Anahtarı',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed:
                  () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Devam Et'),
            ),
          ],
        ),
  );
}
