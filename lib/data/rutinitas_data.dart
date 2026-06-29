import '../models/rutinitas_model.dart';

class RutinitasData {
  // Rutinitas untuk NON-DIABETES (Pencegahan)
  static List<RutinitasModel> getNonDiabetesRutinitas() {
    return [
      RutinitasModel(
        id: 'nd_1',
        title: 'Minum 8 Gelas per Hari',
        description:
            'Minum air putih minimal 8 gelas (2 liter) untuk menjaga hidrasi dan metabolisme',
        color: 'blue',
        isDefault: true,
        frequency: 'harian',
        times: ['08:00'],
        notificationMessage:
            'Jangan lupa minum air putih ya! 💧 Hidrasi yang cukup membantu metabolisme tubuhmu tetap optimal.',
        checklistItems: [
          ChecklistItem(id: 'nd_1_1', title: 'Pagi (06:00-08:00)'),
          ChecklistItem(id: 'nd_1_2', title: 'Pagi (08:00-10:00)'),
          ChecklistItem(id: 'nd_1_3', title: 'Menjelang Siang (10:00-12:00)'),
          ChecklistItem(id: 'nd_1_4', title: 'Siang (12:00-14:00)'),
          ChecklistItem(id: 'nd_1_5', title: 'Sore (14:00-16:00)'),
          ChecklistItem(id: 'nd_1_6', title: 'Sore (16:00-18:00)'),
          ChecklistItem(id: 'nd_1_7', title: 'Malam (18:00-20:00)'),
          ChecklistItem(id: 'nd_1_8', title: 'Malam (20:00-22:00)'),
        ],
      ),
      RutinitasModel(
        id: 'nd_2',
        title: 'Aktivitas Fisik',
        description:
            'Olahraga atau aktivitas fisik minimal 30 menit setiap hari',
        color: 'red',
        isDefault: true,
        frequency: 'harian',
        times: ['07:00'],
        notificationMessage:
            'Yuk bergerak! 🏃 Aktivitas fisik 30 menit sehari terbukti membantu mencegah diabetes.',
        checklistItems: [
          ChecklistItem(id: 'nd_2_1', title: 'Olahraga/Jalan Kaki 30 menit'),
          ChecklistItem(id: 'nd_2_2', title: 'Peregangan 5 menit'),
        ],
      ),
      RutinitasModel(
        id: 'nd_3',
        title: 'Pola Makan Sehat',
        description: 'Konsumsi sayur, buah, protein seimbang dan batasi gula',
        color: 'yellow',
        isDefault: true,
        frequency: 'harian',
        times: ['08:00'],
        notificationMessage:
            'Perhatikan pola makanmu hari ini! 🥗 Konsumsi sayur, buah, dan batasi gula untuk menjaga kesehatan.',
        checklistItems: [
          ChecklistItem(
              id: 'nd_3_1', title: 'Konsumsi sayur atau buah hari ini'),
          ChecklistItem(id: 'nd_3_2', title: 'Hindari Minuman Manis'),
          ChecklistItem(id: 'nd_3_3', title: 'Batasi Junk Food'),
          ChecklistItem(
              id: 'nd_3_4',
              title: 'Tambahkan sumber protein pada makanan utama'),
        ],
      ),
      RutinitasModel(
        id: 'nd_4',
        title: 'Tidur Cukup (7-9 Jam)',
        description: 'Tidur teratur 7-9 jam per malam untuk kesehatan optimal',
        color: 'blue',
        isDefault: true,
        frequency: 'harian',
        times: ['22:00'],
        notificationMessage:
            'Sudah waktunya istirahat! 🌙 Tidur 7-9 jam malam ini agar tubuhmu pulih dan siap besok.',
        checklistItems: [
          ChecklistItem(
              id: 'nd_4_1', title: 'Mulai tidur sebelum jam 23:00'),
          ChecklistItem(id: 'nd_4_2', title: 'Bangun di jam yang konsisten'),
          ChecklistItem(id: 'nd_4_3', title: 'Tidur 7-9 jam semalam'),
        ],
      ),
      RutinitasModel(
        id: 'nd_5',
        title: 'Manajemen Stres',
        description:
            'Meditasi, relaksasi, atau aktivitas yang menenangkan pikiran',
        color: 'red',
        isDefault: true,
        frequency: 'harian',
        times: ['15:00'],
        notificationMessage:
            'Luangkan waktu untuk dirimu sendiri. 🧘 Ambil napas dalam-dalam — 5 menit relaksasi bisa membuat perbedaan besar.',
        checklistItems: [
          ChecklistItem(
              id: 'nd_5_1',
              title: 'Meditasi / Pernapasan dalam (5-10 menit)'),
          ChecklistItem(
              id: 'nd_5_2', title: 'Aktivitas santai (baca, musik, dll)'),
        ],
      ),
    ];
  }

