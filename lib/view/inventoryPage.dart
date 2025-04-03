import 'package:bmkg_inventory_system/view/scanPage.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<InventoryPage> {
  // Definisi warna BMKG yang konsisten dengan halaman lain
  static const Color bmkgBlue = Color(0xFF0D47A1);
  static const Color bmkgLightBlue = Color(0xFF1976D2);

  List<String> categories = [
    "Semua",
    "Tersedia",
    "Tidak Tersedia",
    "Peralatan Operasional",
    "Kendaraan",
    "Alat Tulis"
  ];
  String selectedCategory = "Semua";

  List<Map<String, String>> items = [
    {
      "name": "Handy Talky",
      "category": "Peralatan Operasional",
      "location": "Gudang Operasional",
      "status": "Tersedia",
      "image": "assets/handytalky.png"
    },
    {
      "name": "Mobil Dinas BMKG",
      "category": "Kendaraan Operasional",
      "location": "Gudang Stasiun",
      "status": "Tersedia",
      "image": "assets/car.png"
    },
    {
      "name": "Printer Canon TS9521C",
      "category": "Alat Tulis Kantor",
      "location": "Gudang TU",
      "status": "Tersedia",
      "image": "assets/printer.png"
    },
    {
      "name": "Tangga Lipat",
      "category": "Peralatan Operasional",
      "location": "Gudang Operasional",
      "status": "Tidak Tersedia",
      "image": "assets/tanggalipat.png"
    },
    {
      "name": "Handy Talky 2",
      "category": "Peralatan Operasional",
      "location": "Gudang Operasional",
      "status": "Tersedia",
      "image": "assets/handytalky.png"
    },
    {
      "name": "Mobil Dinas BMKG 2",
      "category": "Kendaraan Operasional",
      "location": "Gudang Stasiun",
      "status": "Tersedia",
      "image": "assets/car.png"
    },
    {
      "name": "Printer Canon TS9521C 2",
      "category": "Alat Tulis Kantor",
      "location": "Gudang TU",
      "status": "Tidak Tersedia",
      "image": "assets/printer.png"
    },
    {
      "name": "Tangga Lipat 2",
      "category": "Peralatan Operasional",
      "location": "Gudang Operasional",
      "status": "Tersedia",
      "image": "assets/tanggalipat.png"
    },
    {
      "name": "Handy Talky 3",
      "category": "Peralatan Operasional",
      "location": "Gudang Operasional",
      "status": "Tersedia",
      "image": "assets/handytalky.png"
    },
    {
      "name": "Mobil Dinas BMKG 3",
      "category": "Kendaraan Operasional",
      "location": "Gudang Stasiun",
      "status": "Tidak Tersedia",
      "image": "assets/car.png"
    },
    {
      "name": "Printer Canon TS9521C 3",
      "category": "Alat Tulis Kantor",
      "location": "Gudang TU",
      "status": "Tersedia",
      "image": "assets/printer.png"
    },
    {
      "name": "Tangga Lipat 3",
      "category": "Peralatan Operasional",
      "location": "Gudang Operasional",
      "status": "Tersedia",
      "image": "assets/tanggalipat.png"
    },
    {
      "name": "Handy Talky 4",
      "category": "Peralatan Operasional",
      "location": "Gudang Operasional",
      "status": "Tidak Tersedia",
      "image": "assets/handytalky.png"
    },
    {
      "name": "Mobil Dinas BMKG 4",
      "category": "Kendaraan Operasional",
      "location": "Gudang Stasiun",
      "status": "Tersedia",
      "image": "assets/car.png"
    },
    {
      "name": "Printer Canon TS9521C 4",
      "category": "Alat Tulis Kantor",
      "location": "Gudang TU",
      "status": "Tersedia",
      "image": "assets/printer.png"
    },
    {
      "name": "Tangga Lipat 4",
      "category": "Peralatan Operasional",
      "location": "Gudang Operasional",
      "status": "Tersedia",
      "image": "assets/tanggalipat.png"
    },
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
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

  List<Map<String, String>> getFilteredItems() {
    String query = _searchController.text.toLowerCase();

    return items.where((item) {
      bool matchesCategory;

      if (selectedCategory == "Semua") {
        matchesCategory = true;
      } else if (selectedCategory == "Tersedia" ||
          selectedCategory == "Tidak Tersedia") {
        matchesCategory = item['status'] == selectedCategory;
      } else {
        // Filter by category type
        matchesCategory = item['category']!.contains(selectedCategory);
      }

      bool matchesSearch = item['name']!.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
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

  // Widget untuk filter chip
  Widget _buildFilterChip(String label) {
    bool isSelected = selectedCategory == label;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      selected: isSelected,
      showCheckmark: true,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[200],
      selectedColor: bmkgLightBlue,
      onSelected: (bool selected) {
        setState(() {
          selectedCategory = selected ? label : "Semua";
        });
      },
    );
  }

  // Widget untuk status kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada barang ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba pilih kategori lain atau ubah pencarian',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                selectedCategory = "Semua";
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: bmkgLightBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk filter bottom sheet
  Widget _buildFilterBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Inventaris',
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
          const SizedBox(height: 16),
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('Semua'),
              _buildFilterChip('Tersedia'),
              _buildFilterChip('Tidak Tersedia'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Peralatan Operasional'),
              _buildFilterChip('Kendaraan'),
              _buildFilterChip('Alat Tulis'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = "Semua";
                      _searchController.clear();
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bmkgBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function untuk menampilkan detail item
  void _showItemDetails(Map<String, String> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        bool isAvailable = item['status'] == 'Tersedia';

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan tombol close
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
                    child: Image.asset(
                      item['image']!,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name']!,
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
                            item['status']!,
                            style: TextStyle(
                              color: isAvailable ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                            Icons.category, 'Kategori', item['category']!),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                            Icons.location_on, 'Lokasi', item['location']!),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Button section
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isAvailable
                          ? () {
                              // Navigate to borrow page
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ScanPage(),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.assignment_add),
                      label: const Text('Pinjam'),
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[500],
                        backgroundColor: bmkgBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle report or issue
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Laporan berhasil dikirim'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.report_problem),
                      label: const Text('Laporkan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredItems = getFilteredItems();

    // Sort items - available first
    filteredItems.sort((a, b) {
      if (a['status'] == "Tidak Tersedia" && b['status'] == "Tersedia") {
        return 1;
      } else if (a['status'] == "Tersedia" && b['status'] == "Tidak Tersedia") {
        return -1;
      }
      return 0;
    });

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
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filter function
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (context) => _buildFilterBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Section with Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [bmkgBlue, bmkgLightBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: bmkgBlue.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari barang inventaris...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: bmkgBlue),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: bmkgBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          color: Colors.white,
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          onPressed: _scanBarcode,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  // Category Chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: categories.map((category) {
                        bool isSelected = selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[800],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            showCheckmark: false,
                            backgroundColor: Colors.white.withOpacity(0.9),
                            selectedColor: bmkgLightBlue,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                selectedCategory = category;
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

            // Results Count
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredItems.length} Barang Ditemukan',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sort,
                              size: 16,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tersedia Dulu',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
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

            // Item List
            Expanded(
              child: filteredItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        var item = filteredItems[index];
                        bool isAvailable = item['status'] == 'Tersedia';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              // Show item details
                              _showItemDetails(item);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Item Image with Status Indicator
                                  Stack(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Image.asset(
                                          item['image']!,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isAvailable
                                                ? Colors.green
                                                : Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          width: 18,
                                          height: 18,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 16),

                                  // Item Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Item Name
                                            Expanded(
                                              child: Text(
                                                item['name']!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            // Status Badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isAvailable
                                                    ? Colors.green
                                                        .withOpacity(0.1)
                                                    : Colors.red
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                item['status']!,
                                                style: TextStyle(
                                                  color: isAvailable
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // Category
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.category,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item['category']!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        // Location
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item['location']!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Arrow Icon
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
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
