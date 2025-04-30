import 'package:bmkg_inventory_system/view/addPage.dart';
import 'package:bmkg_inventory_system/view/returnPage.dart';
import 'package:bmkg_inventory_system/view/takePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  // Definisi warna BMKG yang konsisten dengan login
  static const Color bmkgBlue = Color(0xFF0D47A1);
  static const Color bmkgLightBlue = Color(0xFF1976D2);

  // Variabel untuk menyimpan statistik barang
  int totalBarang = 0;
  int barangTersedia = 0;
  int barangDipinjam = 0;

  // Variabel untuk nama pengguna
  String _username = "Pengguna";

  // Timer untuk refresh berkala
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchBarangData();
    _loadUsername();

    // Atur timer untuk refresh setiap 30 detik
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchBarangData();
    });
  }

  // Memuat nama pengguna dari SharedPreferences
  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Pengguna';
    });
  }

  @override
  void dispose() {
    // Batalkan timer saat widget di-dispose
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchBarangData() async {
    try {
      final response = await http.get(
        Uri.parse('http://api-bmkg.athaland.my.id/api/barang'),
      );

      if (response.statusCode == 200) {
        // Parse JSON response
        List<dynamic> barangList = json.decode(response.body);

        // Cek apakah widget masih ada sebelum setState
        if (mounted) {
          setState(() {
            // Hitung total barang
            totalBarang = barangList.length;

            // Hitung barang tersedia
            barangTersedia = barangList
                .where((barang) => barang['status'] == 'tersedia')
                .length;

            // Hitung barang dipinjam (diasumsikan status selain 'tersedia' adalah dipinjam)
            barangDipinjam = barangList
                .where((barang) => barang['status'] == 'terpinjam')
                .length;
          });
        }
      } else {
        // Tangani error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat data: ${response.statusCode}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Tangani error koneksi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error koneksi: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    List<String> months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    String basicGreeting;
    if (hour < 12)
      basicGreeting = "Selamat Pagi";
    else if (hour < 15)
      basicGreeting = "Selamat Siang";
    else if (hour < 18)
      basicGreeting = "Selamat Sore";
    else
      basicGreeting = "Selamat Malam";

    return "$basicGreeting, $_username!";
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
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              getFormattedDate(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
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
                            '$totalBarang',
                            'Total\nBarang',
                            Icons.inventory,
                            Colors.white,
                          ),
                          _buildStatCard(
                            '$barangTersedia',
                            'Barang\nTersedia',
                            Icons.check_circle,
                            Colors.white,
                          ),
                          _buildStatCard(
                            '$barangDipinjam',
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

                // Kelola Inventory (sama seperti sebelumnya)
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
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
                                MaterialPageRoute(
                                    builder: (context) => const AddPage()));
                          },
                        ),

                        const SizedBox(height: 5),
                        const Divider(),
                        const SizedBox(height: 5),

                        _buildMenuButton(
                          icon: Icons.edit_note,
                          title: 'Pengambilan ATK',
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const TakePage()));
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
                                MaterialPageRoute(
                                    builder: (context) => const ReturnPage()));
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
  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
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
  Widget _buildMenuButton(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
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
}
