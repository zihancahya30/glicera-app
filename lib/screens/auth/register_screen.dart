import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/connectivity_helper.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _checkInternetConnection() async {
    return ConnectivityHelper.checkConnection();
  }

  Future<void> _handleRegister() async {
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
        final result = await _authService.register(
          nama: _namaController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (result['success']) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text(
                'Verifikasi Email',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              content: Text(
                'Kami sudah mengirim link verifikasi ke ${_emailController.text.trim()}.\n\n'
                'Buka email tersebut, klik link verifikasi, lalu masuk kembali ke aplikasi.',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
          );

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
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
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Daftar untuk mulai deteksi diabetes',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Nama Field
                TextFormField(
                  controller: _namaController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    if (value.length < 3) {
                      return 'Nama minimal 3 karakter';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nama Lengkap',
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
                
                // Email Field (WAJIB @gmail.com)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.endsWith('@gmail.com')) {
                      return 'Harus menggunakan email Gmail (@gmail.com)';
                    }
                    if (!RegExp(r'^[\w\.-]+@gmail\.com$').hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Masukkan Email (@gmail.com)',
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
                
                const SizedBox(height: 8),
                
                // Email Helper Text
                const Text(
                  '* Gunakan email Gmail untuk registrasi',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
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
                    if (value.length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Password harus mengandung huruf besar';
                    }
                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return 'Password harus mengandung huruf kecil';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Password harus mengandung angka';
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
                    errorMaxLines: 2,
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
                
                // Password Helper Text
                const Text(
                  '* Minimal 8 karakter, mengandung huruf besar, huruf kecil, dan angka',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
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
                            'Daftar',
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
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Masuk',
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
