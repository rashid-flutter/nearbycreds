import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nearbycreds/src/features/scanner/screen/scanner_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _hasScanned = false;
  final ImagePicker _picker = ImagePicker();

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null) {
      _hasScanned = true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned: $code')),
      );

      try {
        // Try parsing the QR code as JSON
        final Map<String, dynamic> parsedData = jsonDecode(code);
        // Navigate directly to ScannerDetailsScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScannerDetailsScreen(parsedData: parsedData),
          ),
        );
      } catch (e) {
        // If it's not JSON (for example, GPay QR), show the raw content
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScannerDetailsScreen(parsedData: {'rawCode': code}),
          ),
        );
      }
    }
  }

  Future<void> _scanFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final File file = File(pickedFile.path);

      final String? result = await _scanQrFromImage(file);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanned from gallery: $result')),
        );
        log(result);

        try {
          // Try parsing the QR code as JSON
          final Map<String, dynamic> parsedData = jsonDecode(result);
          context.push('/details', extra: parsedData);
        } catch (e) {
          // If it's not JSON (for example, GPay QR), show the raw content
          context.push('/details', extra: {'rawCode': result});
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No QR code found in image')),
        );
      }
    }
  }

  Future<String?> _scanQrFromImage(File file) async {
    try {
      final inputImage = mlkit.InputImage.fromFile(file);
      final barcodeScanner = mlkit.BarcodeScanner();
      final barcodes = await barcodeScanner.processImage(inputImage);
      debugPrint('Barcodes found: ${barcodes.length}');
      await barcodeScanner.close();

      for (final barcode in barcodes) {
        debugPrint('Barcode found: ${barcode.rawValue}');
        return barcode.rawValue;
      }

      return null;
    } catch (e) {
      debugPrint('Error decoding QR code: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _scanFromGallery,
                    child: const Icon(Icons.image, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
