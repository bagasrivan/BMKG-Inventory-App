import 'package:bmkg_inventory_system/view/addPage.dart';
import 'package:bmkg_inventory_system/view/returnPage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  // Definisi warna BMKG yang konsisten dengan login
  static const Color bmkgBlue = Color(0xFF0D47A1);
  static const Color bmkgLightBlue = Color(0xFF1976D2);
  static const Color bmkgVeryLightBlue = Color(0xFFBBDEFB);
  
  String getFormattedDate() {
    DateTime now = DateTime.now();
    List<String> months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni", 
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar untuk responsif
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: bmkgBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20)
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Fungsi notifikasi di sini
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tidak ada notifikasi baru'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan salam
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 16, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getGreeting(),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: bmkgBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Selamat datang di Sistem Inventaris BMKG',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Dashboard Summary dengan shadow dan gradien
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [bmkgBlue, bmkgLightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: bmkgBlue.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tanggal dengan desain yang lebih modern
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, 
                          vertical: 8
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today, 
                              size: 16, 
                              color: Colors.white
                            ),
                            const SizedBox(width: 8),
                            Text(
                              getFormattedDate(),
                              style: const TextStyle(
                                fontSize: 14, 
                                color: Colors.white,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Statistik dengan desain card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(
                            '12', 
                            'Total\nBarang', 
                            Icons.inventory, 
                            Colors.white,
                          ),
                          _buildStatCard(
                            '8', 
                            'Barang\nTersedia', 
                            Icons.check_circle, 
                            Colors.white,
                          ),
                          _buildStatCard(
                            '4', 
                            'Barang\nDipinjam', 
                            Icons.pending_actions, 
                            Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Kelola Inventory
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                  shadowColor: Colors.grey.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header card
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: bmkgLightBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: bmkgLightBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Kelola Inventaris',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: bmkgBlue,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 5),
                        
                        // Menu Peminjaman
                        _buildMenuButton(
                          icon: Icons.assignment_add,
                          title: 'Peminjaman Barang',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddPage())
                            );
                          },
                        ),
                        
                        const SizedBox(height: 5),
                        const Divider(),
                        const SizedBox(height: 5),
                        
                        // Menu Pengembalian
                        _buildMenuButton(
                          icon: Icons.assignment_return,
                          title: 'Pengembalian Barang',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ReturnPage())
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

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
        ),
      ),
    );
  }
  
  // Widget untuk membuat card statistik
  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk membuat tombol menu
  Widget _buildMenuButton({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bmkgLightBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 24,
                color: bmkgLightBlue,
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
            const Icon(
              Icons.keyboard_arrow_right,
              color: bmkgBlue,
            )
          ],
        ),
      ),
    );
  }
  
  // Widget untuk membuat item aktivitas
  Widget _buildActivityItem(
    String title, 
    String person, 
    String time,
    IconData itemIcon
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bmkgLightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              itemIcon,
              size: 24,
              color: bmkgLightBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$person • $time',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}