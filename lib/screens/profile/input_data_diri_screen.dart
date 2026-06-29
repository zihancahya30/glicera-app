import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';

class InputDataDiriScreen extends StatefulWidget {
  const InputDataDiriScreen({super.key});

  @override
  State<InputDataDiriScreen> createState() => _InputDataDiriScreenState();
}

class _InputDataDiriScreenState extends State<InputDataDiriScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usiaController = TextEditingController();
  final _beratBadanController = TextEditingController();
  final _tinggiBadanController = TextEditingController();
  
  String? _selectedJenisKelamin;
  String? _selectedRiwayatDiabetes;
  bool _isLoading = false;

  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _riwayatDiabetesOptions = ['Ada', 'Tidak Ada', 'Tidak Tahu'];

  @override
  void initState() {
    super.initState();
    _checkUserAuth();
  }

  // CEK USER AUTH SAAT SCREEN DIBUKA
  Future<void> _checkUserAuth() async {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) {
      // User tidak login, redirect ke login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi berakhir. Silakan login kembali.'),
            backgroundColor: AppColors.error,
          ),
        );
        
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _usiaController.dispose();
    _beratBadanController.dispose();
    _tinggiBadanController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      // Validasi dropdown jenis kelamin
      if (_selectedJenisKelamin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih jenis kelamin'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      // Validasi dropdown riwayat diabetes
      if (_selectedRiwayatDiabetes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih riwayat keluarga diabetes'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      
      try {
        // Get current user
        final user = Supabase.instance.client.auth.currentUser;
        
        // CRITICAL: Cek lagi apakah user masih login
        if (user == null) {
          setState(() => _isLoading = false);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesi berakhir. Silakan login kembali.'),
                backgroundColor: AppColors.error,
              ),
            );
            
            // Redirect ke login
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
          return;
        }

        // Parse input values
        final usia = int.tryParse(_usiaController.text);
        final beratBadan = double.tryParse(_beratBadanController.text);
        final tinggiBadan = double.tryParse(_tinggiBadanController.text);

        // Prepare data to save
        final nama = user.userMetadata?['nama'] as String?;
        final userData = {
          'id': user.id,
          if (nama != null && nama.isNotEmpty) 'nama': nama,
          'email': user.email ?? '',
          'usia': usia,
          'berat_badan': beratBadan,
          'tinggi_badan': tinggiBadan,
          'jenis_kelamin': _selectedJenisKelamin,
          'riwayat_keluarga': _selectedRiwayatDiabetes,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await Supabase.instance.client
            .from('users')
            .upsert(userData, onConflict: 'id');

        setState(() => _isLoading = false);
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil disimpan! Selamat datang di Glicera'),
              backgroundColor: AppColors.teal,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } on PostgrestException catch (e) {
        setState(() => _isLoading = false);
        
        if (mounted) {
          final errorMessage = e.code == '42501'
              ? 'Data belum bisa disimpan. Silakan login ulang lalu coba lagi.'
              : 'Gagal menyimpan data. Silakan coba lagi.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Terjadi kesalahan. Silakan coba lagi.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Disable back button
        actions: [
          // Logout button (opsional)
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar'),
                  content: const Text('Yakin ingin keluar? Data yang belum disimpan akan hilang.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await Supabase.instance.client.auth.signOut();
                if (!context.mounted) return;
                navigator.pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Profil Data Diri',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Lengkapi data diri untuk pengalaman terbaik',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Usia Field
                TextFormField(
                  controller: _usiaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Usia (tahun)',
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
                    if (value == null || value.isEmpty) {
                      return 'Usia tidak boleh kosong';
                    }
                    final usia = int.tryParse(value);
                    if (usia == null) {
                      return 'Usia harus berupa angka';
                    }
                    if (usia < 1 || usia > 120) {
                      return 'Usia tidak valid (1-120 tahun)';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Berat Badan Field
                TextFormField(
                  controller: _beratBadanController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Masukkan Berat Badan (kg)',
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
                    if (value == null || value.isEmpty) {
                      return 'Berat badan tidak boleh kosong';
                    }
                    final berat = double.tryParse(value);
                    if (berat == null) {
                      return 'Berat badan harus berupa angka';
                    }
                    if (berat < 20 || berat > 300) {
                      return 'Berat badan tidak valid (20-300 kg)';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Tinggi Badan Field
                TextFormField(
                  controller: _tinggiBadanController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Masukkan Tinggi Badan (cm)',
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
                    if (value == null || value.isEmpty) {
                      return 'Tinggi badan tidak boleh kosong';
                    }
                    final tinggi = double.tryParse(value);
                    if (tinggi == null) {
                      return 'Tinggi badan harus berupa angka';
                    }
                    if (tinggi < 100 || tinggi > 250) {
                      return 'Tinggi badan tidak valid (100-250 cm)';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Jenis Kelamin Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedJenisKelamin,
                  decoration: InputDecoration(
                    hintText: 'Jenis Kelamin',
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
                  items: _jenisKelaminOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedJenisKelamin = newValue;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Riwayat Keluarga Diabetes Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedRiwayatDiabetes,
                  decoration: InputDecoration(
                    hintText: 'Riwayat Keluarga Diabetes',
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
                  items: _riwayatDiabetesOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRiwayatDiabetes = newValue;
                    });
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            'Simpan & Lanjutkan',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info text
                const Text(
                  'Data Anda akan disimpan dengan aman dan hanya digunakan untuk keperluan aplikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
