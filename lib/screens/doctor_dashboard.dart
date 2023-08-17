import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:records_application/constants/auth_methods.dart';
import 'package:records_application/constants/space.dart';
import 'package:records_application/screens/doctorlogin.dart';

import '../constants/custom_button.dart';
import '../methods/firestore.dart';
import '../models/doctors.dart';
import '../models/doctors.dart' as model;

import '../pages/variables.dart';
import '../providers/doctor_provider.dart';
import 'homegrid.dart'; // Rename your Doctors model

class Dashboard extends StatefulWidget {
  static const routeName = "/dashboard";
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  FirestoreMethods firestore = FirestoreMethods();
  final AuthMethods _authMethods = AuthMethods();
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
                    leading: const Icon(CupertinoIcons.home),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pushNamed(context, '/home');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(CupertinoIcons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          onTap: (int index) {
            if (index == 0) {
              Navigator.pushNamed(context, '/notifications');
            } else if (index == 1) {
              Navigator.pushNamed(context, '/settings');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/home');
            }
          },
          type: BottomNavigationBarType.fixed,
          iconSize: 20,
          backgroundColor: const Color.fromARGB(255, 209, 142, 233),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.alarm,
                color: Colors.blue,
              ),
              label: 'notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.settings,
                color: Colors.green,
              ),
              label: 'settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.home,
                color: Colors.purple,
              ),
              label: 'Home',
            ),
          ],
        ),
        body: Column(
          children: [
            Consumer<DoctorProvider>(
              builder: (context, doctorProvider, _) {
                final doctor = doctorProvider.getDoctor;
                return Text('Welcome Doctor, ${doctor.username.toString()}');
              },
            ),
            const Space(),
            CustomButton(
              onTap: () {
                _authMethods.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const DocLoginPage())); // Navigate back to login page
              },
              label: 'Sign Out',
            ),
            const HomeGrid(),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
