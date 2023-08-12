//import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/doctor_auth.dart';
import '../constants/custom_button.dart';
import '../constants/custom_textfield.dart';
import '../constants/global_variables.dart';
import '../constants/logo.dart';
import '../constants/space.dart';
import '../constants/utils.dart';
import '../firebase_options.dart';
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
  bool visible = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _comfirmPasswordController =
      TextEditingController();
  final TextEditingController _doctorIdController = TextEditingController();
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
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
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
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _comfirmPasswordController.dispose();
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
            child: FutureBuilder(
                future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );

                    case ConnectionState.done:
                      return Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Logo(),
                            const Space(),
                            Stack(
                              children: [
                                _image != null
                                    ? CircleAvatar(
                                        radius: 64,
                                        backgroundImage: MemoryImage(_image!),
                                        backgroundColor:
                                            GlobalVariables.primaryColor,
                                      )
                                    : const CircleAvatar(
                                        radius: 64,
                                        backgroundImage: AssetImage(
                                            'assets/images/blank.png'),
                                        backgroundColor:
                                            Colors.deepPurpleAccent),
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
                              controller: _nameController,
                              obscure: false,
                            ),
                            const Space(),
                            MyTextField(
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter Doctor ID";
                                }
                                // Add more validation if needed
                                return null;
                              },
                              inputType: TextInputType.number,
                              label: "Doctor ID",
                              controller: _doctorIdController,
                              obscure: false,
                            ),
                            const Space(),
                            MyTextField(
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter an Email";
                                }
                                if (!RegExp(
                                        "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                    .hasMatch(value)) {
                                  return "Invalid Email !";
                                }
                                return null;
                              },
                              inputType: TextInputType.emailAddress,
                              label: "Email",
                              controller: _emailController,
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
                                  controller: _passwordController,
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
                                    if (_comfirmPasswordController.text !=
                                        _passwordController.text) {
                                      return "Passwords do not match";
                                    }
                                    return null;
                                  },
                                  inputType: TextInputType.text,
                                  label: "Comfirm Password",
                                  controller: _comfirmPasswordController,
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
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return "please Enter Your Contact";
                                    }
                                    if (value.length < 10) {
                                      return "contact is Short";
                                    }

                                    return null;
                                  },
                                  inputType: TextInputType.phone,
                                  label: "contact",
                                  obscure: false,
                                  controller: _contactController,
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
                              onPressed: () => Navigator.pushNamed(
                                  context, DocLoginPage.routeName),
                              child: const Text("Already Have an Account"),
                            )
                          ],
                        ),
                      );
                    default:
                      return const Text("Loading");
                  }
                }),
          ),
        ),
      ),
    );
  }
}
