import '../models/edukasi_model.dart';

class EdukasiData {
  static List<EdukasiModel> getEdukasi() {
    return [
      EdukasiModel(
        id: 'edu_1',
        title: 'Apa Itu Diabetes',
        color: 'blue',
        image: 'assets/images/what_diabetes.png',
        description:
            'Diabetes mellitus adalah penyakit kronis akibat gangguan produksi atau fungsi insulin yang menyebabkan kadar gula darah tinggi secara terus-menerus.',
        sections: [
          EdukasiSectionModel(
            title: 'Apa Itu Insulin?',
            summary: 'Hormon pengatur gula darah yang diproduksi pankreas.',
            detail:
                'Insulin adalah hormon yang diproduksi oleh sel beta pankreas.\n\n'
                '• Fungsinya membantu glukosa masuk ke dalam sel tubuh untuk diubah menjadi energi\n'
                '• Tanpa insulin yang cukup, glukosa menumpuk di darah dan tidak bisa digunakan sel sebagai bahan bakar\n'
                '• Penumpukan glukosa inilah yang disebut hiperglikemia — kondisi utama pada diabetes',
            image: 'assets/images/img_insulin.png',
          ),
          EdukasiSectionModel(
            title: 'Kadar Gula Darah Normal',
            summary:
                'Gula darah puasa normal < 100 mg/dL. Prediabetes 100–125. Diabetes ≥ 126.',
            detail:
                'Ada 3 cara mengukur kadar gula darah:\n\n'
                '• Gula Darah Puasa (GDP)\n'
                '  - Normal: < 100 mg/dL\n'
                '  - Prediabetes: 100–125 mg/dL\n'
                '  - Diabetes: ≥ 126 mg/dL\n\n'
                '• Gula Darah 2 Jam Setelah Makan\n'
                '  - Normal: < 140 mg/dL\n'
                '  - Prediabetes: 140–199 mg/dL\n'
                '  - Diabetes: ≥ 200 mg/dL\n\n'
                '• HbA1c (rata-rata 3 bulan terakhir)\n'
                '  - Normal: < 5,7%\n'
                '  - Prediabetes: 5,7–6,4%\n'
                '  - Diabetes: ≥ 6,5%',
            image: 'assets/images/img_glukometer.png',
          ),
          EdukasiSectionModel(
            title: 'Prevalensi di Indonesia',
            summary:
                '11,7% penduduk Indonesia usia ≥ 15 tahun menderita diabetes (SKI 2023).',
            detail:
                'Berdasarkan Survei Kesehatan Indonesia (SKI) 2023, prevalensi diabetes di Indonesia '
                'mencapai 11,7% pada penduduk usia 15 tahun ke atas. '
                'Artinya sekitar 1 dari 9 orang dewasa Indonesia mengidap diabetes.\n\n'
                'Lebih mengkhawatirkan, banyak penderita tidak menyadari kondisinya '
                'karena gejala awal sering tidak terasa. Deteksi dini melalui '
                'skrining rutin sangat penting untuk mencegah komplikasi.',
            image: 'assets/images/img_statistik.png',
          ),
          EdukasiSectionModel(
            title: 'Mengapa Diabetes Berbahaya?',
            summary:
                'Gula darah tinggi merusak pembuluh darah, saraf, ginjal, dan mata.',
            detail:
                'Diabetes yang tidak terkontrol merusak pembuluh darah secara perlahan di seluruh tubuh. '
                'Komplikasi jangka panjang yang dapat terjadi:\n\n'
                '• Penyakit jantung dan stroke — penyebab kematian utama penderita diabetes\n'
                '• Nefropati (kerusakan ginjal) — bisa berujung cuci darah\n'
                '• Retinopati (kerusakan mata) — bisa menyebabkan kebutaan\n'
                '• Neuropati (kerusakan saraf) — kesemutan, mati rasa, nyeri\n'
                '• Luka kaki diabetik — sembuh sangat lambat, risiko amputasi\n\n'
                'Semua komplikasi ini dapat dicegah dengan menjaga gula darah tetap terkontrol.',
            image: 'assets/images/img_jantung.png',
          ),
        ],
      ),
      EdukasiModel(
        id: 'edu_2',
        title: 'Gejala Awal Diabetes',
        color: 'red',
        image: 'assets/images/diabetes3.jpg',
        description:
            'Kenali tanda-tanda awal diabetes sedini mungkin. Banyak penderita tidak sadar hingga komplikasi muncul karena gejalanya tampak biasa.',
        sections: [
          EdukasiSectionModel(
            title: 'Gejala 3P (Gejala Klasik)',
            summary:
                'Poliuria (sering kencing), Polidipsia (sering haus), Polifagia (sering lapar).',
            detail:
                'Tiga gejala klasik diabetes disebut 3P:\n\n'
                '• Poliuria — Sering buang air kecil, terutama malam hari. '
                'Ginjal bekerja keras membuang kelebihan glukosa lewat urine sehingga volume urine meningkat drastis.\n\n'
                '• Polidipsia — Merasa haus terus-menerus karena tubuh kehilangan banyak cairan akibat sering kencing. '
                'Mulut terasa kering meski sudah minum banyak.\n\n'
                '• Polifagia — Sering lapar meski baru makan. Sel tubuh tidak mendapat energi dari glukosa '
                'sehingga otak terus mengirim sinyal lapar. Uniknya berat badan justru turun.',
            image: 'assets/images/img_minumair.png',
          ),
          EdukasiSectionModel(
            title: 'Mudah Lelah & Berat Badan Turun',
            summary:
                'Tubuh kekurangan energi karena glukosa tidak bisa masuk ke sel.',
            detail:
                'Karena insulin tidak bekerja optimal, sel-sel tubuh tidak mendapat pasokan glukosa '
                'yang cukup sebagai bahan bakar. Akibatnya:\n\n'
                '• Tubuh terasa lelah dan lemas sepanjang hari meski sudah cukup tidur\n'
                '• Sulit berkonsentrasi dan mudah mengantuk\n'
                '• Berat badan turun drastis tanpa diet — karena tubuh mulai membakar lemak '
                'dan otot sebagai sumber energi pengganti\n'
                '• Penurunan 5–10 kg dalam waktu singkat tanpa sebab jelas perlu diwaspadai',
            image: 'assets/images/img_lelah.png',
          ),
          EdukasiSectionModel(
            title: 'Luka Sulit Sembuh',
            summary:
                'Luka kecil bisa membutuhkan waktu berminggu-minggu untuk sembuh.',
            detail:
                'Kadar gula darah tinggi mengganggu sistem kekebalan tubuh dan merusak pembuluh darah kecil, '
                'sehingga aliran darah ke luka berkurang. Dampaknya:\n\n'
                '• Luka kecil seperti goresan atau lecet sembuh sangat lambat\n'
                '• Mudah terinfeksi bakteri atau jamur\n'
                '• Terutama di area kaki karena sirkulasi darah paling jauh dari jantung\n'
                '• Infeksi bisa semakin dalam hingga jaringan dalam — dalam kasus berat bisa berujung amputasi\n\n'
                'Periksa kaki setiap hari untuk mendeteksi luka sekecil apapun.',
            image: 'assets/images/img_lukakaki.png',
          ),
          EdukasiSectionModel(
            title: 'Penglihatan Kabur',
            summary:
                'Gula darah tinggi mengubah bentuk lensa mata sehingga penglihatan berubah.',
            detail:
                'Hiperglikemia menyebabkan lensa mata menyerap cairan berlebih dan mengembang, '
                'sehingga kemampuan fokus mata berubah. Gejala yang dirasakan:\n\n'
                '• Pandangan tidak jelas, seperti berkabut\n'
                '• Penglihatan berubah-ubah, kadang jelas kadang buram\n'
                '• Sulit membaca tulisan kecil\n\n'
                'Ini berbeda dari retinopati diabetik (kerusakan pembuluh darah di retina) '
                'yang merupakan komplikasi jangka panjang. Penglihatan kabur di awal '
                'bisa membaik ketika gula darah terkontrol.',
            image: 'assets/images/img_mata.png',
          ),
          EdukasiSectionModel(
            title: 'Infeksi & Kesemutan Berulang',
            summary:
                'Kesemutan di tangan/kaki dan infeksi jamur berulang adalah tanda kerusakan saraf awal.',
            detail:
                'Dua gejala lain yang sering diabaikan:\n\n'
                '• Kesemutan/baal di tangan dan kaki — tanda awal neuropati diabetik. '
                'Gula darah tinggi merusak serabut saraf kecil yang mengirim sinyal sentuhan dan nyeri.\n\n'
                '• Infeksi jamur berulang — terutama di area genital pada wanita (keputihan berulang) '
                'dan infeksi kulit. Jamur berkembang subur di lingkungan kadar gula tinggi.\n\n'
                '• Infeksi saluran kemih berulang — gejala umum yang sering tidak dikaitkan dengan diabetes.\n\n'
                'Jika mengalami 2 atau lebih gejala di atas, segera periksakan gula darah ke dokter.',
            image: 'assets/images/kesemutan.png',
          ),
        ],
      ),
      EdukasiModel(
        id: 'edu_3',
        title: 'Jenis-Jenis Diabetes',
        color: 'yellow',
        image: 'assets/images/diabetes2.png',
        description:
            'Diabetes bukan satu penyakit tunggal. Ada beberapa jenis dengan penyebab, karakteristik, dan penanganan yang berbeda.',
        sections: [
          EdukasiSectionModel(
            title: 'Diabetes Tipe 1',
            summary:
                'Autoimun — sistem tubuh menyerang pankreas. Butuh insulin seumur hidup.',
            detail:
                'Diabetes Tipe 1 adalah penyakit autoimun di mana sistem kekebalan tubuh '
                'secara keliru menyerang dan menghancurkan sel beta pankreas yang memproduksi insulin.\n\n'
                '• Siapa yang terkena: Terutama anak-anak, remaja, dan dewasa muda\n'
                '• Penyebab: Genetik + faktor pemicu lingkungan (infeksi virus tertentu)\n'
                '• Bukan karena pola makan atau gaya hidup\n'
                '• Gejala: Muncul tiba-tiba dan cepat memburuk\n'
                '• Penanganan: Wajib suntik insulin setiap hari seumur hidup\n'
                '• Proporsi: Hanya 5–10% dari total kasus diabetes',
            image: 'assets/images/diabetes-tipe-1.png',
          ),
          EdukasiSectionModel(
            title: 'Diabetes Tipe 2',
            summary:
                'Paling umum (90%). Tubuh resisten insulin. Erat dengan gaya hidup.',
            detail:
                'Diabetes Tipe 2 adalah jenis paling umum, mencakup 90–95% semua kasus diabetes.\n\n'
                '• Apa yang terjadi: Sel tubuh menjadi resisten terhadap insulin, '
                'sehingga pankreas harus bekerja lebih keras. Lama-kelamaan pankreas kelelahan '
                'dan produksi insulin berkurang.\n\n'
                '• Siapa yang berisiko: Usia > 40 tahun, kelebihan berat badan, '
                'kurang gerak, riwayat keluarga diabetes\n\n'
                '• Gejala: Berkembang perlahan, sering tidak disadari selama bertahun-tahun\n\n'
                '• Penanganan: Perubahan gaya hidup, obat antidiabetes oral, '
                'dan insulin jika diperlukan\n\n'
                '• Kabar baik: Diabetes Tipe 2 DAPAT DICEGAH dengan gaya hidup sehat!',
            image: 'assets/images/img_obesitas.png',
          ),
          EdukasiSectionModel(
            title: 'Diabetes Gestasional',
            summary:
                'Terjadi saat hamil. Biasanya hilang setelah melahirkan, tapi meningkatkan risiko Tipe 2.',
            detail:
                'Diabetes gestasional terjadi ketika wanita hamil mengalami kadar gula darah tinggi '
                'meskipun sebelumnya tidak pernah diabetes.\n\n'
                '• Penyebab: Hormon kehamilan mengganggu kerja insulin\n'
                '• Kapan terdeteksi: Biasanya pada trimester ke-2 atau ke-3\n'
                '• Terjadi pada: 2–10% kehamilan\n\n'
                '• Risiko jika tidak ditangani:\n'
                '  - Bayi lahir terlalu besar (makrosomia)\n'
                '  - Bayi hipoglikemia setelah lahir\n'
                '  - Persalinan prematur\n\n'
                '• Setelah melahirkan: Kadar gula biasanya kembali normal, '
                'tapi ibu memiliki risiko 50% lebih tinggi terkena Diabetes Tipe 2.',
            image: 'assets/images/img_hamil.png',
          ),
          EdukasiSectionModel(
            title: 'Prediabetes',
            summary:
                'Kadar gula di atas normal tapi belum diabetes. Masih bisa KEMBALI NORMAL.',
            detail:
                'Prediabetes adalah kondisi "zona peringatan" sebelum diabetes.\n\n'
                '• Kadar gula darah puasa: 100–125 mg/dL\n'
                '• HbA1c: 5,7–6,4%\n'
                '• 2 jam setelah makan: 140–199 mg/dL\n\n'
                'Pada prediabetes, sel tubuh mulai resisten terhadap insulin tapi '
                'pankreas masih mampu mengompensasi.\n\n'
                '• Tanpa intervensi: 15–30% penderita prediabetes akan berkembang '
                'menjadi Diabetes Tipe 2 dalam 5 tahun\n\n'
                '• Dengan intervensi gaya hidup:\n'
                '  - Turunkan berat badan 5–7%\n'
                '  - Olahraga 150 menit/minggu\n'
                '  → Risiko diabetes turun 58% dan kadar gula BISA kembali normal!',
            image: 'assets/images/img_prediabetes.png',
          ),
        ],
      ),
      EdukasiModel(
        id: 'edu_4',
        title: 'Pola Makan Sehat',
        color: 'blue',
        image: 'assets/images/edu_makan.png',
        description:
            'Pola makan adalah senjata utama melawan diabetes. Pilihan makanan yang tepat dapat menstabilkan gula darah sepanjang hari.',
        sections: [
          EdukasiSectionModel(
            title: 'Pilih Karbohidrat Kompleks',
            summary:
                'Nasi merah, oatmeal, ubi, dan roti gandum dicerna lambat sehingga gula darah lebih stabil.',
            detail:
                'Karbohidrat kompleks mengandung serat tinggi sehingga dicerna lebih lambat '
                'dibanding karbohidrat sederhana. Dampaknya, kenaikan gula darah bertahap dan tidak melonjak.\n\n'
                'Pilihan terbaik:\n'
                '• Nasi merah / nasi cokelat — ganti nasi putih secara bertahap\n'
                '• Oatmeal — sarapan ideal, kenyang lama\n'
                '• Ubi jalar / kentang dengan kulit\n'
                '• Roti gandum utuh (whole wheat)\n'
                '• Jagung\n\n'
                'Hindari:\n'
                '• Nasi putih berlebihan\n'
                '• Roti putih, mi instan, kue, donat\n'
                '• Minuman manis, soda, teh manis kemasan',
            image: 'assets/images/img_nasiputih.png',
          ),
          EdukasiSectionModel(
            title: 'Perbanyak Sayur & Buah',
            summary:
                'Sayuran non-tepung dan buah segar kaya serat membantu memperlambat penyerapan gula.',
            detail:
                'Sayuran dan buah adalah fondasi diet anti-diabetes.\n\n'
                'Sayuran yang dianjurkan (5 porsi/hari):\n'
                '• Sayuran hijau: bayam, kangkung, brokoli, kale\n'
                '• Tomat, wortel, terong, kacang panjang, timun\n'
                '• Hindari sayuran bertepung berlebihan (kentang, singkong)\n\n'
                'Buah yang dianjurkan (3 porsi/hari):\n'
                '• Apel, pir, jeruk, jambu biji, pepaya, melon\n'
                '• Alpukat — lemak sehat, indeks glikemik rendah\n\n'
                'Buah yang perlu dibatasi:\n'
                '• Mangga matang, durian, anggur, buah kalengan dalam sirup',
            image: 'assets/images/img_sayuran.png',
          ),
          EdukasiSectionModel(
            title: 'Protein Berkualitas Setiap Hari',
            summary:
                'Protein tidak menaikkan gula darah dan membantu rasa kenyang lebih lama.',
            detail:
                'Protein adalah nutrisi penting yang tidak langsung mempengaruhi gula darah. '
                'Mengonsumsi protein cukup membantu menjaga massa otot dan memperlambat penyerapan karbohidrat.\n\n'
                'Sumber protein terbaik:\n'
                '• Ikan (salmon, tuna, sarden, kembung) — 2–3x seminggu, kaya omega-3\n'
                '• Ayam tanpa kulit — rendah lemak jenuh\n'
                '• Telur — 1 butir/hari, kaya nutrisi\n'
                '• Tahu dan tempe — protein nabati terjangkau, khas Indonesia\n'
                '• Kacang-kacangan (edamame, kacang merah)\n\n'
                'Batasi:\n'
                '• Daging merah — maksimal 2x seminggu\n'
                '• Daging olahan (sosis, nugget, kornet)',
            image: 'assets/images/img_ikan.png',
          ),
          EdukasiSectionModel(
            title: 'Lemak Sehat vs Lemak Jahat',
            summary:
                'Pilih minyak zaitun, alpukat, dan ikan. Hindari gorengan dan santan kental.',
            detail:
                'Tidak semua lemak berbahaya. Lemak sehat justru membantu menstabilkan gula darah.\n\n'
                'Lemak sehat (dianjurkan):\n'
                '• Minyak zaitun / minyak kanola untuk memasak\n'
                '• Alpukat — sumber lemak tak jenuh tunggal\n'
                '• Kacang almond, walnut, mete — camilan sehat\n'
                '• Ikan berlemak (omega-3) — salmon, sarden, makarel\n\n'
                'Lemak jahat (hindari):\n'
                '• Gorengan — minyak bekas pakai menghasilkan radikal bebas\n'
                '• Santan kental berlebihan\n'
                '• Margarin / mentega berlebihan\n'
                '• Fast food dan makanan cepat saji',
            image: 'assets/images/img_minyak.png',
          ),
          EdukasiSectionModel(
            title: 'Metode Piring Sehat',
            summary:
                '50% sayuran, 25% protein, 25% karbo kompleks — panduan porsi mudah setiap makan.',
            detail:
                'Metode Piring (Plate Method) adalah cara mudah mengatur porsi makan tanpa '
                'perlu menghitung kalori:\n\n'
                '• ½ piring (50%) → Sayuran non-tepung\n'
                '  Contoh: tumis bayam, salad, brokoli rebus, sup sayur\n\n'
                '• ¼ piring (25%) → Protein berkualitas\n'
                '  Contoh: ikan bakar, ayam panggang, tahu/tempe, telur\n\n'
                '• ¼ piring (25%) → Karbohidrat kompleks\n'
                '  Contoh: nasi merah, ubi, jagung, oatmeal\n\n'
                'Tips tambahan:\n'
                '• Makan perlahan — 20 menit per porsi\n'
                '• Gunakan piring lebih kecil untuk kontrol porsi\n'
                '• Minum air putih sebelum makan\n'
                '• Jangan melewatkan sarapan',
            image: 'assets/images/img_piring.png',
          ),
        ],
      ),
      EdukasiModel(
        id: 'edu_5',
        title: 'Gaya Hidup Sehat',
        color: 'red',
        image: 'assets/images/edu_gaya_hidup.png',
        description:
            'Gaya hidup sehat adalah kombinasi kebiasaan harian yang secara bersama-sama melindungi tubuh dari diabetes dan berbagai penyakit kronis.',
        sections: [
          EdukasiSectionModel(
            title: 'Olahraga 150 Menit per Minggu',
            summary:
                'WHO merekomendasikan 150 menit aerobik/minggu. Olahraga langsung menurunkan gula darah.',
            detail:
                'Saat berolahraga, otot menyerap glukosa dari darah langsung tanpa memerlukan insulin.\n\n'
                'Rekomendasi mingguan:\n'
                '• Aerobik sedang: 150–300 menit/minggu\n'
                '  Contoh: jalan cepat, bersepeda, berenang, senam\n'
                '• ATAU aerobik berat: 75–150 menit/minggu\n'
                '  Contoh: jogging, HIIT, lompat tali\n'
                '• Latihan kekuatan: 2 hari/minggu\n'
                '  Contoh: angkat beban ringan, push-up, squat\n\n'
                'Tips memulai:\n'
                '• Mulai dari 10–15 menit, tingkatkan bertahap\n'
                '• Pilih olahraga yang kamu sukai agar konsisten\n'
                '• Jadwalkan di waktu tetap setiap hari',
            image: 'assets/images/img_jogging.png',
          ),
          EdukasiSectionModel(
            title: 'Jaga Berat Badan Ideal',
            summary:
                'Turun 5–10% berat badan dapat meningkatkan sensitivitas insulin hingga 50%.',
            detail:
                'Kelebihan lemak, terutama di perut, adalah penyebab utama resistensi insulin.\n\n'
                'Cara mengukur risiko:\n'
                '• BMI untuk Asia:\n'
                '  Normal: 18,5–22,9\n'
                '  Kelebihan berat: ≥ 23\n'
                '  Obesitas: ≥ 25\n\n'
                '• Lingkar pinggang (risiko tinggi):\n'
                '  Pria: > 90 cm\n'
                '  Wanita: > 80 cm\n\n'
                'Cara menurunkan berat badan sehat:\n'
                '• Defisit kalori 300–500 kkal/hari\n'
                '• Target: 0,5–1 kg per minggu\n'
                '• Kombinasi diet sehat + olahraga\n'
                '• Hindari diet ekstrem',
            image: 'assets/images/img_timbangan.png',
          ),
          EdukasiSectionModel(
            title: 'Tidur 7–9 Jam Berkualitas',
            summary:
                'Kurang tidur meningkatkan resistensi insulin dan nafsu makan berlebih.',
            detail:
                'Penelitian membuktikan kurang tidur (< 6 jam/malam) meningkatkan risiko '
                'diabetes hingga 28% karena:\n\n'
                '• Hormon kortisol (stres) meningkat → gula darah naik\n'
                '• Hormon ghrelin (lapar) meningkat → nafsu makan tidak terkontrol\n'
                '• Sensitivitas insulin menurun\n\n'
                'Tips tidur berkualitas:\n'
                '• Tidur dan bangun di jam yang sama setiap hari\n'
                '• Hindari layar gadget 1 jam sebelum tidur\n'
                '• Kamar sejuk (18–22°C), gelap, dan tenang\n'
                '• Hindari kafein setelah jam 14.00\n'
                '• Jangan tidur siang > 30 menit',
            image: 'assets/images/img_tidur.png',
          ),
          EdukasiSectionModel(
            title: 'Kelola Stres dengan Baik',
            summary:
                'Stres kronis memicu kortisol yang langsung menaikkan gula darah.',
            detail:
                'Stres punya dampak fisik langsung pada gula darah.\n\n'
                'Mekanismenya:\n'
                'Stres → kortisol & adrenalin meningkat → hati melepas glukosa ke darah '
                '→ gula darah naik → sulit terkontrol\n\n'
                'Teknik manajemen stres:\n'
                '• Meditasi 10–15 menit/hari — terbukti menurunkan HbA1c\n'
                '• Teknik pernapasan 4-7-8: tarik napas 4 detik, tahan 7 detik, buang 8 detik\n'
                '• Olahraga — melepas endorfin, hormon kebahagiaan alami\n'
                '• Journaling — tulis pikiran dan perasaan setiap malam\n'
                '• Konsultasi psikolog jika stres tidak tertangani',
            image: 'assets/images/img_meditasi.png',
          ),
          EdukasiSectionModel(
            title: 'Hindari Rokok & Alkohol',
            summary:
                'Rokok meningkatkan risiko diabetes 30–40%. Berhenti merokok adalah langkah terbaik.',
            detail:
                'Dampak rokok terhadap diabetes:\n'
                '• Meningkatkan risiko terkena Diabetes Tipe 2 sebesar 30–40%\n'
                '• Mempercepat kerusakan pembuluh darah\n'
                '• Meningkatkan resistensi insulin\n'
                '• Memperburuk semua komplikasi diabetes\n\n'
                'Tips berhenti merokok:\n'
                '• Tentukan tanggal berhenti yang spesifik\n'
                '• Beritahu keluarga dan minta dukungan mereka\n'
                '• Hindari pemicu (kopi, alkohol, situasi stres)\n'
                '• Konsultasi dokter untuk nicotine replacement therapy\n\n'
                'Alkohol:\n'
                '• Lebih baik dihindari sepenuhnya\n'
                '• Kalori tinggi → memperburuk obesitas\n'
                '• Bisa menyebabkan hipoglikemia jika minum tanpa makan',
            image: 'assets/images/img_rokok.png',
          ),
        ],
      ),
      EdukasiModel(
        id: 'edu_6',
        title: 'Pencegahan Diabetes',
        color: 'yellow',
        image: 'assets/images/edu_pencegahan.png',
        description:
            'Diabetes Tipe 2 adalah penyakit yang DAPAT DICEGAH. Studi Diabetes Prevention Program membuktikan perubahan gaya hidup menurunkan risiko diabetes hingga 58%.',
        sections: [
          EdukasiSectionModel(
            title: 'Kenali Faktor Risiko Anda',
            summary:
                'Usia > 45 tahun, obesitas, riwayat keluarga, dan kurang gerak adalah faktor risiko utama.',
            detail:
                'Faktor risiko yang TIDAK bisa diubah (tapi perlu diwaspadai):\n'
                '• Usia ≥ 45 tahun\n'
                '• Riwayat keluarga diabetes\n'
                '• Riwayat diabetes gestasional\n'
                '• PCOS pada wanita\n'
                '• Etnis Asia memiliki risiko lebih tinggi\n\n'
                'Faktor risiko yang BISA diubah (fokus di sini!):\n'
                '• Kelebihan berat badan / obesitas\n'
                '• Kurang aktivitas fisik\n'
                '• Pola makan tinggi gula\n'
                '• Merokok aktif\n'
                '• Kurang tidur (< 6 jam/malam)\n'
                '• Stres kronis\n'
                '• Hipertensi dan kolesterol tinggi',
            image: 'assets/images/img_risikocheck.png',
          ),
          EdukasiSectionModel(
            title: 'Target Penurunan Berat Badan',
            summary:
                'Turunkan 7% berat badan awal. Ini terbukti paling efektif mencegah diabetes.',
            detail:
                'Hasil studi DPP (Diabetes Prevention Program):\n'
                'Peserta yang menurunkan 7% berat badan + olahraga 150 menit/minggu '
                'berhasil menurunkan risiko diabetes sebesar 58%!\n\n'
                'Cara menghitung target:\n'
                '• Berat badan 80 kg → target turun 5,6 kg\n'
                '• Berat badan 70 kg → target turun 4,9 kg\n\n'
                'Strategi penurunan berat badan sehat:\n'
                '• Kurangi 300–500 kkal per hari dari total asupan\n'
                '• Perbanyak sayuran dan protein di setiap makan\n'
                '• Kurangi karbohidrat sederhana dan gorengan\n'
                '• Target realistis: 0,5–1 kg per minggu',
            image: 'assets/images/img_timbangan.png',
          ),
          EdukasiSectionModel(
            title: 'Program Gerak 150 Menit/Minggu',
            summary:
                'Olahraga rutin adalah cara paling efektif meningkatkan sensitivitas insulin.',
            detail:
                'Olahraga bekerja seperti insulin alami — otot yang aktif menyerap glukosa '
                'dari darah tanpa butuh insulin.\n\n'
                'Program mingguan:\n'
                '• Senin: Jalan cepat 30 menit\n'
                '• Selasa: Latihan kekuatan\n'
                '• Rabu: Jalan cepat 30 menit\n'
                '• Kamis: Yoga atau peregangan\n'
                '• Jumat: Jalan cepat 30 menit\n'
                '• Sabtu: Olahraga favorit (berenang, bersepeda)\n'
                '• Minggu: Jalan santai bersama keluarga\n\n'
                'Tambahan harian tanpa gym:\n'
                '• Jalan 10.000 langkah per hari\n'
                '• Naik tangga, bukan lift\n'
                '• Berdiri dan peregangan tiap 30 menit duduk',
            image: 'assets/images/img_jogging.png',
          ),
          EdukasiSectionModel(
            title: 'Skrining Rutin — Deteksi Dini',
            summary:
                'Semua orang ≥ 45 tahun wajib skrining. Usia lebih muda jika ada faktor risiko.',
            detail:
                'Banyak penderita diabetes tidak sadar kondisinya selama bertahun-tahun.\n\n'
                'Siapa yang harus skrining segera?\n'
                '• Semua orang usia ≥ 45 tahun\n'
                '• Usia < 45 tahun jika: BMI ≥ 23, riwayat keluarga diabetes, '
                'hipertensi, kolesterol abnormal, atau PCOS\n\n'
                'Frekuensi skrining:\n'
                '• Hasil normal: skrining ulang tiap 3 tahun\n'
                '• Prediabetes: skrining ulang tiap 6–12 bulan\n'
                '• Faktor risiko tinggi: tiap tahun\n\n'
                'Pemeriksaan yang dilakukan:\n'
                '• Gula darah puasa (GDP)\n'
                '• HbA1c\n'
                '• Tes toleransi glukosa oral',
            image: 'assets/images/cek_rutin.png',
          ),
          EdukasiSectionModel(
            title: 'Balik dari Prediabetes ke Normal',
            summary:
                'Prediabetes BISA kembali normal. Tindakan dalam 12 minggu pertama sangat menentukan.',
            detail:
                'Prediabetes bukan vonis mati — ini adalah kesempatan emas untuk berbalik arah.\n\n'
                'Rencana aksi 12 minggu untuk penderita prediabetes:\n'
                '• Minggu 1–4: Ubah pola makan (kurangi karbo putih, perbanyak sayur)\n'
                '• Minggu 5–8: Tambahkan olahraga 30 menit/hari\n'
                '• Minggu 9–12: Benahi pola tidur dan kelola stres\n\n'
                'Monitor kemajuan:\n'
                '• Konsultasi rutin tiap 3 bulan dengan dokter\n'
                '• Pantau HbA1c setiap 3–6 bulan\n'
                '• Catat berat badan setiap minggu\n\n'
                'Kabar baiknya: Banyak orang berhasil menurunkan HbA1c dari zona '
                'prediabetes kembali ke normal dalam 3–6 bulan!',
            image: 'assets/images/img_prediabetes.png',
          ),
        ],
      ),
    ];
  }
}