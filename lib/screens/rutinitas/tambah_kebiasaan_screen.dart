import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/rutinitas_model.dart';

class TambahKebiasaanScreen extends StatefulWidget {
  const TambahKebiasaanScreen({super.key});

  @override
  State<TambahKebiasaanScreen> createState() => _TambahKebiasaanScreenState();
}

class _TambahKebiasaanScreenState extends State<TambahKebiasaanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaAktivitasController = TextEditingController();

  String _selectedJenisAktivitas = 'Harian';
  int _pengulangan = 1;
  TimeOfDay _waktuSekali = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _waktuMingguan = const TimeOfDay(hour: 8, minute: 0);
  DateTime _tanggalSekali = DateTime.now();
  final List<TimeOfDay> _waktuHarian = [
    const TimeOfDay(hour: 8, minute: 0),
  ];

  final List<String> _allDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  final List<String> _daysDisplay = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min',
  ];
  final List<String> _selectedDays = ['Monday', 'Wednesday', 'Friday'];

  bool _enableNotifikasi = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _namaAktivitasController.dispose();
    super.dispose();
  }

  void _addWaktuHarian() {
    setState(() {
      _waktuHarian.add(const TimeOfDay(hour: 12, minute: 0));
    });
  }

  void _removeWaktuHarian(int index) {
    if (_waktuHarian.length > 1) {
      setState(() => _waktuHarian.removeAt(index));
    }
  }

  Future<void> _selectTimeHarian(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _waktuHarian[index],
    );
    if (picked != null) {
      setState(() => _waktuHarian[index] = picked);
    }
  }

  Future<void> _selectTimeSekali() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _waktuSekali,
    );
    if (picked != null) {
      setState(() => _waktuSekali = picked);
    }
  }

  Future<void> _selectTimeMingguan() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _waktuMingguan,
    );
    if (picked != null) {
      setState(() => _waktuMingguan = picked);
    }
  }

  Future<void> _selectTanggalSekali() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalSekali,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _tanggalSekali = picked);
    }
  }

  void _setPengulangan(int value) {
    setState(() {
      _pengulangan = value;
      while (_waktuHarian.length < value) {
        _waktuHarian.add(const TimeOfDay(hour: 12, minute: 0));
      }
      while (_waktuHarian.length > value) {
        _waktuHarian.removeLast();
      }
    });
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
        _selectedDays.sort(
            (a, b) => _allDays.indexOf(a).compareTo(_allDays.indexOf(b)));
      }
    });
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);

    List<String> times = [];
    List<String>? selectedDays;
    DateTime? dueDate;
    List<ChecklistItem> checklistItems = [];

    if (_selectedJenisAktivitas == 'Harian') {
      times = _waktuHarian
          .map((t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
          .toList();
      checklistItems = List.generate(
        times.length,
        (i) => ChecklistItem(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}_${i + 1}',
          title: 'Selesai pukul ${times[i]}',
        ),
      );
    } else if (_selectedJenisAktivitas == 'Sekali') {
      times = [
        '${_waktuSekali.hour.toString().padLeft(2, '0')}:${_waktuSekali.minute.toString().padLeft(2, '0')}'
      ];
      dueDate = _tanggalSekali;
      checklistItems = [
        ChecklistItem(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Selesai pukul ${times.first}',
        ),
      ];
    } else if (_selectedJenisAktivitas == 'Mingguan') {
      times = [
        '${_waktuMingguan.hour.toString().padLeft(2, '0')}:${_waktuMingguan.minute.toString().padLeft(2, '0')}'
      ];
      selectedDays = _selectedDays;
      checklistItems = [
        ChecklistItem(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Selesai pukul ${times.first}',
        ),
      ];
    }

    final newRutinitas = RutinitasModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: _namaAktivitasController.text.trim(),
      description: 'Kebiasaan pribadi - $_selectedJenisAktivitas',
      color: 'blue',
      isDefault: false,
      frequency: _selectedJenisAktivitas.toLowerCase(),
      repetition: _selectedJenisAktivitas == 'Harian' ? _pengulangan : null,
      times: times,
      selectedDays: selectedDays,
      dueDate: dueDate,
      enableNotification: _enableNotifikasi,
      checklistItems: checklistItems,
    );

    // FIX: Tidak ada schedule notifikasi di sini sama sekali.
    // Notifikasi akan dijadwalkan oleh _setupNotifications di
    // rutinitas_harian_screen setelah routine ini ditambah ke list,
    // sehingga index-nya konsisten dan tidak ada ID yang bentrok.

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.pop(context, newRutinitas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Kebiasaan\nBaru',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Aktivitas
                      TextFormField(
                        controller: _namaAktivitasController,
                        decoration: InputDecoration(
                          hintText: 'Nama Aktivitas',
                          hintStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.textHint,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama aktivitas tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Jenis Aktivitas
                      const Text(
                        'Jenis Aktivitas',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildJenisButton('Harian'),
                          const SizedBox(width: 12),
                          _buildJenisButton('Sekali'),
                          const SizedBox(width: 12),
                          _buildJenisButton('Mingguan'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Konten sesuai jenis aktivitas
                      if (_selectedJenisAktivitas == 'Harian') ...[
                        const Text(
                          'Pengulangan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _pengulangan > 1
                                  ? () => _setPengulangan(_pengulangan - 1)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 36),
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                Text(
                                  '$_pengulangan',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'Kali Sehari',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              onPressed: _pengulangan < 10
                                  ? () => _setPengulangan(_pengulangan + 1)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline,
                                  size: 36),
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Atur Waktu',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              onPressed: _addWaktuHarian,
                              icon: const Icon(Icons.add_circle,
                                  color: AppColors.secondary),
                              iconSize: 28,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._waktuHarian.asMap().entries.map((entry) {
                          final index = entry.key;
                          final time = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: AppColors.white, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _selectTimeHarian(index),
                                      child: Text(
                                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_waktuHarian.length > 1)
                                    IconButton(
                                      onPressed: () =>
                                          _removeWaktuHarian(index),
                                      icon: const Icon(Icons.delete_outline,
                                          color: AppColors.white),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ] else if (_selectedJenisAktivitas == 'Sekali') ...[
                        const Text(
                          'Tanggal Aktivitas',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _selectTanggalSekali,
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: AppColors.grey, width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    color: AppColors.primary, size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  '${_tanggalSekali.day.toString().padLeft(2, '0')}/${_tanggalSekali.month.toString().padLeft(2, '0')}/${_tanggalSekali.year}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Waktu Reminder',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: AppColors.white, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: _selectTimeSekali,
                                  child: Text(
                                    '${_waktuSekali.hour.toString().padLeft(2, '0')}:${_waktuSekali.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: AppColors.grey, width: 1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: AppColors.textSecondary, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Reminder hanya akan muncul 1 kali pada waktu yang ditentukan',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_selectedJenisAktivitas == 'Mingguan') ...[
                        const Text(
                          'Pilih Hari',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              List.generate(_allDays.length, (index) {
                            final day = _allDays[index];
                            final dayDisplay = _daysDisplay[index];
                            final isSelected =
                                _selectedDays.contains(day);
                            return GestureDetector(
                              onTap: () => _toggleDay(day),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    dayDisplay,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Waktu Aktivitas',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: AppColors.white, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: _selectTimeMingguan,
                                  child: Text(
                                    '${_waktuMingguan.hour.toString().padLeft(2, '0')}:${_waktuMingguan.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: AppColors.grey, width: 1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: AppColors.textSecondary, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Jam yang sama akan diterapkan pada semua hari yang dipilih',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Opsi Notifikasi
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Ingatkan saya lewat notifikasi',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Switch(
                              value: _enableNotifikasi,
                              onChanged: (value) =>
                                  setState(() => _enableNotifikasi = value),
                              activeThumbColor: AppColors.success,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Tombol Batal & Simpan
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: OutlinedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed:
                                    _isSaving ? null : _handleSimpan,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  disabledBackgroundColor:
                                      AppColors.primary.withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: AppColors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Simpan',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJenisButton(String jenis) {
    final isSelected = _selectedJenisAktivitas == jenis;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedJenisAktivitas = jenis),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.grey,
              width: 1,
            ),
          ),
          child: Text(
            jenis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}