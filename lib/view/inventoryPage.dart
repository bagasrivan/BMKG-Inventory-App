import 'package:bmkg_inventory_system/view/scanPage.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<InventoryPage> {
  List<String> categories = ["Semua", "Tersedia"];
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

  TextEditingController _searchController = TextEditingController();

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

  List<Map<String, String>> getFilteredItems() {
    String query = _searchController.text.toLowerCase();

    return items.where((item) {
      bool matchesCategory =
          selectedCategory == "Semua Barang" || item['status'] == "Tersedia";
      bool matchesSearch = item['name']!.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Widget build(BuildContext context) {
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
        title: Text('Barang'),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
        automaticallyImplyLeading: false,
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
                hintText: 'Cek ketersediaan barang',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.qr_code_scanner),
                  color: Colors.blue[400],
                  onPressed: _scanBarcode,
                ),
                filled: true,
                fillColor: Colors.grey[60],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none)),
          ),
          SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map(
                (categories) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
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
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              var item = filteredItems[index];
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
                  trailing: Text(
                    item['status']!,
                    style: TextStyle(
                        color: item['status'] == 'Tersedia'
                            ? Colors.green
                            : Colors.red,
                        fontSize: 10),
                  ),
                ),
              );
            },
          ))
        ]),
      ),
    );
  }
}
