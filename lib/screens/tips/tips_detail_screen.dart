import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/tips_model.dart';

class TipsDetailScreen extends StatefulWidget {
  final TipsModel tips;

  const TipsDetailScreen({super.key, required this.tips});

  @override
  State<TipsDetailScreen> createState() => _TipsDetailScreenState();
}

class _TipsDetailScreenState extends State<TipsDetailScreen> {
  bool get _isMovementTip {
    final title = widget.tips.title.toLowerCase();
    return title.contains('aktivitas fisik') ||
        title.contains('olahraga') ||
        title.contains('gerakan');
  }

  String get _sectionTitle =>
      _isMovementTip ? 'Gerakan-Gerakan' : 'Poin-Poin Penting';

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return const Color(0xFF4A7EFF);
      case 'red':
        return const Color(0xFFFF6B6B);
      case 'yellow':
        return const Color(0xFFFFD966);
      case 'green':
        return const Color(0xFF26A69A);
      case 'purple':
        return const Color(0xFF9C27B0);
      default:
        return AppColors.primary;
    }
  }

  // ── Parse detail text menjadi lines terstruktur ──
  List<String> _parseDetailText(String detail) {
    final lines = detail.split('\n');
    return lines.where((line) => line.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getColorFromString(widget.tips.color);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Tips',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER IMAGE ──
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cardColor, cardColor.withValues(alpha: 0.7)],
                ),
              ),
              child: Image.asset(
                widget.tips.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 80,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── JUDUL ──
                  Text(
                    widget.tips.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── DESKRIPSI ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: cardColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      widget.tips.description,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── LABEL POIN PENTING ──
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _sectionTitle,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── KARTU SECTION (bergambar) ──
                  ...List.generate(widget.tips.sections.length, (index) {
                    final section = widget.tips.sections[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSectionCard(section, cardColor),
                    );
                  }),

                  const SizedBox(height: 32),

                  // ── LABEL PENJELASAN LENGKAP ──
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Penjelasan Lengkap',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── KONTEN DETAIL TERSTRUKTUR ──
                  ...widget.tips.sections.asMap().entries.map((entry) {
                    final i = entry.key;
                    final section = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildDetailSection(i + 1, section, cardColor),
                    );
                  }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KARTU SECTION (bergambar) ──
  Widget _buildSectionCard(TipsSectionModel section, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Container(
              width: 100,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColor.withValues(alpha: 0.3),
                    cardColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Image.asset(
                section.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_not_supported,
                  color: cardColor.withValues(alpha: 0.5),
                  size: 40,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    section.summary,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── KARTU DETAIL SECTION (terstruktur rapi) ──
  Widget _buildDetailSection(
      int number, TipsSectionModel section, Color cardColor) {
    final detailLines = _parseDetailText(section.detail);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Isi section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: detailLines.map((line) {
                // Bullet point dengan •
                if (line.startsWith('•')) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4, right: 8),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: cardColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            line.substring(1).trim(),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Teks biasa atau judul
                final isBold = line.contains('-') && line.length < 50;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                      color: isBold ? cardColor : AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}