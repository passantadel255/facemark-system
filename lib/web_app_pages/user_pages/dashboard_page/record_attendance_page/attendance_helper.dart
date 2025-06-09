// Import necessary Dart and Flutter libraries
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/record_attendance_page/dialogs/show_save_confirmation_dialog.dart';
import 'package:facemark/custom_widgets/custom_snack_bar.dart';
import 'package:facemark/custom_widgets/loading.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:js' as js;

// Data model for each student face
class StudentFace {
  final double x, y, width, height;
  final String index;
  final double confidence;
  String label;
  bool isAuth;
  final Uint8List croppedImage;

  StudentFace({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.index,
    required this.label,
    required this.confidence,
    required this.isAuth,
    required this.croppedImage,
  });
}

// Crop a face image from a ui.Image using a Rect
Future<Uint8List> cropImageFromUiImage(ui.Image image, Rect faceRect) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final src = faceRect;
  final dst = Rect.fromLTWH(0, 0, faceRect.width, faceRect.height);
  final paint = Paint();
  canvas.drawImageRect(image, src, dst, paint);
  final picture = recorder.endRecording();
  final croppedImage = await picture.toImage(
    faceRect.width.toInt(),
    faceRect.height.toInt(),
  );
  final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

// Resize image to desired dimensions using filter
Future<Uint8List> resizeImageWithFilter(Uint8List inputBytes, int targetWidth, int targetHeight) async {
  final codec = await ui.instantiateImageCodec(inputBytes, targetWidth: targetWidth, targetHeight: targetHeight);
  final frame = await codec.getNextFrame();
  final img = frame.image;
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

// Add padding to face Rect ensuring it stays within bounds
Rect addPadding(Rect rect, double paddingFraction, ui.Image img) {
  final padX = rect.width * paddingFraction;
  final padY = rect.height * paddingFraction;
  final newX = (rect.left - padX).clamp(0.0, img.width.toDouble());
  final newY = (rect.top - padY).clamp(0.0, img.height.toDouble());
  final newW = (rect.width + 2 * padX).clamp(1.0, img.width - newX);
  final newH = (rect.height + 2 * padY).clamp(1.0, img.height - newY);
  return Rect.fromLTWH(newX, newY, newW, newH);
}

// Filter duplicate student faces by keeping only the most confident detection
List<StudentFace> filterDuplicateIndexesByConfidence(List<StudentFace> faceBoxes) {
  final Map<String, List<StudentFace>> grouped = {};
  for (var face in faceBoxes) {
    grouped.putIfAbsent(face.index, () => []).add(face);
  }
  final List<StudentFace> result = [];
  for (final entry in grouped.entries) {
    final faces = entry.value;
    faces.sort((a, b) => b.confidence.compareTo(a.confidence));
    final best = faces.first;
    result.add(best);
    for (var i = 1; i < faces.length; i++) {
      final f = faces[i];
      result.add(StudentFace(
        x: f.x, y: f.y, width: f.width, height: f.height, index: f.index,
        label: f.label, confidence: f.confidence, croppedImage: f.croppedImage,
        isAuth: false,
      ));
    }
  }
  return result;
}

// Save attendance and absence data to Firestore
Future<void> saveReport(context, {attendees, absent, lecId, courseCode}) async {
  final confirmed = await showSaveConfirmationDialog(context);
  if (!confirmed) return;
  showLoading(context);
  try {
    final attendanceData = attendees.map((student) => {
      'id': student['id'].toString(),
      'manually': student['manually'] ?? false,
    }).toList();
    final absenceData = absent.map((student) => {
      'id': student['id'].toString(),
      'manually': student['manually'] ?? false,
    }).toList();
    final query = await FirebaseFirestore.instance
        .collection('classes')
        .where('id', isEqualTo: lecId)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final docRef = query.docs.first.reference;
      await docRef.update({
        'st_attendance': attendanceData,
        'st_absence': absenceData,
      });
      await calculateAbsenceRate(context, attendanceData, absenceData, courseCode);
      Navigator.of(context).pop(); // close loading
      Navigator.of(context).pop(); // close dialog/page
      showCustomSnackBar(context, "Report saved successfully!", isSuccess:true);
    } else {
      Navigator.of(context).pop();
      showCustomSnackBar(context, "Lecture not found.", isSuccess: false);
    }
  } catch (e) {
    Navigator.of(context).pop();
    showCustomSnackBar(context, "Error saving report: $e", isSuccess: false);
  }
}

// Update student records with new attendance statistics
Future<void> calculateAbsenceRate(context, attendanceData, absenceData, courseCode) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final courseQuery = await firestore.collection('courses')
        .where('code', isEqualTo: courseCode)
        .limit(1)
        .get();
    if (courseQuery.docs.isEmpty) throw Exception("Course with code $courseCode not found.");
    final courseDoc = courseQuery.docs.first;
    final courseRef = courseDoc.reference;
    final courseData = courseDoc.data();
    final courseName = courseData['name'] ?? courseCode;
    int newTotalClasses = (courseData['total_classes'] ?? 0) + 1;
    await courseRef.update({'total_classes': newTotalClasses});
    final now = Timestamp.now();

    Future<void> updateStudent(String studentId, bool attended) async {
      final userQuery = await firestore.collection('users')
          .where('id', isEqualTo: studentId)
          .limit(1)
          .get();
      if (userQuery.docs.isEmpty) return;
      final userRef = userQuery.docs.first.reference;
      final userData = userQuery.docs.first.data();
      final rawRates = userData['attendance_rates'] ?? [];
      final List<Map<String, dynamic>> rates = rawRates.map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r)).toList();

      int index = rates.indexWhere((r) => r['code'] == courseCode);
      if (index == -1) {
        rates.add({
          'code': courseCode,
          'name': courseName,
          'attend_num': attended ? 1 : 0,
          'total_classes': newTotalClasses,
          'attend_per': attended ? 100 : 0,
          'last_attended': now,
        });
      } else {
        int attendNum = rates[index]['attend_num'] ?? 0;
        if (attended) attendNum += 1;
        rates[index] = {
          ...rates[index],
          'attend_num': attendNum,
          'total_classes': newTotalClasses,
          'attend_per': ((attendNum / newTotalClasses) * 100).round(),
          'last_attended': now,
        };
      }

      await userRef.update({'attendance_rates': rates});
    }

    for (final student in attendanceData) {
      await updateStudent(student['id'], true);
    }
    for (final student in absenceData) {
      await updateStudent(student['id'], false);
    }

  } catch (e) {
    showCustomSnackBar(context, "Failed to calculate absence rate: $e", isSuccess: false);
  }
}

// Check if the face recognition model has loaded in JS context
bool get isModelLoaded {
  try {
    final result = js.context['modelLoaded'];
    return result == true;
  } catch (e) {
    return false;
  }
}


