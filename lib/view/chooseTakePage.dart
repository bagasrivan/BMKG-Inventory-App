import 'dart:math';

import 'package:bmkg_inventory_system/view/scanPage.dart';
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
  final int stok;
  final String? qr;

  InventoryItem({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.status,
    required this.gudang,
    required this.kategori,
    required this.stok,
    this.qr,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    // Untuk debugging
    print("Parsing item: ${json['id']} - ${json['nama']}");

    // Konversi id ke int, dengan mempertimbangkan jika id berbentuk string
    int itemId;
    if (json['id'] is int) {
      itemId = json['id'];
    } else if (json['id'] is String) {
      try {
        itemId = int.parse(json['id']);
      } catch (e) {
        print("Error parsing id string to int: ${json['id']}");
        itemId = 0; // Default value
      }
    } else {
      itemId = 0;
    }

    // Handle null atau empty values dengan nilai default yang aman
    return InventoryItem(
      id: itemId,
      nama: json['nama'] ?? 'Barang Tidak Bernama',
      gambar: json['gambar'] ?? '',
      status: json['status'] ?? 'Tidak Tersedia',
      gudang: json['gudang'] ?? 'Tidak Diketahui',
      kategori: json['kategori'] ?? 'Umum',
      stok: json['stok'] is int ? json['stok'] : 0, // Default stok 0 jika tidak ada
      qr: json['qr']?.toString(),
    );
  }
}

class ChooseTakePage extends StatefulWidget {
  const ChooseTakePage({super.key});

  @override
  _ChooseTakeState createState() => _ChooseTakeState();
}

class _ChooseTakeState extends State<ChooseTakePage> {
  // Definisi warna BMKG yang konsisten dengan halaman lain
  static const Color bmkgBlue = Color(0xFF0D47A1);
  static const Color bmkgLightBlue = Color(0xFF1976D2);

  List<String> categories = ["Tersedia", "Semua Barang"];
  String selectedCategory = "Tersedia";
  List<Map<String, dynamic>> selectedItems = []; // Simpan id, nama, dan jumlah barang

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInventoryItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://api-bmkg.athaland.my.id/api/barang/ambil'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Debug untuk melihat response
      print("API Response status: ${response.statusCode}");
      print(
          "API Response body: ${response.body.substring(0, min(100, response.body.length))}...");

