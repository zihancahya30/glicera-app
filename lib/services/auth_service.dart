import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<User?> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map((event) => event.session?.user);
  User? get currentUser => _supabase.auth.currentUser;

  String _authErrorMessage(AuthException e, {bool isLogin = false}) {
    final message = e.message.toLowerCase();

    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('user already registered')) {
      return 'Email sudah terdaftar. Silakan login.';
    }
    if (message.contains('invalid login credentials')) {
      return 'Email atau password salah';
    }
    if (message.contains('email not confirmed') ||
        message.contains('not confirmed')) {
      return 'Email belum diverifikasi. Silakan cek inbox email Anda.';
    }
    if (message.contains('invalid email')) {
      return 'Format email tidak valid';
    }
    if (message.contains('weak password') || message.contains('password')) {
      return isLogin ? 'Password salah' : 'Password terlalu lemah';
    }
    if (message.contains('network') || message.contains('socket')) {
      return 'Tidak ada koneksi internet';
    }

    return isLogin
        ? 'Login gagal: ${e.message}'
        : 'Registrasi gagal: ${e.message}';
  }

  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'nama': nama},
        emailRedirectTo: 'glicera://auth-callback',
      );

      final user = response.user;
      if (user == null) {
        return {
          'success': false,
          'message': 'Gagal membuat akun. Silakan coba lagi.',
        };
      }

      return {
        'success': true,
        'message': 'Registrasi berhasil. Silakan cek email untuk verifikasi.',
        'userId': user.id,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _authErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return {
          'success': false,
          'message': 'Gagal login. Silakan coba lagi.',
        };
      }

      // Cek apakah email sudah diverifikasi
      final isEmailConfirmed = user.emailConfirmedAt != null;
      if (!isEmailConfirmed) {
        return {
          'success': false,
          'message': 'Email belum diverifikasi. Silakan cek inbox email Anda.',
          'requiresEmailVerification': true,
          'userId': user.id,
          'userEmail': user.email,
        };
      }

      return {
        'success': true,
        'message': 'Login berhasil!',
        'userId': user.id,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _authErrorMessage(e, isLogin: true),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'glicera://reset-password',
      );

      return {
        'success': true,
        'message': 'Link reset kata sandi sudah dikirim ke email Anda.',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _authErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim link reset. Silakan coba lagi.',
      };
    }
  }

  Future<Map<String, dynamic>> updatePassword({
    required String password,
  }) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: password));
      return {
        'success': true,
        'message': 'Kata sandi berhasil diperbarui. Silakan login kembali.',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _authErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui kata sandi. Silakan coba lagi.',
      };
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();

      return data == null ? null : UserModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  Stream<UserModel?> streamUserData(String uid) {
    if (uid.isEmpty) return Stream.value(null);

    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', uid)
        .map((rows) => rows.isEmpty ? null : UserModel.fromMap(rows.first));
  }

  Future<Map<String, dynamic>> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      final updateData = Map<String, dynamic>.from(data)
        ..['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('users').update(updateData).eq('id', uid);

      if (updateData['nama'] != null) {
        await _supabase.auth.updateUser(
          UserAttributes(data: {'nama': updateData['nama']}),
        );
      }

      return {'success': true, 'message': 'Profil berhasil diperbarui'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui profil. Silakan coba lagi.',
      };
    }
  }

  Future<bool> isProfileCompleted(String uid) async {
    final user = await getUserData(uid);
    return user?.usia != null &&
        user?.beratBadan != null &&
        user?.tinggiBadan != null &&
        user?.jenisKelamin != null;
  }

  /// Check apakah email user sudah diverifikasi
  bool isEmailVerified() {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  /// Resend email verifikasi
  Future<Map<String, dynamic>> resendEmailVerification({
    required String email,
  }) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'glicera://auth-callback',
      );

      return {
        'success': true,
        'message': 'Email verifikasi telah dikirim ulang. Silakan cek inbox Anda.',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _authErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim ulang email. Silakan coba lagi.',
      };
    }
  }
}
