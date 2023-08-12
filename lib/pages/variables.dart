import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class Variables {
  FirebaseAuth auth = FirebaseAuth.instance;

  final String isUser = 'is_user';
  final String message = 'message';
  final String time = 'time';

  void pop(BuildContext context) {
    Navigator.pop(context);
  }

  Future pushPage(BuildContext context, Widget page) {
    return Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return page;
      },
    ));
  }

  Future replacePage(BuildContext context, Widget page) {
    return Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return page;
      },
    ));
  }

  double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  Widget buildLeaderTile(int i, UserModel model) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.grey.shade200,
      ),
      child: ListTile(
        leading: CircleAvatar(child: Text('${i + 1}')),
        title: Text(model.username),
      ),
    );
  }
}
