import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../Services/doctor_auth.dart';
import '../constants/custom_button.dart';
import '../constants/custom_textfield.dart';
import '../constants/forgot_password_screen.dart';
import '../constants/logo.dart';
import '../constants/space.dart';
import '../constants/loading.dart';
import '../firebase_options.dart';
import '../pages/verification.dart';
import 'doctor_signup.dart';

class DocLoginPage extends StatefulWidget {
  static const routeName = "/docloginpage";

  const DocLoginPage({super.key});
  @override
  State<DocLoginPage> createState() => _DocLoginPageState();
}

class _DocLoginPageState extends State<DocLoginPage> {
  late double width;
  late double height;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    const Verification();
  }

  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  String error = "";

  Future signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      await AuthMethod().loginDoctor(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Verification(),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, DocLoginPage.routeName);
      }
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
    return loading
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 79, 112, 87),
              title: const Text(' Doctor Login'),
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
                                    label: "Email",
                                    inputType: TextInputType.emailAddress,
                                    obscure: false,
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
                                    controller: _emailController,
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
                                              : const Icon(
                                                  Icons.visibility_off),
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
                                            context, SignUp.routeName),
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
