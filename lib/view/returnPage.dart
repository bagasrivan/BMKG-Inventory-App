import 'dart:async';
import 'dart:io';
import 'package:bmkg_inventory_system/controller/navigation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  _ReturnState createState() => _ReturnState();
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

  // Fetch borrowed items from API
  Future<void> _fetchBorrowedItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Add authentication token if required
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // More robust API call with timeout and error handling
      final response = await http.get(
        Uri.parse('http://api-bmkg.athaland.my.id/api/barang/statusPinjam'),
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

        // Multiple strategies to extract items
        List<dynamic> items = _extractItemsFromResponse(responseBody);

        if (items.isNotEmpty) {
          setState(() {
            borrowedItems = items.map((item) {
              return _mapToBorrowedItem(item);
            }).toList();
          });
        } else {
          // Specific handling for empty data
          setState(() {
            borrowedItems = [];
          });

          _showCustomSnackBar(
            message: 'Tidak ada barang yang sedang dipinjam',
            color: Colors.orange,
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

// Ekstrak items dari berbagai struktur response
  List<dynamic> _extractItemsFromResponse(dynamic responseBody) {
    // Daftar kemungkinan field yang mungkin berisi items
    final possibleFields = [
      'data',
      'items',
      'result',
      'results',
      'borrowed_items',
      'list'
    ];

    // Coba ekstrak items dari field yang mungkin
    if (responseBody is List) return responseBody;

    if (responseBody is Map) {
      for (var field in possibleFields) {
        if (responseBody[field] is List && responseBody[field].isNotEmpty) {
          return responseBody[field];
        }
      }
    }

    return [];
  }

// Mapping yang lebih fleksibel untuk BorrowedItem
// Mapping yang lebih fleksibel untuk BorrowedItem
  BorrowedItem _mapToBorrowedItem(dynamic item) {
    // Pastikan item adalah Map
    final itemMap = item is Map ? item : {};

    // Definisi field-field yang mungkin
    final possibleIdFields = ['id', 'barang_id', 'item_id', 'ID'];
    final possibleNameFields = ['nama', 'nama_barang', 'item_name', 'name'];
    final possibleDateFields = [
      'tanggal_pinjam',
      'tanggal',
      'date',
      'borrow_date'
    ];
    final possibleLocationFields = ['lokasi', 'location'];
    final possibleBorrowerFields = [
      'nama_peminjam',
      'peminjam',
      'borrower',
      'user_name'
    ];

    // Perbaikan fungsi extractId
    int extractId() {
      for (var field in possibleIdFields) {
        if (itemMap.containsKey(field)) {
          dynamic idValue = itemMap[field];

          // Handle different possible types of ID
          if (idValue == null) continue;

          // Jika sudah int, langsung kembalikan
          if (idValue is int) return idValue;

          // Jika string, coba parsing
          if (idValue is String) {
            int? parsedId = int.tryParse(idValue);
            if (parsedId != null) return parsedId;
          }

          // Jika double, konversi ke int
          if (idValue is double) {
            return idValue.toInt();
          }
        }
      }

      // Generate hash unik jika tidak ada ID valid
      return itemMap.hashCode.abs();
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
      id: extractId(),
      name: extractField(possibleNameFields),
      borrowedDate: extractDate(),
      location: extractField(possibleLocationFields),
      borrowerName: extractField(possibleBorrowerFields),
      condition: "Baik", // Default condition
      notes: "",
      isSelected: false,
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
      color: Colors.green,
    );

    // Optional: Log the full error response for debugging
    print('Error Response Body: ${response.body}');
  }

  // Validasi form
  void _validateForm() {
    setState(() {
      _isFormValid = selectedItems.isNotEmpty &&
          selectedItems.every((item) => item.condition.isNotEmpty);
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
                                Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: Text(
                                    "Kondisi: ${item.condition}",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: item.condition == "Rusak"
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.w500),
                                  ),
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
                child: const Text('Konfirmasi'),
              ),
            ],
          );
        });
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
        print('Item ID: ${item.id}, Name: ${item.name}');
      }

      // Kumpulkan ID barang yang akan dikembalikan
      final barangIds = selectedItems.map((item) => item.id).toList();

      // Kirim request ke API dengan struktur baru
      final requestBody = {"daftar_barang": barangIds};

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

        // Navigasi ke halaman utama (HomePage) dan hapus semua rute sebelumnya
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Navigation()),
            (Route<dynamic> route) => false);
      } else {
        // Error dari server
        String errorMessage =
            responseBody['message'] ?? 'Gagal mengembalikan barang';

        // Tampilkan pesan error dari server
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Navigation()),
            (Route<dynamic> route) => false);
      }
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

                        // Tanggal Pengembalian
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
                                                        item.name,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
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
                                            ),
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
              backgroundColor: bmkgBlue,
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
              selectedItems.add(item);
            }
            _validateForm();
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              // Condition selection (only show if item is selected)
              if (isSelected) ...[
                const Divider(height: 20),
                const Text(
                  "Kondisi Barang:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: bmkgBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildConditionRadio(
                        selectedItems.indexWhere(
                            (selectedItem) => selectedItem.id == item.id),
                        "Baik"),
                    const SizedBox(width: 16),
                    _buildConditionRadio(
                        selectedItems.indexWhere(
                            (selectedItem) => selectedItem.id == item.id),
                        "Rusak"),
                  ],
                ),

                // Notes field (if condition is "Rusak")
                if (selectedItems.any((selectedItem) =>
                    selectedItem.id == item.id &&
                    selectedItem.condition == "Rusak"))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        "Catatan:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: bmkgBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            final index = selectedItems.indexWhere(
                                (selectedItem) => selectedItem.id == item.id);
                            if (index != -1) {
                              selectedItems[index] =
                                  selectedItems[index].copyWith(notes: value);
                              _validateForm();
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Deskripsikan kerusakan barang",
                          hintStyle:
                              TextStyle(fontSize: 13, color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: bmkgBlue),
                          ),
                        ),
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
              ],
            ],
          ),
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

// Helper function to extract value from different possible field names
dynamic _extractValue(Map<String, dynamic> item, List<String> possibleKeys) {
  for (var key in possibleKeys) {
    if (item.containsKey(key) && item[key] != null) {
      return item[key];
    }
  }
  return null;
}

// Kelas model untuk item yang dipinjam
class BorrowedItem {
  final int id;
  final String name;
  final DateTime borrowedDate;
  final String location;
  final String borrowerName;
  final String condition;
  final String notes;
  final bool isSelected;

  BorrowedItem({
    required this.id,
    required this.name,
    required this.borrowedDate,
    required this.location,
    required this.borrowerName,
    required this.condition,
    required this.notes,
    required this.isSelected,
  });

  BorrowedItem copyWith({
    int? id,
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
