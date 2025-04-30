import 'package:bmkg_inventory_system/view/chooseTakePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TakePage extends StatefulWidget {
  const TakePage({super.key});

  @override
  _TakeState createState() => _TakeState();
}

class _TakeState extends State<TakePage> {
  // Definisi warna BMKG yang konsisten dengan halaman lain
  static const Color bmkgBlue = Color(0xFF0D47A1);
  static const Color bmkgLightBlue = Color(0xFF1976D2);

  String? selectedLocation;
  String _loggedInUserName = "Memuat..."; // Default value while loading
  int _userId = 0; // Menyimpan ID user yang login
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> selectedItems = []; // Ubah ke Map untuk menyimpan nama, ID, dan jumlah
  bool _isFormValid = false;
  bool _isLoading = true;
  bool _isSubmitting = false; // Flag untuk proses submit

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

  final List<String> locations = ["Operasional", "Tata Usaha", "Radar"];

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Simulasi loading data
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInUserName = prefs.getString('username') ?? 'Pengguna';
      _userId = prefs.getInt('user_id') ?? 0; // Mengambil user_id dari SharedPreferences
      _validateForm(); // Validate form after loading username
    });
  }

  // Validasi form
  void _validateForm() {
    setState(() {
      _isFormValid = selectedLocation != null &&
          _loggedInUserName.isNotEmpty &&
          _loggedInUserName != "Memuat..." &&
          selectedItems.isNotEmpty;
    });
  }

  // Format tanggal manual ke dalam bahasa Indonesia
  String _formatTanggal(DateTime date) {
    return "${date.day} ${_namabulan[date.month - 1]} ${date.year}";
  }

  // Dialog konfirmasi hapus item
  void _confirmDelete(Map<String, dynamic> item) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Konfirmasi Hapus Barang'),
            content: const Text(
                "Apakah Anda yakin ingin menghapus barang ini dari daftar pengambilan?"),
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
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectedItems.remove(item);
                    _validateForm();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Hapus'),
              ),
            ],
          );
        });
  }

  // Dialog konfirmasi submit
  void _confirmSubmit() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Konfirmasi Pengambilan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Apakah data pengambilan sudah benar?"),
                const SizedBox(height: 16),
                _buildConfirmationInfoRow(
                  label: "Lokasi",
                  value: selectedLocation!,
                ),
                _buildConfirmationInfoRow(
                  label: "Pengambil",
                  value: _loggedInUserName,
                ),
                _buildConfirmationInfoRow(
                  label: "Tanggal Pinjam",
                  value: _formatTanggal(DateTime.now()),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Barang yang diambil:",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                ...selectedItems
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.circle,
                                  size: 6, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text("${item['nama']} (${item['jumlah']} item)"),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
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

  Widget _buildConfirmationInfoRow(
      {required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label + ":",
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

  // Submit form - Mengirim data ke API dengan format yang baru
  Future<void> _submitForm() async {
    // Cek jika user_id tidak valid
    if (_userId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text('ID User tidak valid, silakan login ulang'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Ekstrak ID barang dan jumlah yang dipilih
      List<int> itemIds = selectedItems.map<int>((item) => item['id'] as int).toList();
      List<int> itemJumlah = selectedItems.map<int>((item) => item['jumlah'] as int).toList();

      // Persiapkan data untuk dikirim ke API sesuai format yang diminta
      final requestBody = {
        "id_user": _userId,
        "id_barang": itemIds,
        "jumlah": itemJumlah
      };

      // Tampilkan data yang akan dikirim untuk keperluan debugging
      print("Sending data: ${jsonEncode(requestBody)}");

      // Kirim request ke API
      final response = await http.post(
        Uri.parse('http://api-bmkg.athaland.my.id/api/ambilmulti'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Debug response
      print("API Response status: ${response.statusCode}");
      print("API Response body: ${response.body}");

      // Cek status response
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 207) {
        // Sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Pengambilan barang berhasil disimpan'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigasi kembali ke halaman sebelumnya
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        });
      } else {
        // Error dari server
        Map<String, dynamic> errorResponse = jsonDecode(response.body);
        throw Exception(
            errorResponse['message'] ?? 'Gagal menyimpan pengambilan');
      }
    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Error: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Loading screen
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: bmkgBlue,
            backgroundColor: bmkgLightBlue.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: TextStyle(
              color: bmkgBlue,
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pengambilan Barang',
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
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                                    Icons.assignment_add,
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
                                        'Form Pengambilan Barang',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: bmkgBlue,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Silahkan isi pengambilan barang dengan lengkap',
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

                      // Form pengambilan
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
                                // Lokasi field
                                _buildFormLabel("Lokasi Pengambilan"),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: selectedLocation,
                                    hint: const Text("Pilih Lokasi"),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: bmkgBlue),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      border: InputBorder.none,
                                    ),
                                    isExpanded: true,
                                    items: locations
                                        .map((loc) => DropdownMenuItem(
                                            value: loc, child: Text(loc)))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLocation = value;
                                        _validateForm();
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Pengambil field (static with username already filled)
                                _buildFormLabel("Nama Pengambil"),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person, color: bmkgBlue),
                                      const SizedBox(width: 12),
                                      Text(
                                        _loggedInUserName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Tanggal Pinjam (STATIC - MODIFIED)
                                _buildFormLabel("Tanggal Pengambilan"),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    color: Colors.grey
                                        .shade50, // Background abu-abu muda untuk menunjukkan field tidak aktif
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          color: bmkgBlue),
                                      const SizedBox(width: 12),
                                      Text(
                                        _formatTanggal(DateTime.now()),
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Barang yang diambil
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildFormLabel("Barang yang Diambil"),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ChooseTakePage()));

                                        if (result != null) {
                                          // Mengubah format data yang diterima untuk menyimpan ID dan nama barang
                                          setState(() {
                                            selectedItems = result;
                                            _validateForm();
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text("Pilih Barang"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: bmkgBlue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Daftar barang yang dipilih
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedItems.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 4.0, bottom: 8.0),
                                child: Text(
                                  "${selectedItems.length} barang dipilih (${selectedItems.fold(0, (sum, item) => sum + (item['jumlah'] as int))} item)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),

                            selectedItems.isNotEmpty
                                ? ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: selectedItems.length,
                                    itemBuilder: (context, index) {
                                      final item = selectedItems[index];
                                      return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        elevation: 1,
                                        shadowColor:
                                            Colors.black.withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 8),
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: bmkgLightBlue
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.inventory_2,
                                              color: bmkgLightBlue,
                                            ),
                                          ),
                                          title: Text(
                                            item['nama'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Jumlah: ${item['jumlah']} item",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline),
                                            color: Colors.red,
                                            onPressed: () =>
                                                _confirmDelete(item),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(20),
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
                                          'Belum ada barang dipilih',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Silakan pilih barang yang akan diambil',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                            const SizedBox(height: 24),

                            // Tombol Submit
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
                                        'Simpan Pengambilan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                            // Footer
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'Pastikan data yang dimasukkan sudah benar',
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
                                'Menyimpan pengambilan...',
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
    );
  }
}