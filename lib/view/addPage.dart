import 'package:bmkg_inventory_system/view/chooseItemPage.dart';
import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<AddPage> {
  // Definisi warna BMKG yang konsisten dengan halaman lain
  static const Color bmkgBlue = Color(0xFF0D47A1);
  static const Color bmkgLightBlue = Color(0xFF1976D2);
  
  String? selectedLocation;
  final TextEditingController _userController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<String> selectedItems = [];
  bool _isFormValid = false;

  // Nama bulan dalam bahasa Indonesia
  final List<String> _namabulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<String> locations = [
    "Operasional", 
    "Tata Usaha", 
    "Radar", 
    "Meteorologi", 
    "Klimatologi", 
    "Geofisika"
  ];

  @override
  void initState() {
    super.initState();
    _userController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  // Validasi form
  void _validateForm() {
    setState(() {
      _isFormValid = selectedLocation != null && 
                    _userController.text.isNotEmpty && 
                    selectedItems.isNotEmpty;
    });
  }

  // Format tanggal manual ke dalam bahasa Indonesia
  String _formatTanggal(DateTime date) {
    return "${date.day} ${_namabulan[date.month - 1]} ${date.year}";
  }

  // Dialog konfirmasi hapus item
  void _confirmDelete(String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Barang'),
          content: const Text("Apakah Anda yakin ingin menghapus barang ini dari daftar peminjaman?"),
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
      }
    );
  }

  // Dialog konfirmasi submit
  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Peminjaman'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Apakah data peminjaman sudah benar?"),
              const SizedBox(height: 16),
              _buildConfirmationInfoRow(
                label: "Lokasi",
                value: selectedLocation!,
              ),
              _buildConfirmationInfoRow(
                label: "Peminjam",
                value: _userController.text,
              ),
              _buildConfirmationInfoRow(
                label: "Tanggal Pinjam",
                value: _formatTanggal(selectedDate),
              ),
              const SizedBox(height: 8),
              const Text(
                "Barang yang dipinjam:",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              ...selectedItems.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(item),
                  ],
                ),
              )).toList(),
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
      }
    );
  }

  Widget _buildConfirmationInfoRow({required String label, required String value}) {
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
              child: Text('Peminjaman barang berhasil disimpan'),
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
          'Peminjaman Barang',
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
      body: SingleChildScrollView(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Form Peminjaman Barang',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: bmkgBlue,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Silakan isi data peminjaman barang dengan lengkap',
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
            
            // Form peminjaman
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
                      _buildFormLabel("Lokasi Peminjaman"),
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
                          icon: const Icon(Icons.arrow_drop_down, color: bmkgBlue),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: InputBorder.none,
                          ),
                          isExpanded: true,
                          items: locations.map((loc) => 
                            DropdownMenuItem(
                              value: loc, 
                              child: Text(loc)
                            )
                          ).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedLocation = value;
                              _validateForm();
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Peminjam field
                      _buildFormLabel("Nama Peminjam"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _userController,
                        decoration: InputDecoration(
                          hintText: "Masukkan nama peminjam",
                          prefixIcon: const Icon(Icons.person, color: bmkgBlue),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Tanggal Pinjam
                      _buildFormLabel("Tanggal Peminjaman"),
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
                                _formatTanggal(selectedDate),
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
                      
                      // Barang yang dipinjam
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFormLabel("Barang yang Dipinjam"),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ChooseItemPage())
                              );

                              if (result != null) {
                                setState(() {
                                  selectedItems = List<String>.from(result);
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
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
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
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: bmkgLightBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.inventory_2,
                                  color: bmkgLightBlue,
                                ),
                              ),
                              title: Text(
                                item,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () => _confirmDelete(item),
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
                              'Silakan pilih barang yang akan dipinjam',
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
                        'Simpan Peminjaman',
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