import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facemark/services/converting_functions.dart';
import 'package:facemark/web_app_pages/user_pages/extra_classes/create_edit_class_dialog.dart';
import 'package:facemark/custom_widgets/custom_back_button.dart';
import 'package:facemark/custom_widgets/custom_icon_widget.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:facemark/components/headers.dart';
import 'package:facemark/components/sidebar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CourseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const CourseDetailsPage({super.key, required this.courseData});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {

  void toggleMenu() {
    setState(() {
      isMenu = !isMenu;
    });
  }

  Future<List<Map<String, dynamic>>> fetchStudents(List<dynamic> studentIds) async {
    if (studentIds.isEmpty) return [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', whereIn: studentIds)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Row(
        children: [
          Sidebar(toggleMenu: toggleMenu),
          Expanded(
            child: Column(
              children: [
                const HeaderBar(
                  title: "Course Details",
                  icon: Icons.menu_book_outlined,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // back Button
                        CustomBackButton(),
                        SizedBox(height: 10),
                        Expanded(
                          child: userData.role == "student"
                              ? _buildStudentView()
                              : userData.role == "teacher"
                              ? _buildTeacherView()
                              : _buildUnknownRoleView(),
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

  Widget _buildTeacherView() {
    final List<dynamic> studentIds = widget.courseData['students_id'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20),
      child: Container(
        constraints: BoxConstraints(maxWidth: 950),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchStudents(studentIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No students found at this Course.'));
                }

                final students = snapshot.data!;
                return _buildStudentsList(students);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentView() {
    return Center(
      child: Text("Course Details Student", style: TextStyle(color: Colors.grey[600], fontSize: 24)),
    );
  }

  Widget _buildUnknownRoleView() {
    return const Center(
      child: Text(
        "Unknown Role",
        style: TextStyle(color: Colors.grey, fontSize: 24),
      ),
    );
  }



  Widget _buildHeaderSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isDesk = screenWidth > 800;


    return Container(
      width: double.maxFinite,
      height: 225,

      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF192A51),
        borderRadius: BorderRadius.circular(28.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_logo/course-profile.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          // Blur only on the specific Container
          Positioned(
            top: 0, // Adjust position as needed
            left: 0,
            right: 0,
            height: 225,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0), // Blur intensity
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28.0),
                ),
              ),
            ),
          ),
          // Content Overlay
          Positioned(
            bottom: 0,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.courseData['name'] ?? 'Unknown Course',
                  style: TextStyle(
                    fontSize: isDesk ? 30 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(1, 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFF5E6E8),
                    fontFamily: 'Roboto',
                  ),
                    children: [
                      const TextSpan(text: "Code: "),
                      TextSpan(
                        text: "${widget.courseData['code'] ?? 'Unknown'}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF5E6E8),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => CreateEditClassDialog(
                        isEdit: false,
                        CourseCode: widget.courseData['code'],
                      ),
                    );
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7F2FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  icon: CustomIconWidget(icon: Icons.calendar_month_outlined, size: 18, iconColor: Color(0xFF967AA1)),
                  label: const Text(
                    "Schedule New Extra Class",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF192A51),
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

  Widget _buildStudentsList(List<Map<String, dynamic>> students) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Student number: ${students.length}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF192A51),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.of(context).size.height * .5 +  10,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(right:25,top: 4),
            shrinkWrap: true,
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _buildStudentCard(student);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    var screenWidth = MediaQuery.of(context).size.width;
    bool isDesk = screenWidth >= 800;

    final String code = widget.courseData['code']; // Course code from course data.

    // Find the attendance data in the `attendance_rates` list where 'code' matches the course code.
    final Map<String, dynamic> attendanceData = (student['attendance_rates'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (rate) => rate['code'] == code,
      orElse: () => {},
    );

    // Extract attendance details.
    final int attendanceCount = attendanceData['attend_num'] ?? 0;
    final int totalClasses = attendanceData['total_classes'] ?? 0;
    final double attendancePercentage = attendanceData['attend_per'] ?? 0.0;
    final String lastAttendance = attendanceData['last_attended'] != null
        ? getDateFromTimestamp(attendanceData['last_attended']).toString()
        : 'N/A';


    // Extract student details.
    final String name = '${student['first_name'] ?? ''} ${student['last_name'] ?? ''}';
    final String id = student['id'] ?? 'Unknown ID';
    final String email = student['email'] ?? 'example@email.com';

    // Build the student card.
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  height: isDesk ?  80 : 65,
                  width: isDesk ?  80 : 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(38),
                        blurRadius: 3,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      student['image_url'],
                      fit: BoxFit.cover,
                      width: 65,
                      height: 65,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(minWidth: 200),
                    child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: isDesk ? 18 : 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1B20),
                              fontFamily: 'Roboto',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "id: $id",
                            style: TextStyle(
                              fontSize: isDesk ? 14 : 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF49454F),
                              fontFamily: 'Roboto',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "email: $email",
                            style: TextStyle(
                              fontSize: isDesk ? 14 : 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF49454F),
                              fontFamily: 'Roboto',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
            
                          ),
                          Text(
                            "last attendance: $lastAttendance",
                            style: TextStyle(
                              fontSize: isDesk ? 14 : 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF49454F),
                              fontFamily: 'Roboto',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,

                          ),
                        ],
                      ),
                  ),
                ),
              ],
            ),
          ),
          _buildAttendanceIndicator(attendancePercentage, attendanceCount, totalClasses),
        ],
      ),
    );
  }

  Widget _buildAttendanceIndicator(double percentage, int attendanceCount, int totalClasses) {
    final screenWidth = MediaQuery.of(context).size.width;

    return screenWidth >= 800 ?
    Row(
      children: [
        Text(
          "$attendanceCount / $totalClasses",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
            color: Color(0xFF192A51),
          ),
        ),
        SizedBox(width: 20),
        CircularPercentIndicator(
          animation: true,
          animationDuration: 1200,
          radius: 30.0,
          lineWidth: 6.0,
          percent: percentage / 100, // Convert to a scale of 0-1
          center: Text(
            "${percentage.toInt()}%",
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          progressColor: percentage < 50 ? Colors.red : Colors.green,
          backgroundColor: Colors.grey[300]!,
          circularStrokeCap: CircularStrokeCap.round,

        ),
      ],
    ):
    Column(
      children: [
        CircularPercentIndicator(
          animation: true,
          animationDuration: 1200,
          radius: 25.0,
          lineWidth: 4.0,
          percent: percentage / 100, // Convert to a scale of 0-1
          center: Text(
            "${percentage.toInt()}%",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          progressColor: percentage < 50 ? Colors.red : Colors.green,
          backgroundColor: Colors.grey[300]!,
          circularStrokeCap: CircularStrokeCap.round,

        ),
        SizedBox(height: 10),
        Text(
          "$attendanceCount / $totalClasses",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
            color: Color(0xFF192A51),
          ),
        ),

      ],
    );
  }
}
