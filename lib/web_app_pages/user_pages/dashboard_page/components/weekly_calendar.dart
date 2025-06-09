import 'package:facemark/custom_widgets/custom_icon_widget.dart';
import 'package:facemark/services/converting_functions.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyCalendar extends StatefulWidget {
  const WeeklyCalendar({super.key});

  @override
  _WeeklyCalendarState createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  DateTime currentDate = DateTime.now();
  late DateTime weekStartDate;
  late DateTime weekEndDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setWeekRange();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  void _setWeekRange() {
    // Calculate the start (Saturday) and end (Thursday) of the current week
    int daysFromSaturday = (currentDate.weekday + 1) % 7; // Saturday is 6
    weekStartDate = currentDate.subtract(Duration(days: daysFromSaturday));
    weekEndDate = weekStartDate.add(const Duration(days: 5)); // Ends on Thursday
  }

  void _navigateWeek(bool isNext) {
    setState(() {
      if (isNext) {
        weekStartDate = weekStartDate.add(const Duration(days: 7));
        weekEndDate = weekEndDate.add(const Duration(days: 7));
      } else {
        weekStartDate = weekStartDate.subtract(const Duration(days: 7));
        weekEndDate = weekEndDate.subtract(const Duration(days: 7));
      }
    });
  }


  getTeacherClasses(DateTime day) {

    // Return the filtered classes
    return FirebaseFirestore.instance
        .collection('classes')
        .where('teacher_id', isEqualTo: userData.id) // Filter by doctor_id
        .where('start_date', isGreaterThanOrEqualTo: Timestamp.fromDate(day))
        .where('start_date', isLessThan: Timestamp.fromDate(day.add(const Duration(days: 1))))
        .orderBy('start_date', descending: false) // Order by time
        .get();
  }

  getStudentClasses(DateTime day) {
    // Return the filtered classes
    return FirebaseFirestore.instance
        .collection('classes')
        .where('students', arrayContains: userData.id) // Filter by student id
        .where('start_date', isGreaterThanOrEqualTo: Timestamp.fromDate(day))
        .where('start_date', isLessThan: Timestamp.fromDate(day.add(const Duration(days: 1))))
        .orderBy('start_date', descending: false) // Order by time
        .get();
  }

  @override
  Widget build(BuildContext context) {
    // Generate days for the current week (Saturday to Thursday)
    List<DateTime> weekDays = List.generate(
        6, (index) => weekStartDate.add(Duration(days: index)));

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 4,
            color: Colors.black.withAlpha(50),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Week Navigation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              margin: const EdgeInsets.only(bottom: 5),
              width: double.maxFinite,
              child: Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "${weekStartDate.day} - ${weekEndDate.day}   ${_monthName(weekStartDate.month)} ${weekStartDate.year}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                      height: 1.19,
                      color: Colors.black,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 4),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:CustomIconWidget(icon: Icons.keyboard_arrow_left_outlined,size: 30,),
                        onPressed: () => _navigateWeek(false),
                      ),
                      IconButton(
                        icon:CustomIconWidget(icon: Icons.keyboard_arrow_right_outlined,size: 30,),
                        onPressed: () => _navigateWeek(true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Weekday Columns
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thickness: 6,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: weekDays.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DateTime day = weekDays[index];
                      return _buildDayColumn(day);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayColumn(DateTime day) {
    return FutureBuilder<QuerySnapshot>(
      future:userData.role == 'teacher' ? getTeacherClasses(day) : getStudentClasses(day),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                _buildDateHeader(day),
                const SizedBox(height: 50),
                const Text("No classes", style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        }

        var courses = snapshot.data!.docs;
        final ScrollController scrollController = ScrollController();

        return Container(
          constraints: BoxConstraints(minWidth: 120, maxWidth: 130),
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              _buildDateHeader(day),
              const SizedBox(height: 12),
              Expanded(
                child: Scrollbar(
                  controller: scrollController,
                  thickness: 5,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    controller: scrollController,
                    scrollDirection: Axis.vertical,
                    child:
                    Column(
                      children: [
                        ...courses.map((doc) {
                          var course = doc.data() as Map<String, dynamic>;
                          return _buildCourseCard(course, day);
                        }),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime day) {
    return Container(
      width: 110,
      height: 60,
      decoration: BoxDecoration(
        color: _isToday(day) ? const Color(0xFFF5E6E8) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 4,
            color: _isToday(day) ? Colors.black.withAlpha(50) : Colors.transparent,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _dayCode(day.weekday),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              height: 1,
              shadows: [
                Shadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${day.day}/${day.month}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              height: 1,
              shadows: [
                Shadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),

          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, DateTime day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(left: 8, top: 5, bottom: 5),
      width: 105,
      decoration: BoxDecoration(
        color: _isToday(day) ? const Color(0xFFfaf3f4) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
          Text(
            "code: ${course['course_code']}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          course['room'] == 'Online' ?
          Text(
            "Online",
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
            ),
          ) :
          Text(
            "Room: ${course['room']}",
            style: TextStyle(
              color: const Color(0xFFD6B717),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 5,),
          Text(
            "start: ${formatTimestamp(course["start_date"], course["end_date"])[0]}",
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            "end: ${formatTimestamp(course["start_date"], course["end_date"])[1]}",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime day) {
    DateTime today = DateTime.now();
    return day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
  }

  String _dayCode(int weekday) {
    const days = ["Sa", "Su", "Mo", "Tu", "We", "Th"];
    return days[(weekday + 1) % 7]; // Correct mapping for Saturday to Thursday
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }
}
