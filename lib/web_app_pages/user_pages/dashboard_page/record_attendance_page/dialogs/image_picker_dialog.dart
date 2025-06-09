import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../desktop_camera_handler.dart';

void showImageSourceDialog({
  required BuildContext context,
  required Function(Uint8List imageBytes) onImageSelected,
}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title & Subtitle
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Image pickup",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF192A51),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "locate you image source",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF192A51),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Camera & Gallery buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Camera Button
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();

                    bool isMobileWeb = html.window.navigator.userAgent.contains("Mobi");

                    if (isMobileWeb) {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        onImageSelected(bytes);
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => DesktopCameraCapture(onCaptured: onImageSelected),
                      );
                    }
                  },
                  icon: const Icon(Icons.camera_alt, color: Color(0xFF192A51)),
                  label: const Text("Camera", style: TextStyle(color: Color(0xFF192A51))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD5C6E0),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 20,),
                // Gallery Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                    uploadInput.accept = 'image/*';
                    uploadInput.click();

                    uploadInput.onChange.listen((event) {
                      final file = uploadInput.files?.first;
                      if (file != null) {
                        final reader = html.FileReader();
                        reader.readAsArrayBuffer(file);
                        reader.onLoadEnd.listen((_) {
                          onImageSelected(reader.result as Uint8List);
                        });
                      }
                    });
                  },
                  icon: const Icon(Icons.upload_file, color: Color(0xFFD5C6E0),),
                  label: const Text("Upload", style: TextStyle(color: Color(0xFFD5C6E0),)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF192A51),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

    ),
  );
}

