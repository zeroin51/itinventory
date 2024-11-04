import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:crop_image/crop_image.dart';  // Import package untuk crop image


class CropImagePage extends StatelessWidget {
  final Uint8List imageBytes;
  final CropController cropController;
  final Function(Uint8List) onImageCropped;

  const CropImagePage({
    Key? key,
    required this.imageBytes,
    required this.cropController,
    required this.onImageCropped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              // Menggunakan croppedBitmap() untuk mendapatkan hasil cropping
              final croppedBitmap = await cropController.croppedBitmap();
              // ignore: unnecessary_null_comparison
              if (croppedBitmap != null) {
                // Konversi bitmap ke Uint8List (menggunakan toByteData)
                final croppedBytes = await croppedBitmap.toByteData(format: ImageByteFormat.png);
                if (croppedBytes != null) {
                  onImageCropped(croppedBytes.buffer.asUint8List());
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: CropImage(
          controller: cropController,
          image: Image.memory(imageBytes),
        ),
      ),
    );
  }
}