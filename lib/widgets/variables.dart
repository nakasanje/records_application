import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';

class Variables {
  FirebaseAuth auth = FirebaseAuth.instance;

  final String isUser = 'is_user';
  final String message = 'message';
  final String time = 'time';

  void pop(BuildContext context) {
    Navigator.pop(context);
  }

  Future<String> uploadFile(File image, String path, String id) async {
    Reference storageReference = FirebaseStorage.instance.ref(path).child(id);
    await storageReference.putFile(image);
    return await storageReference.getDownloadURL();
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

  Future deleteFile(String imageUrl) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.refFromURL(imageUrl);
    await reference.delete();
  }

  Future<String> cropImage(XFile file) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 6),
    );

    return croppedFile!.path;
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
