import 'package:bmkg_inventory_system/view/addPage.dart';
import 'package:bmkg_inventory_system/view/homePage.dart';
import 'package:bmkg_inventory_system/view/inventoryPage.dart';
import 'package:bmkg_inventory_system/view/profilePage.dart';
import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  // Definisi warna BMKG yang konsisten dengan halaman lain
  static const Color bmkgBlue = Color(0xFF0D47A1);

  final List<Widget> _pages = [
    const HomePage(),
    const InventoryPage(),
    const ProfilePage(),
  ];

  // Label dan ikon untuk tab
  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': Icons.dashboard_rounded,
      'activeIcon': Icons.dashboard_rounded,
      'label': 'Dashboard',
    },
    {
      'icon': Icons.inventory_2_outlined,
      'activeIcon': Icons.inventory_2_rounded,
      'label': 'Inventory',
    },
    {
      'icon': Icons.person_outline_rounded,
      'activeIcon': Icons.person_rounded,
      'label': 'Profil',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: bmkgBlue,
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            selectedIconTheme: const IconThemeData(
              size: 28,
            ),
            unselectedIconTheme: const IconThemeData(
              size: 24,
            ),
            elevation: 0,
            showUnselectedLabels: true,
            items: _tabs.map((tab) {
              final int index = _tabs.indexOf(tab);
              final bool isSelected = _selectedIndex == index;
              return BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      Icon(
                        isSelected ? tab['activeIcon'] : tab['icon'],
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 4,
                          width: 20,
                          decoration: BoxDecoration(
                            color: bmkgBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                    ],
                  ),
                ),
                label: tab['label'],
              );
            }).toList(),
          ),
        ),
      ),
      // Floating Action Button (opsional)
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showQuickActionMenu();
              },
              backgroundColor: bmkgBlue,
              elevation: 4,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  // Menampilkan menu aksi cepat untuk halaman Dashboard
  void _showQuickActionMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildQuickActionButton(
                icon: Icons.assignment_add,
                label: 'Peminjaman Barang',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AddPage()));
                },
              ),
              _buildQuickActionButton(
                icon: Icons.assignment_return,
                label: 'Pengembalian Barang',
                onTap: () {
                  Navigator.pop(context);
                  // Navigasi ke halaman pengembalian
                },
              ),
              _buildQuickActionButton(
                icon: Icons.qr_code_scanner,
                label: 'Scan Kode QR',
                onTap: () {
                  Navigator.pop(context);
                  // Navigasi ke halaman scan
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget untuk tombol aksi cepat
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bmkgBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: bmkgBlue,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
