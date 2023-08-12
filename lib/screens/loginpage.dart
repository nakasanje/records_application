import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:records_application/constants/images.dart';

import 'package:records_application/screens/patientsignup.dart';
//import 'package:records_application/screens/patient_dashboard.dart';

import '../Services/patient_auth.dart';
import '../constants/custom_button.dart';
import '../constants/custom_textfield.dart';
import '../constants/forgot_password_screen.dart';
import '../constants/logo.dart';
import '../constants/space.dart';
import '../firebase_options.dart';
import '../pages/pat_verification.dart';

//import 'doctor_dashboard.dart';

class LoginPage extends StatefulWidget {
  static const routeName = "/loginpage";

  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double width;
  late double height;
  bool visible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  String error = "";

  Future signIn() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          loading = true;
        });
        await AuthMethods().loginPatientUser(
          email: _emailController.text,
          password: _passwordController.text,
        );

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PatVerification(),
            ),
          );
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, LoginPage.routeName);
        }
      }
      // ignore: use_build_context_synchronously
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: "${e.message}",
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color.fromARGB(255, 132, 63, 128),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 79, 112, 87),
        title: const Text(' Patient Login'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 60),
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
                            CustomButton(
                              onTap: signIn,
                              label: "Login",
                            ),
                            const SizedBox(height: 30),
                            Wrap(
                              spacing: 20,
                              direction: Axis.horizontal,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, PSignUp.routeName),
                                  child: const Text("Create an Account"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordPage(),
                                    ),
                                  ),
                                  child: const Text("Forgot Password !"),
                                ),
                              ],
                            )
                          ],
                        ),
                      );

                    default:
                      return const Text("Loading.......");
                  }
                }),
          ),
        ),
      ),
    );
  }
}