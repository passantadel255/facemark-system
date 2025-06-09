import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facemark/services/converting_functions.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:facemark/web_app_pages/user_pages/attendance_history_page/class_history_page.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/components/class_sachedule_card.dart';
import 'package:facemark/components/headers.dart';
import 'package:facemark/components/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> filteredClasses = [];
  List<DocumentSnapshot> allClasses = [];
  List<String> availableCourses = [];
  String selectedCourse = 'All';
  String selectedDate = 'All';
  bool _isLoading = false;

  void toggleMenu() {
    setState(() {
      isMenu = !isMenu;
    });
  }
  // Asynchronously fetches course and class data for the logged-in teacher
  Future<void> _fetchClassesData() async {
    try {
      _isLoading = true;
      final today = DateTime.now();

      // Get courses where the user is a teacher
      final courseSnap = await FirebaseFirestore.instance
          .collection('courses')
          .where('teachers_id', arrayContains: userData.id)
          .get();

      final courseCodes = courseSnap.docs.map((doc) => doc['code'] as String).toList();
      availableCourses = ['All', ...courseCodes];

      if (courseCodes.isEmpty) return;

      // Get only classes before today
      final classSnap = await FirebaseFirestore.instance
          .collection('classes')
          .where('course_code', whereIn: courseCodes)
          .get();

      final filteredByDate = classSnap.docs.where((doc) {
        final start = (doc['start_date'] as Timestamp).toDate();
        return start.isBefore(DateTime(today.year, today.month, today.day));
      }).toList();

      // Sort from newest to oldest
      filteredByDate.sort((a, b) {
        final dateA = (a['start_date'] as Timestamp).toDate();
        final dateB = (b['start_date'] as Timestamp).toDate();
        return dateB.compareTo(dateA);
      });

      setState(() {
        allClasses = filteredByDate;
        filterClasses();
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filters the fetched class list based on selected course and date
  void filterClasses() {
    setState(() {
      // Loop through all fetched classes and filter based on selected values
      filteredClasses = allClasses.where((doc) {
        // Check if class matches selected course code or "All"
        final courseMatch = selectedCourse == 'All' || doc['course_code'] == selectedCourse;

        // Convert class start date to a formatted string and check if it matches selected date
        final dateMatch = selectedDate == 'All' ||
            DateFormat('yyyy-MM-dd').format((doc['start_date'] as Timestamp).toDate()) == selectedDate;

        // Include class only if both course and date match the filter
        return courseMatch && dateMatch;
      }).toList(); // Convert the result back into a list
    });
  }


  @override
  void initState() {
    super.initState();
    _fetchClassesData();
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
          Sidebar(toggleMenu: toggleMenu),
          Expanded(
            child: Column(
              children: [
                const HeaderBar(title: "Attendance History", icon:Icons.history_edu_outlined ),
                Expanded(
                  child: _isLoading ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          "Loading Attendance History...",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ) :
                  Column(
                    children: [
                      FilterBar(),
                      filteredClasses.isEmpty
                          ? Expanded(
                        child: Center(
                          child: Text(
                            "No classes found",
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
                      )
                          : Expanded(
                        child: Scrollbar(
                          controller: _scrollController,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Center(
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 1100),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: List.generate(
                                    filteredClasses.length,
                                        (index) => SizedBox(
                                      width: double.infinity,
                                      child: buildClassCard(filteredClasses[index]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )


                    ],
                  )

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget FilterBar() {
    var courses = availableCourses;
    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      constraints: BoxConstraints(minWidth: 1200),
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFD),
        border: Border.all(
          color: const Color(0xFFD1D9E2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D101828), // #101828 with 5% opacity = 0x0D
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Wrap(
        alignment: screenWidth > 1200 ? WrapAlignment.spaceEvenly : WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.spaceBetween,
        spacing: 24,
        runSpacing: 12,
        children: [
          Text(
            "Filter by:",
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              color: Color(0xFF192A51),
            ),
          ),
          Container(
            constraints: BoxConstraints(minWidth: 950),
            child: Wrap(
              alignment: screenWidth > 800 ? WrapAlignment.spaceEvenly : WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,

              spacing: 24,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Course Code:", style: TextStyle(color: const Color(0xFF5F6D7E),fontSize: 16)),
                    const SizedBox(width: 10),
                    Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFD1D9E2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCourse,
                          icon: const Icon(Icons.keyboard_arrow_down_outlined,
                              size: 18, color: Color(0xff192A51)),
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12),
                          items: courses
                              .map((code) => DropdownMenuItem(
                            value: code,
                            child: Row(
                              children: [
                                const Icon(Icons.menu_book_outlined,
                                    size: 18, color: Color(0xff192A51)),
                                const SizedBox(width: 8),
                                Text(code),
                              ],
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedCourse = value;
                                filterClasses();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Date of Day:", style: TextStyle(color: const Color(0xFF5F6D7E),fontSize: 16)),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () async {
                        final yesterday = DateTime.now().subtract(const Duration(days: 1));

                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: yesterday,
                          firstDate: DateTime(2023),
                          lastDate: yesterday,
                        );

                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                            filterClasses();
                          });
                        }
                      },
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          // Assuming a transparent background or inherited from parent
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFD1D9E2), // Border/Default/Default
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12), // optional, based on layout
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined,
                                size: 18, color: Color(0xff192A51)),
                            const SizedBox(width: 8),
                            Text(selectedDate),
                            const Spacer(),
                            if (selectedDate != 'All')
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedDate = 'All';
                                    filterClasses();
                                  });
                                },
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: Color(0xFF5F6D7E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

            ),
          ),
        ],
      ),
    );
  }

  Widget buildClassCard(DocumentSnapshot lecData) {
    var screenWidth = MediaQuery.of(context).size.width;


    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFD1D9E2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.spaceBetween,
        alignment: screenWidth >= 900 ? WrapAlignment.spaceBetween : WrapAlignment.center,
        runSpacing: 24,
        spacing: 24,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.spaceBetween,
            alignment: WrapAlignment.center,
            runSpacing: 24,
            spacing: 24,
            children: [
              if(screenWidth >= 800)
              Image.asset(
                "assets/images/app_logo/course-image-student.png",
                height: 150,
                width: 150,
                fit: BoxFit.fitHeight,
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 2000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lecData['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF192A51), // Dark Blue
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          getDateFromTimestamp(lecData['start_date']).toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF5F6D7E), // Soft Gray
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TimeColumn(
                          date: formatTimestamp(lecData["start_date"], lecData["end_date"]),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: 260,
                              minHeight: 90,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xffF2F4F8),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.black.withAlpha(38),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Course code: ${lecData['course_code']}"),
                                lecData['room'] == 'online'
                                    ? const Text("Online", style: TextStyle(color: Colors.green))
                                    : Text("Room: ${lecData['room']}", style: const TextStyle(color: Color(0xffD6B717))),
                                Text(
                                  "Attendees: ${(((lecData.data() as Map<String, dynamic>)['st_attendance']) as List?)?.length ?? 0}",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
                borderRadius: BorderRadius.circular(20),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      classHistoryPage(lecData: lecData)
                  ),
                );
              },
              child: Container(
                height: 35,
                width: 160,
                decoration: BoxDecoration(
                  color: Color(0xff192A51),
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
                    "View Attendance >" ,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

