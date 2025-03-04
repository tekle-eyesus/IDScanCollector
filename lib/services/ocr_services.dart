import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  Future<String> scanTextFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    return recognizedText.text; // Extracted text
  }
}
