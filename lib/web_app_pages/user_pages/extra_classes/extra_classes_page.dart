import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:facemark/web_app_pages/user_pages/extra_classes/create_edit_class_dialog.dart';
import 'package:facemark/web_app_pages/user_pages/extra_classes/extra_class_schedule_card.dart';
import 'package:facemark/custom_widgets/custom_elevated_button.dart';
import 'package:facemark/custom_widgets/custom_snack_bar.dart';
import 'package:facemark/components/headers.dart';
import 'package:facemark/components/sidebar.dart';
import 'package:flutter/material.dart';

class ExtraClassesPage extends StatefulWidget {
  const ExtraClassesPage({super.key});

  @override
  State<ExtraClassesPage> createState() => _ExtraClassesPageState();
}

class _ExtraClassesPageState extends State<ExtraClassesPage> {
  bool isNow = true;
  bool isLoading = false;

  final List<Map<String, dynamic>> _upComingList = []; // Populate this with your Firestore/DB data
  final List<Map<String, dynamic>> _passedList = []; // Same here

  void toggleMenu() {
    setState(() {
      isMenu = !isMenu;
    });
  }

  Future<void> _fetchExtraClassesData() async {
    DateTime now = DateTime.now();

    try {
      isLoading = true;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('teacher_id', isEqualTo: userData.id)
          .where('type', isEqualTo: 'Extra Lecture')
          .get();

      _upComingList.clear();
      _passedList.clear();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        Timestamp startDateTimestamp = data['start_date'];
        DateTime startDate = startDateTimestamp.toDate();

        if (startDate.isAfter(now)) {
          _upComingList.add(data);
        } else {
          _passedList.add(data);
        }
      }

      // Sort upcoming list from newest to oldest based on start_date
      _upComingList.sort((a, b) {
        DateTime dateA = (a['start_date'] as Timestamp).toDate();
        DateTime dateB = (b['start_date'] as Timestamp).toDate();
        return dateA.compareTo(dateB); // Newest first
      });

      // Sort passed list from newest to oldest based on start_date
      _passedList.sort((a, b) {
        DateTime dateA = (a['start_date'] as Timestamp).toDate();
        DateTime dateB = (b['start_date'] as Timestamp).toDate();
        return dateB.compareTo(dateA); // Newest first
      });


    } catch (e) {
      print("Error fetching extra classes: $e");
      showCustomSnackBar(context,"Error fetching extra classes: $e", isSuccess: false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    _fetchExtraClassesData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Row(
        children: [
          Sidebar(toggleMenu: toggleMenu),
          Expanded(
            child:Column(
              children: [
                const HeaderBar(title: "Extra Classes", icon: Icons.class_outlined),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final isDesktop = screenWidth >= 800;

                      return isLoading
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                "Loading extra classes...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        )
                            : (isDesktop ? DesktopView() : mobileView());
                    },
                  ),
                )
              ],
            )

          ),
        ],
      ),
    );
  }


  Widget DesktopView() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /// ======================= Upcoming Column =======================
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // Header
                            Container(
                              constraints: const BoxConstraints(minWidth: 150, maxWidth: 150),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xffF2F4F8),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
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
                              child: Text(
                                'Upcoming',
                                style: TextStyle(
                                  fontSize:  18,
                                  fontFamily: 'Roboto',
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
                                textAlign: TextAlign.center,
                              ),
                            ),

                            // List
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 450),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xffF2F4F8),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                    topRight: Radius.circular(15),
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
                                child: _upComingList.isNotEmpty ?
                                ListView.builder(
                                  itemCount: _upComingList.length,
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  itemBuilder: (context, index) {
                                    return ExtraClassScheduleCard(
                                      lecData: _upComingList[index],
                                      type: 'Extra Class',
                                      isDesktop: true,);
                                  },
                                ) :
                                noClasses(isNow: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                  /// ======================= Passed Column =======================
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Container(
                              constraints: const BoxConstraints(minWidth: 150, maxWidth: 150),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xffF2F4F8),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
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
                              child: Text(
                                'Passed',
                                style: TextStyle(
                                  fontSize:  18,
                                  fontFamily: 'Roboto',
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
                                textAlign: TextAlign.center,
                              ),
                            ),

                            // List
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 450),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xffF2F4F8),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                    topRight: Radius.circular(15),
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
                                child: _passedList.isNotEmpty ?
                                ListView.builder(
                                  itemCount: _passedList.length,
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  itemBuilder: (context, index) {
                                    return ExtraClassScheduleCard(
                                      lecData: _passedList[index],
                                      type: 'Extra Class',
                                      isDesktop: true,
                                    );
                                  },
                                ) :
                                noClasses(isNow: false),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: CustomElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => CreateEditClassDialog(
                    isEdit: false,
                  ),
                );
              },
              text: "Add Extra class    +",
              width: 300,
              height: 50,
            ),
          )
        ],
      ),
    );
  }


  Widget mobileView (){
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 25),
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    onTap: () {
                      setState(() {
                        isNow = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: isNow
                          ? BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        color: Color(0xffF2F4F8),
                      )
                          : null,
                      child: Text(
                        'Upcoming',
                        style: TextStyle(
                          fontSize:  16,
                          fontFamily: 'Roboto',
                          fontWeight: isNow ? FontWeight.w600 : FontWeight.w500,
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
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    onTap: () {
                      setState(() {
                        isNow = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: !isNow
                          ? BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        color: Color(0xffF2F4F8),
                      )
                          : null,
                      child: Text(
                        'Passed',
                        style: TextStyle(
                          fontSize:  16,
                          fontFamily: 'Roboto',
                          fontWeight: !isNow ? FontWeight.w600 : FontWeight.w500,
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          isNow ?
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                color: Color(0xffF2F4F8),
              ),
              child: _upComingList.isNotEmpty ?  ListView.builder(
                itemCount: _upComingList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ExtraClassScheduleCard(
                    lecData: _upComingList[index],
                    type: 'Extra Class',
                    isDesktop: false,
                  );
                },
              ) :
              noClasses(isNow: isNow),
            )
          ) :
          Expanded(
            child:
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                ),
                color: Color(0xffF2F4F8),
              ),
              child: _passedList.isNotEmpty ?
              ListView.builder(
                itemCount: _passedList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ExtraClassScheduleCard(
                    lecData: _passedList[index],
                    type: 'Extra Class',
                    isDesktop: false,
                  );
                },
              ) :
              noClasses(isNow: isNow),
            )
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: CustomElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => CreateEditClassDialog(
                    isEdit: false,
                  ),
                );
              },
              text: "Add Extra class    +",
              width: 260,
              height: 45,

            ),
          )
        ],
      ),
    );
  }

  Widget noClasses({required bool isNow}) {
    return Center(
      child: Text(
        isNow ? "No upcoming extra classes" : "No passed extra classes",
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
    );
  }
}



