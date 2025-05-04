import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:bmkg_inventory_system/controller/navigation.dart';
import 'dart:convert';

// Assuming this is defined elsewhere in your app
const Color bmkgBlue = Color(0xFF0D47A1);
const Color bmkgLightBlue = Color(0xFF2196F3);

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _usernameController.text = prefs.getString('username') ?? '';

      // Perbaikan di sini - pastikan user_id selalu string
      var rawUserId = prefs.get('user_id');
      if (rawUserId != null) {
        // Konversi ke string apapun tipe aslinya
        _userId = rawUserId.toString();
      } else {
        _userId = '';
      }

      // If user_id is not found, try to get it from another source or show an error
      if (_userId.isEmpty) {
        // You might need to fetch the user ID from your backend if not stored locally
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Peringatan: ID pengguna tidak ditemukan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memuat data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if user ID is available
    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID pengguna tidak tersedia')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare request body
      final Map<String, String> requestBody = {
        'username': _usernameController.text.trim(),
      };

      // Only include password if it's been changed
      if (_passwordController.text.isNotEmpty) {
        requestBody['password'] = _passwordController.text;
      }

      // API call to update profile
      final response = await http.put(
        Uri.parse('http://api-bmkg.athaland.my.id/api/update?id=$_userId'),
        headers: {
          'Content-Type': 'application/json',
          // Add any required authorization headers here
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Parse response
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          // Update shared preferences with new username
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', _usernameController.text.trim());

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );

          // Go back to profile page
          Navigator.pop(context, true); // Pass true to indicate success
        } else {
          // Show error message from API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(responseData['message'] ?? 'Gagal memperbarui profil'),
              backgroundColor: Colors.green,
            ),
          );
        }
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Navigation()),
            (Route<dynamic> route) => false);
      } else {
        // Handle HTTP error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: bmkgBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: bmkgBlue),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [bmkgBlue, bmkgLightBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: bmkgBlue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.edit_note_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Perbarui Informasi Profil',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Perbarui username dan kata sandi untuk akun BMKG Inventory System',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Edit Form
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section header
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 24,
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: bmkgBlue,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Informasi Akun',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: bmkgBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Username field
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'Masukkan username baru',
                                  prefixIcon:
                                      const Icon(Icons.person, color: bmkgBlue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: bmkgBlue, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Username tidak boleh kosong';
                                  }
                                  if (value.length < 4) {
                                    return 'Username minimal 4 karakter';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Password divider
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 24,
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Kata Sandi (Opsional)',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Kata Sandi Baru',
                                  hintText:
                                      'Biarkan kosong jika tidak ingin mengubah',
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: bmkgBlue),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: bmkgBlue, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      value.length < 6) {
                                    return 'Kata sandi minimal 6 karakter';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Confirm password field
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  labelText: 'Konfirmasi Kata Sandi',
                                  hintText: 'Konfirmasi kata sandi baru',
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: bmkgBlue),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: bmkgBlue, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (_passwordController.text.isNotEmpty) {
                                    if (value == null || value.isEmpty) {
                                      return 'Konfirmasi kata sandi diperlukan';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Kata sandi tidak cocok';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bmkgBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    // Cancel button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 12),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
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
}