  // Rutinitas untuk DIABETES (Pengelolaan)
  static List<RutinitasModel> getDiabetesRutinitas() {
    return [
      RutinitasModel(
        id: 'd_1',
        title: 'Cek Gula Darah',
        description:
            'Monitor gula darah sesuai anjuran dokter (puasa, 2 jam PP, atau sebelum tidur)',
        color: 'blue',
        isDefault: true,
        frequency: 'harian',
        times: ['06:30'],
        notificationMessage:
            'Saatnya cek gula darah puasa! 🩸 Catat hasilnya agar dokter bisa memantau kondisimu dengan lebih baik.',
        checklistItems: [
          ChecklistItem(id: 'd_1_1', title: 'Cek Puasa (pagi)'),
          ChecklistItem(id: 'd_1_2', title: 'Cek 2 jam setelah makan'),
          ChecklistItem(id: 'd_1_3', title: 'Catat Hasil'),
        ],
      ),
      RutinitasModel(
        id: 'd_2',
        title: 'Minum Obat Teratur',
        description:
            'Konsumsi obat diabetes sesuai resep dokter tanpa terlewat',
        color: 'red',
        isDefault: true,
        frequency: 'harian',
        times: ['07:00', '12:00', '19:00'],
        notificationMessage:
            'Jangan lupa minum obat! 💊 Konsumsi obat sesuai jadwal adalah kunci pengelolaan diabetes yang baik.',
        checklistItems: [
          ChecklistItem(id: 'd_2_1', title: 'Minum obat sesuai jadwal pagi'),
          ChecklistItem(
              id: 'd_2_2',
              title: 'Minum obat sesuai jadwal siang, jika ada'),
          ChecklistItem(
              id: 'd_2_3',
              title: 'Minum obat sesuai jadwal malam, jika ada'),
        ],
      ),
      RutinitasModel(
        id: 'd_3',
        title: 'Minum 8 Gelas per Hari',
        description:
            'Minum air putih minimal 8 gelas untuk menjaga fungsi ginjal',
        color: 'blue',
        isDefault: true,
        frequency: 'harian',
        times: ['08:00'],
        notificationMessage:
            'Sudah minum air putih hari ini? 💧 Hidrasi yang cukup sangat penting untuk menjaga fungsi ginjalmu.',
        checklistItems: [
          ChecklistItem(id: 'd_3_1', title: 'Pagi (06:00-08:00)'),
          ChecklistItem(id: 'd_3_2', title: 'Pagi (08:00-10:00)'),
          ChecklistItem(id: 'd_3_3', title: 'Menjelang Siang (10:00-12:00)'),
          ChecklistItem(id: 'd_3_4', title: 'Siang (12:00-14:00)'),
          ChecklistItem(id: 'd_3_5', title: 'Sore (14:00-16:00)'),
          ChecklistItem(id: 'd_3_6', title: 'Sore (16:00-18:00)'),
          ChecklistItem(id: 'd_3_7', title: 'Malam (18:00-20:00)'),
          ChecklistItem(id: 'd_3_8', title: 'Malam (20:00-22:00)'),
        ],
      ),
      RutinitasModel(
        id: 'd_4',
        title: 'Aktivitas Fisik',
        description: 'Olahraga ringan-sedang 30 menit, hindari hipoglikemia',
        color: 'yellow',
        isDefault: true,
        frequency: 'harian',
        times: ['07:00'],
        notificationMessage:
            'Waktunya gerak! 🚶 Olahraga ringan 30 menit membantu tubuhmu menggunakan gula darah lebih efisien.',
        checklistItems: [
          ChecklistItem(id: 'd_4_1', title: 'Olahraga/Jalan Kaki 30 menit'),
          ChecklistItem(
              id: 'd_4_2', title: 'Istirahat cukup (hindari kelelahan)'),
          ChecklistItem(
              id: 'd_4_3',
              title: 'Cek kondisi tubuh sebelum/sesudah olahraga'),
        ],
      ),
      RutinitasModel(
        id: 'd_5',
        title: 'Pola Makan Diabetes',
        description:
            'Diet rendah gula, tinggi serat, porsi terkontrol sesuai anjuran ahli gizi',
        color: 'blue',
        isDefault: true,
        frequency: 'harian',
        times: ['08:00'],
        notificationMessage:
            'Jaga pola makanmu hari ini! 🥦 Diet rendah gula dan tinggi serat adalah senjata utama melawan diabetes.',
        checklistItems: [
          ChecklistItem(
              id: 'd_5_1', title: 'Hindari gula tambahan/minuman manis'),
          ChecklistItem(
              id: 'd_5_2', title: 'Konsumsi serat dari sayur atau buah'),
          ChecklistItem(id: 'd_5_3', title: 'Makan dengan porsi terkontrol'),
          ChecklistItem(
              id: 'd_5_4', title: 'Tambahkan protein pada makanan utama'),
        ],
      ),
      RutinitasModel(
        id: 'd_6',
        title: 'Perawatan Kaki',
        description: 'Cek kaki setiap hari, jaga kebersihan, hindari luka',
        color: 'red',
        isDefault: true,
        frequency: 'harian',
        times: ['21:00'],
        notificationMessage:
            'Sudah cek kaki hari ini? 👣 Perawatan kaki rutin mencegah komplikasi serius pada penderita diabetes.',
        checklistItems: [
          ChecklistItem(
              id: 'd_6_1', title: 'Cek Kaki (perhatikan luka/kemerahan)'),
          ChecklistItem(id: 'd_6_2', title: 'Cuci Kaki dengan Air Hangat'),
          ChecklistItem(id: 'd_6_3', title: 'Keringkan dengan Baik'),
          ChecklistItem(id: 'd_6_4', title: 'Pakai Sepatu Nyaman'),
        ],
      ),
      RutinitasModel(
        id: 'd_7',
        title: 'Tidur Cukup (7-9 Jam)',
        description: 'Tidur teratur untuk kontrol gula darah yang lebih baik',
        color: 'yellow',
        isDefault: true,
        frequency: 'harian',
        times: ['22:00'],
        notificationMessage:
            'Waktunya istirahat! 🌙 Tidur yang cukup membantu tubuhmu mengontrol gula darah dengan lebih stabil.',
        checklistItems: [
          ChecklistItem(
              id: 'd_7_1', title: 'Mulai tidur sebelum jam 23:00'),
          ChecklistItem(id: 'd_7_2', title: 'Bangun di jam yang konsisten'),
          ChecklistItem(id: 'd_7_3', title: 'Tidur 7-9 jam semalam'),
        ],
      ),
      RutinitasModel(
        id: 'd_8',
        title: 'Manajemen Stres',
        description: 'Kelola stress karena dapat mempengaruhi gula darah',
        color: 'blue',
        isDefault: true,
        frequency: 'harian',
        times: ['15:00'],
        notificationMessage:
            'Jangan biarkan stres mengganggu kesehatanmu! 🧘 Stres yang tidak terkontrol dapat menaikkan gula darah.',
        checklistItems: [
          ChecklistItem(
              id: 'd_8_1', title: 'Meditasi / Relaksasi (10 menit)'),
          ChecklistItem(id: 'd_8_2', title: 'Berbagi dengan orang terdekat'),
          ChecklistItem(id: 'd_8_3', title: 'Aktivitas yang menyenangkan'),
        ],
      ),
      RutinitasModel(
        id: 'd_9',
        title: 'Catat Gula Darah',
        description: 'Dokumentasikan hasil pemeriksaan gula darah harian',
        color: 'red',
        isDefault: true,
        frequency: 'harian',
        times: ['20:00'],
        notificationMessage:
            'Sudah catat hasil gula darahmu hari ini? 📓 Catatan harian membantu dokter memantau perkembanganmu.',
        checklistItems: [
          ChecklistItem(id: 'd_9_1', title: 'Catat di buku/aplikasi'),
          ChecklistItem(
              id: 'd_9_2',
              title: 'Lihat kembali catatan gula darah hari ini'),
        ],
      ),
    ];
  }
}