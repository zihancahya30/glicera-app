import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/rutinitas_model.dart';
import '../models/scan_result_model.dart';

class SupabaseService {
  static const String _bucketName = 'scan-photos'; // Nama bucket di Supabase Storage untuk menyimpan foto hasil skrining
  final SupabaseClient _supabase = Supabase.instance.client; // Inisialisasi SupabaseClient yang sudah terhubung & terautentikasi (di-setup sekali di main.dart)

  // Urutkan daftar hasil scan dari yang PALING BARU ke paling lama
  List<ScanResultModel> _sortScanResultsByTanggal(
      List<ScanResultModel> results) {
    results.sort((a, b) => b.tanggal.compareTo(a.tanggal)); // Urutkan dari yang terbaru ke yang lama
    return results;
  }

  // Ambil URL signed untuk foto hasil skrining, jika ada path foto tapi belum ada URL
  Future<ScanResultModel> _withSignedImageUrl(ScanResultModel result) async {
    final path = result.fotoPath;
    // Jika path foto kosong atau sudah ada URL, kembalikan hasil scan apa adanya
    if (path == null || path.isEmpty || result.fotoUrl?.isNotEmpty == true) {
      return result;
    }
    try {
      // Buat signed URL untuk foto hasil skrining yang tersimpan di Supabase Storage
      final signedUrl = await _supabase.storage
          .from(_bucketName)
          .createSignedUrl(path, 60 * 60); // Signed URL berlaku selama 1 jam (3600 detik)
      return ScanResultModel( // bikin object baru dengan signed URL yang sudah diambil
        id: result.id,
        userId: result.userId,
        tanggal: result.tanggal,
        kategori: result.kategori,
        probabilitas: result.probabilitas,
        fotoUrl: signedUrl,
        fotoPath: result.fotoPath,
        analisis: result.analisis,
        rekomendasi: result.rekomendasi,
      );
    } catch (_) { // Jika gagal bikin signed URL, kembalikan hasil scan apa adanya (tanpa URL)
      return result;
    }
  }

  // Ambil URL signed untuk semua foto hasil skrining
  Future<List<ScanResultModel>> _withSignedImageUrls(
      List<ScanResultModel> results) async {
    return Future.wait(results.map(_withSignedImageUrl));
  }

  // ─────────────────────────────────────────────────────────────────
  // SCAN RESULTS
  // ─────────────────────────────────────────────────────────────────

  Future<String?> uploadImage(
      String userId, String imageId, File imageFile) async { 
    try {
      // Buat path untuk menyimpan foto hasil skrining di Supabase Storage
      final storagePath = '$userId/$imageId.jpg';  // Format path: userId/imageId.jpg
      await _supabase.storage.from(_bucketName).upload( // panggil Supabase Storage, target bucket 'scan-photos'
            storagePath, // path tujuan di storage
            imageFile, // file gambar yang akan diupload
            fileOptions: const FileOptions(
              cacheControl: '3600', // Cache control untuk signed URL (1 jam)
              upsert: true, // Jika file sudah ada, timpa dengan yang baru
              contentType: 'image/jpeg',
            ),
          );
      return storagePath;
    } catch (_) {
      return null;
    }
  }

  // Simpan hasil skrining ke tabel 'scan_results' di Supabase
  Future<Map<String, dynamic>> saveScanResult(ScanResultModel result) async {
    try {
      await _supabase.from('scan_results').insert(result.toMap());
      return {'success': true};
    } on PostgrestException catch (e) {
      debugPrint(
        'Save scan result failed: code=${e.code}, message=${e.message}',
      );
      return {
        'success': false,
        'message': 'Hasil skrining belum bisa disimpan. Silakan coba lagi.',
        'code': e.code,
      };
    } catch (e) {
      debugPrint('Save scan result failed: $e');
      return {
        'success': false,
        'message': 'Hasil skrining belum bisa disimpan. Silakan coba lagi.',
      };
    }
  }

  // Ambil riwayat skrining untuk pengguna tertentu
  Future<List<ScanResultModel>> getScanHistory(String userId) async {
    try {
      final rows = await _supabase
          .from('scan_results')
          .select()
          .eq('user_id', userId)
          .order('tanggal', ascending: false);

      final results = rows
          .map<ScanResultModel>((row) => ScanResultModel.fromMap(row))
          .toList();
      return _withSignedImageUrls(_sortScanResultsByTanggal(results));
    } catch (_) {
      return [];
    }
  }

  // Ambil riwayat skrining untuk pengguna tertentu secara real-time (stream)
  Stream<List<ScanResultModel>> streamScanHistory(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _supabase
        .from('scan_results')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('tanggal', ascending: false)
        .asyncMap((rows) async {
          final results = rows
              .map<ScanResultModel>((row) => ScanResultModel.fromMap(row))
              .toList();
          return _withSignedImageUrls(_sortScanResultsByTanggal(results));
        })
        .handleError((_) => <ScanResultModel>[]);
  }

