import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/connectivity_helper.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSendingReset = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _checkInternetConnection() async {
    return ConnectivityHelper.checkConnection();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Check internet connection first
      final hasInternet = await _checkInternetConnection();

      if (!hasInternet) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tidak ada koneksi internet. Pastikan Anda terhubung ke internet.',
              ),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      setState(() => _isLoading = true);

      try {
        final result = await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        if (result['success']) {
          // Login berhasil, cek apakah user sudah punya data profil
          final userId = result['userId'];
          
          try {
            final profileCompleted =
                await _authService.isProfileCompleted(userId);

            setState(() => _isLoading = false);

            if (mounted) {
              if (profileCompleted) {
                // User sudah punya data profil, langsung ke dashboard
                Navigator.pushReplacementNamed(context, '/dashboard');
              } else {
                // User belum punya data profil, ke input data diri
                Navigator.pushReplacementNamed(context, '/input-data-diri');
              }
            }
          } catch (e) {
            setState(() => _isLoading = false);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memuat data: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
              
              // Fallback: tetap ke dashboard
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          }
        } else {
          setState(() => _isLoading = false);
          
          // Cek apakah error karena email belum diverifikasi
          final requiresEmailVerification = result['requiresEmailVerification'] ?? false;
          if (requiresEmailVerification) {
            // Email belum diverifikasi, redirect ke pending screen
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/email-verification-pending');
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        
        if (mounted) {
          String errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
          
          if (e.toString().contains('network')) {
            errorMessage = 'Koneksi gagal. Periksa internet Anda dan coba lagi.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Reset Kata Sandi',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email akun',
            hintText: 'Masukkan email yang terdaftar',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, emailController.text.trim()),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    emailController.dispose();
    if (email == null || email.isEmpty) return;

    if (!RegExp(r'^[\w\.-]+@gmail\.com$').hasMatch(email)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada koneksi internet. Pastikan Anda terhubung ke internet.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSendingReset = true);

    final result = await _authService.sendPasswordResetEmail(email: email);

    if (!mounted) return;
    setState(() => _isSendingReset = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? AppColors.teal : AppColors.error,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Masuk',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Masuk untuk melanjutkan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[\w\.-]+@gmail\.com$').hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Masukkan Email',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Masukkan Password',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading || _isSendingReset
                        ? null
                        : _handleForgotPassword,
                    child: Text(
                      _isSendingReset ? 'Mengirim...' : 'Lupa kata sandi?',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF4E54C8),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E54C8),
                      disabledBackgroundColor: AppColors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            'Masuk',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4E54C8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
