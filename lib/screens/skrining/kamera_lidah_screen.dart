import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../core/constants/app_colors.dart';

class CapturedTonguePhoto {
  final File originalFile;
  final File croppedFile;

  const CapturedTonguePhoto({
    required this.originalFile,
    required this.croppedFile,
  });
}

/// Hasil analisis frame real-time dari kamera
class _LiveFrameResult {
  final _LiveFrameQuality quality;
  final String message;
  final double brightness;
  final double coverage;
  final bool tongueDetected;

  const _LiveFrameResult({
    required this.quality,
    required this.message,
    required this.brightness,
    required this.coverage,
    required this.tongueDetected,
  });
}

enum _LiveFrameQuality {
  good,
  fair,
  poor,
}

/// Halaman kamera custom dengan real-time feedback kualitas foto lidah.
/// Mengembalikan [File] foto yang dipilih user, atau null jika dibatalkan.
class KameraLidahScreen extends StatefulWidget {
  const KameraLidahScreen({super.key});

  @override
  State<KameraLidahScreen> createState() => _KameraLidahScreenState();
}

class _KameraLidahScreenState extends State<KameraLidahScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _isCapturing = false;
  bool _isAnalyzingFrame = false;
  bool _isSwitchingCamera = false;
  String? _cameraError;

  // Index kamera yang sedang aktif
  int _selectedCameraIndex = 0;

  _LiveFrameResult _liveResult = const _LiveFrameResult(
    quality: _LiveFrameQuality.poor,
    message: 'Arahkan kamera ke lidah yang dijulurkan.',
    brightness: 0,
    coverage: 0,
    tongueDetected: false,
  );

  // Gambar yang baru saja dijepret, menunggu konfirmasi user
  File? _capturedFile;
  File? _croppedFile;
  bool _showConfirmation = false;
  Size? _lastPreviewSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.stopImageStream();
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraWithIndex(_selectedCameraIndex);
    }
  }

  /// Inisialisasi kamera pertama kali — default kamera belakang
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _cameraError = 'Tidak ada kamera yang tersedia.');
        return;
      }

      // Default: kamera belakang. Fallback ke kamera pertama jika tidak ada.
      int backIndex = 0;
      for (int i = 0; i < _cameras!.length; i++) {
        if (_cameras![i].lensDirection == CameraLensDirection.back) {
          backIndex = i;
          break;
        }
      }

      _selectedCameraIndex = backIndex;
      await _initCameraWithIndex(_selectedCameraIndex);
    } catch (e) {
      if (mounted) {
        setState(() => _cameraError = 'Gagal membuka kamera: $e');
      }
    }
  }

  /// Inisialisasi kamera berdasarkan index — dipakai juga saat switch kamera
  Future<void> _initCameraWithIndex(int index) async {
    try {
      if (_cameras == null || index >= _cameras!.length) {
        return;
      }

      // Dispose controller lama jika ada
      if (_controller != null) {
        await _controller!.stopImageStream().catchError((_) {});
        await _controller!.dispose();
        _controller = null;
      }

      if (mounted) {
        setState(() {
          _isCameraReady = false;
          _cameraError = null;
        });
      }

      final controller = CameraController(
        _cameras![index],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _controller = controller;
      await controller.initialize();

      if (!mounted) {
        return;
      }

      setState(() {
        _isCameraReady = true;
        _cameraError = null;
        _selectedCameraIndex = index;
      });

      _startFrameAnalysis();
    } catch (e) {
      if (mounted) {
        setState(() => _cameraError = 'Gagal membuka kamera: $e');
      }
    }
  }

  /// Switch antara kamera belakang dan depan
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2 || _isSwitchingCamera) {
      return;
    }

    setState(() => _isSwitchingCamera = true);

    // Toggle ke index berikutnya
    final nextIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _initCameraWithIndex(nextIndex);

    if (mounted) {
      setState(() => _isSwitchingCamera = false);
    }
  }

  /// Apakah ada lebih dari satu kamera (tombol switch ditampilkan)
  bool get _canSwitchCamera => (_cameras?.length ?? 0) > 1;

  /// Apakah kamera aktif sekarang adalah kamera depan
  bool get _isFrontCamera {
    if (_cameras == null || _selectedCameraIndex >= _cameras!.length) {
      return false;
    }
    return _cameras![_selectedCameraIndex].lensDirection ==
        CameraLensDirection.front;
  }

  void _startFrameAnalysis() {
    _controller?.startImageStream((CameraImage frame) async {
      if (_isAnalyzingFrame || _isCapturing || _showConfirmation) {
        return;
      }
      _isAnalyzingFrame = true;

      try {
        final result = await _analyzeFrame(frame);
        if (mounted && !_showConfirmation) {
          setState(() => _liveResult = result);
        }
      } catch (_) {
        // Abaikan error frame individual
      } finally {
        await Future.delayed(const Duration(milliseconds: 500));
        _isAnalyzingFrame = false;
      }
    });
  }

  /// Analisis cepat frame kamera untuk feedback real-time.
  Future<_LiveFrameResult> _analyzeFrame(CameraImage frame) async {
    final bytes = frame.planes[0].bytes;
    final width = frame.width;
    final height = frame.height;

    final centerStartX = (width * 0.2).round();
    final centerEndX = (width * 0.8).round();
    final centerStartY = (height * 0.25).round();
    final centerEndY = (height * 0.80).round();

    final stepX = max(1, (centerEndX - centerStartX) ~/ 20);
    final stepY = max(1, (centerEndY - centerStartY) ~/ 20);

    double totalBrightness = 0;
    int reddishCount = 0;
    int totalSampled = 0;

    for (int y = centerStartY; y < centerEndY; y += stepY) {
      for (int x = centerStartX; x < centerEndX; x += stepX) {
        final idx = y * width + x;
        if (idx >= bytes.length) {
          continue;
        }
        final yValue = bytes[idx].toDouble();
        totalBrightness += yValue;
        if (yValue > 70 && yValue < 190) {
          reddishCount++;
        }
        totalSampled++;
      }
    }

    if (totalSampled == 0) {
      return const _LiveFrameResult(
        quality: _LiveFrameQuality.poor,
        message: 'Tidak bisa membaca frame. Coba pindahkan kamera.',
        brightness: 0,
        coverage: 0,
        tongueDetected: false,
      );
    }

    final avgBrightness = totalBrightness / totalSampled;
    final reddishRatio = reddishCount / totalSampled;
    final coverage = reddishRatio;

    if (avgBrightness < 60) {
      return _LiveFrameResult(
        quality: _LiveFrameQuality.poor,
        message: 'Terlalu gelap. Cari pencahayaan yang lebih terang.',
        brightness: avgBrightness,
        coverage: coverage,
        tongueDetected: false,
      );
    }
    if (avgBrightness > 210) {
      return _LiveFrameResult(
        quality: _LiveFrameQuality.poor,
        message: 'Terlalu terang. Hindari cahaya langsung ke kamera.',
        brightness: avgBrightness,
        coverage: coverage,
        tongueDetected: false,
      );
    }
    if (reddishRatio < 0.25) {
      return _LiveFrameResult(
        quality: _LiveFrameQuality.fair,
        message: 'Julurkan lidah lebih jauh dan dekatkan kamera.',
        brightness: avgBrightness,
        coverage: coverage,
        tongueDetected: false,
      );
    }
    if (reddishRatio < 0.45) {
      return _LiveFrameResult(
        quality: _LiveFrameQuality.fair,
        message: 'Bagus! Coba dekatkan sedikit agar lidah lebih dominan.',
        brightness: avgBrightness,
        coverage: coverage,
        tongueDetected: true,
      );
    }

    return _LiveFrameResult(
      quality: _LiveFrameQuality.good,
      message: 'Posisi sudah baik! Tekan tombol untuk memotret.',
      brightness: avgBrightness,
      coverage: coverage,
      tongueDetected: true,
    );
  }

  Future<void> _capturePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      await _controller!.stopImageStream();
      final xFile = await _controller!.takePicture();
      final file = File(xFile.path);
      final croppedFile = await _cropPhotoFromGuideFrame(file);

      if (mounted) {
        setState(() {
          _capturedFile = file;
          _croppedFile = croppedFile;
          _showConfirmation = true;
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil foto: $e')),
        );
        _startFrameAnalysis();
      }
    }
  }

  void _confirmPhoto() {
    final capturedFile = _capturedFile;
    final croppedFile = _croppedFile;
    if (capturedFile == null || croppedFile == null) {
      return;
    }
    Navigator.of(context).pop(
      CapturedTonguePhoto(
        originalFile: capturedFile,
        croppedFile: croppedFile,
      ),
    );
  }

  void _retakePhoto() {
    setState(() {
      _capturedFile = null;
      _croppedFile = null;
      _showConfirmation = false;
    });
    _startFrameAnalysis();
  }

  Future<File> _cropPhotoFromGuideFrame(File originalFile) async {
    final bytes = await originalFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      return originalFile;
    }

    final image = img.bakeOrientation(decodedImage);
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final previewSize = _lastPreviewSize ?? imageSize;
    final guideRect = _guideRectForSize(previewSize);
    final cropRect = _mapPreviewRectToImageRect(
      guideRect,
      previewSize,
      imageSize,
    );

    final cropped = img.copyCrop(
      image,
      x: cropRect.left.round(),
      y: cropRect.top.round(),
      width: cropRect.width.round(),
      height: cropRect.height.round(),
    );

    final croppedPath = originalFile.path.toLowerCase().endsWith('.jpg')
        ? originalFile.path.replaceAll(
            RegExp(r'\.jpg$', caseSensitive: false),
            '_guide_crop.jpg',
          )
        : '${originalFile.path}_guide_crop.jpg';
    final croppedFile = File(croppedPath);
    await croppedFile.writeAsBytes(img.encodeJpg(cropped, quality: 92));
    return croppedFile;
  }

  Rect _guideRectForSize(Size size) {
    return Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.22,
      size.width * 0.70,
      size.height * 0.45,
    );
  }

  Rect _mapPreviewRectToImageRect(
    Rect previewRect,
    Size previewSize,
    Size imageSize,
  ) {
    final fittedSizes = applyBoxFit(BoxFit.cover, imageSize, previewSize);
    final sourceRect = Alignment.center.inscribe(
      fittedSizes.source,
      Offset.zero & imageSize,
    );
    final destinationRect = Alignment.center.inscribe(
      fittedSizes.destination,
      Offset.zero & previewSize,
    );

    final scaleX = sourceRect.width / destinationRect.width;
    final scaleY = sourceRect.height / destinationRect.height;
    final mappedRect = Rect.fromLTWH(
      sourceRect.left + (previewRect.left - destinationRect.left) * scaleX,
      sourceRect.top + (previewRect.top - destinationRect.top) * scaleY,
      previewRect.width * scaleX,
      previewRect.height * scaleY,
    );

    return Rect.fromLTRB(
      mappedRect.left.clamp(0.0, imageSize.width).toDouble(),
      mappedRect.top.clamp(0.0, imageSize.height).toDouble(),
      mappedRect.right.clamp(0.0, imageSize.width).toDouble(),
      mappedRect.bottom.clamp(0.0, imageSize.height).toDouble(),
    );
  }

  Color get _feedbackColor {
    switch (_liveResult.quality) {
      case _LiveFrameQuality.good:
        return Colors.green;
      case _LiveFrameQuality.fair:
        return const Color(0xFFF59E0B);
      case _LiveFrameQuality.poor:
        return Colors.redAccent;
    }
  }

  IconData get _feedbackIcon {
    switch (_liveResult.quality) {
      case _LiveFrameQuality.good:
        return Icons.check_circle_outline;
      case _LiveFrameQuality.fair:
        return Icons.info_outline;
      case _LiveFrameQuality.poor:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _cameraError != null
            ? _buildErrorView()
            : !_isCameraReady
                ? _buildLoadingView()
                : _showConfirmation
                    ? _buildConfirmationView()
                    : _buildCameraView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Membuka kamera...',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined,
                color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              _cameraError ?? 'Kamera tidak tersedia.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Kembali',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _controller;
    final previewSize = controller?.value.previewSize;
    if (controller == null || previewSize == null) {
      return const SizedBox();
    }

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final previewWidth = isPortrait ? previewSize.height : previewSize.width;
    final previewHeight = isPortrait ? previewSize.width : previewSize.height;

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewWidth,
          height: previewHeight,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Preview kamera
        _buildCameraPreview(),

        // Overlay gelap + kotak panduan
        _buildGuideOverlay(),

        // Tombol kembali (kiri atas)
        Positioned(
          top: 12,
          left: 12,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        // Label judul (tengah atas)
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Foto Lidah',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        // Tombol switch kamera (kanan atas)
        if (_canSwitchCamera)
          Positioned(
            top: 12,
            right: 12,
            child: _isSwitchingCamera
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      _isFrontCamera
                          ? Icons.camera_rear
                          : Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                    tooltip: _isFrontCamera
                        ? 'Ganti ke kamera belakang'
                        : 'Ganti ke kamera depan',
                    onPressed: _switchCamera,
                  ),
          ),

        // Label kamera aktif (di bawah tombol switch)
        if (_canSwitchCamera)
          Positioned(
            top: 56,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _isFrontCamera ? 'Depan' : 'Belakang',
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                  fontSize: 11,
                ),
              ),
            ),
          ),

        // Banner feedback real-time
        Positioned(
          bottom: 140,
          left: 16,
          right: 16,
          child: _buildFeedbackBanner(),
        ),

        // Tombol capture
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: _buildCaptureButton(),
        ),
      ],
    );
  }

  Widget _buildGuideOverlay() {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      _lastPreviewSize = Size(w, h);

      final guideRect = _guideRectForSize(Size(w, h));
      final guideLeft = guideRect.left;
      final guideTop = guideRect.top;
      final guideWidth = guideRect.width;
      final guideRight = guideLeft + guideWidth;

      final borderColor = _feedbackColor;

      return CustomPaint(
        painter: _GuideOverlayPainter(
          guideRect: guideRect,
          borderColor: borderColor,
        ),
        child: Stack(
          children: [
            Positioned(
              top: guideTop - 36,
              left: guideLeft,
              right: w - guideRight,
              child: Center(
                child: Text(
                  'Posisikan lidah di sini',
                  style: TextStyle(
                    color: borderColor,
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFeedbackBanner() {
    final color = _feedbackColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(_feedbackIcon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _liveResult.message,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    final isReady = _liveResult.quality != _LiveFrameQuality.poor;
    return Center(
      child: GestureDetector(
        onTap: (_isCapturing || !isReady || _isSwitchingCamera)
            ? null
            : _capturePhoto,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isReady ? Colors.white : Colors.white38,
            border: Border.all(
              color: _feedbackColor,
              width: 3,
            ),
          ),
          child: _isCapturing
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: Colors.black54,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  Icons.camera_alt,
                  color: isReady ? Colors.black87 : Colors.black38,
                  size: 32,
                ),
        ),
      ),
    );
  }

  Widget _buildConfirmationView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: _retakePhoto,
              ),
              const Spacer(),
              const Text(
                'Konfirmasi Foto',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _capturedFile != null
                  ? Image.file(_capturedFile!, fit: BoxFit.contain)
                  : const SizedBox(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pastikan lidah terlihat jelas dan tidak buram sebelum melanjutkan.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _retakePhoto,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Ambil Ulang'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _confirmPhoto,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Gunakan Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Painter untuk overlay panduan posisi lidah dengan lubang di tengah
class _GuideOverlayPainter extends CustomPainter {
  final Rect guideRect;
  final Color borderColor;

  _GuideOverlayPainter({
    required this.guideRect,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(guideRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(guideRect, const Radius.circular(16)),
      borderPaint,
    );

    const cornerLen = 22.0;
    final cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(guideRect.topLeft,
        Offset(guideRect.left + cornerLen, guideRect.top), cornerPaint);
    canvas.drawLine(guideRect.topLeft,
        Offset(guideRect.left, guideRect.top + cornerLen), cornerPaint);
    canvas.drawLine(guideRect.topRight,
        Offset(guideRect.right - cornerLen, guideRect.top), cornerPaint);
    canvas.drawLine(guideRect.topRight,
        Offset(guideRect.right, guideRect.top + cornerLen), cornerPaint);
    canvas.drawLine(guideRect.bottomLeft,
        Offset(guideRect.left + cornerLen, guideRect.bottom), cornerPaint);
    canvas.drawLine(guideRect.bottomLeft,
        Offset(guideRect.left, guideRect.bottom - cornerLen), cornerPaint);
    canvas.drawLine(guideRect.bottomRight,
        Offset(guideRect.right - cornerLen, guideRect.bottom), cornerPaint);
    canvas.drawLine(guideRect.bottomRight,
        Offset(guideRect.right, guideRect.bottom - cornerLen), cornerPaint);

    final guidePaint = Paint()
      ..color = borderColor.withValues(alpha: 0.25)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(guideRect.left, guideRect.top + guideRect.height / 2),
      Offset(guideRect.right, guideRect.top + guideRect.height / 2),
      guidePaint,
    );
    canvas.drawLine(
      Offset(guideRect.left + guideRect.width / 2, guideRect.top),
      Offset(guideRect.left + guideRect.width / 2, guideRect.bottom),
      guidePaint,
    );
  }

  @override
  bool shouldRepaint(_GuideOverlayPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.guideRect != guideRect;
  }
}