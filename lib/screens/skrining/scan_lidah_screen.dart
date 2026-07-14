import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/connectivity_helper.dart';
import '../../models/scan_result_model.dart';
import '../../services/supabase_service.dart';
import '../../services/ml_service.dart';
import '../../services/auth_service.dart';
import 'hasil_skrining_screen.dart';
import 'kamera_lidah_screen.dart';

class ScanLidahScreen extends StatefulWidget {
  const ScanLidahScreen({super.key});

  @override
  State<ScanLidahScreen> createState() => _ScanLidahScreenState();
}

class _ScanLidahScreenState extends State<ScanLidahScreen> {
  int _selectedIndex = 1;
  final MLService _mlService = MLService();
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  File? _croppedImageFile;
  _TongueDetectionResult? _detectionResult;
  bool _isAnalyzing = false;
  bool _isPreparingImage = false;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _mlService.initialize();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    final isOnline = await ConnectivityHelper.checkConnection();
    if (!mounted) {
      return;
    }
    setState(() => _isOnline = isOnline);
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) {
        return;
      }
      setState(() => _isOnline = ConnectivityHelper.isOnlineResult(results));
    });
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/riwayat');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profil');
        break;
    }
  }

  void _showOnlineFeatureMessage({String featureName = 'Fitur ini'}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Butuh koneksi internet',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '$featureName tersedia saat perangkat terhubung ke internet.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Mengerti',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<_TongueDetectionResult?> _cropImageForTongue(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        return null;
      }

      final result = _detectTongueRegion(image);
      final croppedImage = img.copyCrop(
        image,
        x: result.cropRect.left.round(),
        y: result.cropRect.top.round(),
        width: result.cropRect.width.round(),
        height: result.cropRect.height.round(),
      );

      final tempPath = imageFile.path.toLowerCase().endsWith('.jpg')
          ? imageFile.path.replaceAll(
              RegExp(r'\.jpg$', caseSensitive: false), '_cropped.jpg')
          : '${imageFile.path}_cropped.jpg';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 90));

      return result.copyWith(croppedFile: tempFile);
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  _TongueDetectionResult _detectTongueRegion(img.Image image) {
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final fallbackRect = _defaultCropRect(imageSize);

    final resizedWidth = min(320, image.width);
    final resizedHeight =
        max(1, (image.height * resizedWidth / image.width).round());
    final preview = img.copyResize(
      image,
      width: resizedWidth,
      height: resizedHeight,
      interpolation: img.Interpolation.average,
    );

    final roiLeft = (preview.width * 0.12).round();
    final roiTop = (preview.height * 0.18).round();
    final roiRight = (preview.width * 0.88).round();
    final roiBottom = (preview.height * 0.88).round();

    final candidateMask = List.generate(
      preview.height,
      (_) => List<bool>.filled(preview.width, false),
    );
    int candidateCount = 0;
    double totalBrightness = 0;
    double totalSharpness = 0;

    for (int y = roiTop; y < roiBottom; y++) {
      for (int x = roiLeft; x < roiRight; x++) {
        final pixel = preview.getPixel(x, y);
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();
        final maxChannel = max(r, max(g, b));
        final minChannel = min(r, min(g, b));
        final saturation = maxChannel - minChannel;
        final brightness = 0.299 * r + 0.587 * g + 0.114 * b;
        final redness = r - ((g + b) / 2);
        final normalizedY = (y - roiTop) / max(1, roiBottom - roiTop);

        // ── PERBAIKAN B: turunkan batas brightness atas dari 225 → 195
        // agar pixel gigi/bibir glossy yang sangat terang tidak lolos filter
        final isTonguePixel = r > g * 1.06 &&
            r > b * 1.04 &&
            redness > 18 &&
            saturation > 20 &&
            brightness > 55 &&
            brightness < 195 && // ← diturunkan dari 225
            normalizedY > 0.18;

        if (!isTonguePixel) {
          continue;
        }

        candidateMask[y][x] = true;
        candidateCount++;
        totalBrightness += brightness;

        if (x + 1 < roiRight) {
          final nextPixel = preview.getPixel(x + 1, y);
          totalSharpness += (r - nextPixel.r).abs() +
              (g - nextPixel.g).abs() +
              (b - nextPixel.b).abs();
        }
        if (y + 1 < roiBottom) {
          final nextPixel = preview.getPixel(x, y + 1);
          totalSharpness += (r - nextPixel.r).abs() +
              (g - nextPixel.g).abs() +
              (b - nextPixel.b).abs();
        }
      }
    }

    if (candidateCount < (preview.width * preview.height * 0.01)) {
      return _TongueDetectionResult(
        cropRect: fallbackRect,
        imageSize: imageSize,
        quality: _FrameQuality.poor,
        statusText: _FrameQuality.poor.label,
        helperText:
            'Area lidah belum terbaca jelas. Coba ambil ulang dengan lidah lebih dekat ke tengah dan pencahayaan yang lebih terang.',
      );
    }

    final component = _findBestTongueComponent(
      candidateMask,
      roiLeft: roiLeft,
      roiTop: roiTop,
      roiRight: roiRight,
      roiBottom: roiBottom,
      previewHeight: preview.height,
    );

    if (component == null || component.pixelCount < 300) {
      return _TongueDetectionResult(
        cropRect: fallbackRect,
        imageSize: imageSize,
        quality: _FrameQuality.poor,
        statusText: _FrameQuality.poor.label,
        helperText:
            'Area lidah belum terbaca jelas. Coba ambil ulang dengan lidah lurus ke depan dan bibir tidak terlalu dominan.',
      );
    }

    final rawRect = Rect.fromLTRB(
      component.minX.toDouble(),
      component.minY.toDouble(),
      component.maxX.toDouble() + 1,
      component.maxY.toDouble() + 1,
    );
    final paddingX = rawRect.width * 0.08;
    final paddingY = rawRect.height * 0.12;
    final paddedRect = Rect.fromLTRB(
      max(0.0, rawRect.left - paddingX),
      max(0.0, rawRect.top - paddingY),
      min(preview.width.toDouble(), rawRect.right + paddingX),
      min(preview.height.toDouble(), rawRect.bottom + paddingY),
    );

    final scaleX = image.width / preview.width;
    final scaleY = image.height / preview.height;
    final cropRect = Rect.fromLTRB(
      paddedRect.left * scaleX,
      paddedRect.top * scaleY,
      paddedRect.right * scaleX,
      paddedRect.bottom * scaleY,
    );

    final safeRect = _clampCropRect(
      cropRect,
      imageSize,
      minimumWidth: image.width * 0.22,
      minimumHeight: image.height * 0.22,
    );

    final averageBrightness = totalBrightness / candidateCount;
    final averageSharpness = totalSharpness / max(1, candidateCount);
    final coverage =
        safeRect.width * safeRect.height / (image.width * image.height);
    final averageCenter = Offset(component.centerX, component.centerY);
    final centerOffset = Offset(
      (averageCenter.dx - preview.width / 2).abs() / preview.width,
      (averageCenter.dy - preview.height / 2).abs() / preview.height,
    );

    final quality = _evaluateFrameQuality(
      brightness: averageBrightness,
      sharpness: averageSharpness,
      coverage: coverage,
      centerOffset: centerOffset,
    );

    return _TongueDetectionResult(
      cropRect: safeRect,
      imageSize: imageSize,
      quality: quality,
      statusText: quality.label,
      helperText: _qualityMessage(
        quality,
        brightness: averageBrightness,
        coverage: coverage,
        centerOffset: centerOffset,
      ),
    );
  }

  Rect _defaultCropRect(Size size) {
    return Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.25,
      size.width * 0.6,
      size.height * 0.5,
    );
  }

  Rect _clampCropRect(
    Rect rect,
    Size imageSize, {
    required double minimumWidth,
    required double minimumHeight,
  }) {
    double left = rect.left;
    double top = rect.top;
    double right = rect.right;
    double bottom = rect.bottom;

    if (rect.width < minimumWidth) {
      final expand = (minimumWidth - rect.width) / 2;
      left -= expand;
      right += expand;
    }
    if (rect.height < minimumHeight) {
      final expand = (minimumHeight - rect.height) / 2;
      top -= expand;
      bottom += expand;
    }

    left = left.clamp(0.0, max(0.0, imageSize.width - minimumWidth)).toDouble();
    top = top.clamp(0.0, max(0.0, imageSize.height - minimumHeight)).toDouble();
    right = right.clamp(left + minimumWidth, imageSize.width).toDouble();
    bottom = bottom.clamp(top + minimumHeight, imageSize.height).toDouble();

    return Rect.fromLTRB(left, top, right, bottom);
  }

  _TongueComponent? _findBestTongueComponent(
    List<List<bool>> mask, {
    required int roiLeft,
    required int roiTop,
    required int roiRight,
    required int roiBottom,
    // ── PERBAIKAN A: tambah parameter tinggi preview untuk hitung posisi Y relatif
    required int previewHeight,
  }) {
    final visited = List.generate(
      mask.length,
      (_) => List<bool>.filled(mask.first.length, false),
    );
    _TongueComponent? bestComponent;
    double bestScore = double.negativeInfinity;
    final targetX = (roiLeft + roiRight) / 2;

    // ── PERBAIKAN D: geser targetY dari 0.62 → 0.72 agar lebih ke bawah
    final targetY = roiTop + ((roiBottom - roiTop) * 0.72);

    for (int y = roiTop; y < roiBottom; y++) {
      for (int x = roiLeft; x < roiRight; x++) {
        if (!mask[y][x] || visited[y][x]) {
          continue;
        }

        final queue = <Point<int>>[Point<int>(x, y)];
        visited[y][x] = true;
        int head = 0;
        int minX = x;
        int minY = y;
        int maxX = x;
        int maxY = y;
        int pixelCount = 0;
        double sumX = 0;
        double sumY = 0;

        while (head < queue.length) {
          final point = queue[head++];
          final px = point.x;
          final py = point.y;

          pixelCount++;
          sumX += px;
          sumY += py;
          minX = min(minX, px);
          minY = min(minY, py);
          maxX = max(maxX, px);
          maxY = max(maxY, py);

          for (int ny = max(roiTop, py - 1);
              ny <= min(roiBottom - 1, py + 1);
              ny++) {
            for (int nx = max(roiLeft, px - 1);
                nx <= min(roiRight - 1, px + 1);
                nx++) {
              if (visited[ny][nx] || !mask[ny][nx]) {
                continue;
              }
              visited[ny][nx] = true;
              queue.add(Point<int>(nx, ny));
            }
          }
        }

        if (pixelCount < 120) {
          continue;
        }

        final centerX = sumX / pixelCount;
        final centerY = sumY / pixelCount;
        final width = maxX - minX + 1;
        final height = maxY - minY + 1;

        // ── PERBAIKAN C: buang komponen yang terlalu lebar dibanding tinggi
        // Bibir cenderung sangat lebar & pendek (aspectRatio > 2.8)
        final aspectRatio = width / max(1, height);
        if (aspectRatio > 2.8) {
          continue;
        }

        // ── PERBAIKAN A: penalti besar jika center komponen ada di atas 45% frame
        // Lidah secara anatomi selalu ada di bawah gigi/bibir
        final relativeY = centerY / previewHeight;
        final isLikelyLip = relativeY < 0.45;
        final lipPenalty = isLikelyLip ? 500.0 : 0.0;

        final distancePenalty =
            (centerX - targetX).abs() * 1.2 + (centerY - targetY).abs() * 0.9;
        final shapeBonus = height > width * 0.45 ? 120.0 : 0.0;

        // ── lipPenalty ditambahkan ke formula scoring
        final score = pixelCount + shapeBonus - distancePenalty - lipPenalty;

        if (score > bestScore) {
          bestScore = score;
          bestComponent = _TongueComponent(
            minX: minX,
            minY: minY,
            maxX: maxX,
            maxY: maxY,
            pixelCount: pixelCount,
            centerX: centerX,
            centerY: centerY,
          );
        }
      }
    }

    return bestComponent;
  }

  _FrameQuality _evaluateFrameQuality({
    required double brightness,
    required double sharpness,
    required double coverage,
    required Offset centerOffset,
  }) {
    final isTooDark = brightness < 85;
    final isTooBright = brightness > 200;
    final isTooSmall = coverage < 0.10;
    final isTooLarge = coverage > 0.52;
    final isOffCenter = centerOffset.dx > 0.16 || centerOffset.dy > 0.18;
    final isSoft = sharpness < 28;

    if (isTooDark ||
        isTooBright ||
        isTooSmall ||
        isTooLarge ||
        isOffCenter ||
        isSoft) {
      return _FrameQuality.fair;
    }
    return _FrameQuality.good;
  }

  String _qualityMessage(
    _FrameQuality quality, {
    required double brightness,
    required double coverage,
    required Offset centerOffset,
  }) {
    if (quality == _FrameQuality.good) {
      return 'Posisi lidah sudah cukup jelas untuk dianalisis. Anda bisa lanjut atau ambil ulang jika ingin frame yang lebih rapi.';
    }
    if (brightness < 85) {
      return 'Foto terlihat agak gelap. Coba arahkan wajah ke cahaya yang lebih terang agar area lidah lebih mudah terbaca.';
    }
    if (brightness > 200) {
      return 'Foto terlalu terang. Kurangi cahaya langsung agar warna lidah tidak terlalu pudar.';
    }
    if (coverage < 0.10) {
      return 'Area lidah terlihat masih kecil. Dekatkan kamera sedikit agar crop otomatis lebih fokus ke lidah.';
    }
    if (centerOffset.dx > 0.16 || centerOffset.dy > 0.18) {
      return 'Posisi lidah belum cukup di tengah frame. Coba ambil ulang dengan lidah lebih lurus di tengah.';
    }
    return 'Frame sudah cukup baik, tetapi hasil akan lebih stabil jika lidah memenuhi area tengah dan bibir tidak terlalu dominan.';
  }

  Future<void> _prepareCapturedImage(
    File imageFile, {
    File? croppedImageFile,
  }) async {
    setState(() {
      _imageFile = imageFile;
      _croppedImageFile = null;
      _detectionResult = null;
      _isPreparingImage = croppedImageFile == null;
    });

    if (croppedImageFile != null) {
      setState(() {
        _croppedImageFile = croppedImageFile;
        _isPreparingImage = false;
      });
      return;
    }

    final detection = await _cropImageForTongue(imageFile);
    if (!mounted) {
      return;
    }

    setState(() {
      _croppedImageFile = detection?.croppedFile;
      _detectionResult = detection;
      _isPreparingImage = false;
    });
  }

  Future<void> _ambilFoto() async {
    try {
      final CapturedTonguePhoto? photo =
          await Navigator.of(context).push<CapturedTonguePhoto>(
        MaterialPageRoute(
          builder: (context) => const KameraLidahScreen(),
          fullscreenDialog: true,
        ),
      );
      if (photo == null) {
        return;
      }
      await _prepareCapturedImage(
        photo.originalFile,
        croppedImageFile: photo.croppedFile,
      );
    } catch (e) {
      debugPrint('KameraLidahScreen error, fallback ke image_picker: $e');
      try {
        final XFile? fallbackPhoto = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1000,
          maxHeight: 1000,
        );
        if (fallbackPhoto != null && mounted) {
          await _prepareCapturedImage(File(fallbackPhoto.path));
        }
      } catch (fallbackError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengambil foto: $fallbackError')),
          );
        }
      }
    }
  }

  Future<void> _analisisFoto() async {
    if (!_isOnline) {
      _showOnlineFeatureMessage(featureName: 'Analisis hasil scan');
      return;
    }
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil foto lidah terlebih dahulu')),
      );
      return;
    }
    if (_isPreparingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Foto sedang disiapkan. Mohon tunggu sebentar.')),
      );
      return;
    }
    if (!_isValidTongueFrameForAnalysis()) {
      _showInvalidTongueFrameMessage();
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final fileToAnalyze = _croppedImageFile ?? _imageFile!;
      final result = await _mlService.predict(fileToAnalyze);

      if (!result['success']) {
        if (mounted) {
          setState(() => _isAnalyzing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Analisis gagal'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final userId = _authService.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          setState(() => _isAnalyzing = false);
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        return;
      }
      final scanId = const Uuid().v4(); // ini yang bikin ID dari scan

      String? fotoPath;
      try {
        fotoPath =
            await _supabaseService.uploadImage(userId, scanId, _imageFile!);
      } catch (_) {}

      final scanResult = ScanResultModel(
        id: scanId,
        userId: userId,
        tanggal: DateTime.now(),
        kategori: result['kategori'],
        probabilitas: result['probabilitas'],
        fotoPath: fotoPath,
        analisis: List<String>.from(result['analisis']),
        rekomendasi: List<String>.from(result['rekomendasi']),
      );

      final saveResult = await _supabaseService.saveScanResult(scanResult);
      if (saveResult['success'] != true) {
        if (mounted) {
          setState(() => _isAnalyzing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                saveResult['message'] ??
                    'Hasil skrining belum bisa disimpan. Silakan coba lagi.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      setState(() => _isAnalyzing = false);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HasilSkriningScreen(
              result: scanResult,
              imageFile: _imageFile,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan. Silakan coba lagi.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  bool _isValidTongueFrameForAnalysis() {
    return _croppedImageFile != null;
  }

  void _showInvalidTongueFrameMessage() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Foto Belum Sesuai',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          _detectionResult?.helperText ??
              'Hasil crop lidah belum tersedia. Ambil ulang foto dengan lidah berada di dalam frame panduan kamera.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Mengerti',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _previewBorderColor {
    final quality = _detectionResult?.quality;
    if (quality == _FrameQuality.good) {
      return Colors.green;
    }
    if (quality == _FrameQuality.fair) {
      return AppColors.secondary;
    }
    return _imageFile != null ? AppColors.primary : AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        title: const Text(
          'Ambil Foto Lidah',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(
              context,
              '/pengaturan',
              arguments: _selectedIndex,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                border: Border.all(color: _previewBorderColor, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.white,
              ),
              child: _imageFile != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                        if (_isPreparingImage)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          ),
                        if (_croppedImageFile != null)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _previewBorderColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  _croppedImageFile!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildBoundingBoxOverlay(hasImage: false),
                        Center(
                          child: Icon(
                            Icons.photo_camera_outlined,
                            size: 54,
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: _buildEmptyPreviewHint(),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            _buildPanduan(),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.secondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _detectionResult?.helperText ??
                              'Area kecil adalah hasil crop dari frame panduan kamera. Foto asli tetap ditampilkan agar Anda bisa memeriksa posisi dan kejelasan lidah.',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (_isAnalyzing)
              const Column(
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Sedang menganalisis...\nMohon tunggu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            else if (_imageFile == null)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _ambilFoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ambil Foto',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isPreparingImage
                          ? null
                          : (_isOnline
                              ? _analisisFoto
                              : () => _showOnlineFeatureMessage(
                                    featureName: 'Analisis hasil scan',
                                  )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isOnline && _isValidTongueFrameForAnalysis()
                                ? AppColors.primary
                                : AppColors.grey.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isPreparingImage
                            ? 'Menyiapkan Foto...'
                            : 'Analisis Sekarang',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isOnline
                              ? (_isValidTongueFrameForAnalysis()
                                  ? AppColors.white
                                  : AppColors.textSecondary)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _ambilFoto,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Ambil Ulang',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildBoundingBoxOverlay({required bool hasImage}) {
    return CustomPaint(
      painter: _BoundingBoxPainter(
        detectionResult: hasImage ? _detectionResult : null,
        fallbackColor: hasImage ? _previewBorderColor : AppColors.primary,
      ),
      child: Container(),
    );
  }

  Widget _buildEmptyPreviewHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.center_focus_strong, color: AppColors.primary, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ambil foto lidah dengan posisi di tengah frame dan pencahayaan terang.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanduan() {
    final panduan = [
      'Gunakan pencahayaan terang dan hindari bayangan pada area mulut.',
      'Buka mulut secukupnya lalu julurkan lidah lurus ke depan.',
      'Usahakan lidah memenuhi area tengah frame, sementara bibir dan gigi tidak terlalu dominan.',
      'Pegang kamera stabil dari jarak dekat sedang agar hasil crop otomatis lebih akurat.',
    ];
    return Column(
      children: panduan.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\u2022 ',
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomNavBar() {
    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Beranda',
      ),
      _NavItem(
        icon: Icons.camera_alt_outlined,
        activeIcon: Icons.camera_alt,
        label: 'Skrining',
      ),
      _NavItem(
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        label: 'Riwayat',
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isActive = _selectedIndex == index;
              return GestureDetector(
                onTap: () => _onNavItemTapped(index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? items[index].activeIcon : items[index].icon,
                        color: isActive
                            ? const Color(0xFFFFC107)
                            : Colors.white.withValues(alpha: 0.7),
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index].label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? const Color(0xFFFFC107)
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BoundingBoxPainter extends CustomPainter {
  final _TongueDetectionResult? detectionResult;
  final Color fallbackColor;

  _BoundingBoxPainter({
    required this.detectionResult,
    required this.fallbackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final defaultRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.25,
      size.width * 0.6,
      size.height * 0.5,
    );
    final rect = detectionResult == null
        ? defaultRect
        : _mapImageRectToCanvas(
            detectionResult!.cropRect,
            detectionResult!.imageSize,
            size,
          );
    final boxColor = detectionResult?.quality == _FrameQuality.good
        ? Colors.green
        : fallbackColor;

    final borderPaint = Paint()
      ..color = boxColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final guidePaint = Paint()
      ..color = boxColor.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final cornerPaint = Paint()
      ..color = boxColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, rect.top), shadowPaint);
    canvas.drawRect(
        Rect.fromLTWH(0, rect.top, rect.left, rect.height), shadowPaint);
    canvas.drawRect(
        Rect.fromLTWH(
            rect.right, rect.top, size.width - rect.right, rect.height),
        shadowPaint);
    canvas.drawRect(
        Rect.fromLTWH(0, rect.bottom, size.width, size.height - rect.bottom),
        shadowPaint);

    canvas.drawRect(rect, borderPaint);

    const cornerLength = 20.0;
    canvas.drawLine(
        rect.topLeft, Offset(rect.left + cornerLength, rect.top), cornerPaint);
    canvas.drawLine(
        rect.topLeft, Offset(rect.left, rect.top + cornerLength), cornerPaint);
    canvas.drawLine(rect.topRight, Offset(rect.right - cornerLength, rect.top),
        cornerPaint);
    canvas.drawLine(rect.topRight, Offset(rect.right, rect.top + cornerLength),
        cornerPaint);
    canvas.drawLine(rect.bottomLeft,
        Offset(rect.left + cornerLength, rect.bottom), cornerPaint);
    canvas.drawLine(rect.bottomLeft,
        Offset(rect.left, rect.bottom - cornerLength), cornerPaint);
    canvas.drawLine(rect.bottomRight,
        Offset(rect.right - cornerLength, rect.bottom), cornerPaint);
    canvas.drawLine(rect.bottomRight,
        Offset(rect.right, rect.bottom - cornerLength), cornerPaint);

    canvas.drawLine(
      Offset(rect.left, rect.top + rect.height / 2),
      Offset(rect.right, rect.top + rect.height / 2),
      guidePaint,
    );
    canvas.drawLine(
      Offset(rect.left + rect.width / 2, rect.top),
      Offset(rect.left + rect.width / 2, rect.bottom),
      guidePaint,
    );
  }

  Rect _mapImageRectToCanvas(Rect imageRect, Size imageSize, Size canvasSize) {
    final fittedSizes = applyBoxFit(BoxFit.cover, imageSize, canvasSize);
    final sourceRect = Alignment.center.inscribe(
      fittedSizes.source,
      Offset.zero & imageSize,
    );
    final destinationRect = Alignment.center.inscribe(
      fittedSizes.destination,
      Offset.zero & canvasSize,
    );
    final scaleX = destinationRect.width / sourceRect.width;
    final scaleY = destinationRect.height / sourceRect.height;
    return Rect.fromLTWH(
      destinationRect.left + (imageRect.left - sourceRect.left) * scaleX,
      destinationRect.top + (imageRect.top - sourceRect.top) * scaleY,
      imageRect.width * scaleX,
      imageRect.height * scaleY,
    );
  }

  @override
  bool shouldRepaint(_BoundingBoxPainter oldDelegate) {
    return oldDelegate.detectionResult != detectionResult ||
        oldDelegate.fallbackColor != fallbackColor;
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

enum _FrameQuality {
  good('Frame cukup baik'),
  fair('Frame perlu diperhatikan'),
  poor('Frame kurang ideal');

  const _FrameQuality(this.label);
  final String label;
}

class _TongueDetectionResult {
  final Rect cropRect;
  final Size imageSize;
  final _FrameQuality quality;
  final String statusText;
  final String helperText;
  final File? croppedFile;

  const _TongueDetectionResult({
    required this.cropRect,
    required this.imageSize,
    required this.quality,
    required this.statusText,
    required this.helperText,
    this.croppedFile,
  });

  _TongueDetectionResult copyWith({
    Rect? cropRect,
    Size? imageSize,
    _FrameQuality? quality,
    String? statusText,
    String? helperText,
    File? croppedFile,
  }) {
    return _TongueDetectionResult(
      cropRect: cropRect ?? this.cropRect,
      imageSize: imageSize ?? this.imageSize,
      quality: quality ?? this.quality,
      statusText: statusText ?? this.statusText,
      helperText: helperText ?? this.helperText,
      croppedFile: croppedFile ?? this.croppedFile,
    );
  }
}

class _TongueComponent {
  final int minX;
  final int minY;
  final int maxX;
  final int maxY;
  final int pixelCount;
  final double centerX;
  final double centerY;

  const _TongueComponent({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.pixelCount,
    required this.centerX,
    required this.centerY,
  });
}
