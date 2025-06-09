
import 'package:facemark/services/converting_functions.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/components/action_panel.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/components/attendance_rates_card.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/components/class_sachedule_card.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/components/notification_feed.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/components/weekly_calendar.dart';
import 'package:flutter/material.dart';
import 'package:facemark/components/headers.dart';
import 'package:facemark/components/sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();


  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController2.dispose();
    super.dispose();
  }


  void toggleMenu() {
    setState(() {
      isMenu = !isMenu;
    });
  }


  Stream<QuerySnapshot> fetchTeacherClasses() {
    // Get the start and end of the current day
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Return the filtered classes
    return FirebaseFirestore.instance
        .collection('classes')
        .where('teacher_id', isEqualTo: userData.id) // Filter by doctor_id
        .where('start_date', isGreaterThanOrEqualTo: startOfDay) // Start of today
        .where('start_date', isLessThanOrEqualTo: endOfDay) // End of today
        .orderBy('start_date', descending: false) // Order by time
        .snapshots();
  }

  Stream<QuerySnapshot> fetchStudentClasses() {
    // Get the start and end of the current day
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Return the filtered classes
    return FirebaseFirestore.instance
        .collection('classes')
        .where('students', arrayContains: userData.id) // Check if userId is in the students array
        .where('start_date', isGreaterThanOrEqualTo: startOfDay) // Start of today
        .where('start_date', isLessThanOrEqualTo: endOfDay) // End of today
        .orderBy('start_date', descending: false) // Order by time
        .snapshots();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /*floatingActionButton: FloatingActionButton(
              onPressed: (){
                showCustomSnackBar(context, "testing long text false, testing long text false, testing long text false, testing long text false, testing long text false, testing long text false, testing long text false, ", isSuccess: true);},
              tooltip: 'Add Data',
              child: Icon(Icons.add),
            ),*/
      body: Row(
        children: [
          Sidebar(toggleMenu: toggleMenu),
          Expanded(
            child: Column(
              children: [
                const HeaderBar(
                  title: "Dashboard",
                  icon: Icons.dashboard_outlined,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: userData.role == "student"
                          ? _buildStudentView()
                          : userData.role == "teacher"
                          ? _buildTeacherView()
                          : _buildUnknownRoleView(),
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
    final screenWidth = MediaQuery.of(context).size.width;
    bool isDesk = screenWidth > 1200 ;

    return Column(
      children: [
        // Today’s Upcoming Classes section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Upcoming Classes",
              style: TextStyle(
                fontSize:  20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold  ,
                color: Color(0xFF192A51),
                shadows:  [
                  Shadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    color: Colors.black.withAlpha(64),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              getFormattedDate(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontFamily: 'Roboto',

              ),
            ),

            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: fetchTeacherClasses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F8),
                        borderRadius:BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                            color: Colors.black.withAlpha(50),
                          ),
                        ],
                      ),
                      height: 280,
                      child: const Center(child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F8),
                        borderRadius:BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                            color: Colors.black.withAlpha(50),
                          ),
                        ],
                      ),
                      height: 280,
                      child: Center(
                          child: Text("No upcoming classes available for Today.",
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
                      )
                  );
                }

                final classes = snapshot.data!.docs;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F8),
                    borderRadius:BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                        color: Colors.black.withAlpha(50),
                      ),
                    ],
                  ),
                  height: 280, // Set a fixed height for the scrollable area
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 7,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final lecData = classes[index].data() as Map<String, dynamic>;
                        return Container(
                          width: 400,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                          margin: EdgeInsets.only(top:12, bottom: 30, right: 20, left: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FBFD),
                            borderRadius:BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 4),
                                blurRadius: 4,
                                color: Colors.black.withAlpha(50),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.black.withAlpha(38), // Stroke color with 15% transparency
                              width: 1, // Stroke width
                            ),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12, top: 4),
                            child: ClassScheduleCard(
                              lecData: lecData,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),

        isDesk ?
        //Desktop View
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //calender
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly Calendar",
                    style: TextStyle(
                      fontSize:  20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold  ,
                      color: Color(0xFF192A51),
                      shadows:  [
                        Shadow(
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                          color: Colors.black.withAlpha(64),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 420,
                    child: WeeklyCalendar(),
                  ),
                ],
              ),

            ),
            SizedBox(width: 20),

            //action panel
            Expanded(
              flex: 4,
              child: Container(
                margin: EdgeInsets.only(top: 40),
                child: Stack(
                  children: [
                    // Inner Shadow Overlay
                    Positioned.fill(
                      child: Container(
                        height: 430,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(0),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(25), // Inner shadow color
                              Colors.black.withAlpha(25), // Inner shadow color
                              Colors.transparent, // Fade out

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Outer Container (Background and Border Radius)
                    Container(
                      height: 430,
                      margin: EdgeInsets.only(left: 10,top: 10),
                      padding: EdgeInsets.only(top: 15, left: 20, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8), // Top-left corner radius
                          topRight: Radius.circular(0), // Top-right corner radius
                          bottomLeft: Radius.circular(0), // Bottom-left corner radius
                          bottomRight: Radius.circular(0), // Bottom-right corner radius
                        ),
                      ),
                      child: Column(
                        children: [
                          ActionPanel(),
                          SizedBox(height: 30),
                          NotificationFeed(),
                        ],
                      ),
                    ),



                  ],
                ),
              ),
            ),
          ],
        ) :

        //Tab & mobile View
        Column(
          children: [
            //calender
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Calendar",
                  style: TextStyle(
                    fontSize:  20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold  ,
                    color: Color(0xFF192A51),
                    shadows:  [
                      Shadow(
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                        color: Colors.black.withAlpha(64),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 420,
                  child: WeeklyCalendar(),
                ),
              ],
            ),
            SizedBox(width: 20),

            //action panel & notification feed
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Stack(
                children: [
                  // Inner Shadow Overlay
                  Positioned.fill(
                    child: Container(
                      height: 430,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(25), // Inner shadow color
                            Colors.black.withAlpha(25), // Inner shadow color
                            Colors.transparent, // Fade out

                          ],
                        ),
                      ),
                    ),
                  ),
                  // Outer Container (Background and Border Radius)
                  Container(
                    height: 430,
                    margin: EdgeInsets.only(left: 10,top: 10),
                    padding: EdgeInsets.only(top: 15, left: 20, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8), // Top-left corner radius
                        topRight: Radius.circular(0), // Top-right corner radius
                        bottomLeft: Radius.circular(0), // Bottom-left corner radius
                        bottomRight: Radius.circular(0), // Bottom-right corner radius
                      ),
                    ),
                    child: Column(
                      children: [
                        ActionPanel(),
                        SizedBox(height: 30),
                        NotificationFeed(),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentView() {

    final screenWidth = MediaQuery.of(context).size.width;
    bool isDesk = screenWidth > 1200 ;

    return
      isDesk ?
      //Desktop View
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Attendance Rates & Calender
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 25, bottom: 40),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(38), // Shadow color
                    blurRadius: 4, // Blur effect
                    offset: const Offset(6, 10),
                    spreadRadius: 0, // Spread radius
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attendance Rates
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Attendance Rates",
                        style: TextStyle(
                          fontSize:  20,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold  ,
                          color: Color(0xFF192A51),
                          shadows:  [
                            Shadow(
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                              color: Colors.black.withAlpha(64),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F8),
                        borderRadius:BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                            color: Colors.black.withAlpha(50),
                          ),
                        ],
                      ),
                      height: 290, // Set a fixed height for the scrollable area
                      child:
                      userData.attendance_rates.isNotEmpty ?
                      Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          thickness: 7,
                          child: ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: userData.attendance_rates.length,
                            itemBuilder: (context, index) {
                              return AttendanceRatesCard(
                                    courseName: userData.attendance_rates[index]['name'],
                                    courseCode: userData.attendance_rates[index]['code'],
                                    percentage: userData.attendance_rates[index]['attend_per'],
                                  );
                            },
                          ),


                      ):
                      Center(
                          child: Text("No Courses available for you yet.",
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
                      ),
                    ),
                      const SizedBox(height: 24),
                    ],
                  ),

                  //Calender
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Weekly Calendar",
                        style: TextStyle(
                          fontSize:  20,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold  ,
                          color: Color(0xFF192A51),
                          shadows:  [
                            Shadow(
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                              color: Colors.black.withAlpha(64),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 420,
                        child: WeeklyCalendar(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          ),
          SizedBox(width: 10),

          // Today’s Upcoming Classes section & Notification Feed
          Expanded(
            flex: 1,
            child:Container(
              margin: EdgeInsets.only(left: 10),
              padding: EdgeInsets.only( left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), // Top-left corner radius
                  topRight: Radius.circular(0), // Top-right corner radius
                  bottomLeft: Radius.circular(0), // Bottom-left corner radius
                  bottomRight: Radius.circular(0), // Bottom-right corner radius
                ),
              ),
              child: Column(
                children: [
                  // Today’s Upcoming Classes section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Upcoming Classes",
                        style: TextStyle(
                          fontSize:  20,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold  ,
                          color: Color(0xFF192A51),
                          shadows:  [
                            Shadow(
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                              color: Colors.black.withAlpha(64),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        getFormattedDate(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontFamily: 'Roboto',

                        ),
                      ),

                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: fetchStudentClasses(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F8),
                                  borderRadius:BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0, 4),
                                      blurRadius: 4,
                                      color: Colors.black.withAlpha(50),
                                    ),
                                  ],
                                ),
                                height: 480,
                                child: const Center(child: CircularProgressIndicator()));
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F8),
                                  borderRadius:BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0, 4),
                                      blurRadius: 4,
                                      color: Colors.black.withAlpha(50),
                                    ),
                                  ],
                                ),
                                height: 480,
                                child: Center(
                                    child: Text("No upcoming classes available for Today.",
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
                                )
                            );
                          }

                          final classes = snapshot.data!.docs;

                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F8),
                              borderRadius:BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 4),
                                  blurRadius: 4,
                                  color: Colors.black.withAlpha(50),
                                ),
                              ],
                            ),
                            height: 480, // Set a fixed height for the scrollable area
                            child: Scrollbar(
                              controller: _scrollController2,
                              thumbVisibility: true,
                              thickness: 7,
                              child: ListView.builder(
                                controller: _scrollController2,
                                scrollDirection: Axis.vertical,
                                itemCount: classes.length,
                                itemBuilder: (context, index) {
                                  final lecData = classes[index].data() as Map<String, dynamic>;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                                    margin: EdgeInsets.only(top:12, bottom: 30, right: 30, left: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FBFD),
                                      borderRadius:BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 4),
                                          blurRadius: 4,
                                          color: Colors.black.withAlpha(50),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.black.withAlpha(38), // Stroke color with 15% transparency
                                        width: 1, // Stroke width
                                      ),
                                    ),

                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 12, top: 4),
                                      child: ClassScheduleCard(
                                        lecData: lecData,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                  //NotificationFeed
                  SizedBox(height: 20,),
                  NotificationFeed(),
                ],
              ),
            ),

          ),
        ],
      ) :

      //Tab & mobile View
      Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attendance Rates
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attendance Rates",
                    style: TextStyle(
                      fontSize:  20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold  ,
                      color: Color(0xFF192A51),
                      shadows:  [
                        Shadow(
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                          color: Colors.black.withAlpha(64),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F8),
                      borderRadius:BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                          color: Colors.black.withAlpha(50),
                        ),
                      ],
                    ),
                    height: 290, // Set a fixed height for the scrollable area
                    child:
                    userData.attendance_rates.isNotEmpty ?
                    Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 7,
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: userData.attendance_rates.length,
                        itemBuilder: (context, index) {
                          return AttendanceRatesCard(
                            courseName: userData.attendance_rates[index]['name'],
                            courseCode: userData.attendance_rates[index]['code'],
                            percentage: userData.attendance_rates[index]['attend_per'],
                          );
                        },
                      ),


                    ):
                    Center(
                        child: Text("No Courses available for you yet.",
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
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

              // Today’s Upcoming Classes section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Upcoming Classes",
                    style: TextStyle(
                      fontSize:  20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold  ,
                      color: Color(0xFF192A51),
                      shadows:  [
                        Shadow(
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                          color: Colors.black.withAlpha(64),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getFormattedDate(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontFamily: 'Roboto',

                    ),
                  ),

                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: fetchStudentClasses(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F8),
                              borderRadius:BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 4),
                                  blurRadius: 4,
                                  color: Colors.black.withAlpha(50),
                                ),
                              ],
                            ),
                            height: 500,
                            child: const Center(child: CircularProgressIndicator()));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F8),
                              borderRadius:BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 4),
                                  blurRadius: 4,
                                  color: Colors.black.withAlpha(50),
                                ),
                              ],
                            ),
                            height: 500,
                            child: Center(
                                child: Text("No upcoming classes available for Today.",
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
                            )
                        );
                      }

                      final classes = snapshot.data!.docs;

                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F8),
                          borderRadius:BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                              color: Colors.black.withAlpha(50),
                            ),
                          ],
                        ),
                        height: 500, // Set a fixed height for the scrollable area
                        child: Scrollbar(
                          controller: _scrollController2,
                          thumbVisibility: true,
                          thickness: 7,
                          child: ListView.builder(
                            controller: _scrollController2,
                            scrollDirection: Axis.vertical,
                            itemCount: classes.length,
                            itemBuilder: (context, index) {
                              final lecData = classes[index].data() as Map<String, dynamic>;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                                margin: EdgeInsets.only(top:12, bottom: 30, right: 30, left: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FBFD),
                                  borderRadius:BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0, 4),
                                      blurRadius: 4,
                                      color: Colors.black.withAlpha(50),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.black.withAlpha(38), // Stroke color with 15% transparency
                                    width: 1, // Stroke width
                                  ),
                                ),

                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                                  child: ClassScheduleCard(
                                    lecData: lecData,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
          SizedBox(height: 20,),
          Column(
            children: [
              //Calender
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly Calendar",
                    style: TextStyle(
                      fontSize:  20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold  ,
                      color: Color(0xFF192A51),
                      shadows:  [
                        Shadow(
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                          color: Colors.black.withAlpha(64),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 420,
                    child: WeeklyCalendar(),
                  ),
                ],
              ),

              SizedBox(height: 20,),
              NotificationFeed(),
            ],
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




