import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:id_scan_collector/services/ocr_services.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String scannedText = '';
  File? selectedImage;

  Future<void> pickImageAndScan() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });

      String extractedText =
          await OCRService().scanTextFromImage(pickedFile.path);
      setState(() {
        scannedText = extractedText;
      });
    } else {
      print("No image selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan ID")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selectedImage != null
                ? Image.file(selectedImage!,
                    width: 200, height: 200, fit: BoxFit.cover)
                : Text("No image selected"),
            SizedBox(height: 20),
            Text(scannedText.isEmpty ? "Scan an ID" : scannedText),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImageAndScan,
              child: Text("Select Image & Scan"),
            ),
          ],
        ),
      ),
    );
  }
}
