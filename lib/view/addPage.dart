import 'package:bmkg_inventory_system/view/chooseItemPage.dart';
import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<AddPage> {
  String? selectedLocation;
  DateTime selectedDate = DateTime.now();
  List<String> selectedItems = [];

  void _confirmDelete(String item) {
    showDialog(
        context: context,
        builder: (BuildContext build) {
          return AlertDialog(
            title: Text('Konfirmasi Hapus Barang Dipinjam'),
            content: Text("Apakah anda yakin ingin menghapus barang dipinjam?"),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text('Batal'),
              ),
              TextButton(
                child: Text('Ya'),
                onPressed: () {
                  setState(() {
                    selectedItems.remove(item);
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peminjaman Barang'),
        backgroundColor: Colors.blue[200],
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: const Text(
                      'Lokasi',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedLocation,
                      items: ["Oprasional", "Tata Usaha", "Radar"]
                          .map((loc) =>
                              DropdownMenuItem(value: loc, child: Text(loc)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: const Text(
                      'User',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(
                      label: Text('Input User'),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  )),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: const Text(
                      'Barang',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    width: 173,
                  ),
                  InkWell(
                    child: Row(
                      children: [
                        Text(
                          'Pilih Barang',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Icon(Icons.keyboard_arrow_right),
                      ],
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChooseItemPage()));

                      if (result != null) {
                        setState(() {
                          selectedItems = List<String>.from(result);
                        });
                        print('Barang dipilih : $selectedItems');
                      }
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              selectedItems.isNotEmpty
                  ? Column(
                      children: selectedItems.map((item) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(item),
                          trailing: IconButton(
                              onPressed: () {
                                _confirmDelete(item);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              )),
                        ),
                      );
                    }).toList())
                  : Center(
                      child: Text(
                        'Belum ada barang dipilih',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: const Text(
                      'Tanggal Pinjam',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    width: 139,
                  ),
                  InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2099));
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "${selectedDate.day} - ${selectedDate.month} - ${selectedDate.year}"),
                          SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 154),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/navigation');
                    },
                    child: const Text(
                      'Selesai',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
}
