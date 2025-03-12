import 'package:bmkg_inventory_system/view/addPage.dart';
import 'package:flutter/material.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  String getFormattedDate() {
    DateTime now = DateTime.now();
    List<String> months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[200],
        titleTextStyle: const TextStyle(fontSize: 20, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.lightBlue[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 10),
                          Text(
                            getFormattedDate(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Column(
                            children: [
                              Text("12",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                "Total Barang",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text("8",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                "Barang Tersedia",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text("4",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                "Barang Dipinjam",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Tambahkan Cloud Image atau Widget Hiasan
                  Positioned(
                    top: -10,
                    right: 14,
                    child: Icon(Icons.cloud, size: 60, color: Colors.blue[300]),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 7,
            ),
            Card(
              color: Colors.grey[80],
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelola',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        child: Row(
                          children: [
                            Icon(
                              Icons.assignment_add,
                              size: 24,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              'Peminjaman Barang',
                              style: TextStyle(fontSize: 18),
                            ),
                            Spacer(),
                            Icon(Icons.keyboard_arrow_right)
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddPage()));
                        },
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        child: Row(
                          children: [
                            Icon(
                              Icons.assignment_return,
                              size: 24,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              'Pengembalian Barang',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(
                              width: 62,
                            ),
                            Icon(Icons.keyboard_arrow_right),
                          ],
                        ),
                        onTap: () {},
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 7,
            ),
          ],
        ),
      ),
    );
  }
}
