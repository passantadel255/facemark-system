import 'package:facemark/web_app_pages/user_pages/attendance_history_page/class_history_page.dart';
import 'package:facemark/custom_widgets/hex_color.dart';
import 'package:facemark/services/converting_functions.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/record_attendance_page/record_attendance_page.dart';
import 'package:flutter/material.dart';


class ClassScheduleCard extends StatelessWidget {
  final lecData;

  const ClassScheduleCard({super.key,this.lecData});

  @override
  Widget build(BuildContext context) {
    bool isAttendance = lecData['st_attendance'] != null || lecData['st_absence'] != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Logo
              if(userData.role == 'teacher')

                Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration:  BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF192A51),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 4),
                          blurRadius: 4,
                          color: Colors.black.withAlpha(64),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/app_logo/dashoboard-logo-small.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecData['name'],
                    style: const TextStyle(
                      color: Color(0xFF192A51), // Dark blue
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  if(userData.role == 'teacher')

                    Text(
                    lecData['type'],
                    style: const TextStyle(
                      color: Color(0xFF192A51), // Dark blue
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),

            ]
        ),
        if(userData.role != 'teacher')
          const SizedBox(height: 10),

          Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TimeColumn(
              date: formatTimestamp(lecData["start_date"], lecData["end_date"]),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  minWidth: userData.role == 'teacher' ? 260 : 240,
                  minHeight: userData.role == 'teacher' ? 90 : 75,
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
                    color: Colors.black.withAlpha(38), // Stroke color with 15% transparency
                    width: 1, // Stroke width
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Course code: ${lecData['course_code']}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    lecData['room'] == 'Online' ?
                    Text(
                      "Online",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ) :
                    Text(
                      "Room: ${lecData['room']}",
                      style: TextStyle(
                        color: const Color(0xFFD6B717),
                        fontSize: 12,
                      ),
                    ),
                    if(userData.role == 'teacher')
                      Text(
                      "Student number: ${lecData['students'].length.toString()}",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontFamily: 'Roboto',

                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if(userData.role == 'teacher')
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                isAttendance ?
                classHistoryPage(lecData: lecData)
                    :RecordAttendancePage(lecData: lecData)
                ),


              );
            },
            child: Container(
              height: 35,
              width: 160,
              decoration: BoxDecoration(
                color: isAttendance ? Color(0xffD5C6E0) : Color(0xff192A51),
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
                  isAttendance ? "View Attendance >" : "Start Attendance >",
                  style: TextStyle(
                    color: isAttendance ? Color(0xff192A51) : Colors.white,
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
    );
  }
}

class TimeColumn extends StatelessWidget {
  final List<String> date;

  const TimeColumn({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date[0],
              style: const TextStyle(
                color: Color(0xff1D364C),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 35),
            Text(
              date[1],
              style: const TextStyle(
                color: Color(0xff1D364C),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                color: HexColor("#192A51"),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              height: 36,
              width: 4,
              decoration: BoxDecoration(
                  color: HexColor("#967AA1"),
                  borderRadius: BorderRadius.circular(20)
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                color: HexColor("#192A51"),
                shape: BoxShape.circle,
              ),
            ),

          ],
        )
      ],
    );
  }
}