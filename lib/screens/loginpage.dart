import 'package:firebase_auth/firebase_auth.dart';
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

import '../constants/space.dart';
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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  String error = "";

  Future signIn() async {
    try {
      if (_formKey.currentState!.validate()) {
        FocusManager.instance.primaryFocus!.unfocus();
        setState(() {
          loading = true;
        });
        await AuthMethods().loginPatientUser(
          email: emailController.text,
          password: passwordController.text,
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
    emailController.dispose();
    passwordController.dispose();
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
                        onPressed: () =>
                            Navigator.pushNamed(context, PSignUp.routeName),
                        child: const Text("Don't Have Account? SignUp"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        ),
                        child: const Text("Forgot Password !"),
                      ),
                    ],
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
