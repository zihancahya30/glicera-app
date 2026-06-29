import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';

class EmailVerificationPendingScreen extends StatefulWidget {
  const EmailVerificationPendingScreen({super.key});

  @override
  State<EmailVerificationPendingScreen> createState() =>
      _EmailVerificationPendingScreenState();
}

class _EmailVerificationPendingScreenState
    extends State<EmailVerificationPendingScreen> {
  final _authService = AuthService();
  bool _isResending = false;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startAutoCheckVerification();
  }

  /// Auto check email verification setiap 5 detik
  void _startAutoCheckVerification() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _checkEmailVerification();
      }
    });
  }

  /// Cek apakah email sudah diverifikasi
  Future<void> _checkEmailVerification() async {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) return;
    
    // Refresh session untuk get latest user data dari Supabase
    try {
      await Supabase.instance.client.auth.refreshSession();
      
      final currentUser = Supabase.instance.client.auth.currentUser;
      final isVerified = currentUser?.emailConfirmedAt != null;
      
      debugPrint('Email verified check: $isVerified');
      
      if (isVerified && mounted) {
        // Email sudah diverifikasi!
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email berhasil diverifikasi! Selamat datang di Glicera'),
              backgroundColor: AppColors.teal,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Redirect ke input data diri atau dashboard
          Navigator.pushReplacementNamed(context, '/input-data-diri');
        }
      } else {
        // Email belum diverifikasi, cek lagi nanti
        _startAutoCheckVerification();
      }
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      _startAutoCheckVerification();
    }
  }

  /// Resend email verifikasi
  Future<void> _handleResendEmail() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _isResending = true);

    final result = await _authService.resendEmailVerification(
      email: user.email!,
    );

    if (!mounted) return;
    setState(() => _isResending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? AppColors.teal : AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );

    if (result['success']) {
      // Start countdown untuk disable tombol resend selama 60 detik
      setState(() => _resendCountdown = 60);
      for (int i = 60; i > 0; i--) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() => _resendCountdown = i - 1);
        }
      }
    }
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email ?? 'email tidak tersedia';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.mail_outline_rounded,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Verifikasi Email Anda',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Kami telah mengirim link verifikasi ke:\n$userEmail\n\nBuka email dan klik link verifikasi untuk melanjutkan.',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Menunggu Verifikasi',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Kami akan otomatis memeriksa setiap 5 detik',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Resend Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isResending || _resendCountdown > 0
                        ? null
                        : _handleResendEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _isResending
                        ? const CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          )
                        : Text(
                            _resendCountdown > 0
                                ? 'Kirim ulang dalam ${_resendCountdown}s'
                                : 'Kirim Ulang Email Verifikasi',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Logout Button
                TextButton(
                  onPressed: _handleLogout,
                  child: const Text(
                    'Kembali ke Login',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Help section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tidak menemukan email?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Periksa folder Spam atau Promosi\n'
                        '• Tunggu beberapa menit\n'
                        '• Coba kirim ulang email verifikasi',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
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
