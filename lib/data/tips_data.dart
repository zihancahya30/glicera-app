import '../models/tips_model.dart';

class TipsData {
  static List<TipsModel> getTipsHarian() {
    return [
      TipsModel(
        id: 'tips_1',
        title: 'Memahami Diabetes',
        color: 'yellow',
        image: 'assets/images/diabetes.png',
        description:
            'Pahami apa itu diabetes dan bagaimana cara mencegahnya sejak dini.',
        sections: [
          TipsSectionModel(
            title: 'Apa itu Diabetes?',
            summary:
                'Diabetes adalah kondisi peningkatan kadar gula darah dalam tubuh.',
            detail:
                'Diabetes adalah penyakit kronis yang ditandai dengan peningkatan kadar gula (glukosa) dalam darah. '
                'Tanpa penanganan yang tepat, diabetes dapat menyebabkan berbagai komplikasi serius terhadap kesehatan.\n\n'
                '• Tubuh tidak dapat menghasilkan insulin yang cukup\n'
                '• Atau tidak dapat menggunakan insulin dengan baik\n'
                '• Insulin adalah hormon yang membantu mengontrol kadar gula darah\n'
                '• Kondisi ini menyebabkan glukosa menumpuk di dalam darah',
            image: 'assets/images/what_diabetes.png',
          ),
          TipsSectionModel(
            title: 'Jenis-Jenis Diabetes',
            summary:
                'Tipe 1, Tipe 2, dan Gestasional adalah jenis-jenis utama diabetes.',
            detail:
                'Ada tiga jenis diabetes utama:\n\n'
                '• Diabetes Tipe 1\n'
                '  - Pankreas tidak dapat menghasilkan insulin\n'
                '  - Biasanya terjadi pada anak-anak dan dewasa muda\n'
                '  - Memerlukan injeksi insulin seumur hidup\n\n'
                '• Diabetes Tipe 2\n'
                '  - Tubuh resisten terhadap insulin\n'
                '  - Jenis paling umum (90% dari semua diabetes)\n'
                '  - Dapat dicegah dengan gaya hidup sehat\n\n'
                '• Diabetes Gestasional\n'
                '  - Terjadi pada wanita hamil\n'
                '  - Biasanya hilang setelah persalinan\n'
                '  - Meningkatkan risiko diabetes tipe 2 di masa depan',
            image: 'assets/images/diabetes2.png',
          ),
          TipsSectionModel(
            title: 'Gejala Diabetes',
            summary:
                'Rasa haus berlebih, sering buang air kecil, dan kelelahan.',
            detail:
                'Kenali tanda-tanda diabetes sejak dini:\n\n'
                '• Rasa haus yang berlebihan (Polidipsia)\n'
                '• Sering buang air kecil terutama malam hari (Poliuria)\n'
                '• Rasa lapar yang terus-menerus (Polifagia)\n'
                '• Kelelahan dan kelemahan tanpa sebab jelas\n'
                '• Luka yang lambat sembuh\n'
                '• Pandangan kabur atau berubah-ubah\n'
                '• Kesemutan atau baal di tangan/kaki',
            image: 'assets/images/img_glukometer.png',
          ),
          TipsSectionModel(
            title: 'Faktor Risiko Diabetes',
            summary:
                'Keturunan, obesitas, gaya hidup tidak sehat, dan usia.',
            detail:
                'Beberapa faktor yang meningkatkan risiko diabetes:\n\n'
                '• Riwayat keluarga yang menderita diabetes\n'
                '• Kelebihan berat badan atau obesitas\n'
                '• Tekanan darah tinggi (hipertensi)\n'
                '• Kolesterol atau trigliserida tinggi\n'
                '• Gaya hidup tidak aktif dan kurang gerak\n'
                '• Usia di atas 45 tahun\n'
                '• Riwayat diabetes gestasional sebelumnya',
            image: 'assets/images/diabetes4.png',
          ),
          TipsSectionModel(
            title: 'Cara Pencegahan Diabetes',
            summary: 'Gaya hidup sehat dapat mencegah atau menunda diabetes.',
            detail:
                'Langkah-langkah pencegahan yang dapat dilakukan:\n\n'
                '• Jaga berat badan ideal (BMI 18,5–22,9 untuk Asia)\n'
                '• Olahraga teratur minimal 150 menit per minggu\n'
                '• Konsumsi makanan sehat, tinggi serat, rendah gula\n'
                '• Batasi asupan gula tambahan dan minuman manis\n'
                '• Kelola stres dengan baik setiap hari\n'
                '• Tidur cukup 7–9 jam per malam\n'
                '• Lakukan pemeriksaan kesehatan rutin setiap tahun\n'
                '• Jangan merokok dan hindari alkohol',
            image: 'assets/images/edu_pencegahan.png',
          ),
        ],
      ),

      TipsModel(
        id: 'tips_2',
        title: 'Tips Pola Makan',
        color: 'blue',
        image: 'assets/images/nutrition.jpg',
        description:
            'Panduan lengkap untuk menjaga pola makan sehat dan mencegah diabetes.',
        sections: [
          TipsSectionModel(
            title: 'Konsumsi Makanan Berserat Tinggi',
            summary: 'Sayuran hijau, buah-buahan segar, dan gandum utuh.',
            detail:
                'Serat memperlambat penyerapan gula sehingga gula darah lebih stabil.\n\n'
                '• Sayuran hijau: bayam, brokoli, kangkung, kale\n'
                '• Buah-buahan segar: apel, pir, jeruk, jambu biji\n'
                '• Gandum utuh, oatmeal, dan beras merah\n'
                '• Kacang-kacangan: kacang merah, edamame, lentil\n'
                '• Serat memperlambat penyerapan gula sehingga gula darah lebih stabil',
            image: 'assets/images/fiber.jpg',
          ),
          TipsSectionModel(
            title: 'Batasi Gula dan Karbohidrat Sederhana',
            summary:
                'Hindari minuman manis dan pilih nasi merah daripada nasi putih.',
            detail:
                'Gula dan karbohidrat sederhana dapat menyebabkan lonjakan gula darah.\n\n'
                '• Hindari minuman manis: soda, teh manis kemasan, jus kemasan\n'
                '• Kurangi kue, permen, cokelat manis, dan donat\n'
                '• Ganti nasi putih dengan nasi merah secara bertahap\n'
                '• Batasi roti putih, mi instan, dan pasta putih\n'
                '• Baca label nutrisi — waspadai gula tersembunyi di produk kemasan',
            image: 'assets/images/sugar.jpg',
          ),
          TipsSectionModel(
            title: 'Porsi Makan Teratur',
            summary: 'Makan 3x sehari dengan porsi sedang dan teratur.',
            detail:
                'Pola makan teratur membantu menjaga kadar gula darah tetap stabil.\n\n'
                '• Makan 3 kali sehari di jam yang sama setiap hari\n'
                '• Tambahkan camilan sehat di antara waktu makan jika perlu\n'
                '• Jangan melewatkan sarapan — sarapan menstabilkan gula darah pagi\n'
                '• Usahakan makan malam sebelum jam 19.00\n'
                '• Makan perlahan — sekitar 20 menit per porsi',
            image: 'assets/images/portion.jpg',
          ),
          TipsSectionModel(
            title: 'Pilih Protein Berkualitas',
            summary:
                'Ikan, ayam tanpa kulit, telur, tahu, dan tempe adalah pilihan terbaik.',
            detail:
                'Protein berkualitas membantu menjaga kadar gula darah tetap stabil.\n\n'
                '• Ikan (salmon, tuna, sarden, kembung) — 2–3x seminggu\n'
                '• Ayam atau bebek tanpa kulit — rendah lemak jenuh\n'
                '• Telur rebus atau orak-arik — 1 butir per hari\n'
                '• Tahu dan tempe — protein nabati khas Indonesia\n'
                '• Kacang-kacangan sebagai camilan pengganti gorengan',
            image: 'assets/images/protein.jpg',
          ),
          TipsSectionModel(
            title: 'Kontrol Porsi dengan Metode Piring',
            summary:
                '50% sayuran, 25% protein, 25% karbohidrat kompleks.',
            detail:
                'Metode piring memudahkan kontrol porsi tanpa harus menghitung kalori.\n\n'
                '• Isi setengah piring (50%) dengan sayuran non-tepung\n'
                '• Isi seperempat piring (25%) dengan protein berkualitas\n'
                '• Isi seperempat piring (25%) dengan karbohidrat kompleks\n'
                '• Gunakan piring berukuran lebih kecil untuk kontrol porsi\n'
                '• Minum segelas air putih sebelum makan agar lebih cepat kenyang',
            image: 'assets/images/balance.jpg',
          ),
        ],
      ),

      TipsModel(
        id: 'tips_3',
        title: 'Tips Aktivitas Fisik',
        color: 'red',
        image: 'assets/images/exercise.png',
        description:
            'Panduan olahraga dan aktivitas fisik untuk kesehatan optimal.',
        sections: [
          TipsSectionModel(
            title: 'Olahraga Aerobik Rutin',
            summary:
                '150 menit per minggu: jalan cepat, bersepeda, atau berenang.',
            detail:
                'Olahraga aerobik bekerja seperti insulin alami — otot yang aktif menyerap glukosa langsung dari darah.\n\n'
                '• Jalan cepat 30 menit, 5 hari seminggu adalah target ideal\n'
                '• Bersepeda santai atau statis selama 30–45 menit\n'
                '• Berenang — olahraga terbaik untuk seluruh tubuh\n'
                '• Senam aerobik atau zumba untuk variasi yang menyenangkan\n'
                '• Jogging ringan jika kondisi fisik memungkinkan',
            image: 'assets/images/cardio.jpg',
          ),
          TipsSectionModel(
            title: 'Latihan Kekuatan',
            summary:
                '2x seminggu: angkat beban ringan, push-up, atau squat.',
            detail:
                'Latihan kekuatan membantu membangun otot yang menyerap glukosa lebih efisien.\n\n'
                '• Angkat beban ringan (1–3 kg) untuk pemula\n'
                '• Push-up dan sit-up bisa dilakukan di rumah tanpa alat\n'
                '• Squat dan lunges untuk memperkuat otot kaki\n'
                '• Resistance band sebagai alternatif murah dan efektif\n'
                '• Yoga atau pilates menggabungkan kekuatan dan fleksibilitas',
            image: 'assets/images/strength.png',
          ),
          TipsSectionModel(
            title: 'Aktif dalam Keseharian',
            summary:
                'Naik tangga, parkir lebih jauh, berkebun, atau bersih rumah.',
            detail:
                'Aktivitas sehari-hari juga berkontribusi pada kesehatan dan kontrol gula darah.\n\n'
                '• Naik tangga dan hindari lift atau eskalator\n'
                '• Parkir lebih jauh dari tujuan agar lebih banyak berjalan\n'
                '• Berdiri saat menelepon atau meeting singkat\n'
                '• Lakukan peregangan setiap 30 menit saat duduk bekerja\n'
                '• Berkebun atau membersihkan rumah termasuk aktivitas fisik',
            image: 'assets/images/daily.jpg',
          ),
          TipsSectionModel(
            title: 'Peregangan Setiap Hari',
            summary:
                'Peregangan pagi dan malam selama 10 menit untuk fleksibilitas.',
            detail:
                'Peregangan rutin membantu meningkatkan fleksibilitas dan mengurangi risiko cedera.\n\n'
                '• Peregangan leher dan bahu selama 5 menit di pagi hari\n'
                '• Peregangan punggung bawah untuk mencegah nyeri\n'
                '• Peregangan kaki dan betis — penting untuk penderita diabetes\n'
                '• Peregangan sebelum tidur membantu relaksasi otot\n'
                '• Lakukan setiap gerakan dengan perlahan dan tahan 15–30 detik',
            image: 'assets/images/stretch.jpg',
          ),
          TipsSectionModel(
            title: 'Tips Memulai Olahraga',
            summary:
                'Mulai dari 10 menit, tingkatkan bertahap, pilih yang disukai.',
            detail:
                'Kunci sukses adalah konsistensi dan memilih olahraga yang menyenangkan.\n\n'
                '• Mulai dari durasi pendek (10–15 menit) lalu tingkatkan bertahap\n'
                '• Pilih jenis olahraga yang benar-benar kamu nikmati\n'
                '• Ajak teman, pasangan, atau keluarga agar lebih semangat\n'
                '• Tetapkan jadwal tetap — konsistensi lebih penting dari intensitas\n'
                '• Catat aktivitas harian untuk memantau kemajuan',
            image: 'assets/images/tips.png',
          ),
        ],
      ),

      TipsModel(
        id: 'tips_4',
        title: 'Kelola Stres',
        color: 'green',
        image: 'assets/images/stress.png',
        description:
            'Teknik dan strategi untuk mengelola stres dengan baik demi gula darah yang stabil.',
        sections: [
          TipsSectionModel(
            title: 'Meditasi Setiap Hari',
            summary:
                'Meditasi 10–15 menit setiap pagi membantu menenangkan pikiran.',
            detail:
                'Meditasi rutin terbukti dapat menurunkan kadar HbA1c dan stres.\n\n'
                '• Mulai dengan 5–10 menit, tingkatkan bertahap hingga 15–20 menit\n'
                '• Lakukan di pagi hari sebelum aktivitas untuk memulai hari dengan tenang\n'
                '• Fokus pada pernapasan — amati napas masuk dan keluar\n'
                '• Gunakan aplikasi panduan seperti Headspace atau Calm jika perlu\n'
                '• Meditasi rutin terbukti dapat menurunkan kadar HbA1c',
            image: 'assets/images/meditate.jpg',
          ),
          TipsSectionModel(
            title: 'Teknik Pernapasan 4-7-8',
            summary:
                'Tarik napas 4 detik, tahan 7 detik, hembuskan 8 detik.',
            detail:
                'Teknik pernapasan ini membantu menenangkan sistem saraf secara cepat.\n\n'
                '• Tarik napas perlahan melalui hidung selama 4 detik\n'
                '• Tahan napas selama 7 detik\n'
                '• Hembuskan napas perlahan melalui mulut selama 8 detik\n'
                '• Ulangi 4–6 kali setiap sesi\n'
                '• Lakukan kapan saja saat merasa cemas atau tegang',
            image: 'assets/images/breathe.png',
          ),
          TipsSectionModel(
            title: 'Hobi yang Menenangkan',
            summary:
                'Membaca, menggambar, berkebun, atau mendengarkan musik.',
            detail:
                'Aktivitas hobi yang menyenangkan membantu mengalihkan pikiran dari sumber stres.\n\n'
                '• Membaca buku — mengalihkan pikiran dari sumber stres\n'
                '• Menggambar atau mewarnai — terapi ekspresi yang efektif\n'
                '• Mendengarkan musik instrumental atau alam\n'
                '• Berkebun atau merawat tanaman — terapi alam terbukti efektif\n'
                '• Menulis jurnal — tuangkan pikiran dan perasaan tiap malam',
            image: 'assets/images/hobby.jpg',
          ),
          TipsSectionModel(
            title: 'Hubungan Sosial dan Konseling',
            summary:
                'Berbicara dengan orang terdekat atau konseling profesional.',
            detail:
                'Dukungan sosial sangat penting dalam mengelola stres.\n\n'
                '• Luangkan waktu berkualitas bersama keluarga setiap hari\n'
                '• Ceritakan beban pikiran kepada teman atau orang yang dipercaya\n'
                '• Bergabung dengan komunitas atau grup dukungan\n'
                '• Konsultasi dengan psikolog jika stres terasa tidak tertangani\n'
                '• Batasi konsumsi berita negatif yang memicu kecemasan',
            image: 'assets/images/talk.png',
          ),
        ],
      ),

      TipsModel(
        id: 'tips_5',
        title: 'Istirahat Cukup',
        color: 'purple',
        image: 'assets/images/istirahat cukup.png',
        description:
            'Panduan tidur berkualitas untuk menjaga gula darah dan kesehatan yang optimal.',
        sections: [
          TipsSectionModel(
            title: 'Tidur 7–9 Jam per Malam',
            summary:
                'Kurang tidur meningkatkan resistensi insulin hingga 28%.',
            detail:
                'Tidur berkualitas sama pentingnya dengan diet dan olahraga.\n\n'
                '• Orang dewasa membutuhkan 7–9 jam tidur setiap malam\n'
                '• Kurang dari 6 jam meningkatkan resistensi insulin secara signifikan\n'
                '• Tidur lebih dari 9 jam juga berkaitan dengan risiko kesehatan\n'
                '• Kualitas tidur lebih penting daripada sekadar durasi\n'
                '• Tidur yang nyenyak membantu tubuh memulihkan sensitivitas insulin',
            image: 'assets/images/tidur_7 jam.png',
          ),
          TipsSectionModel(
            title: 'Jadwal Tidur Teratur',
            summary:
                'Tidur dan bangun pada jam yang sama setiap hari, termasuk weekend.',
            detail:
                'Ritme sircadian yang stabil membantu metabolisme glukosa bekerja optimal.\n\n'
                '• Tidur dan bangun di jam yang sama setiap hari tanpa terkecuali\n'
                '• Konsistensi jadwal termasuk di hari Sabtu dan Minggu\n'
                '• Ritme sircadian yang stabil membantu metabolisme glukosa bekerja optimal\n'
                '• Hindari begadang meski keesokan harinya libur\n'
                '• Setel alarm tidur — bukan hanya alarm bangun',
            image: 'assets/images/schedule.png',
          ),
          TipsSectionModel(
            title: 'Ciptakan Lingkungan Tidur Nyaman',
            summary:
                'Kamar gelap, sejuk (18–22°C), dan bebas gangguan suara.',
            detail:
                'Lingkungan yang tepat sangat membantu kualitas tidur.\n\n'
                '• Pastikan kamar cukup gelap — gunakan tirai tebal atau penutup mata\n'
                '• Atur suhu kamar pada 18–22°C untuk tidur paling nyenyak\n'
                '• Minimalisir kebisingan — gunakan earplug jika perlu\n'
                '• Pastikan kasur dan bantal nyaman dan mendukung postur\n'
                '• Ventilasi udara yang baik membantu tidur lebih berkualitas',
            image: 'assets/images/tidur_nyaman.png',
          ),
          TipsSectionModel(
            title: 'Hindari Pengganggu Tidur',
            summary:
                'Hindari layar gadget minimal 1 jam sebelum tidur.',
            detail:
                'Beberapa hal dapat mengganggu kualitas tidur.\n\n'
                '• Jauhkan semua gadget minimal 1 jam sebelum tidur\n'
                '• Cahaya biru dari layar menghambat produksi hormon melatonin\n'
                '• Hindari kafein (kopi, teh, cokelat) setelah jam 14.00\n'
                '• Hindari makan berat 3 jam sebelum tidur\n'
                '• Alkohol memperburuk kualitas tidur meski awalnya terasa mengantuk',
            image: 'assets/images/gadget.png',
          ),
          TipsSectionModel(
            title: 'Ritual Sebelum Tidur',
            summary:
                'Mandi air hangat, membaca buku, atau meditasi ringan.',
            detail:
                'Rutinitas sebelum tidur membantu tubuh dan pikiran bersiap untuk istirahat.\n\n'
                '• Mandi air hangat 1–2 jam sebelum tidur membantu menurunkan suhu tubuh\n'
                '• Membaca buku fisik (bukan e-book) selama 15–20 menit\n'
                '• Meditasi atau pernapasan dalam selama 5–10 menit\n'
                '• Dengarkan musik tenang atau suara alam\n'
                '• Tulis 3 hal yang kamu syukuri hari ini — membantu pikiran lebih positif',
            image: 'assets/images/relax.png',
          ),
        ],
      ),
    ];
  }
}