import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';

class DesktopCameraCapture extends StatefulWidget {
  final Function(Uint8List imageBytes) onCaptured;

  const DesktopCameraCapture({super.key, required this.onCaptured});

  @override
  State<DesktopCameraCapture> createState() => _DesktopCameraCaptureState();
}

class _DesktopCameraCaptureState extends State<DesktopCameraCapture> {
  CameraController? controller;
  bool isCameraInitialized = false;
  String? errorMessage;
  bool isRetrying = false;

  Uint8List? _capturedBytes;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _initializeCamera();
    });
  }

  Future<void> _initializeCamera() async {
    setState(() {
      isRetrying = true;
      isCameraInitialized = false;
      errorMessage = null;
      _capturedBytes = null;
    });

    try {
      print("Step A: Getting available cameras...");
      final cameras = await availableCameras();
      print("Step B: Cameras found: ${cameras.length}");

      if (cameras.isEmpty) {
        print("Step C: No camera found");
        setState(() {
          errorMessage = "No camera found on this device.";
          isRetrying = false;
        });
        return;
      }

      print("Step D: Initializing controller...");
      controller = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
      await controller!.initialize();
      print("Step E: Controller initialized successfully.");

      setState(() {
        isCameraInitialized = true;
        isRetrying = false;
      });
    } on CameraException catch (e) {
      print("CameraException: ${e.code} - ${e.description}");
      setState(() {
        errorMessage = "Camera error: ${e.description ?? e.code}";
        isRetrying = false;
      });
    } catch (e, stack) {
      print("Unexpected error: $e");
      print("Stack trace: $stack");
      setState(() {
        errorMessage = "Unexpected error initializing camera: $e";
        isRetrying = false;
      });
    }

  }

  Future<void> _capturePhoto() async {
    if (controller == null || !isCameraInitialized) return;

    try {
      final XFile file = await controller!.takePicture();
      final bytes = await file.readAsBytes();
      setState(() {
        _capturedBytes = bytes;
      });
      await controller?.dispose();
      controller = null; // Cleanup reference
    } catch (e) {
      setState(() {
        errorMessage = "Failed to capture image.\n\nError: $e";
      });
    }
  }



  void _confirmAttendance() async {
    await controller?.dispose();
    controller = null; // Cleanup reference

    if (_capturedBytes != null) {
      widget.onCaptured(_capturedBytes!);
    }

    if (mounted) Navigator.pop(context);
  }

  void _close() async {
    await controller?.dispose();
    controller = null; // Cleanup reference
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button dismiss
      child: AlertDialog(
        title: const Text("Camera"),
        content: errorMessage != null
            ? _buildErrorUI()
            : _capturedBytes != null
            ? _buildCapturedPreview()
            : _buildLivePreview(),
        actions: _buildActions(),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
        const SizedBox(height: 16),
        Text(
          errorMessage!,
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: isRetrying ? null : _initializeCamera,
          icon: const Icon(Icons.refresh),
          label: const Text("Retry Camera Access"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple.shade100,
            foregroundColor: Colors.deepPurple.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLivePreview() {
    return isCameraInitialized
        ? AspectRatio(
      aspectRatio: controller!.value.aspectRatio,
      child: CameraPreview(controller!),
    )
        : Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        SizedBox(height: 16),
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text("Initializing camera..."),
      ],
    );
  }

  Widget _buildCapturedPreview() {
    return Image.memory(
      _capturedBytes!,
      fit: BoxFit.contain,
    );
  }

  List<Widget> _buildActions() {
    if (_capturedBytes != null) {
      return [
        TextButton(
          onPressed: _initializeCamera,
          child: const Text("Re-capture"),
        ),
        TextButton(
          onPressed: _confirmAttendance,
          child: const Text("Start Attendance"),
        ),
      ];
    } else {
      return [
        TextButton(
          onPressed: isCameraInitialized ? _capturePhoto : null,
          child: const Text("Capture"),
        ),
        TextButton(
          onPressed: _close,
          child: const Text("Cancel"),
        ),
      ];
    }
  }
}
