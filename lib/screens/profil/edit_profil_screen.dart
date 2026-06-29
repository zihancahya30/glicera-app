import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _usiaController;
  late TextEditingController _beratController;
  late TextEditingController _tinggiController;

  UserModel? _currentUser;
  String? _jenisKelamin;
  String? _riwayatKeluarga;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _usiaController = TextEditingController();
    _beratController = TextEditingController();
    _tinggiController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      
      if (user == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final userData = await _authService.getUserData(user.id);

      if (userData != null) {
        setState(() {
          _currentUser = userData;
          _namaController.text = userData.nama;
          _usiaController.text = userData.usia?.toString() ?? '';
          _beratController.text = userData.beratBadan?.toString() ?? '';
          _tinggiController.text = userData.tinggiBadan?.toString() ?? '';
          _jenisKelamin = userData.jenisKelamin;
          _riwayatKeluarga = userData.riwayatKeluarga;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    _beratController.dispose();
    _tinggiController.dispose();
    super.dispose();
  }

  Future<void> _simpanProfil() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    final data = {
      'nama': _namaController.text.trim(),
      'usia': int.tryParse(_usiaController.text),
      'berat_badan': double.tryParse(_beratController.text),
      'tinggi_badan': double.tryParse(_tinggiController.text),
      'jenis_kelamin': _jenisKelamin,
      'riwayat_keluarga': _riwayatKeluarga,
    };

    final result = await _authService.updateProfile(
      uid: _currentUser!.uid,
      data: data,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: AppColors.teal,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Data pengguna tidak ditemukan'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usiaController,
                label: 'Usia',
                hint: 'Masukkan usia',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Usia tidak boleh kosong';
                  }
                  final usia = int.tryParse(value);
                  if (usia == null || usia < 1 || usia > 120) {
                    return 'Usia tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Jenis Kelamin',
                value: _jenisKelamin,
                items: const ['Laki-laki', 'Perempuan'],
                onChanged: (value) => setState(() => _jenisKelamin = value),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _beratController,
                label: 'Berat Badan (kg)',
                hint: 'Masukkan berat badan',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Berat badan tidak boleh kosong';
                  }
                  final berat = double.tryParse(value);
                  if (berat == null || berat < 20 || berat > 300) {
                    return 'Berat badan tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _tinggiController,
                label: 'Tinggi Badan (cm)',
                hint: 'Masukkan tinggi badan',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tinggi badan tidak boleh kosong';
                  }
                  final tinggi = double.tryParse(value);
                  if (tinggi == null || tinggi < 100 || tinggi > 250) {
                    return 'Tinggi badan tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Riwayat Keluarga Diabetes',
                value: _riwayatKeluarga,
                items: const ['Ada', 'Tidak Ada', 'Tidak Tahu'],
                onChanged: (value) => setState(() => _riwayatKeluarga = value),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanProfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: onChanged,
            hint: const Text('Pilih'),
          ),
        ),
      ],
    );
  }
}
