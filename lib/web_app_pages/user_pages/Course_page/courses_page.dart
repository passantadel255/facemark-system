import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facemark/services/converting_functions.dart';
import 'package:facemark/components/headers.dart';
import 'package:facemark/components/sidebar.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:facemark/web_app_pages/user_pages/Course_page/course_details_page.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {

  final Map<String, String> _teachersCache = {};
  bool _isLoadingTeachers = true; // Loading flag


  void toggleMenu() {
    setState(() {
      isMenu = !isMenu;
    });
  }

  Future<List<Map<String, dynamic>>> fetchTeacherCourses() async {
    print("fetchClasses");
    // Fetch data from Firestore based on the user role
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('teachers_id', arrayContains: userData.id) // Dynamic filter based on role
        .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<String> fetchTeachersForCourse(String courseCode) async {
    // Step 1: Query the courses collection to find the document with the matching course code
    final courseSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('code', isEqualTo: courseCode)
        .get();

    if (courseSnapshot.docs.isEmpty) {
      return "No course found with the given code.";
    }

    // Step 2: Extract the teachers_id list from the course document
    final List<dynamic> teachersIdList = courseSnapshot.docs.first.data()['teachers_id'] ?? [];

    if (teachersIdList.isEmpty) {
      return "No teachers assigned to this course.";
    }

    // Step 3: Query the users collection to get the names of the teachers
    final teachersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', whereIn: teachersIdList)
        .get();

    if (teachersSnapshot.docs.isEmpty) {
      return "No teacher data found.";
    }

    // Step 4: Extract the names and format them
    final teacherNames = teachersSnapshot.docs.map((doc) {
      final data = doc.data();
      final firstName = data['first_name'] ?? '';
      final lastName = data['last_name'] ?? '';
      final fullName = (firstName.isNotEmpty || lastName.isNotEmpty)
          ? "$firstName $lastName".trim()
          : 'Unknown Name';
      return "Eng. $fullName";
    }).toList();


    return teacherNames.join(', ');
  }

  Future<void> _fetchAllTeachers() async {
    for (var course in userData.attendance_rates) {
      final code = course['code']; // Or adjust based on your Course structure
      final teachers = await fetchTeachersForCourse(code);
      _teachersCache[code] = teachers;
    }
    setState(() {
      _isLoadingTeachers = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAllTeachers();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(toggleMenu: toggleMenu),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderBar(
                  title: "My Courses",
                  icon: Icons.menu_book_outlined,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    child: userData.role == "student"
                        ? _buildStudentView()
                        : userData.role == "teacher"
                        ? _buildTeacherView()
                        : _buildUnknownRoleView(),
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchTeacherCourses(), // Fetch classes for teacher
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  "Loading Your Courses...",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text("No Courses available for you.",
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
              )
          );
        }

        final classes = snapshot.data!;
        return _buildWrap(classes);
      },
    );
  }
  Widget _buildWrap(List<Map<String, dynamic>> classes) {
    const double cardWidth = 320; // Fixed width for CourseCard

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: isMenu ? 30 : 40, // Space between cards horizontally
          runSpacing: 35, // Space between rows
          children: classes.map((course) {
            return SizedBox(
              width: cardWidth,
              child: _buildTeacherCourseCard(
                courseData: course,
                imagePath: 'assets/images/app_logo/facemark-squre-logo.png', // Replace with your actual image path
              ),
            );
          }).toList(),        ),
      ),
    );
  }
  Widget _buildTeacherCourseCard({courseData, imagePath}) {

    String courseName = courseData['name'] ?? 'Unknown';
    String courseCode = courseData['code'] ?? 'Unknown';
    int studentNumber = (courseData['students_id'] as List<dynamic>).length;

    return Container(
      decoration: BoxDecoration(
        color: Color(0XFFF9FBFD),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.black.withAlpha(38), // Stroke color with 15% transparency
          width: 1, // Stroke width
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Image Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0XFF192A51),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.black.withAlpha(38), // Stroke color with 15% transparency
                    width: 1, // Stroke width
                  ),
                ),

                child: Image.asset(
                  imagePath,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Course Information
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF192A51),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF192A51), // Text color (dark blue)
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Montserrat', // Optional font family
                        ),
                        children: [
                          const TextSpan(text: "Course code: "),
                          TextSpan(
                            text: courseCode,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4), // Add spacing between lines
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF192A51), // Text color (dark blue)
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Montserrat', // Optional font family
                        ),
                        children: [
                          const TextSpan(text: "Student number: "),
                          TextSpan(
                            text: "$studentNumber",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
              width: 320,
              height: 1,
              color: Color(0xffD1D9E2)
          ),
          const SizedBox(height: 16),

          // More Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CourseDetailsPage(courseData: courseData)),
                  );
                },
                child: Container(
                  height: 28,
                  width: 95,
                  decoration: BoxDecoration(
                    color: const Color(0xff192A51),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                        color: Colors.black.withAlpha(50),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "More",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }


  Widget _buildStudentView() {
    final courses = userData.attendance_rates;
    final screenWidth = MediaQuery.of(context).size.width;
    bool isDesk = screenWidth >= 800;

    if (_isLoadingTeachers) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              "Loading Courses...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    if (courses.isEmpty) {
      return Center(
        child: Text(
          "No Courses available for you yet.",
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            color: Color(0xFF192A51),
            shadows: [
              Shadow(
                offset: Offset(0, 4),
                blurRadius: 4,
                color: Colors.black.withAlpha(64),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isDesk ? 25 : 8),
      constraints: BoxConstraints(maxWidth: 1100),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Courses Number: ${courses.length}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF192A51),
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                final courseCode = course['code'];

                return _buildStudentCourseCard(course, _teachersCache[courseCode] ?? "No teachers");
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStudentCourseCard(Map<String, dynamic> course, String teachersText) {
    var screenWidth = MediaQuery.of(context).size.width;
    bool isDesk = screenWidth >= 800;

    final int attendanceCount = course['attend_num'] ?? 0;
    final int totalClasses = course['total_classes'] ?? 0;
    final double attendancePercentage = course['attend_per'] ?? 0.0;
    final String name = course['name'] ?? 'Unknown Course';
    final String code = course['code'] ?? 'Unknown Code';
    final String lastAttendance = course['last_attended'] != null
        ? getDateFromTimestamp(course['last_attended']).toString()
        : 'N/A';

    // Split teachers if needed
    final List<String> teacherNames = teachersText.split(', ');

    return Container(
      constraints: BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.only(bottom: 25.0),
      padding: EdgeInsets.symmetric(horizontal: isDesk ? 25.0 : 15, vertical: isDesk ? 20 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Image + Details
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/app_logo/course-image-student.png',
                  width: isDesk ? 80 : 60,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: isDesk ? 16 : 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Name
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
                      const SizedBox(height: 4),

                      // Last Attendance
                      Text(
                        "Last Attendance: $lastAttendance",
                        style: TextStyle(
                          fontSize: isDesk ? 14 : 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF49454F),
                          fontFamily: 'Roboto',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Course Code
                      Text(
                        "Code: $code",
                        style: TextStyle(
                          fontSize: isDesk ? 14 : 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF49454F),
                          fontFamily: 'Roboto',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Teachers Names (Formatted RichText)
                      RichText(
                        text: TextSpan(
                          children: List.generate(teacherNames.length, (index) {
                            final fullName = teacherNames[index];
                            if (fullName.startsWith('Eng. ')) {
                              final namePart = fullName.substring(5); // Remove "Eng. "
                              return TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Eng. ",
                                    style: TextStyle(
                                      fontSize: isDesk ? 14 : 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF49454F),
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  TextSpan(
                                    text: namePart,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF49454F),
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  if (index != teacherNames.length - 1)
                                    const TextSpan(
                                      text: ", ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF49454F),
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                ],
                              );
                            } else {
                              return TextSpan(text: fullName); // Fallback
                            }
                          }),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isDesk ? 16 : 8),
          // Right: Attendance Indicator
          _buildAttendanceIndicator(
            attendancePercentage,
            attendanceCount,
            totalClasses,
          ),
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


  Widget _buildUnknownRoleView() {
    return const Center(
      child: Text(
        "Unknown Role",
        style: TextStyle(color: Colors.grey, fontSize: 24),
      ),
    );
  }
}
