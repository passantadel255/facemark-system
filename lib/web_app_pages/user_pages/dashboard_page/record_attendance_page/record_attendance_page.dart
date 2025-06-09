import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/record_attendance_page/dialogs/add_absent_students_dialog.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/record_attendance_page/dialogs/delete_confirmation_dialog.dart';
import 'package:facemark/custom_widgets/custom_rich_text.dart';
import 'package:facemark/custom_widgets/custom_snack_bar.dart';
import 'package:facemark/components/lightbox_image_viewer.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:js' as js;
import 'package:facemark/custom_widgets/custom_back_button.dart';
import 'package:facemark/custom_widgets/custom_elevated_button.dart';
import 'package:facemark/components/headers.dart';
import 'package:facemark/components/sidebar.dart';
import 'package:facemark/services/converting_functions.dart';

import 'attendance_helper.dart';
import 'dialogs/image_picker_dialog.dart';


class RecordAttendancePage extends StatefulWidget {
  final dynamic lecData;
  const RecordAttendancePage({super.key, required this.lecData});

  @override
  State<RecordAttendancePage> createState() => _RecordAttendancePageState();
}

class _RecordAttendancePageState extends State<RecordAttendancePage> {
  final ScrollController _scrollController = ScrollController();

  bool isAttendance = false;
  var st_attendance;
  var st_absence;

  Uint8List? _pickedImageBytes;
  List<StudentFace> _studentFaces = [];
  bool _isFaceDetecting = false;
  bool _isFaceRecognizing = false;

  List studentsData = [];
  List attendees = [];
  List absent = [];
  List unauthorized = [];

  double imageOriginalWidth = 1;
  double imageOriginalHeight = 1;
  int detectedFacesNum = 0;


  /// Retrieves student data from Firestore based on provided student IDs
  Future<void> getStudentData() async {

    for (String studentId in widget.lecData['students']) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: studentId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data();
          final String fullName = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}';

          //print("image link: ${data['image_url']}");

