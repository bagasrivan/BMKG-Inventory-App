import 'package:flutter/material.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  _ReturnState createState() => _ReturnState();
}

class _ReturnState extends State<ReturnPage> {
  // Definisi warna BMKG yang konsisten dengan halaman lain
  static const Color bmkgBlue = Color(0xFF0D47A1);
  static const Color bmkgLightBlue = Color(0xFF1976D2);
  
  String? selectedLoanID;
  String? selectedLocation;
  String? selectedBorrower;
  DateTime loanDate = DateTime.now();
  DateTime returnDate = DateTime.now();
  List<LoanedItem> returnedItems = [];
  bool _isFormValid = false;
  bool _isLoading = true;

  // Nama bulan dalam bahasa Indonesia
  final List<String> _namabulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  // Data peminjaman (dummy data yang nantinya dari API/database)
  final List<Map<String, dynamic>> loanData = [
    {
      "id": "PM-2025-001",
      "borrower": "Ahmad Fauzi",
      "location": "Operasional",
      "date": DateTime(2025, 4, 5),
      "items": [
        {"name": "Laptop Dell XPS", "condition": "Baik", "notes": ""},
        {"name": "Proyektor Epson", "condition": "Baik", "notes": ""},
      ]
    },
    {
      "id": "PM-2025-002",
      "borrower": "Siti Aminah",
      "location": "Meteorologi",
      "date": DateTime(2025, 4, 7),
      "items": [
        {"name": "Anemometer", "condition": "Baik", "notes": ""},
        {"name": "Barometer", "condition": "Baik", "notes": ""},
        {"name": "Tablet Samsung", "condition": "Baik", "notes": ""}
      ]
    },
    {
      "id": "PM-2025-003",
      "borrower": "Budi Santoso",
      "location": "Geofisika",
      "date": DateTime(2025, 4, 8),
      "items": [
        {"name": "Seismometer", "condition": "Baik", "notes": ""},
        {"name": "GPS Geodetik", "condition": "Baik", "notes": ""}
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    // Simulasi loading data
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Validasi form
  void _validateForm() {
    setState(() {
      _isFormValid = selectedLoanID != null && 
                    returnedItems.isNotEmpty &&
                    returnedItems.every((item) => item.condition.isNotEmpty);
    });
  }

  // Format tanggal manual ke dalam bahasa Indonesia
  String _formatTanggal(DateTime date) {
    return "${date.day} ${_namabulan[date.month - 1]} ${date.year}";
  }

  // Fungsi untuk memuat data peminjaman ketika ID dipilih
  void _loadLoanData(String id) {
    final selectedLoan = loanData.firstWhere((loan) => loan["id"] == id);
    setState(() {
      selectedBorrower = selectedLoan["borrower"] as String;
      selectedLocation = selectedLoan["location"] as String;
      loanDate = selectedLoan["date"] as DateTime;
      returnedItems = (selectedLoan["items"] as List).map<LoanedItem>((item) => 
        LoanedItem(
          name: item["name"] as String,
          condition: "Baik", // Default condition
          notes: ""
        )
      ).toList();
      _validateForm();
    });
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
                  label: "ID Pinjam",
                  value: selectedLoanID!,
                ),
                _buildConfirmationInfoRow(
                  label: "Lokasi",
                  value: selectedLocation!,
                ),
                _buildConfirmationInfoRow(
                  label: "Peminjam",
                  value: selectedBorrower!,
                ),
                _buildConfirmationInfoRow(
                  label: "Tanggal Pinjam",
                  value: _formatTanggal(loanDate),
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
                ...returnedItems.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: Colors.grey),
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
                            color: item.condition == "Rusak" ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      if (item.notes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 14.0),
                          child: Text(
                            "Catatan: ${item.notes}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic
                            ),
                          ),
                        ),
                    ],
                  ),
                )).toList(),
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
      }
    );
  }

  // Layout info konfirmasi
  Widget _buildConfirmationInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
              child: Text('Pengembalian barang berhasil disimpan'),
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
        : SingleChildScrollView(
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
                              Icons.assignment_return,
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
                                  'Form Pengembalian Barang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: bmkgBlue,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Silakan isi data pengembalian barang dengan lengkap',
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
                
                // Form pengembalian
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
                          // ID Peminjaman field
                          _buildFormLabel("ID Peminjaman"),
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
                              value: selectedLoanID,
                              hint: const Text("Pilih ID Peminjaman"),
                              icon: const Icon(Icons.arrow_drop_down, color: bmkgBlue),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: InputBorder.none,
                              ),
                              isExpanded: true,
                              items: loanData.map((loan) => 
                                DropdownMenuItem<String>(
                                  value: loan["id"] as String, 
                                  child: Text("${loan["id"]} - ${loan["borrower"]}")
                                )
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedLoanID = value;
                                  if (value != null) {
                                    _loadLoanData(value);
                                  }
                                });
                              },
                            ),
                          ),
                          
                          if (selectedLoanID != null) ...[
                            const SizedBox(height: 20),
                            
                            // Info Peminjaman
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: bmkgLightBlue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: bmkgLightBlue.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline, color: bmkgBlue, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Informasi Peminjaman",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: bmkgBlue,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    icon: Icons.person,
                                    label: "Peminjam",
                                    value: selectedBorrower!,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    icon: Icons.location_on,
                                    label: "Lokasi",
                                    value: selectedLocation!,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    icon: Icons.calendar_today,
                                    label: "Tanggal Pinjam",
                                    value: _formatTanggal(loanDate),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Tanggal Pengembalian
                            _buildFormLabel("Tanggal Pengembalian"),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: returnDate,
                                  firstDate: loanDate,
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
                                    returnDate = pickedDate;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: bmkgBlue),
                                    const SizedBox(width: 12),
                                    Text(
                                      _formatTanggal(returnDate),
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Daftar Barang yang Dikembalikan
                            _buildFormLabel("Barang yang Dikembalikan"),
                            const SizedBox(height: 12),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: returnedItems.length,
                              itemBuilder: (context, index) {
                                return _buildReturnItemCard(index);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Tombol Submit
                if (selectedLoanID != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
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
                          padding: const EdgeInsets.symmetric(vertical: 20),
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
              ],
            ),
          ),
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
            "Memuat data peminjaman...",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk info row
  Widget _buildInfoRow({
    required IconData icon,
    required String label, 
    required String value
  }) {
    return Row(
      children: [
        Icon(icon, color: bmkgLightBlue.withOpacity(0.7), size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label + ":",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  // Widget untuk kartu item pengembalian
  Widget _buildReturnItemCard(int index) {
    final item = returnedItems[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
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
                    color: bmkgLightBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: bmkgLightBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Kondisi barang
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
                _buildConditionRadio(index, "Baik"),
                const SizedBox(width: 16),
                _buildConditionRadio(index, "Rusak"),
              ],
            ),
            const SizedBox(height: 12),
            
            // Catatan (muncul jika kondisi rusak)
            if (item.condition == "Rusak")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        returnedItems[index] = returnedItems[index].copyWith(notes: value);
                        _validateForm();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Deskripsikan kerusakan barang",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        ),
      ),
    );
  }
  
  // Widget radio button kondisi
  Widget _buildConditionRadio(int index, String value) {
    return InkWell(
      onTap: () {
        setState(() {
          returnedItems[index] = returnedItems[index].copyWith(
            condition: value,
            notes: value == "Baik" ? "" : returnedItems[index].notes
          );
          _validateForm();
        });
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: returnedItems[index].condition,
            activeColor: value == "Baik" ? Colors.green : Colors.red,
            onChanged: (newValue) {
              setState(() {
                returnedItems[index] = returnedItems[index].copyWith(
                  condition: newValue!,
                  notes: newValue == "Baik" ? "" : returnedItems[index].notes
                );
                _validateForm();
              });
            },
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: returnedItems[index].condition == value
                  ? (value == "Baik" ? Colors.green : Colors.red)
                  : Colors.grey[700],
              fontWeight: returnedItems[index].condition == value
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

// Kelas model untuk item yang dikembalikan
class LoanedItem {
  final String name;
  final String condition;
  final String notes;
  
  LoanedItem({
    required this.name,
    required this.condition,
    required this.notes,
  });
  
  LoanedItem copyWith({
    String? name,
    String? condition,
    String? notes,
  }) {
    return LoanedItem(
      name: name ?? this.name,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
    );
  }
}