      if (response.statusCode == 200) {
        try {
          // Coba parse JSON dengan error handling yang lebih baik
          final dynamic jsonData = json.decode(response.body);

          // Periksa tipe data dari jsonData
          if (jsonData is List) {
            // Jika response adalah List, proses secara normal
            setState(() {
              items = jsonData.map((item) {
                try {
                  return InventoryItem.fromJson(item);
                } catch (e) {
                  print("Error parsing item: $e");
                  print("Item data: $item");
                  // Return item default jika parsing gagal
                  return InventoryItem(
                    id: 0,
                    nama:
                        "Error: ${e.toString().substring(0, min(20, e.toString().length))}...",
                    gambar: '',
                    status: 'Tidak Tersedia',
                    gudang: 'Unknown',
                    kategori: 'Unknown',
                    stok: 0,
                  );
                }
              }).toList();

              _filterItems();
              _isLoading = false;
            });
          } else if (jsonData is Map<String, dynamic>) {
            // Jika response adalah Object/Map, periksa apakah ada properti data atau results
            if (jsonData.containsKey('data') && jsonData['data'] is List) {
              setState(() {
                items = (jsonData['data'] as List)
                    .map((item) => InventoryItem.fromJson(item))
                    .toList();
                _filterItems();
                _isLoading = false;
              });
            } else if (jsonData.containsKey('results') &&
                jsonData['results'] is List) {
              setState(() {
                items = (jsonData['results'] as List)
                    .map((item) => InventoryItem.fromJson(item))
                    .toList();
                _filterItems();
                _isLoading = false;
              });
            } else {
              // Jika tidak ditemukan format yang dikenal, tampilkan error
              throw Exception('Format data API tidak dikenali');
            }
          } else {
            throw Exception('Format response API tidak valid');
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Gagal mem-parsing data: ${e.toString()}';
            _isLoading = false;
          });
          print("Error parsing JSON: ${e.toString()}");
          print("Response body: ${response.body}");
        }
      } else {
        throw Exception(
            'Gagal memuat data inventaris: HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
      });
      print("Network error: ${e.toString()}");
    }
  }

  void _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanPage()),
    );
    if (result != null) {
      setState(() {
        _searchController.text = result;
      });
    }
  }

  void _onComplete() {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silahkan pilih minimal satu barang'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
    } else {
      Navigator.pop(context, selectedItems);
    }
  }

  void _showQuantityDialog(InventoryItem item) {
    int quantity = 1; // Default quantity

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Pilih Jumlah ${item.nama}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Stok tersedia: ${item.stok}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: bmkgBlue,
                        onPressed: quantity > 1
                            ? () {
                                setState(() {
                                  quantity--;
                                });
                              }
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: bmkgBlue,
                        onPressed: quantity < item.stok
                            ? () {
                                setState(() {
                                  quantity++;
                                });
                              }
                            : null,
                      ),
                    ],
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
                    'Batal',
                    style: TextStyle(color: bmkgBlue),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bmkgBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Tambahkan item ke daftar dengan jumlahnya
                    this.setState(() {
                      selectedItems.add({
                        'id': item.id,
                        'nama': item.nama,
                        'jumlah': quantity,
                      });
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Konfirmasi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      filteredItems = items.where((item) {
        bool matchesCategory = selectedCategory == "Semua Barang" ||
            (item.status.toLowerCase() == "tersedia" && item.stok > 0);
        bool matchesSearch = item.nama.toLowerCase().contains(query);

        return matchesCategory && matchesSearch;
      }).toList();

      // Urutkan barang yang tersedia ke atas
      filteredItems.sort((a, b) {
        if (a.status.toLowerCase() == "tidak tersedia" ||
            a.stok == 0 && b.status.toLowerCase() == "tersedia" && b.stok > 0) {
          return 1;
        } else if (a.status.toLowerCase() == "tersedia" && a.stok > 0 &&
            (b.status.toLowerCase() == "tidak tersedia" || b.stok == 0)) {
          return -1;
        }
        return 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pilih Barang ATK',
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
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
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
                        style: const TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: _fetchInventoryItems,
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header dengan informasi dan search
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: bmkgLightBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.inventory_2,
                                  color: bmkgLightBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Pilih Barang ATK',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: bmkgBlue,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Pilih barang ATK yang akan diambil',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Search field
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Cari nama barang atau scan barcode',
                              prefixIcon:
                                  const Icon(Icons.search, color: bmkgBlue),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.qr_code_scanner,
                                    color: bmkgBlue),
                                onPressed: _scanBarcode,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: bmkgBlue, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Kategori chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: selectedCategory == category,
                              selectedColor: bmkgLightBlue.withOpacity(0.2),
                              backgroundColor: Colors.grey[100],
                              labelStyle: TextStyle(
                                color: selectedCategory == category
                                    ? bmkgBlue
                                    : Colors.grey,
                                fontWeight: selectedCategory == category
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedCategory = category;
                                  _filterItems();
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Daftar Barang
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: filteredItems.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 64,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tidak ada barang ditemukan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  var item = filteredItems[index];
                                  // Cek apakah item sudah dipilih
                                  bool isSelected = selectedItems
                                      .any((element) => element['id'] == item.id);

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    elevation: 1,
                                    shadowColor: Colors.black.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(12),
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: bmkgLightBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Image.network(
                                          item.gambar,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey[400],
                                            );
                                          },
                                        ),
                                      ),
                                      title: Text(
                                        item.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.category,
                                                size: 14,
                                                color: bmkgLightBlue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                item.kategori,
                                                style:
                                                    const TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: bmkgLightBlue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                item.gudang,
                                                style:
                                                    const TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.inventory,
                                                size: 14,
                                                color: bmkgLightBlue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Stok: ${item.stok}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: item.stok > 0
                                                      ? Colors.green[700]
                                                      : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: item.status.toLowerCase() ==
                                                  "tidak tersedia" ||
                                              item.stok <= 0
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Tidak Tersedia',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isSelected
                                                    ? bmkgLightBlue
                                                        .withOpacity(0.2)
                                                    : bmkgBlue,
                                                foregroundColor: isSelected
                                                    ? bmkgBlue
                                                    : Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: item.status
                                                              .toLowerCase() ==
                                                          "tidak tersedia" ||
                                                      item.stok <= 0
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        if (isSelected) {
                                                          // Hapus item dari daftar
                                                          selectedItems.removeWhere(
                                                              (element) =>
                                                                  element['id'] ==
                                                                  item.id);
                                                        } else {
                                                          // Tampilkan dialog pemilihan jumlah
                                                          _showQuantityDialog(item);
                                                        }
                                                      });
                                                    },
                                              child: Text(
                                                isSelected ? 'Batal' : 'Pilih',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),

                    // Footer dengan tombol selesai
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${selectedItems.length}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: bmkgBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Jenis Barang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (selectedItems.isNotEmpty)
                                Text(
                                  'Total: ${selectedItems.fold(0, (sum, item) => sum + (item['jumlah'] as int))} item',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _onComplete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bmkgBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Selesai',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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