  // Ambil hasil skrining terbaru untuk pengguna tertentu
  Future<ScanResultModel?> getLatestScan(String userId) async {
    try {
      final data = await _supabase
          .from('scan_results')
          .select()
          .eq('user_id', userId)
          .order('tanggal', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      return _withSignedImageUrl(ScanResultModel.fromMap(data));
    } catch (_) {
      return null;
    }
  }

  // Hapus hasil skrining
  Future<Map<String, dynamic>> deleteScanResult(String scanId) async {
    try {
      final data = await _supabase
          .from('scan_results')
          .select('foto_path')
          .eq('id', scanId)
          .maybeSingle();

      final fotoPath = data?['foto_path'];
      if (fotoPath is String && fotoPath.isNotEmpty) {
        await _supabase.storage.from(_bucketName).remove([fotoPath]);
      }

      await _supabase.from('scan_results').delete().eq('id', scanId);
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // RUTINITAS
  // ─────────────────────────────────────────────────────────────────

  // Format tanggal menjadi string "YYYY-MM-DD" untuk digunakan sebagai kunci di tabel 'routine_progress'
  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // Ambil daftar rutinitas aktif milik user tertentu
  Future<List<RutinitasModel>> getUserRoutines(String userId) async {
    try {
      final rows = await _supabase
          .from('user_routines')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: true);

      return rows
          .map<RutinitasModel>((row) => RutinitasModel.fromSupabaseMap(row))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Simpan rutinitas milik user
  Future<Map<String, dynamic>> saveUserRoutine({
    required String userId,
    required RutinitasModel routine,
  }) async {
    try {
      await _supabase
          .from('user_routines')
          .upsert(routine.toSupabaseMap(userId));
      return {'success': true};
    } on PostgrestException catch (e) {
      debugPrint('Save user routine failed: ${e.message}');
      return {'success': false, 'message': e.message};
    } catch (e) {
      debugPrint('Save user routine failed: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Hapus kebiasaan custom milik user (soft delete: set is_active = false)
  // Juga hapus semua progress terkait rutinitas ini
  Future<Map<String, dynamic>> deleteUserRoutine({
    required String userId,
    required String routineId,
  }) async {
    try {
      // Soft delete: tandai is_active = false
      // (data tetap ada di DB untuk audit, tapi tidak tampil di app)
      await _supabase
          .from('user_routines')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', routineId)
          .eq('user_id', userId); // Pastikan hanya bisa hapus milik sendiri

      // Hapus juga semua progress rutinitas ini
      await _supabase
          .from('routine_progress')
          .delete()
          .eq('user_id', userId)
          .eq('routine_id', routineId);

      return {'success': true};
    } on PostgrestException catch (e) {
      debugPrint('Delete user routine failed: ${e.message}');
      return {
        'success': false,
        'message': 'Gagal menghapus kebiasaan. Silakan coba lagi.',
        'code': e.code,
      };
    } catch (e) {
      debugPrint('Delete user routine failed: $e');
      return {
        'success': false,
        'message': 'Gagal menghapus kebiasaan. Silakan coba lagi.',
      };
    }
  }

  // Ambil progress rutinitas untuk tanggal tertentu
  Future<Map<String, List<String>>> getRoutineProgressForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final rows = await _supabase
          .from('routine_progress')
          .select('routine_id, completed_item_ids')
          .eq('user_id', userId)
          .eq('activity_date', _dateKey(date));

      return {
        for (final row in rows)
          row['routine_id'] as String:
              List<String>.from(row['completed_item_ids'] ?? [])
      };
    } catch (_) {
      return {};
    }
  }

  // Simpan progress rutinitas untuk tanggal tertentu
  Future<Map<String, dynamic>> saveRoutineProgress({
    required String userId,
    required RutinitasModel routine,
    required DateTime date,
  }) async {
    try {
      final completedItemIds = routine.checklistItems
          .where((item) => item.isCompleted)
          .map((item) => item.id)
          .toList();
      final dateKey = _dateKey(date);

      await _supabase.from('routine_progress').upsert(
        {
          'id': '${userId}_${routine.id}_$dateKey',
          'user_id': userId,
          'routine_id': routine.id,
          'activity_date': dateKey,
          'completed_item_ids': completedItemIds,
          'total_items': routine.checklistItems.length,
          'completed_items': completedItemIds.length,
          'is_completed': routine.checklistItems.isNotEmpty &&
              completedItemIds.length == routine.checklistItems.length,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,routine_id,activity_date',
      );

      return {'success': true};
    } on PostgrestException catch (e) {
      debugPrint(
        'Save routine progress failed: code=${e.code}, message=${e.message}',
      );
      return {
        'success': false,
        'message': 'Progress belum bisa disimpan. Silakan coba lagi.',
        'code': e.code,
      };
    } catch (e) {
      debugPrint('Save routine progress failed: $e');
      return {
        'success': false,
        'message': 'Progress belum bisa disimpan. Silakan coba lagi.',
      };
    }
  }

  // Reset progress rutinitas untuk tanggal tertentu
  Future<Map<String, dynamic>> resetRoutineProgressForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      await _supabase
          .from('routine_progress')
          .delete()
          .eq('user_id', userId)
          .eq('activity_date', _dateKey(date));
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}