import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:records_application/models/patient_user.dart';
import 'package:records_application/models/patient_user.dart' as model;
import 'package:records_application/screens/receivingdoc.dart';

import '../Services/patient_auth.dart';
import '../constants/custom_button.dart';
import '../constants/space.dart';
import '../methods/firestore.dart';
import '../models/doctors.dart';
import '../models/share.dart';
import '../pages/variables.dart';
import '../providers/patient_user_provider.dart';
import 'loginpage.dart';
// Replace with the correct import path

class PatientDashboard extends StatefulWidget {
  static const String routeName = '/patientDashboard';

  const PatientDashboard({Key? key}) : super(key: key);

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  List<SharedRecordModel> sharedRecords = [];
  FirestoreMethods firestore = FirestoreMethods();
  final AuthMethods _authMethods = AuthMethods();
  List<DoctorModel> receivingDoctorsFromSelectedPatient = [];

  Variables variables = Variables();

  late PatientUser patientuser;

  getUser() async {
    var snap =
        await firestore.patientuserCollection.doc(firestore.patient).get();
    patientuser = PatientUser.fromSnap(snap);
  }

  @override
  void initState() {
    super.initState();
    addData();
    getUser();
    fetchSharedRecords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final userModel = FirebaseAuth.instance.currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  //signout function

  Future<void> signOut() async {
    await auth.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  addData() async {
    PatientUserProvider patientuserProvider =
        Provider.of<PatientUserProvider>(context, listen: false);
    await patientuserProvider.refreshPatientUser();
  }
  // Add this list

  Future<void> fetchSharedRecords() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('SharedRecords').get();

      final recordsData = snapshot.docs.map<SharedRecordModel>((doc) {
        return SharedRecordModel.fromSnap(doc);
      }).toList();

      setState(() {
        sharedRecords = recordsData;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _approveRecord(SharedRecordModel record) async {
    try {
      // Update the approval status of the record
      await FirebaseFirestore.instance
          .collection('SharedRecords')
          .doc(record.id)
          .update({'approvalStatus': 'approved'});

      // Refresh the shared records list

      await fetchSharedRecords();

      if (record.patientId == patientuser.patientId) {
        String sharingDoctorToken = 'sharingDoctor_fcm_token_here';

        await NotificationService().sendNotification(
          title: 'Record Approved',
          body: 'Your shared record has been approved.',
          token: sharingDoctorToken, // Replace with the actual FCM token
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record declined')),
        );
      } // ... Show snackbar ...
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error declining record: $error')),
      ); // ... Handle error ...
    }
  }

  Future<void> _declineRecord(SharedRecordModel record) async {
    try {
      // Update the approval status of the record
      await FirebaseFirestore.instance
          .collection('SharedRecords')
          .doc(record.id)
          .update({'approvalStatus': 'declined'});

      // Refresh the shared records list
      await fetchSharedRecords();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record declined')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error declining record: $error')),
      );
      _fetchReceivingDoctorsFromSelectedPatient(record.patientId);
    }
  }

  Future<void> _fetchReceivingDoctorsFromSelectedPatient(
      String patientId) async {
    // Fetch the list of receiving doctors for the selected patient
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('SharedRecords')
          .where('patientId', isEqualTo: patientId)
          .get();

      final receivingDoctorsData = snapshot.docs
          .map<DoctorModel>((doc) {
            return DoctorModel(
              doctorId: doc['receivingDoctorId'],
              username: 'Unknown Name',
              email: 'Unknown Email',
              photoUrl: '',
              // Other properties of the receiving doctor
            );
          })
          .toSet() // Remove duplicates
          .toList();

      // Navigate to the ReceivingDoctorsScreen with the list of doctors
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ReceivingDoctorsScreen(
            currentPatientId: '',
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    model.PatientUser patientuser =
        Provider.of<PatientUserProvider>(context, listen: false).getPatientUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Dashboard')),
      drawer: Drawer(
        child: ListView(
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
                    patientuser.photoUrl,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              accountName:
                  Text(patientuser.username), // Use the doctor's username
              accountEmail: Text(patientuser.email), // Use the doctor's email
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Doctors with your records:'),
              onTap: () {
                _fetchReceivingDoctorsFromSelectedPatient(
                    patientuser.patientId);
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: receivingDoctorsFromSelectedPatient.length,
              itemBuilder: (context, index) {
                final doctor = receivingDoctorsFromSelectedPatient[index];
                return ListTile(
                  title: Text('Doctor ID: ${doctor.doctorId}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReceivingDoctorsScreen(
                          currentPatientId: '',
                        ),
                      ),
                    );
                  },
                  // You can display more doctor properties here
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
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
            icon: Icon(Icons.notifications),
            label: 'notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Welcome ${patientuser.username.toString()}'),
            const Space(),
            CustomButton(
              onTap: () {
                _authMethods.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const LoginPage())); // Navigate back to login page
              },
              label: 'Sign Out',
            ),
            // Display shared records
            Expanded(
              child: ListView.builder(
                itemCount: sharedRecords.length,
                itemBuilder: (context, index) {
                  final record = sharedRecords[index];
                  return ListTile(
                    title:
                        Text('Record from Doctor: ${record.sharingDoctorId}'),
                    subtitle: Text('Approval Status: ${record.approvalStatus}'),
                    trailing: record.approvalStatus == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _approveRecord(record),
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                              ),
                              IconButton(
                                onPressed: () => _declineRecord(record),
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                              ),
                            ],
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
