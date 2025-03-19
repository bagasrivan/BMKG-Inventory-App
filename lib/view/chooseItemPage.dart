import 'package:bmkg_inventory_system/view/scanPage.dart';
import 'package:flutter/material.dart';

class ChooseItemPage extends StatefulWidget {
  const ChooseItemPage({super.key});

  @override
  _ChooseItemState createState() => _ChooseItemState();
}

class _ChooseItemState extends State<ChooseItemPage> {
  List<String> categories = ["Tersedia", "Semua Barang"];
  String selectedCategory = "Tersedia";
  Set<String> selectedItems = {};

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
      MaterialPageRoute(builder: (context) => ScanPage()),
    );
    if (result != null) {
      setState(() {
        _searchController.text = result;
      });
    }
  }

  void _onComplete() {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Silahkan pilih minimal satu barang'),
        backgroundColor: Colors.red,
      ));
    } else {
      Navigator.pop(context, selectedItems.toList());
    }
  }

  void _confirmSelection(String itemName) {
    showDialog(
        context: context,
        builder: (BuildContext build) {
          return AlertDialog(
            title: Text('Konfirmasi Peminjaman Barang'),
            content: Text('Apakah anda yakin ingin meminjam $itemName?'),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text('Batal'),
              ),
              TextButton(
                child: Text('Ya'),
                onPressed: () {
                  setState(() {
                    selectedItems.add(itemName);
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  List<Map<String, String>> getFilteredItems() {
    String query = _searchController.text.toLowerCase();

    return items.where((item) {
      bool matchesCategory =
          selectedCategory == "Semua Barang" || item['status'] == "Tersedia";
      bool matchesSearch = item['name']!.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext) {
    List<Map<String, String>> filteredItems = getFilteredItems();

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
        title: Text('Pilih Barang'),
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
        backgroundColor: Colors.blue[200],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: 'Cari nama barang atau scan barcode',
                  hintStyle: TextStyle(fontSize: 12),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.qr_code_scanner),
                    onPressed: _scanBarcode,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  )),
            ),
          ),
          SizedBox(
            height: 1,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map(
                (categories) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                        label: Text(categories),
                        selected: selectedCategory == categories,
                        selectedColor: Colors.blue[100],
                        onSelected: (bool selected) {
                          setState(() {
                            selectedCategory = categories;
                          });
                        }),
                  );
                },
              ).toList(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  var item = filteredItems[index];
                  bool isSelected = selectedItems.contains(item['name']);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                        leading: Image.asset(item['image']!, width: 50),
                        title: Text(
                          item['name']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['category']!,
                              style: TextStyle(fontSize: 12),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.blue[200],
                                ),
                                Text(
                                  item['location']!,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            )
                          ],
                        ),
                        trailing: item['status'] == "Tidak Tersedia"
                            ? Text(
                                'Tidak Tersedia',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade50,
                                  foregroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: item['status'] == "Tidak Tersedia"
                                    ? null
                                    : () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedItems.remove(item['name']);
                                          } else {
                                            _confirmSelection(item['name']!);
                                          }
                                        });
                                      },
                                child: Text(
                                  isSelected ? 'Batal' : 'Pilih',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 2)),
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
                          color: Colors.green),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Barang',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _onComplete,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                  child: Text(
                    'Selesai',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
