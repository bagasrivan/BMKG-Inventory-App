import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryItem {
  final int id;
  final String nama;
  final String gambar;
  final String status;
  final String gudang;
  final String kategori;
  final int? stok;
  final String? qr;

  InventoryItem({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.status,
    required this.gudang,
    required this.kategori,
    this.stok,
    this.qr,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      nama: json['nama'],
      gambar: json['gambar'] ?? '',
      status: json['status'],
      gudang: json['gudang'],
      kategori: json['kategori'],
      stok: json['stok'],
      qr: json['qr'],
    );
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<InventoryPage> {
  // Definisi warna BMKG yang konsisten dengan halaman lain
  static const Color bmkgBlue = Color(0xFF0D47A1);

  List<String> categories = [
    "Semua",
    "Tersedia",
    "Tidak Tersedia",
    "Perkakas",
    "Alat Tulis",
    "Gudang Operasional",
    "Gudang Tata Usaha",
    "Gudang Stasiun"
  ];
  String selectedCategory = "Semua";

  List<InventoryItem> items = [];
  List<InventoryItem> filteredItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
    _fetchInventoryItems();
  }

  Future<void> _fetchInventoryItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://api-bmkg.athaland.my.id/api/barang'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          items = responseData
              .map((item) => InventoryItem.fromJson(item))
              .toList();
          _filterItems();
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data inventaris');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      filteredItems = items.where((item) {
        bool matchesCategory;

        if (selectedCategory == "Semua") {
          matchesCategory = true;
        } else if (selectedCategory == "Tersedia" ||
            selectedCategory == "Tidak Tersedia") {
          matchesCategory = item.status == selectedCategory.toLowerCase();
        } else {
          // Cek kategori atau gudang
          matchesCategory = 
            item.kategori == selectedCategory || 
            item.gudang == selectedCategory;
        }

        bool matchesSearch = item.nama.toLowerCase().contains(query);

        return matchesCategory && matchesSearch;
      }).toList();

      // Sort items - available first
      filteredItems.sort((a, b) {
        if (a.status == "tidak tersedia" && b.status == "tersedia") {
          return 1;
        } else if (a.status == "tersedia" && b.status == "tidak tersedia") {
          return -1;
        }
        return 0;
      });
    });
  }

  void _showItemDetails(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        bool isAvailable = item.status == 'tersedia';

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Barang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Gambar dan informasi
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.network(
                      item.gambar,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nama,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: TextStyle(
                              color: isAvailable ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.category, 
                          'Kategori', 
                          item.kategori
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.location_on, 
                          'Gudang', 
                          item.gudang
                        ),
                        if (item.stok != null)
                          const SizedBox(height: 8),
                        if (item.stok != null)
                          _buildInfoRow(
                            Icons.inventory, 
                            'Stok', 
                            item.stok.toString()
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Widget untuk baris informasi
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: bmkgBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: bmkgBlue,
            ),
          )
        : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: _fetchInventoryItems,
                    child: Text('Coba Lagi'),
                  )
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Search dan Filter
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari barang...',
                            prefixIcon: const Icon(Icons.search, color: bmkgBlue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: categories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: selectedCategory == category,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      selectedCategory = selected ? category : "Semua";
                                      _filterItems();
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Daftar Barang
                  Expanded(
                    child: filteredItems.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada barang ditemukan',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            var item = filteredItems[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16, 
                                vertical: 8
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(item.gambar),
                                  backgroundColor: Colors.transparent,
                                ),
                                title: Text(item.nama),
                                subtitle: Text(
                                  '${item.kategori} - ${item.gudang}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10, 
                                    vertical: 5
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.status == 'tersedia' 
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item.status.toUpperCase(),
                                    style: TextStyle(
                                      color: item.status == 'tersedia' 
                                        ? Colors.green 
                                        : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                onTap: () => _showItemDetails(item),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}