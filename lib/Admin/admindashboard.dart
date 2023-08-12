import 'package:flutter/material.dart';

import '../pages/patientrecords.dart';
import '../pages/sharerecords.dart';
import '../pages/uploadrecords.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PatientRecords(), // Replace with your PatientRecords page
    const UploadRecords(), // Replace with your UploadRecords page
    const ShareRecords(), // Replace with your ShareRecords page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Patient Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: 'Share Records',
          ),
        ],
      ),
    );
  }
}
