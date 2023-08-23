// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/doctors.dart';

// ignore: camel_case_types
class Fetch extends StatelessWidget {
  static const routeName = "/fetch";

  const Fetch({super.key});

  fetchUsers() async {
    List<Map<String, dynamic>> products = [];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("doctor").get();

    for (var doc in snapshot.docs) {
      products.add(doc.data() as Map<String, dynamic>);
    }

    return products;
  }

  getuserdata(String email) async {
    // got from auth provider
    var auth = FirebaseAuth.instance.currentUser;
    //got from user provider
    var firestore = await FirebaseFirestore.instance
        .collection("doctor")
        .where("email", isEqualTo: email)
        .where('role', isEqualTo: 'doctor')
        .get();
    var wat = firestore.docs.map((e) => DoctorModel.fromSnap(e)).toList();
    return wat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
        backgroundColor: const Color.fromARGB(255, 79, 112, 87),
      ),
      body: SizedBox(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("doctor").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot documentSnapshot =
                          snapshot.data!.docs[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/DoctorDetails');
                        },
                        child: Row(
                          children: [
                            Expanded(child: Text(documentSnapshot["username"])),
                            const SizedBox(height: 20),
                            Expanded(child: Text(documentSnapshot["email"]))
                          ],
                        ),
                      );
                    });
              }
              return const CircularProgressIndicator();
            }),
      ),
    );
  }
}
