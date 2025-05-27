import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<dynamic> borrowedItems = [];
  bool isLoading = true;
  bool isError = false;
  String? errorMessage;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Ambil user ID dari SharedPreferences
  void _loadUserId() async {
    print("Mulai load user_id");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? storedUserId = prefs.getInt('user_id');
      print("Hasil get user_id: $storedUserId");

      if (storedUserId != null && storedUserId > 0) {
        setState(() {
          userId = storedUserId;
        });
        print("User ID yang akan digunakan: $userId");
        fetchBorrowedItems();
      } else {
        print("user_id null atau tidak valid");
        setState(() {
          isError = true;
          isLoading = false;
          errorMessage = "ID pengguna tidak ditemukan. Silakan login ulang.";
        });
      }
    } catch (e) {
      print("Error saat mengambil user_id: $e");
      setState(() {
        isError = true;
        isLoading = false;
        errorMessage = "Gagal mengambil data pengguna: ${e.toString()}";
      });
    }
  }

  // Fetch data dari API berdasarkan userId
  Future<void> fetchBorrowedItems() async {
    if (userId == null || userId! <= 0) {
      setState(() {
        isError = true;
        isLoading = false;
        errorMessage = "ID pengguna tidak valid";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        isError = false;
        errorMessage = null;
      });

      final apiUrl =
          'http://api-bmkg.athaland.my.id/api/barang/peminjam?id_user=$userId';
      print("🔍 DEBUGGING API CALL");
      print("📍 Full URL: $apiUrl");
      print("👤 User ID: $userId");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Flutter-App/1.0',
        },
      ).timeout(const Duration(seconds: 30));

      print("\n📊 RESPONSE STATUS & HEADERS:");
      print("Status Code: ${response.statusCode}");
      print("Reason Phrase: ${response.reasonPhrase}");

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) {
          print("⚠️ SUCCESS BUT EMPTY BODY - mungkin tidak ada data");
          setState(() {
            borrowedItems = [];
            isLoading = false;
            isError = false;
          });
          return;
        }

        try {
          final jsonResponse = json.decode(response.body);
          print("\n✅ JSON PARSING SUCCESS:");
          print("JSON Type: ${jsonResponse.runtimeType}");

          List<dynamic> items = [];

          if (jsonResponse is List) {
            items = jsonResponse;
          } else if (jsonResponse is Map<String, dynamic>) {
            // Handle various possible response structures
            if (jsonResponse.containsKey('data')) {
              var data = jsonResponse['data'];
              items = data is List ? data : [data];
            } else if (jsonResponse.containsKey('result')) {
              var result = jsonResponse['result'];
              items = result is List ? result : [result];
            } else if (jsonResponse.containsKey('items')) {
              items = jsonResponse['items'] is List
                  ? jsonResponse['items']
                  : [jsonResponse['items']];
            }
          }

          print("\n📦 PARSED ITEMS:");
          print("Items count: ${items.length}");

          setState(() {
            borrowedItems = items;
            isLoading = false;
            isError = false;
          });
        } catch (jsonError) {
          print("\n❌ JSON PARSING ERROR: $jsonError");
          setState(() {
            isError = true;
            isLoading = false;
            errorMessage = "Format data tidak valid: $jsonError";
          });
        }
      } else {
        print("\n❌ HTTP ERROR:");
        print("Status: ${response.statusCode}");

        setState(() {
          isError = true;
          isLoading = false;
          errorMessage =
              "Server error (${response.statusCode}): ${response.body}";
        });
      }
    } catch (e) {
      print('\n💥 NETWORK ERROR: $e');
      setState(() {
        isError = true;
        isLoading = false;
        errorMessage = "Koneksi error: ${e.toString()}";
      });
    }
  }

  Future<void> _refreshData() async {
    await fetchBorrowedItems();
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';

    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        appBar: null,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
              ),
              SizedBox(height: 16),
              Text(
                "Memuat data peminjaman...",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (isError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Barang Dipinjam"),
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  "Terjadi Kesalahan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ?? "Gagal memuat data",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (userId == null) {
                          _loadUserId();
                        } else {
                          _refreshData();
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Coba Lagi"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (borrowedItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Barang Dipinjam"),
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: Colors.grey,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                "Tidak Ada Peminjaman",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Anda belum meminjam barang apapun",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Barang Dipinjam (${borrowedItems.length})"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF0D47A1),
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: borrowedItems.length,
          itemBuilder: (context, index) {
            final item = borrowedItems[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with item name and status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D47A1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.inventory,
                            color: Color(0xFF0D47A1),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nama']?.toString() ??
                                    'Nama Barang Tidak Tersedia',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "ID: ${item['id']?.toString() ?? '-'}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item['status']?.toString()),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getStatusText(item['status']?.toString()),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Item details
                    if (item['kategori'] != null) ...[
                      _buildDetailRow(Icons.category, "Kategori",
                          item['kategori'].toString()),
                      const SizedBox(height: 8),
                    ],

                    if (item['gudang'] != null) ...[
                      _buildDetailRow(Icons.location_on, "Lokasi",
                          item['gudang'].toString()),
                      const SizedBox(height: 8),
                    ],

                    if (item['detail'] != null &&
                        item['detail'].toString().isNotEmpty) ...[
                      _buildDetailRow(Icons.info_outline, "Detail",
                          item['detail'].toString()),
                      const SizedBox(height: 8),
                    ],

                    // Show image if available
                    if (item['gambar'] != null &&
                        item['gambar'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['gambar'].toString(),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 48,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'terpinjam':
      case 'dipinjam':
      case 'borrowed':
        return Colors.green;
      case 'pending_pengembalian':
      case 'pending':
      case 'waiting':
        return Colors.orange;
      case 'ditolak':
      case 'rejected':
        return Colors.red;
      case 'dikembalikan':
      case 'returned':
        return Colors.blue;
      case 'terlambat':
      case 'overdue':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    if (status == null) return 'Unknown';

    switch (status.toLowerCase()) {
      case 'terpinjam':
        return 'Terpinjam';
      case 'pending_pengembalian':
        return 'Pending Kembali';
      case 'dipinjam':
      case 'borrowed':
        return 'Dipinjam';
      case 'pending':
      case 'waiting':
        return 'Pending';
      case 'ditolak':
      case 'rejected':
        return 'Ditolak';
      case 'dikembalian':
      case 'returned':
        return 'Dikembalikan';
      case 'terlambat':
      case 'overdue':
        return 'Terlambat';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }
}
