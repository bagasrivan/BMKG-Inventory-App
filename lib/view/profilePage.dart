import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  // Definisi warna BMKG yang konsisten dengan halaman lain
  static const Color bmkgBlue = Color(0xFF0D47A1);
  static const Color bmkgLightBlue = Color(0xFF1976D2);

  // Data profil pengguna
  final Map<String, String> _userData = {
    'name': 'Bagaskara',
    'role': 'Developer yang Ganteng',
  };

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar untuk responsif
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: bmkgBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              _showLogoutDialog(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header profile dengan gradient background
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [bmkgBlue, bmkgLightBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
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
                  const SizedBox(height: 20),
                  // Profile Image
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: isSmallScreen ? 60 : 80,
                      backgroundImage: const AssetImage('assets/profile.png'),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // User name
                  Text(
                    'Hai, ${_userData['name']}!',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  // Role badge
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _userData['role']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Options cards section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                  
                  // Account options section
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Text(
                      'Akun & Keamanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: bmkgBlue,
                      ),
                    ),
                  ),
                  
                  // Account options cards
                  Card(
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildActionItem(
                          icon: Icons.person_outline,
                          iconColor: bmkgBlue,
                          title: 'Edit Profil',
                          onTap: () {
                            // Navigate to edit profile
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur Edit Profil akan segera tersedia'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionItem(
                          icon: Icons.lock_outline,
                          iconColor: bmkgBlue,
                          title: 'Ubah Kata Sandi',
                          onTap: () {
                            // Navigate to change password
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur Ubah Kata Sandi akan segera tersedia'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionItem(
                          icon: Icons.security_outlined,
                          iconColor: bmkgBlue,
                          title: 'Keamanan Akun',
                          onTap: () {
                            // Navigate to security settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur Keamanan Akun akan segera tersedia'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Additional options
                  Card(
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildActionItem(
                          icon: Icons.help_outline,
                          iconColor: Colors.orange,
                          title: 'Bantuan',
                          onTap: () {
                            // Navigate to help page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur Bantuan akan segera tersedia'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionItem(
                          icon: Icons.info_outline,
                          iconColor: Colors.green,
                          title: 'Tentang Aplikasi',
                          onTap: () {
                            _showAboutAppDialog();
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionItem(
                          icon: Icons.logout_rounded,
                          iconColor: Colors.red,
                          title: 'Keluar',
                          onTap: () {
                            _showLogoutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Footer
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        '© 2025 BMKG Inventory System',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Item widget
  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Dialog logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(color: bmkgBlue),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
  
  // Dialog about app
  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tentang Aplikasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset('assets/logo-splash.png'),
              ),
              const SizedBox(height: 16),
              const Text(
                'BMKG Inventory System',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Versi 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Aplikasi sistem inventaris dan monitoring barang untuk Badan Meteorologi, Klimatologi, dan Geofisika.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '© 2025 BMKG Indonesia. All Rights Reserved.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Tutup',
                style: TextStyle(color: bmkgBlue),
              ),
            ),
          ],
        );
      },
    );
  }
}