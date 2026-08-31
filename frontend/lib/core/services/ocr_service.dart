import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  OcrService._();

  static final ImagePicker _imagePicker = ImagePicker();

  static final TextRecognizer _textRecognizer =
      TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  // ==========================================
  // Scan text from camera
  // ==========================================

  static Future<String?> scanFromCamera() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (image == null) {
      return null;
    }

    return extractText(image.path);
  }

  // ==========================================
  // Scan text from gallery / screenshot
  // ==========================================

  static Future<String?> scanFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (image == null) {
      return null;
    }

    return extractText(image.path);
  }

  // ==========================================
  // Extract text from image
  // ==========================================

  static Future<String?> extractText(
    String imagePath,
  ) async {
    final file = File(imagePath);

    if (!await file.exists()) {
      throw Exception(
        'The selected image could not be found.',
      );
    }

    final inputImage = InputImage.fromFilePath(
      imagePath,
    );

    final recognizedText =
        await _textRecognizer.processImage(
      inputImage,
    );

    final text = recognizedText.text.trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  // ==========================================
  // Dispose OCR engine
  // ==========================================

  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}