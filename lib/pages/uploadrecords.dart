import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../constants/custom_button.dart';
import '../constants/space.dart';

class UploadRecords extends StatefulWidget {
  static const String routeName = '/uploadRecords';

  const UploadRecords({super.key});

  // ... (existing code)

  @override
  State<UploadRecords> createState() => _UploadRecordsState();
}

class _UploadRecordsState extends State<UploadRecords> {
  // ... (existing code)

  String? _filePath;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          _filePath = result.files.single.path!;
        });
      }
    } catch (e) {
      print('File picking error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Records')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ... (existing form fields)

            CustomButton(
              onTap: _pickFile,
              label: 'Pick File',
            ),

            const SizedBox(height: 20), // Add vertical spacing

            if (_filePath != null) Text('Selected file: $_filePath'),

            const Space(), // Add flexible space to center buttons
          ],
        ),
      ),
    );
  }
}
