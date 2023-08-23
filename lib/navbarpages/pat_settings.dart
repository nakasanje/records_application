import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/patient_auth.dart';
import '../constants/custom_button.dart';
import '../screens/loginpage.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final AuthMethods _authMethods = AuthMethods();
  double _currentTextSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadSavedTextSize();
  }

  Future<void> _loadSavedTextSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double savedTextSize = prefs.getDouble('textSize') ?? 16.0;
    setState(() {
      _currentTextSize = savedTextSize;
    });
  }

  Future<void> _saveTextSize(double textSize) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', textSize);
  }

  Future<void> signOut() async {
    await _authMethods.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  // Add a function to open the text size settings screen
  void _openTextSizeSettings() async {
    double newSize = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextSizeSettings(currentSize: _currentTextSize),
      ),
    );

    setState(() {
      _currentTextSize = newSize;
    });
    await _saveTextSize(newSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 79, 112, 87),
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              onTap: signOut,
              label: "Sign Out",
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openTextSizeSettings,
              child: const Text('Text Size Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class TextSizeSettings extends StatefulWidget {
  final double currentSize;

  const TextSizeSettings({Key? key, required this.currentSize})
      : super(key: key);

  @override
  State<TextSizeSettings> createState() => _TextSizeSettingsState();
}

class _TextSizeSettingsState extends State<TextSizeSettings> {
  double _textSize = 16.0;

  @override
  void initState() {
    super.initState();
    _textSize = widget.currentSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Size Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adjust the text size:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Slider(
              value: _textSize,
              onChanged: (newSize) {
                setState(() {
                  _textSize = newSize;
                });
              },
              min: 12.0,
              max: 24.0,
              divisions: 6,
              label: _textSize.toStringAsFixed(1),
            ),
            const SizedBox(height: 20),
            Text(
              'Sample Text',
              style: TextStyle(fontSize: _textSize),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _textSize); // Return selected size
              },
              child: const Text('Apply Text Size'),
            ),
          ],
        ),
      ),
    );
  }
}
