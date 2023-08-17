import 'package:flutter/foundation.dart';
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
  String? _filePath;
  String? _fileName;
  String? _fileExtension;
  // ... (existing code)

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          if (kIsWeb) {
            // For web, store the bytes of the selected file
            _filePath = result.files.single.bytes!.toString();
          } else {
            // For mobile, store the path of the selected file

            _filePath = result.files.single.path!;
            _fileName = result.files.single.name;
            _fileExtension = _fileName!.split('.').last;
          }
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
            Text('Selected file: $_fileName'),
            Text(
                'File Extension: $_fileExtension'), // ... (existing form fields)

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
