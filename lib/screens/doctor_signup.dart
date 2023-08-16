//import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/doctor_auth.dart';
import '../constants/custom_button.dart';
import '../constants/custom_textfield.dart';
import '../constants/global_variables.dart';
import '../constants/images.dart';
import '../constants/logo.dart';
import '../constants/space.dart';
import '../constants/utils.dart';

import 'doctorlogin.dart';

class SignUp extends StatefulWidget {
  static const routeName = "/signup";

  const SignUp({super.key});
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late double width;
  late double height;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController comfirmPasswordController = TextEditingController();
  Uint8List? _image;

  final _formKey = GlobalKey<FormState>();

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
      }

      if (_image != null) {
        await AuthMethod().signUpDoctor(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
          file: _image!,
        );

        if (context.mounted) {
          Navigator.pushNamed(context, DocLoginPage.routeName);
        }
      } else {
        Fluttertoast.showToast(
          msg: "Please provide your image",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red[800],
        );
        Navigator.pop(context);
      }
    }
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    comfirmPasswordController.dispose();
  }

  void registerShowToast() =>
      Fluttertoast.showToast(msg: "Account created successfully");
  bool _isVisible = false;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 79, 112, 87),
        title: const Text('DOCTOR SIGNUP'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 18),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Space(),
                  SvgPicture.asset(
                    login_image,
                    height: width * 0.20,
                  ),
                  const Space(),
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                              backgroundColor: GlobalVariables.primaryColor,
                            )
                          : const CircleAvatar(
                              radius: 64,
                              backgroundImage:
                                  AssetImage('assets/images/blank.png'),
                              backgroundColor: Colors.deepPurpleAccent),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    validate: (value) {
                      if (value!.isEmpty) {
                        return "Enter your name";
                      }
                      return null;
                    },
                    inputType: TextInputType.name,
                    label: "Name",
                    controller: nameController,
                    obscure: false,
                  ),
                  const Space(),
                  MyTextField(
                    validate: (value) {
                      if (value!.isEmpty) {
                        return "Please enter an Email";
                      }
                      if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                          .hasMatch(value)) {
                        return "Invalid Email !";
                      }
                      return null;
                    },
                    inputType: TextInputType.emailAddress,
                    label: "Email",
                    controller: emailController,
                    obscure: false,
                  ),
                  const Space(),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return MyTextField(
                        obscure: !_isVisible,
                        validate: (value) {
                          if (value!.isEmpty) {
                            return "Please enter Password";
                          }
                          if (value.length < 6) {
                            return "Password is Short";
                          }
                          return null;
                        },
                        inputType: TextInputType.text,
                        label: "Password",
                        controller: passwordController,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isVisible = !_isVisible;
                            });
                          },
                          icon: _isVisible
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        ),
                      );
                    },
                  ),
                  const Space(),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return MyTextField(
                        obscure: !_isVisible,
                        validate: (value) {
                          if (value!.isEmpty) {
                            return "Please Confirm your Password";
                          }
                          if (value.length < 6) {
                            return "Password is Short";
                          }
                          if (comfirmPasswordController.text !=
                              passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                        inputType: TextInputType.text,
                        label: "Comfirm Password",
                        controller: comfirmPasswordController,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isVisible = !_isVisible;
                            });
                          },
                          icon: _isVisible
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        ),
                      );
                    },
                  ),
                  const Space(),
                  CustomButton(
                    onTap: signUp,
                    label: "Sign Up",
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, DocLoginPage.routeName),
                    child: const Text("Already Have an Account"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
