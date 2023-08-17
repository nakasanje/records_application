import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:records_application/pages/patientdetails.dart';
import 'package:records_application/pages/patientrecords.dart';
import 'package:records_application/pages/receiverecords.dart';
import 'package:records_application/pages/sharerecords.dart';
import 'package:records_application/pages/uploadrecords.dart';
import 'package:records_application/pages/verification.dart';
import 'package:records_application/providers/patient_user_provider.dart';
import 'package:records_application/providers/user_provider.dart';
import 'package:records_application/router.dart';
import 'package:records_application/screens/loginpage.dart';
import 'package:records_application/screens/doctor_signup.dart';
import 'package:provider/provider.dart';
import 'package:records_application/screens/doctorlogin.dart';
import 'package:records_application/screens/receivingdoc.dart';
import 'package:records_application/selection.dart';

import 'firebase_options.dart';
import 'navbarpages/notifications.dart';
import 'navbarpages/settings.dart';
import 'providers/doctor_provider.dart';
import 'screens/doctor_dashboard.dart';
import 'screens/patientsignup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PatientUserProvider(),
        ),
        // Add other providers here if needed...
      ],
      child: MaterialApp(
        onGenerateRoute: (settings) => generateRoute(settings),
        title: 'Hospital Records',
        theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            primaryColor: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Poppins'),
        debugShowCheckedModeBanner: false,
        home: const SelectionPage(),
        routes: {
          SignUp.routeName: (context) => const SignUp(),
          // ignore: equal_keys_in_map
          PSignUp.routeName: (context) => const PSignUp(),
          LoginPage.routeName: (context) => const LoginPage(),
          DocLoginPage.routeName: (context) => const DocLoginPage(),
          PatientRecords.routeName: (context) => const PatientRecords(),
          ShareRecords.routeName: (context) => const ShareRecords(),
          UploadRecords.routeName: (context) => const UploadRecords(),
          Verification.routeName: (context) => const Verification(),
          ReceivingDoctorPage.routeName: (context) =>
              const ReceivingDoctorPage(),
          //'/home': (context) => const HomePage(),
          '/settings': (context) => const Settings2(),
          '/notifications': (context) => const Notifications(),
          '/home': (context) => const Dashboard(),
          '/PatientDetails': (context) => const PatientDetails(),
          '/ReceivingDoctorScreen': (context) => const ReceivingDoctorsScreen()
        },
      ),
    );
  }
}