          studentsData.add({
            "name": fullName.trim(),
            "email": data['email'] ?? 'unknown@email.com',
            "id": data['id'] ?? '',
            "image": data['image_url'] ?? '',
            "manually": false,
            "index": data['index'] ?? '',
          });
        }
      } catch (e) {
        print("Error querying student with id $studentId: $e");
      }
    }
  }

  /// Initiates image picking, decoding, validation, and face detection
  void _showImageSourceSelection() {
    showImageSourceDialog(
      context: context,
      onImageSelected: (Uint8List imageBytes) async {
        _handleAttendanceReport(imageBytes);
      },
    );
  }

  /// Handles the attendance report
  _handleAttendanceReport  (Uint8List imageBytes) async {
    // Reset UI state before processing
    setState(() {
      _isFaceDetecting = true;
      _pickedImageBytes = null;
      isAttendance = false;
      st_attendance = 'N/A';
      st_absence = 'N/A';
      _studentFaces.clear();
      attendees = studentsData;
      absent.clear();
      unauthorized.clear();

    });

    try {
      // Ensure the image is not empty
      if (imageBytes.isEmpty) {
        throw Exception("Selected image is empty or corrupted.");
      }

      // Decode image to validate dimensions
      final decodedImage = await decodeImageFromList(imageBytes);

      if (decodedImage.width == 0 || decodedImage.height == 0) {
        throw Exception("Invalid image dimensions.");
      }

      // Save image and dimension state
      setState(() {
        _pickedImageBytes = imageBytes;
        imageOriginalWidth = decodedImage.width.toDouble();
        imageOriginalHeight = decodedImage.height.toDouble();
      });

      // Run face detection pipeline
      await runFaceDetection(imageBytes);

      _studentFaces = filterDuplicateIndexesByConfidence(_studentFaces);

      checkStudentAuth();

      // Indicate attendance was recorded
      setState(() {
        isAttendance = true;
        st_attendance = attendees.length.toString();
        st_absence = absent.length.toString();
      });

    } catch (e) {
      debugPrint("Image processing error: $e");
      showCustomSnackBar(context,"Image Error: ${e.toString()}", isSuccess: false);
    } finally {
      setState(() {
        _isFaceDetecting = false;
        _isFaceRecognizing = false;
      });
    }
  }

  /// Detects and identifies faces from the provided image using Firebase Vision + Teachable Machine
  Future<void> runFaceDetection(Uint8List imageBytes) async {

    // 1. Convert image to base64 for Firebase function
    final base64Image = base64Encode(imageBytes);
    try {
      print("Start Face Detection");

      // 2. Call Firebase Cloud Function to detect faces
      final callable = FirebaseFunctions.instance.httpsCallable('detectFaces');
      final response = await callable.call({"base64Image": base64Image});
      final data = response.data;

      // 3. Validate cloud function response
      if (data['success'] != true || data['faces'] == null) {
        throw Exception(data['error'] ?? "Face detection failed");
      }

      final faces = data['faces'] as List;
      if (faces.isEmpty) {
        throw Exception("No faces detected.");
      }

      setState(() {
        _isFaceDetecting = false;
        _isFaceRecognizing = true;
        detectedFacesNum = faces.length;
      });
      print("Detected ${faces.length} faces");

      // 4. Decode original image to ui.Image to allow cropping
      final uiImage = await decodeImageFromList(imageBytes);


      // 5. Process each detected face one by one
      for (final face in faces) {
        final boundingPoly = face['boundingPoly']['vertices'];

        // 5.1 Extract bounding box coordinates
        final x1 = (boundingPoly[0]['x'] ?? 0).toDouble();
        final y1 = (boundingPoly[0]['y'] ?? 0).toDouble();
        final x2 = (boundingPoly[2]['x'] ?? 0).toDouble();
        final y2 = (boundingPoly[2]['y'] ?? 0).toDouble();

        // 5.2 Clamp size to avoid invalid or too small boxes
        final width = (x2 - x1).clamp(10, uiImage.width - x1);
        final height = (y2 - y1).clamp(10, uiImage.height - y1);
        final faceRect = Rect.fromLTWH(x1, y1, width, height);

        // 5.3 Add padding (10%) to the face box for better model accuracy
        final paddedRect = addPadding(faceRect, 0.1, uiImage);

        // 5.4 Crop and resize the padded face region to 224x224 (Teachable Machine input size)
        final croppedBytes = await cropImageFromUiImage(uiImage, paddedRect);
        final resizedFaceBytes = await resizeImageWithFilter(croppedBytes, 224, 224);

        // 5.5 Run recognition on the face (via JS & Teachable Machine)
        final labelData = await runFaceRecognition(resizedFaceBytes);

        // 5.6 Decode JSON response (label and confidence score)
        final decoded = jsonDecode(labelData);

        // 5.7 Find the matching student by index
        final matchedStudent = studentsData.firstWhere(
              (s) => s['index'].toString() == decoded['label'].toString(),
          orElse: () => null,
        );

        final name = matchedStudent?['name'];
        final id = matchedStudent?['id'];

        // 5.8 Save the face result into our local list
        _studentFaces.add(StudentFace(
          x: x1,
          y: y1,
          width: width,
          height: height,
          index: decoded['label'],
          confidence: (decoded['score'] * 100),
          croppedImage: resizedFaceBytes,
          label: "$name\n$id",
          isAuth: true, // Initially assume authenticated
        ));

      }

      // 6. Finalize list: remove any invalid results (0 width faces)
      setState(() {
        _studentFaces = _studentFaces.where((f) => f.width > 0).toList();
      });

    } catch (e) {
      // 7. Show error to user if anything fails
      print("Face Detection Error: $e");
      showCustomSnackBar(context, "Error: $e", isSuccess: false);
      setState(() {
        _isFaceDetecting = false;
        _isFaceRecognizing = false;
      });
    }
  }

  /// Sends a base64 encoded face to Teachable Machine modle for recognition
  Future<String> runFaceRecognition(Uint8List faceImageBytes) async {
    // Ensure model is loaded
    if (!isModelLoaded) await js.context.callMethod('loadModel');

    // Convert to base64
    final base64Image = "data:image/png;base64,${base64Encode(faceImageBytes)}";

    // Handle callback-style async using Completer
    final completer = Completer<String>();

    js.context.callMethod('predictFaceBase64', [
      base64Image,
          (label) {
        completer.complete(label.toString());
      }
    ]);
    print("until now every thing work smooth, then freezing while next step, only for first time");
    return await completer.future;
  }

  /// Check Student Authorization
  void checkStudentAuth() {

    for (var face in _studentFaces) {
      bool matched = false;

      for (var student in attendees) {
        if (student['index'].toString() == face.index.toString() && face.isAuth) {
          matched = true;

          // Attach cropped image to attendee
          student['cropped_image'] = face.croppedImage;

          break;
        }
      }

      //print("=======================");

      // If no match found → mark as unauthorized
      if (!matched) {
        face.isAuth = false;
        unauthorized.add(face.croppedImage);
      }
    }

    // Remove students without a cropped image & move them to Absent
    attendees.removeWhere((student) {
      final isMissingImage = student['cropped_image'] == null ||
          (student['cropped_image'] is Uint8List && (student['cropped_image'] as Uint8List).isEmpty);

      if (isMissingImage) {
        absent.add(student);
      }

      return isMissingImage;
    });

    // Optional debug log
    print("Authenticated: ${_studentFaces.where((f) => f.isAuth).length}");
    print("Unauthenticated faces: ${unauthorized.length}");
    print("Absent students: ${absent.length}");
  }



  @override
  void initState() {
    super.initState();
    isAttendance = widget.lecData['st_attendance'] != null || widget.lecData['st_absence'] != null;
    st_attendance = isAttendance ? widget.lecData['st_attendance'].length.toString() : 'N/A';
    st_absence = isAttendance ? widget.lecData['st_absence'].length.toString() : 'N/A';
    if (!isModelLoaded) {
      js.context.callMethod('loadModel');
    }
    getStudentData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Row(
        children: [
          Sidebar(toggleMenu: () => setState(() {isMenu = !isMenu;})),
          Expanded(
            child: Column(
              children: [
                const HeaderBar(title: "Record Attendance", icon: Icons.history_edu_outlined),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: [
                        CustomBackButton(),
                        SizedBox(height: 25),
                        Expanded(
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            thickness: 8,
                            radius: Radius.circular(4),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 1000,
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: Column(
                                        children: [
                                          // course details
                                          CourseCard(),
                                          const SizedBox(height: 25),

                                          // student image
                                          if (isAttendance)
                                            ImageContainer(),

                                          // waiting for face detection
                                          if (_isFaceDetecting)
                                            Padding(
                                              padding: EdgeInsets.only(top: 150, bottom: 50),
                                              child: Column(
                                                children: [
                                                  CircularProgressIndicator(),
                                                  SizedBox(height: 20),
                                                  Text('Detecting Students Faces...',
                                                    style: TextStyle(
                                                      fontSize:  16,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600  ,
                                                      color: Color(0xFF192A51),
                                                      shadows:  [
                                                        Shadow(
                                                          offset: const Offset(0, 4),
                                                          blurRadius: 4,
                                                          color: Colors.black.withAlpha(64),
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),

                                          // waiting for face recognition
                                          if (_isFaceRecognizing)
                                            Padding(
                                              padding: EdgeInsets.only(top: 150, bottom: 50),
                                              child: Column(
                                                children: [
                                                  Text('$detectedFacesNum Students Detected.',
                                                    style: TextStyle(
                                                      fontSize:  16,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600  ,
                                                      color: Color(0xFF192A51),
                                                      shadows:  [
                                                        Shadow(
                                                          offset: const Offset(0, 4),
                                                          blurRadius: 4,
                                                          color: Colors.black.withAlpha(64),
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 20),
                                                  Text('Recognizing Students Faces...',
                                                    style: TextStyle(
                                                      fontSize:  16,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600  ,
                                                      color: Color(0xFF192A51),
                                                      shadows:  [
                                                        Shadow(
                                                          offset: const Offset(0, 4),
                                                          blurRadius: 4,
                                                          color: Colors.black.withAlpha(64),
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),

                                          if (isAttendance)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 50.0),
                                            child: Wrap(
                                              spacing: 60,
                                              runSpacing: 35,
                                              children: [
                                                AttendeesSection(),
                                                UnauthorizedSection(),
                                              ],
                                            ),
                                          ),

                                          // "Pick Student Image" "Retake the Image" Button
                                          if (!_isFaceDetecting && !_isFaceRecognizing)
                                            Padding(
                                            padding: EdgeInsets.only(
                                              top: !isAttendance ? 150.0 : 0,
                                            ),
                                            child: CustomElevatedButton(
                                              text: !isAttendance
                                                  ? 'Pick Students Image'
                                                  : 'Retake the Image',
                                              onPressed: _showImageSourceSelection,
                                              width: !isAttendance ? 500 : 300,
                                            ),
                                          ),

                                          // "Save Report" Button
                                          if (isAttendance && attendees.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 20
                                            ),
                                            child: CustomElevatedButton(
                                              text: 'Save Report',
                                              onPressed: (){
                                                saveReport(context, attendees: attendees, absent: absent, lecId: widget.lecData['id'], courseCode: widget.lecData['course_code']);
                                              },
                                              width: 300,
                                            ),
                                          ),
                                          SizedBox(height: 50),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget CourseCard(){
    final screenWidth = MediaQuery.of(context).size.width;
    // Determine if the screen is mobile or desktop
    final isMobile = screenWidth <= 677;

    return Container(
      constraints: BoxConstraints(maxWidth: 900),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 4,
            color: Colors.black.withAlpha(50),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(18.0),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: const Color(0xffF2F4F8),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                  color: Colors.black.withAlpha(50),
                ),
              ],
            ),
            child: Text('${widget.lecData['name']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows:  [
                  Shadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    color: Colors.black.withAlpha(64),
                  ),
                ],

              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.all(25.0),
            child: Wrap(
              alignment: isMobile ? WrapAlignment.center : WrapAlignment.spaceBetween,
              spacing: 25,
              runSpacing: 25,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing:10,
                  children: <Widget>[
                    CustomRichText(title: 'Code', value: widget.lecData['course_code']),
                    CustomRichText(title: 'Student number', value: widget.lecData['students'].length.toString()),
                    CustomRichText(title: 'Room', value: widget.lecData['room']),

                  ],
                ),
                !isMobile ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing:15,
                  children: <Widget>[
                    CustomRichText(title: 'Number of attendees', value: st_attendance),
                    CustomRichText(title: 'Number of absentees', value: st_absence),
                  ],
                ):
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing:6,
                  children: <Widget>[
                    Text(getDateFromTimestamp(widget.lecData['start_date']).toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                    SizedBox(height: 2),
                    CustomRichText(title: 'Start', value: getTimeFromTimestamp(widget.lecData['start_date']).toString(),size: 15,),
                    CustomRichText(title: 'End', value: getTimeFromTimestamp(widget.lecData['end_date']).toString(),size: 15,),

                  ],
                ),
                !isMobile ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing:6,
                  children: <Widget>[
                    Text(getDateFromTimestamp(widget.lecData['start_date']).toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                    SizedBox(height: 2),
                    CustomRichText(title: 'Start', value: getTimeFromTimestamp(widget.lecData['start_date']).toString(),size: 15,),
                    CustomRichText(title: 'End', value: getTimeFromTimestamp(widget.lecData['end_date']).toString(),size: 15,),

                  ],
                ):
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing:15,
                  children: <Widget>[
                    CustomRichText(title: 'Number of attendees', value: st_attendance),
                    CustomRichText(title: 'Number of absentees', value: st_absence),
                  ],
                ),
              ],

            ),
          ),

        ],
      ),
    );
  }

  Widget AttendeesSection (){
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F7F9), // Pale pink background
              borderRadius:  BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(64),
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(
              'Attendees : ${attendees.length}/${widget.lecData['students'].length}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF192A51), // Dark blue
              ),
            ),
          ),

          // body
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Color(0xFFF5F7F9), // Pale pink background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(64),
                  offset: Offset(0, 6),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: attendees.isNotEmpty ?
                  ListView.builder(
                    itemCount: attendees.length,
                    itemBuilder: (context, index) {
                      final student = attendees[index];
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFFE0FFDE).withOpacity(.25), // Soft green background
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withAlpha(38), // Stroke color with 15% transparency
                              width: 1, // Stroke width
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF192A51),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    if (!student['manually']) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => LightBoxImageViewer(
                                          imageBytes: student['cropped_image']!,
                                          faceBoxes: [],
                                          imageOriginalWidth: 225,
                                          imageOriginalHeight: 225,
                                          showFaceLabels: false,
                                        ),
                                      );
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: student['manually']
                                        ? Image.network(
                                      student['image'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                      },
                                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error, color: Colors.red)),
                                    )
                                        : Image.memory(
                                      student['cropped_image'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        children: [
                                          TextSpan(text: 'Name: '),
                                          TextSpan(
                                            text: student['name'],
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'email: ${student['email']}',
                                      style: TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                    Text(
                                      'id: ${student['id']}',
                                      style: TextStyle(fontSize: 12, color: Colors.black54),
                                    ),

                                  ],
                                ),
                              ),
                              SizedBox(width: 12),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => DeleteConfirmationDialog(
                                          student: student,
                                          onDelete: () {
                                            setState(() {
                                              attendees.removeAt(index);
                                              absent.add({
                                                ...student,
                                                "manually": true,
                                              });

                                              st_attendance = attendees.length.toString();
                                              st_absence = absent.length.toString();

                                              // Mark related face as unauthenticated
                                              for (var face in _studentFaces) {
                                                if (face.index.toString() == student['index'].toString()) {
                                                  face.isAuth = false;
                                                  break;
                                                }
                                              }
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.close, size: 16, color: Colors.grey[700]),
                                  ),

                                  SizedBox(height: 10,),
                                  if (student['manually'])
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        'added\nmanually',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                      :Center(
                    child: Text("There are no students present, or any faces are not recognized.",
                      style: TextStyle(
                        fontSize:  18,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500  ,
                        color: Color(0xFF192A51),
                        shadows:  [
                          Shadow(
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                            color: Colors.black.withAlpha(64),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF192A51), // Dark blue
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 4,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddAbsentStudentsDialog(
                          absentStudents: absent,
                          onConfirm: (selected) {
                            setState(() {
                              attendees.addAll(selected.map((s) {
                                final student = Map<String, dynamic>.from(s);
                                return {
                                  ...student,
                                  "manually": true,
                                };
                              }));
                              absent.removeWhere((a) => selected.any((s) => s['id'] == a['id']));

                              st_attendance = attendees.length.toString();
                              st_absence = absent.length.toString();
                            });
                          },
                        ),
                      );
                    },
                    child: Text(
                      '+ Add Student',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget UnauthorizedSection (){
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F7F9), // Pale pink background
              borderRadius:  BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(64),
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(
              'UnAuthorized:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          // body
          Container(
            height: 380,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Color(0xFFF5F7F9), // Pale pink background
              borderRadius:  BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(64),
                  offset: Offset(0, 6),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: unauthorized.isNotEmpty ?
            ListView.builder(
              itemCount: unauthorized.length,
              itemBuilder: (context, index) {
                final image = unauthorized[index];
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(right: 12),

                    decoration: BoxDecoration(
                      color: Color(0xFFFFF1F3), // Light pink background
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Color(0xFF192A51),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                                borderRadius: BorderRadius.circular(12),

                                onTap: (){
                                  showDialog(
                                    context: context,
                                    builder: (context) => LightBoxImageViewer(
                                      imageBytes: image!,
                                      faceBoxes: [],
                                      imageOriginalWidth: 225,
                                      imageOriginalHeight: 225,
                                      showFaceLabels: false,
                                    ),
                                  );

                                },
                                child:  ClipRRect(
                                  borderRadius: BorderRadius.circular(12),

                                  child: Image.memory(
                                    image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                            )
                        ),

                        SizedBox(width: 16),
                        Text(
                          'Non Authorized for this Class',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF192A51), // Dark blue
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                :Center(
              child: Text("No unauthorized students",
                style: TextStyle(
                  fontSize:  18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500  ,
                  color: Color(0xFF192A51),
                  shadows:  [
                    Shadow(
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                      color: Colors.black.withAlpha(64),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ImageContainer(){
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      constraints: BoxConstraints(maxWidth: 600, maxHeight: 400),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerWidth = constraints.maxWidth;
          final containerHeight = constraints.maxHeight;

          final imageAspectRatio = imageOriginalWidth / imageOriginalHeight;
          final containerAspectRatio = containerWidth / containerHeight;

          double displayWidth;
          double displayHeight;
          double offsetX = 0;
          double offsetY = 0;

          if (containerAspectRatio > imageAspectRatio) {
            // Image fit height
            displayHeight = containerHeight;
            displayWidth = imageOriginalWidth * displayHeight / imageOriginalHeight;
            offsetX = (containerWidth - displayWidth) / 2;
          } else {
            // Image fit width
            displayWidth = containerWidth;
            displayHeight = imageOriginalHeight * displayWidth / imageOriginalWidth;
            offsetY = (containerHeight - displayHeight) / 2;
          }

          final scaleX = displayWidth / imageOriginalWidth;
          final scaleY = displayHeight / imageOriginalHeight;

          return InkWell(
            onTap: (){
              showDialog(
                context: context,
                builder: (context) => LightBoxImageViewer(
                  imageBytes: _pickedImageBytes!,
                  faceBoxes: _studentFaces,
                  imageOriginalWidth: imageOriginalWidth,
                  imageOriginalHeight: imageOriginalHeight,
                  showFaceLabels: true,
                ),
              );

            },
            child: Stack(
              children: [
                Positioned(
                  left: offsetX,
                  top: offsetY,
                  width: displayWidth,
                  height: displayHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _pickedImageBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                ..._studentFaces.map((face) {
                  return Positioned(
                    left: offsetX + (face.x * scaleX) - 2,
                    top: offsetY + (face.y * scaleY) - 2,
                    width: (face.width * scaleX) + 4,
                    height: (face.height * scaleY) + 4,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: face.isAuth ? -28 : -15,
                          left: 0,
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              face.isAuth ?
                              face.label:
                              "UnAuthorized",
                              style: TextStyle(color: Colors.white, fontSize: 8),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border:  Border.all(color: face.isAuth? Colors.greenAccent : Colors.redAccent, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              ],
            ),
          );
        },
      ),
    );
  }
}


