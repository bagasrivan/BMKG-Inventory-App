import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
        titleTextStyle: TextStyle(fontSize: 20, color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black,),
            onPressed: () {
              _showLogoutDialog(context);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage('assets/profile.png'),
              backgroundColor: Colors.blue[200],
            ),
            SizedBox(height: 10,),
            Text('Hai, Bagaskara!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah anda yakin ingin Logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text('Logout'),
            ),
          ],
        );
      }
    );
  }
}