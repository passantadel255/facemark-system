import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facemark/services/converting_functions.dart';
import 'package:facemark/custom_widgets/custom_back_button.dart';
import 'package:facemark/custom_widgets/custom_rich_text.dart';
import 'package:facemark/components/headers.dart';
import 'package:facemark/components/sidebar.dart';
import 'package:flutter/material.dart';

class classHistoryPage extends StatefulWidget {
  final dynamic lecData;
  const classHistoryPage({super.key, required this.lecData});

  @override
  State<classHistoryPage> createState() => _classHistoryPageState();
}

class _classHistoryPageState extends State<classHistoryPage> {
  final ScrollController _scrollController = ScrollController();

  bool isAttendance = false;
  var st_attendance;
  var st_absence;
  bool _isLoading = false;

  List attendees = [];
  List absent = [];

  /// Retrieves student data from Firestore based on provided student IDs
  Future<void> getStudentData() async {
      _isLoading = true;
    try {
      final rawAttendance = List<Map<String, dynamic>>.from(widget.lecData['st_attendance'] ?? []);
      final rawAbsence = List<Map<String, dynamic>>.from(widget.lecData['st_absence'] ?? []);

      final attendanceIds = rawAttendance.map((s) => s['id'].toString()).toList();
      final absenceIds = rawAbsence.map((s) => s['id'].toString()).toList();

      attendees = [];
      absent = [];

      final usersRef = FirebaseFirestore.instance.collection('users');

      // Fetch attendees with Manually flag
      if (attendanceIds.isNotEmpty) {
        final snapshot = await usersRef.where('id', whereIn: attendanceIds).get();

        attendees = snapshot.docs.map((doc) {
          final student = doc.data();
          final manualRecord = rawAttendance.firstWhere(
                (s) => s['id'].toString() == student['id'].toString(),
            orElse: () => {'manually': false},
          );
          return {
            ...student,
            'manually': manualRecord['manually'] ?? false,
          };
        }).toList();
      }

      // Fetch absent with Manually flag
      if (absenceIds.isNotEmpty) {
        final snapshot = await usersRef.where('id', whereIn: absenceIds).get();

        absent = snapshot.docs.map((doc) {
          final student = doc.data();
          final manualRecord = rawAbsence.firstWhere(
                (s) => s['id'].toString() == student['id'].toString(),
            orElse: () => {'manually': false},
          );
          return {
            ...student,
            'manually': manualRecord['manually'] ?? false,
          };
        }).toList();
      }

      setState(() {});
    } catch (e) {
      print('Error getting student data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load student data: $e')),
      );
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  void initState() {
    super.initState();
    late final Map<String, dynamic> data;

    if (widget.lecData is Map<String, dynamic>) {
      data = widget.lecData as Map<String, dynamic>;
    } else if (widget.lecData is DocumentSnapshot) {
      data = (widget.lecData as DocumentSnapshot).data() as Map<String, dynamic>;
    } else {
      throw Exception("Unsupported lecData type: ${widget.lecData.runtimeType}");
    }

    isAttendance = (data['st_attendance'] != null || data['st_absence'] != null);
    st_attendance = isAttendance ? data['st_attendance'].length.toString() : 'N/A';
    st_absence = isAttendance ? data['st_absence'].length.toString() : 'N/A';


    if(isAttendance) {
      getStudentData();
    }
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
                const HeaderBar(title: "Attendance History", icon: Icons.history_edu_outlined),
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
                                            _isLoading ? Padding(
                                              padding: const EdgeInsets.only(top: 150.0),
                                              child: CircularProgressIndicator(),
                                            ):
                                            !isAttendance ?
                                            Padding(
                                              padding: const EdgeInsets.only(top: 100, bottom: 100),
                                              child: Center(
                                                child: Text(
                                                  "No absences were recorded for this lecture.",
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
                                              ),
                                            ) :
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 50.0),
                                              child: Wrap(
                                                spacing: 60,
                                                runSpacing: 35,
                                                children: [
                                                  AttendeesSection(),
                                                  AbsentSection(),
                                                ],
                                              ),
                                            ),


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
              spacing: isMobile ? 50 : 25,
              runSpacing: isMobile ? 35 : 25,
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
                      final String fullName = '${student['first_name'] ?? ''} ${student['last_name'] ?? ''}';

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
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      student['image_url'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                      },
                                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error, color: Colors.red)),
                                    )
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
                                            text: fullName,
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
                        ),
                      );
                    },
                  )
                      :Center(
                    child: Text("There are no students present.",
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget AbsentSection (){
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
              'Absentees : ${absent.length}/${widget.lecData['students'].length}',
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
                  child: absent.isNotEmpty ?
                  ListView.builder(
                    itemCount: absent.length,
                    itemBuilder: (context, index) {
                      final student = absent[index];
                      final String fullName = '${student['first_name'] ?? ''} ${student['last_name'] ?? ''}';

                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF1F3),
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
                                child:  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      student['image_url'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                      },
                                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error, color: Colors.red)),
                                    )
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
                                            text: fullName,
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

                              if (student['manually'])
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'removed\nmanually',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                      :Center(
                    child: Text("There are no absent students",
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
              ],
            ),
          ),
        ],
      ),
    );
  }

}


