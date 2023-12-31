import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:records_application/models/patient_user.dart' as model;
import '../Services/patient_auth.dart';
import '../constants/custom_button.dart';
import '../constants/space.dart';
import '../methods/firestore.dart';

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

  late Stream<QuerySnapshot> recordStream;
  StreamSubscription<QuerySnapshot>? _recordStreamSubscription;
  Timer? _timer;
  late String patientId;

  Variables variables = Variables();
  late model.PatientUser patientuser;

  @override
  void initState() {
    super.initState();
    addData();

    _recordStreamSubscription = FirebaseFirestore.instance
        .collection('SharedRecords')
        .snapshots()
        .listen((querySnapshot) {
      // Handle the stream data
    });

    // Start the timer
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // Execute the timer logic
    });
    // Pass the patientId here
    recordStream =
        FirebaseFirestore.instance.collection('SharedRecords').snapshots();
  }

  @override
  void dispose() {
    _recordStreamSubscription?.cancel();

    // Cancel the timer if it's active
    _timer?.cancel();

    // Cancel any ongoing asynchronous operations here
    // For example, cancel any Stream subscriptions or timers

    super.dispose();
  }

  Future<void> fetchPatientDetails() async {
    final patientuserProvider =
        Provider.of<PatientUserProvider>(context, listen: false);
    patientuser = patientuserProvider.getPatientUser;
  }

  Future<void> fetchSharedRecords() async {
    try {
      final patientuserProvider =
          Provider.of<PatientUserProvider>(context, listen: false);
      patientuser = patientuserProvider.getPatientUser;
      patientId = patientuser.patientId;

      final snapshot = await FirebaseFirestore.instance
          .collection('SharedRecords')
          .where('id', isEqualTo: patientId)
          .get();

      final recordsData = snapshot.docs.map<SharedRecordModel>((doc) {
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

      setState(() {
        sharedRecords = recordsData;
      });
    } catch (e) {
      print(e);
    }
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

// Inside the build method of _PatientDashboardState
// Apply the _textSize to your text styles

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
    return FutureBuilder<void>(
        future: Future.wait([fetchPatientDetails(), fetchSharedRecords()]),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(title: const Text('Patient Dashboard')),
            drawer: Drawer(
              child: Consumer<PatientUserProvider>(
                builder: (context, doctorProvider, _) {
                  final patientuser = doctorProvider.getPatientUser;
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
                        accountName: Text(
                            patientuser.username), // Use the doctor's username
                        accountEmail:
                            Text(patientuser.email), // Use the doctor's email
                      ),
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text('Home'),
                        onTap: () {
                          Navigator.pushNamed(context, '/homes');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('My Doctors'),
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/ReceivingDoctorScreen');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                        onTap: () {
                          Navigator.pushNamed(context, '/setting');
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
                  Navigator.pushNamed(context, '/homes');
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (sharedRecords.isEmpty) {
                          return const Center(
                              child: Text("You have no records yet."));
                        }
                        return ListView.builder(
                          itemCount: sharedRecords.length,
                          itemBuilder: (context, index) {
                            final record = sharedRecords[index];

                            return ListTile(
                              title: Text(
                                'Hey , do you Approve Sharing Your Records  from Doctor ${record.sharingDoctorName} to Doctor ${record.receivingDoctorName}',
                              ),
                              subtitle: Text(
                                  'Approval Status: ${record.approvalStatus}'),
                              onTap: () {
                                if (record.approvalStatus == 'approved') {
                                  // Show a dialog to confirm revoking access
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Revoke Access'),
                                        content: Text(
                                          'Doctor ${record.receivingDoctorName} will not see your records again if you revoke access',
                                        ),
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
                                          onPressed: () =>
                                              _approveRecord(record),
                                          icon: const Icon(Icons.check,
                                              color: Colors.green),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _declineRecord(record),
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
        });
  }
}
