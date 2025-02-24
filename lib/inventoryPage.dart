import 'package:flutter/foundation.dart';
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
      "image": "assets/ht.png"
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
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barang'),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            decoration: InputDecoration(
                hintText: 'Cari nama barang, barcode, kategori',
                prefixIcon: Icon(Icons.search),
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
        ]),
      ),
    );
  }
}
