import 'package:flutter/material.dart';

class NetworkStatusBanner extends StatelessWidget {
  final bool isOnline;
  final String? onlineMessage;
  final String? offlineMessage;

  const NetworkStatusBanner({
    super.key,
    required this.isOnline,
    this.onlineMessage,
    this.offlineMessage,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isOnline
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFF3E0);
    final borderColor = isOnline
        ? const Color(0xFF66BB6A)
        : const Color(0xFFFFB74D);
    final iconColor = isOnline
        ? const Color(0xFF2E7D32)
        : const Color(0xFFEF6C00);
    final textColor = isOnline
        ? const Color(0xFF1B5E20)
        : const Color(0xFFE65100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: iconColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isOnline
                  ? (onlineMessage ?? 'Online. Semua fitur sinkronisasi siap digunakan.')
                  : (offlineMessage ??
                      'Offline. Beberapa fitur memerlukan koneksi internet untuk berjalan penuh.'),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
