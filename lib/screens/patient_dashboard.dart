import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:records_application/models/patient_user.dart';
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
  late Stream<QuerySnapshot> recordStream;

  Variables variables = Variables();

  late PatientUser patientuser;
  getUser() async {
    var snap =
        await firestore.patientuserCollection.doc(firestore.patientuser).get();
    patientuser = PatientUser.fromSnap(snap);
  }

  @override
  void initState() {
    super.initState();
    addData();
    getUser();
    fetchSharedRecords();
    recordStream = FirebaseFirestore.instance
        .collection('SharedRecords')
        .where('id', isEqualTo: patientuser.patientId)
        .snapshots();
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
    final patientuserProvider =
        Provider.of<PatientUserProvider>(context, listen: false);
    patientuser = patientuserProvider.getPatientUser;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('SharedRecords')
          .where('id', isEqualTo: patientuser.patientId)
          .get();

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
    // Update the approval status of the record
    await FirebaseFirestore.instance
        .collection('SharedRecords')
        .doc(record.id)
        .update({'approvalStatus': 'approved'});

    // Refresh the shared records list

    // ... Handle error ...
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
    }
  }

  Future<void> _revokeAccessFromDoctor(SharedRecordModel record) async {
    try {
      // Update the approval status of the record
      await FirebaseFirestore.instance
          .collection('SharedRecords')
          .doc(record.id)
          .update({'approvalStatus': 'revoked'});

      // Refresh the shared records list
      await fetchSharedRecords();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access revoked')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error revoking access: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Dashboard')),
      drawer: Drawer(
        child: Consumer<PatientUserProvider>(
          builder: (context, patientuserProvider, _) {
            final patientuser = patientuserProvider.getPatientUser;
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
                        patientuser.photoUrl,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  accountName:
                      Text(patientuser.username), // Use the doctor's username
                  accountEmail:
                      Text(patientuser.email), // Use the doctor's email
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
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
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
            Consumer<PatientUserProvider>(
              builder: (context, patientuserProvider, _) {
                final patientuser = patientuserProvider.getPatientUser;
                return Text('Welcome ${patientuser.username.toString()}');
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
                            const LoginPage())); // Navigate back to login page
              },
              label: 'Sign Out',
            ),
            // Display shared records
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: recordStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final recordData =
                      snapshot.data!.docs.map<SharedRecordModel>((doc) {
                    return SharedRecordModel(
                      sharingDoctorName: doc['sharingDoctorName'],
                      approvalStatus: doc['approvalStatus'],
                      id: doc.id,
                      patientId: doc['patientId'],
                      receivingDoctorId: doc['receivingDoctorId'],
                      sharingDoctorId: doc['sharingDoctorId'],
                      receivingDoctorName: doc['receivingDoctorName'],
                    );
                  }).toList();

                  if (recordData.isEmpty) {
                    return const Center(
                        child: Text("You have no records yet."));
                  }
                  return ListView.builder(
                    itemCount: recordData.length,
                    itemBuilder: (context, index) {
                      final record = recordData[index];

                      return ListTile(
                        title: Text(
                            'Do you Approve Sharing Your Record from Doctor ${record.sharingDoctorName}'),
                        subtitle:
                            Text('Approval Status: ${record.approvalStatus}'),
                        onTap: () {
                          if (record.approvalStatus == 'approved') {
                            // Show a dialog to confirm revoking access
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Revoke Access'),
                                  content: Text(
                                      'Do you want to revoke access to the record from Doctor ${record.sharingDoctorName}?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        _revokeAccessFromDoctor(
                                            record); // Revoke access
                                      },
                                      child: const Text('Revoke'),
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
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
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
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
