import 'dart:math';
import 'package:bmkg_inventory_system/view/cartProvider.dart';
import 'package:bmkg_inventory_system/view/scanPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

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
      stok: json['stok'] is int ? json['stok'] : null,
      qr: json['qr']?.toString(),
    );
  }
}

class ChooseItemPage extends StatefulWidget {
  const ChooseItemPage({super.key});

  @override
  _ChooseItemState createState() => _ChooseItemState();
}

class _ChooseItemState extends State<ChooseItemPage> {
  // Definisi warna BMKG yang konsisten dengan halaman lain
  static const Color bmkgBlue = Color(0xFF0D47A1);
  static const Color bmkgLightBlue = Color(0xFF1976D2);

  List<String> categories = ["Tersedia", "Terpinjam"];
  String selectedCategory = "Tersedia";
  List<Map<String, dynamic>> selectedItems =
      []; // Ubah ke List<Map> untuk menyimpan id dan nama barang

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

  // Perbaikan fungsi _fetchInventoryItems() pada ChooseItemPage

  Future<void> _fetchInventoryItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://api-bmkg.athaland.my.id/api/barang/pinjam'),
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
                    status: 'Terpinjam',
                    gudang: 'Unknown',
                    kategori: 'Unknown',
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
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScanPage()),
      );

      print('Scanning result: $result'); // Debug print

      if (result != null) {
        // Cari barang berdasarkan QR/barcode
        final matchingItems = items.where((item) => item.qr == result).toList();

        print('Matching items: ${matchingItems.length}'); // Debug print

        if (matchingItems.isNotEmpty) {
          InventoryItem scannedItem = matchingItems.first;

          // Periksa status barang sebelum konfirmasi
          if (scannedItem.status.toLowerCase() == 'tersedia') {
            _confirmSelection(scannedItem);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Barang ${scannedItem.nama} terpinjam'),
              backgroundColor: Colors.orange,
            ));
          }
        } else {
          // Tampilkan dialog jika barang tidak ditemukan
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Barang dengan barcode $result tidak ditemukan'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      print('Error in scanning: $e'); // Error logging
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _onComplete() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (cartProvider.items.isEmpty) {
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
      // Kirim data barang yang dipilih
      Navigator.pop(context, cartProvider.items);
    }
  }

  // Modify the _confirmSelection method to update selectedItems:

  // Modify the _confirmSelection method to check for item availability:

  void _confirmSelection(InventoryItem item) {
    try {
      // First, check if the item is actually available
      if (item.status.toLowerCase() != "tersedia") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Barang ${item.nama} tidak tersedia untuk dipinjam'),
          backgroundColor: Colors.orange,
        ));
        return; // Exit the method early
      }

      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      print('Attempting to add item: ${item.nama}'); // Debug print

      // Cek apakah barang bisa ditambahkan
      if (cartProvider.canAddItem()) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi Pengambilan Barang'),
              content: Text('Apakah anda yakin ingin mengambil ${item.nama}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Create the item data
                    Map<String, dynamic> itemData = {
                      'id': item.id,
                      'nama': item.nama,
                    };

                    // Tambahkan barang ke keranjang
                    cartProvider.addItem(itemData);

                    // Update the selectedItems list in the state
                    setState(() {
                      selectedItems = List.from(cartProvider.items);
                    });

                    Navigator.of(context).pop();
                  },
                  child: const Text('Ya'),
                ),
              ],
            );
          },
        );
      } else {
        // Tampilkan pesan jika keranjang penuh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keranjang sudah penuh. Maksimal 10 barang.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in confirm selection: $e'); // Error logging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      // Filter items based on search and category
      filteredItems = items.where((item) {
        // Sesuaikan filter berdasarkan kategori yang dipilih
        bool matchesCategory = selectedCategory == "Tersedia"
            ? item.status.toLowerCase() == "tersedia"
            : item.status.toLowerCase() == "terpinjam";

        // Cocokkan dengan nama barang
        bool matchesQuery = item.nama.toLowerCase().contains(query);

        return matchesCategory && matchesQuery;
      }).toList();

      // Urutkan berdasar nama
      filteredItems.sort((a, b) => a.nama.compareTo(b.nama));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pilih Barang',
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
                                      'Pilih Barang',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: bmkgBlue,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Pilih barang yang akan dipinjam',
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
                        child: ListView.builder(
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
                                    errorBuilder: (context, error, stackTrace) {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.kategori,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: bmkgLightBlue,
                                        ),
                                        Text(
                                          item.gudang,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                trailing: item.status.toLowerCase() ==
                                        "terpinjam"
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          foregroundColor: Colors.grey[700],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed:
                                            null, // Tombol benar-benar tidak aktif
                                        child: const Text(
                                          'Terpinjam',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSelected
                                              ? bmkgLightBlue.withOpacity(0.2)
                                              : bmkgBlue,
                                          foregroundColor: isSelected
                                              ? bmkgBlue
                                              : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () {
                                          if (isSelected) {
                                            // Remove the item from the cart provider
                                            final cartProvider =
                                                Provider.of<CartProvider>(
                                                    context,
                                                    listen: false);
                                            cartProvider.removeItem(item.id);

                                            // Update the local selectedItems list
                                            setState(() {
                                              selectedItems =
                                                  List.from(cartProvider.items);
                                            });
                                          } else {
                                            // Only allow selection if item is available
                                            _confirmSelection(item);
                                          }
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
                          Row(
                            children: [
                              Text(
                                '${selectedItems.length}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: bmkgBlue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Barang',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
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
