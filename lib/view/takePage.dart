import 'package:flutter/material.dart';

// Kelas model untuk item yang diambil
class TakeItem {
  final String id;
  final String name;
  final String unit;
  final int stock;
  final int quantity;

  TakeItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.stock,
    required this.quantity,
  });

  TakeItem copyWith({
    String? id,
    String? name,
    String? unit,
    int? stock,
    int? quantity,
  }) {
    return TakeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      quantity: quantity ?? this.quantity,
    );
  }
}

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
  final TextEditingController _userController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<TakeItem> selectedItems = [];
  bool _isFormValid = false;
  bool _isLoading = true;

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

  final List<String> locations = [
    "Operasional",
    "Tata Usaha",
    "Radar"
  ];

  // Daftar ATK yang tersedia (dummy data, nantinya bisa dari database)
  final List<Map<String, dynamic>> atkItems = [
    {"id": "ATK001", "name": "Kertas HVS A4 80gsm", "unit": "Rim", "stock": 25},
    {"id": "ATK002", "name": "Pulpen Hitam", "unit": "Pcs", "stock": 100},
    {"id": "ATK003", "name": "Pensil 2B", "unit": "Pcs", "stock": 50},
    {"id": "ATK004", "name": "Spidol Whiteboard", "unit": "Pcs", "stock": 30},
    {"id": "ATK005", "name": "Penghapus", "unit": "Pcs", "stock": 25},
    {"id": "ATK006", "name": "Map Plastik", "unit": "Pcs", "stock": 45},
    {"id": "ATK007", "name": "Stapler", "unit": "Pcs", "stock": 10},
    {"id": "ATK008", "name": "Isi Staples", "unit": "Box", "stock": 20},
    {"id": "ATK009", "name": "Sticky Notes", "unit": "Pack", "stock": 15},
    {"id": "ATK010", "name": "Paper Clips", "unit": "Box", "stock": 12},
    {
      "id": "ATK011",
      "name": "Tinta Printer Hitam",
      "unit": "Botol",
      "stock": 8
    },
    {
      "id": "ATK012",
      "name": "Tinta Printer Warna",
      "unit": "Botol",
      "stock": 6
    },
  ];

  List<Map<String, dynamic>> filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userController.addListener(_validateForm);
    _searchController.addListener(_filterItems);

    // Inisialisasi items yang difilter
    filteredItems = List.from(atkItems);

    // Simulasi loading data
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Method to build form label with consistent styling
  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey[800],
      ),
    );
  }

