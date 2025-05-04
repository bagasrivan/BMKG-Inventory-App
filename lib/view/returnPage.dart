import 'dart:async';
import 'dart:io';
import 'package:bmkg_inventory_system/controller/navigation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({Key? key}) : super(key: key);

  @override
  _ReturnState createState() => _ReturnState();
}

class BorrowedItem {
  final int id; // This is the borrowing/loan ID
  final int barangId; // This is the actual item/barang ID
  final String name;
  final DateTime borrowedDate;
  final String location;
  final String borrowerName;
  final String condition;
  final String notes;
  final bool isSelected;

  BorrowedItem({
    required this.id,
    required this.barangId,
    required this.name,
    required this.borrowedDate,
    required this.location,
    required this.borrowerName,
    required this.condition,
    required this.notes,
    this.isSelected = false,
  });

  BorrowedItem copyWith({
    int? id,
    int? barangId,
    String? name,
    DateTime? borrowedDate,
    String? location,
    String? borrowerName,
    String? condition,
    String? notes,
    bool? isSelected,
  }) {
    return BorrowedItem(
      id: id ?? this.id,
      barangId: barangId ?? this.barangId,
      name: name ?? this.name,
      borrowedDate: borrowedDate ?? this.borrowedDate,
      location: location ?? this.location,
      borrowerName: borrowerName ?? this.borrowerName,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class _ReturnState extends State<ReturnPage> {
  // Definisi warna BMKG yang konsisten dengan halaman lain
  static const Color bmkgBlue = Color(0xFF0D47A1);
  static const Color bmkgLightBlue = Color(0xFF1976D2);

  String _loggedInUserName = "Memuat...";
  int _userId = 0;
  DateTime returnDate = DateTime.now();
  List<BorrowedItem> borrowedItems = [];
  List<BorrowedItem> selectedItems = [];
  bool _isFormValid = false;
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Tambahkan variabel untuk gudang
  String _selectedWarehouse = "Tata Usaha"; // Default value

  // Tetapkan nilai default gudang yang akan selalu tersedia
  final List<String> _defaultWarehouses = [
    "Tata Usaha",
    "Radar",
    "Operasional"
  ];
  List<String> _warehouseOptions = ["Tata Usaha", "Radar", "Operasional"];

  // Nama bulan dalam bahasa Indonesia
  final List<String> _namabulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  // Metode untuk menggabungkan gudang dari API dengan gudang default
  List<String> _mergeWarehouses(List<dynamic> items) {
    final Set<String> uniqueWarehouses = _defaultWarehouses.toSet();

    // Tambahkan gudang dari API jika ada
    for (var item in items) {
      if (item is Map && item['gudang'] != null) {
        uniqueWarehouses.add(item['gudang'].toString());
      }
    }

    return uniqueWarehouses.toList();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchBorrowedItems();
    });
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInUserName = prefs.getString('username') ?? 'Pengguna';
      _userId = prefs.getInt('user_id') ?? 0;
    });
  }

  // Perbaikan pada metode _fetchBorrowedItems()
  Future<void> _fetchBorrowedItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Add authentication token if required
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // PERBAIKAN: Tambahkan ID user ke URL API
      final userId = prefs.getInt('user_id') ?? 0;

      // Pastikan userId disertakan dalam URL API
      final response = await http.get(
        Uri.parse(
            'http://api-bmkg.athaland.my.id/api/barang/peminjam?id_user=$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10), // Add a timeout
        onTimeout: () {
          throw TimeoutException('Koneksi internet lambat. Silakan coba lagi.');
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      // More comprehensive status code handling
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is List) {
          setState(() {
            borrowedItems = responseBody.map((item) {
              return _mapToBorrowedItem(item);
            }).toList();

            // Merge warehouses from API with default warehouses
            _warehouseOptions = _mergeWarehouses(responseBody);

            // Set default warehouse ke pilihan pertama jika sebelumnya tidak valid
            if (!_warehouseOptions.contains(_selectedWarehouse) &&
                _warehouseOptions.isNotEmpty) {
              _selectedWarehouse = _warehouseOptions.first;
            }
          });

          if (borrowedItems.isEmpty) {
            _showCustomSnackBar(
              message: 'Tidak ada barang yang sedang dipinjam',
              color: Colors.orange,
            );
          }
        } else {
          _showCustomSnackBar(
            message: 'Format data tidak valid',
            color: Colors.red,
          );
        }
      } else {
        // More detailed error handling based on status code
        _handleApiError(response);
      }
    } on SocketException catch (_) {
      _showCustomSnackBar(
        message: 'Tidak ada koneksi internet. Periksa jaringan Anda.',
        color: Colors.red,
      );
    } on TimeoutException catch (_) {
      _showCustomSnackBar(
        message: 'Koneksi timeout. Silakan coba lagi.',
        color: Colors.red,
      );
    } catch (e) {
      _showCustomSnackBar(
        message: 'Gagal memuat data: ${e.toString()}',
        color: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  BorrowedItem _mapToBorrowedItem(dynamic item) {
    // Pastikan item adalah Map
    final itemMap = item is Map ? item : <String, dynamic>{};

    // Define possible field names
    final possibleLoanIdFields = ['id', 'peminjaman_id', 'loan_id', 'ID'];
    final possibleItemIdFields = ['barang_id', 'item_id', 'id_barang'];
    final possibleNameFields = ['nama', 'nama_barang', 'item_name', 'name'];
    final possibleDateFields = [
      'tanggal_pinjam',
      'tanggal',
      'date',
      'borrow_date'
    ];
    final possibleLocationFields = ['lokasi', 'location', 'gudang'];
    final possibleBorrowerFields = [
      'nama_peminjam',
      'peminjam',
      'borrower',
      'user_name'
    ];

    // Extract loan ID (ID peminjaman)
    int extractLoanId() {
      for (var field in possibleLoanIdFields) {
        if (itemMap.containsKey(field)) {
          dynamic idValue = itemMap[field];
          if (idValue == null) continue;
          if (idValue is int) return idValue;
          if (idValue is String) {
            int? parsedId = int.tryParse(idValue);
            if (parsedId != null) return parsedId;
          }
          if (idValue is double) {
            return idValue.toInt();
          }
        }
      }
      return itemMap.hashCode.abs();
    }

    // Extract barang ID (ID barang)
    int extractItemId() {
      for (var field in possibleItemIdFields) {
        if (itemMap.containsKey(field)) {
          dynamic idValue = itemMap[field];
          if (idValue == null) continue;
          if (idValue is int) return idValue;
          if (idValue is String) {
            int? parsedId = int.tryParse(idValue);
            if (parsedId != null) return parsedId;
          }
          if (idValue is double) {
            return idValue.toInt();
          }
        }
      }
      return 0; // Default if no item ID found
    }

    String extractField(List<String> possibleFields,
        {String defaultValue = 'Tidak Diketahui'}) {
      for (var field in possibleFields) {
        if (itemMap.containsKey(field) && itemMap[field] != null) {
          return itemMap[field].toString();
        }
      }
      return defaultValue;
    }

    DateTime extractDate() {
      for (var field in possibleDateFields) {
        if (itemMap.containsKey(field) && itemMap[field] != null) {
          try {
            return DateTime.parse(itemMap[field].toString());
          } catch (_) {
            // Abaikan jika parsing gagal
          }
        }
      }
      return DateTime.now();
    }

    return BorrowedItem(
      id: extractLoanId(),
      barangId: extractItemId(),
      name: extractField(possibleNameFields),
      borrowedDate: extractDate(),
      location: extractField(possibleLocationFields),
      borrowerName: extractField(possibleBorrowerFields),
      condition: "Baik", // Default condition
      notes: "",
    );
  }

  // Penanganan error API yang lebih detail
  void _handleApiError(http.Response response) {
    String errorMessage;

    switch (response.statusCode) {
      case 404:
        errorMessage = 'Data tidak ditemukan';
        break;
      case 500:
        errorMessage = 'Kesalahan server internal';
        break;
      case 403:
        errorMessage = 'Akses ditolak';
        break;
      case 401:
        errorMessage = 'Tidak terautentikasi';
        break;
      default:
        errorMessage = 'Gagal memuat data: Kode status ${response.statusCode}';
    }

    _showCustomSnackBar(
      message: errorMessage,
      color: Colors.red,
    );

    // Optional: Log the full error response for debugging
    print('Error Response Body: ${response.body}');
  }

  // Validasi form
  void _validateForm() {
    setState(() {
      _isFormValid = selectedItems.isNotEmpty &&
          selectedItems.every((item) => item.condition.isNotEmpty) &&
          _selectedWarehouse.isNotEmpty; // Tambahkan validasi gudang
    });
  }

  // Format tanggal manual ke dalam bahasa Indonesia
  String _formatTanggal(DateTime date) {
    return "${date.day} ${_namabulan[date.month - 1]} ${date.year}";
  }

  // Dialog konfirmasi submit
  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pengembalian'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Apakah data pengembalian sudah benar?"),
                const SizedBox(height: 16),
                _buildConfirmationInfoRow(
                  label: "Peminjam",
                  value: _loggedInUserName,
                ),
                _buildConfirmationInfoRow(
                  label: "Tanggal Kembali",
                  value: _formatTanggal(returnDate),
                ),
                _buildConfirmationInfoRow(
                  label: "Gudang Tujuan",
                  value: _selectedWarehouse,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Barang yang dikembalikan:",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                ...selectedItems
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.circle,
                                      size: 6, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(item.name)),
                                ],
                              ),
                              if (item.notes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: Text(
                                    "Catatan: ${item.notes}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Periksa Kembali',
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
                Navigator.of(context).pop();
                _submitForm();
              },
              child: const Text('Konfirmasi',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Layout info konfirmasi
  Widget _buildConfirmationInfoRow(
      {required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    // Tambahkan pengecekan mounted
    if (!mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Log informasi barang yang akan dikembalikan
      print('Selected Items for Return:');
      for (var item in selectedItems) {
        print(
            'Loan ID: ${item.id}, Item ID: ${item.barangId}, Name: ${item.name}');
      }

      // Kumpulkan ID PEMINJAMAN (bukan ID barang) yang akan dikembalikan
      final loanIds = selectedItems.map((item) => item.id).toList();

      // Kirim request ke API dengan struktur baru termasuk gudang
      final requestBody = {
        "id_user": _userId,
        "daftar_barang": loanIds, // Menggunakan ID peminjaman, bukan ID barang
        "gudang": _selectedWarehouse
      };

      // Tambahkan token otorisasi jika diperlukan
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Kirim request ke API
      final response = await http.post(
        Uri.parse('http://api-bmkg.athaland.my.id/api/kembalimulti'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('Return Response Status: ${response.statusCode}');
      print('Return Response Body: ${response.body}');

      // Parsing response body
      final responseBody = json.decode(response.body);

      // Cek status response dan pesan dari server
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Berhasil mengembalikan barang
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(responseBody['message'] ?? 'Pengembalian barang berhasil'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Error dari server
        String errorMessage =
            responseBody['message'] ?? 'Gagal mengembalikan barang';

        // Tampilkan pesan error dari server
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor:
                  Colors.green, // Changed from green to red for error messages
            ),
          );
        }
      }
      Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Navigation()),
            (Route<dynamic> route) => false);
    } catch (e) {
      print('Form Submission Error: $e');

      // Tampilkan pesan error yang lebih informatif
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengembalikan barang: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Tambahkan method helper untuk menampilkan snackbar kustom
  void _showCustomSnackBar({
    required String message,
    Color color = Colors.red,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
                color == Colors.green
                    ? Icons.check_circle
                    : (color == Colors.orange ? Icons.warning : Icons.error),
                color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pengembalian Barang',
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
          ? _buildLoadingScreen()
          : Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _fetchBorrowedItems,
                  color: bmkgBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Header dengan informasi
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
                                      Icons.assignment_return,
                                      color: bmkgLightBlue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Form Pengembalian Barang',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: bmkgBlue,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Pilih barang yang akan dikembalikan',
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
                            ],
                          ),
                        ),

                        // Tanggal Pengembalian dan Gudang Tujuan
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Card(
                            elevation: 2,
                            shadowColor: Colors.black.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFormLabel("Tanggal Pengembalian"),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            color: bmkgBlue),
                                        const SizedBox(width: 12),
                                        Text(
                                          _formatTanggal(DateTime
                                              .now()), // Selalu gunakan tanggal hari ini
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Dropdown untuk Gudang Tujuan - Selalu menampilkan 3 pilihan
                                  const SizedBox(height: 20),
                                  _buildFormLabel("Gudang Terakhir"),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      color: Colors.white,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: _selectedWarehouse,
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: bmkgBlue),
                                        items: _defaultWarehouses
                                            .map((String warehouse) {
                                          return DropdownMenuItem<String>(
                                            value: warehouse,
                                            child: Row(
                                              children: [
                                                const Icon(Icons.warehouse,
                                                    color: bmkgBlue, size: 20),
                                                const SizedBox(width: 12),
                                                Text(
                                                  warehouse,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedWarehouse = newValue!;
                                            _validateForm();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Daftar Barang yang Dipinjam
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, bottom: 8),
                                child: Text(
                                  "Barang yang Sedang Dipinjam",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              if (borrowedItems.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 40,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tidak ada barang yang sedang dipinjam',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Semua barang sudah dikembalikan',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: borrowedItems.length,
                                  itemBuilder: (context, index) {
                                    return _buildBorrowedItemCard(index);
                                  },
                                ),
                              if (selectedItems.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: bmkgLightBlue.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: bmkgLightBlue.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Barang yang akan dikembalikan (${selectedItems.length})",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: bmkgBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...selectedItems
                                          .map((item) => Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0,
                                                    top: 4,
                                                    bottom: 4),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.check_circle,
                                                        size: 16,
                                                        color: Colors.green),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        item.name, // Only shows the item name, not the user
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Tombol Submit
                        if (selectedItems.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isFormValid && !_isSubmitting
                                        ? _confirmSubmit
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: bmkgBlue,
                                      disabledBackgroundColor: Colors.grey[300],
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : const Text(
                                            'Proses Pengembalian',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                  ),
                                ),

                                // Footer
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: Text(
                                      'Pastikan kondisi barang diperiksa dengan teliti',
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

                        // Additional padding at the bottom
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Loading overlay saat submit
                if (_isSubmitting)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: bmkgBlue,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Memproses pengembalian barang...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: borrowedItems.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                _fetchBorrowedItems();
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }

  // Widget untuk tampilan loading
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: bmkgBlue,
          ),
          const SizedBox(height: 20),
          Text(
            "Memuat data barang yang dipinjam...",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk kartu item peminjaman
  Widget _buildBorrowedItemCard(int index) {
    final item = borrowedItems[index];
    final isSelected =
        selectedItems.any((selectedItem) => selectedItem.id == item.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? bmkgBlue.withOpacity(0.5) : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            // Toggle item selection
            if (isSelected) {
              selectedItems
                  .removeWhere((selectedItem) => selectedItem.id == item.id);
            } else {
              selectedItems.add(item.copyWith(condition: "Baik", notes: ""));
            }
            _validateForm();
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? bmkgBlue.withOpacity(0.2)
                        : bmkgLightBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.inventory_2,
                    color: isSelected ? bmkgBlue : bmkgLightBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: isSelected ? bmkgBlue : Colors.black87,
                        ),
                      ),
                      Text(
                        "ID Barang: ${item.id}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.green : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Information about the borrowing
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  item.borrowerName,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  item.location,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  "Dipinjam: ${_formatTanggal(item.borrowedDate)}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  // Widget radio button kondisi
  Widget _buildConditionRadio(int index, String value) {
    if (index == -1) return const SizedBox(); // Safety check

    return InkWell(
      onTap: () {
        setState(() {
          selectedItems[index] = selectedItems[index].copyWith(
              condition: value,
              notes: value == "Baik" ? "" : selectedItems[index].notes);
          _validateForm();
        });
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: selectedItems[index].condition,
            activeColor: value == "Baik" ? Colors.green : Colors.red,
            onChanged: (newValue) {
              setState(() {
                selectedItems[index] = selectedItems[index].copyWith(
                    condition: newValue!,
                    notes:
                        newValue == "Baik" ? "" : selectedItems[index].notes);
                _validateForm();
              });
            },
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: selectedItems[index].condition == value
                  ? (value == "Baik" ? Colors.green : Colors.red)
                  : Colors.grey[700],
              fontWeight: selectedItems[index].condition == value
                  ? FontWeight.w500
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk label form
  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: bmkgBlue,
      ),
    );
  }
}
