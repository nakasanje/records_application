import 'package:flutter/material.dart';

import '../pages/patientrecords.dart';
import '../pages/sharerecords.dart';

import '../screens/fetch_doctors.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';

import 'package:records_application/screens/doctorlogin.dart';
import '../methods/firestore.dart';
import '../models/doctors.dart';

import '../pages/variables.dart';
import '../providers/doctor_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PatientRecords(), // Replace with your PatientRecords page
    const Fetch(), // Replace with your UploadRecords page
    const ShareRecords(), // Replace with your ShareRecords page
  ];
  FirestoreMethods firestore = FirestoreMethods();

  Variables variables = Variables();

  late DoctorModel doctor;

  getUser() async {
    var snap = await firestore.doctorCollection.doc(firestore.doctor).get();
    doctor = DoctorModel.fromSnap(snap);
  }

  @override
  void initState() {
    super.initState();
    addData();
    getUser();
  }

  final userModel = FirebaseAuth.instance.currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  //signout function

  Future<void> signOut() async {
    await auth.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const DocLoginPage()));
  }

  addData() async {
    DoctorProvider doctorProvider =
        Provider.of<DoctorProvider>(context, listen: false);
    await doctorProvider.refreshDoctor();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Dashboard'),
        ),
        drawer: Drawer(
          child: Consumer<DoctorProvider>(
            builder: (context, doctorProvider, _) {
              final doctor = doctorProvider.getDoctor;
              return ListView(
                children: [
                  UserAccountsDrawerHeader(
                    currentAccountPicture: InkWell(
                      child: Container(
                        width: 50,
                        height: 50,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          doctor.photoUrl,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    accountName:
                        Text(doctor.username), // Use the doctor's username
                    accountEmail: Text(doctor.email), // Use the doctor's email
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pushNamed(context, '/home1');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) {
                        return const DocLoginPage();
                      }));
                    },
                  ),
                ],
              );
            },
          ),
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
              icon: Icon(Icons.people),
              label: 'Doctors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.share),
              label: 'Share Records',
            ),
          ],
        ),
      ),
    );
  }
}