// Method to build loading screen
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

  @override
  void dispose() {
    _userController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter items berdasarkan pencarian
  void _filterItems() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(atkItems);
      } else {
        filteredItems = atkItems
            .where((item) =>
                item["name"].toString().toLowerCase().contains(query) ||
                item["id"].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  // Validasi form
  void _validateForm() {
    setState(() {
      _isFormValid = selectedLocation != null &&
          _userController.text.isNotEmpty &&
          selectedItems.isNotEmpty &&
          selectedItems.every((item) => item.quantity > 0);
    });
  }

  // Format tanggal manual ke dalam bahasa Indonesia
  String _formatTanggal(DateTime date) {
    return "${date.day} ${_namabulan[date.month - 1]} ${date.year}";
  }

  // Dialog untuk memilih ATK dan jumlahnya
  void _showSelectItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Barang ATK',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: bmkgBlue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari barang...",
                      prefixIcon: const Icon(Icons.search, color: bmkgBlue),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: bmkgBlue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filterItems();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // List items
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Barang tidak ditemukan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final isSelected = selectedItems.any(
                                  (selectedItem) =>
                                      selectedItem.id == item["id"]);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: isSelected
                                        ? bmkgBlue
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: bmkgLightBlue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.edit_note,
                                          color: bmkgLightBlue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["name"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Stok: ${item["stock"]} ${item["unit"]}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Tombol untuk menambahkan item
                                      isSelected
                                          ? TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedItems.removeWhere(
                                                      (selectedItem) =>
                                                          selectedItem.id ==
                                                          item["id"]);
                                                  this.setState(() {
                                                    _validateForm();
                                                  });
                                                });
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text("Hapus"),
                                            )
                                          : TextButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  selectedItems.add(
                                                    TakeItem(
                                                      id: item["id"],
                                                      name: item["name"],
                                                      unit: item["unit"],
                                                      stock: item["stock"],
                                                      quantity: 1,
                                                    ),
                                                  );
                                                  this.setState(() {
                                                    _validateForm();
                                                  });
                                                });
                                              },
                                              icon: const Icon(Icons.add,
                                                  size: 16),
                                              label: const Text("Tambah"),
                                              style: TextButton.styleFrom(
                                                foregroundColor: bmkgBlue,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Selesai',
                          style: TextStyle(
                            color: bmkgBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // Dialog konfirmasi hapus item
  void _confirmDelete(String id) {
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
                    selectedItems.removeWhere((item) => item.id == id);
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
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Apakah data pengambilan barang sudah benar?"),
                  const SizedBox(height: 16),
                  _buildConfirmationInfoRow(
                    label: "Lokasi",
                    value: selectedLocation!,
                  ),
                  _buildConfirmationInfoRow(
                    label: "Pengambil",
                    value: _userController.text,
                  ),
                  _buildConfirmationInfoRow(
                    label: "Tanggal",
                    value: _formatTanggal(selectedDate),
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
                                  child: Text(
                                      "${item.name} (${item.quantity} ${item.unit})"),
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

  // Submit form
  void _submitForm() {
    // Menampilkan snackbar sukses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text('Pengambilan barang berhasil dicatat'),
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
  }

  // Widget untuk selector jumlah
  Widget _buildQuantitySelector(int index) {
    final item = selectedItems[index];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol kurang
          InkWell(
            onTap: item.quantity > 1
                ? () {
                    setState(() {
                      selectedItems[index] =
                          item.copyWith(quantity: item.quantity - 1);
                      _validateForm();
                    });
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.quantity > 1
                    ? bmkgBlue.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  bottomLeft: Radius.circular(7),
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 16,
                color: item.quantity > 1 ? bmkgBlue : Colors.grey,
              ),
            ),
          ),

          // Display angka
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(
              item.quantity.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          // Tombol tambah
          InkWell(
            onTap: item.quantity < item.stock
                ? () {
                    setState(() {
                      selectedItems[index] =
                          item.copyWith(quantity: item.quantity + 1);
                      _validateForm();
                    });
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.quantity < item.stock
                    ? bmkgBlue.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: item.quantity < item.stock ? bmkgBlue : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pengambilan ATK',
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
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(children: [
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
                              Icons.edit_note,
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
                                  'Form Pengambilan ATK',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: bmkgBlue,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Silakan isi data pengambilan ATK dengan lengkap',
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
                                  .map((loc) => DropdownMenuItem<String>(
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

                          // Pengambil field
                          _buildFormLabel("Nama Pengambil"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _userController,
                            decoration: InputDecoration(
                              hintText: "Masukkan nama pengambil",
                              prefixIcon:
                                  const Icon(Icons.person, color: bmkgBlue),
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

                          const SizedBox(height: 20),

                          // Tanggal Ambil
                          _buildFormLabel("Tanggal Pengambilan"),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2099),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: bmkgBlue,
                                        onPrimary: Colors.white,
                                        onSurface: Colors.black,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: bmkgBlue),
                                  const SizedBox(width: 12),
                                  Text(
                                    _formatTanggal(selectedDate),
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_drop_down,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Barang yang diambil
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFormLabel("Barang yang Diambil"),
                              ElevatedButton.icon(
                                onPressed: _showSelectItemDialog,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Pilih Barang"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: bmkgBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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
                            padding:
                                const EdgeInsets.only(left: 4.0, bottom: 8.0),
                            child: Text(
                              "${selectedItems.length} barang dipilih",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),

                        selectedItems.isNotEmpty
                            ? ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: selectedItems.length,
                                itemBuilder: (context, index) {
                                  final item = selectedItems[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    elevation: 1,
                                    shadowColor: Colors.black.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: bmkgLightBlue
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.edit_note,
                                                  color: bmkgLightBlue,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "Stok tersedia: ${item.stock} ${item.unit}",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.delete_outline),
                                                color: Colors.red,
                                                onPressed: () =>
                                                    _confirmDelete(item.id),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // Quantity selector
                                          Row(
                                            children: [
                                              const Text(
                                                "Jumlah: ",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              _buildQuantitySelector(index),
                                            ],
                                          ),
                                        ],
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

                        // Tombol Submit
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isFormValid ? _confirmSubmit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bmkgBlue,
                              disabledBackgroundColor: Colors.grey[300],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Proses Pengambilan',
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
                      ]),
                ),
              ]),
            ),
    );
  }
}
