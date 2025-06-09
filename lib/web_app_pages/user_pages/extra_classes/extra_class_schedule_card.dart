import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facemark/services/converting_functions.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/components/class_sachedule_card.dart';
import 'package:facemark/web_app_pages/user_pages/extra_classes/create_edit_class_dialog.dart';
import 'package:facemark/custom_widgets/custom_icon_widget.dart';
import 'package:facemark/custom_widgets/custom_snack_bar.dart';
import 'package:facemark/custom_widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExtraClassScheduleCard extends StatefulWidget {
  final lecData;
  final type;
  final isDesktop;


  const ExtraClassScheduleCard({super.key, required this.type, required this.lecData, required this.isDesktop});

  @override
  State<ExtraClassScheduleCard> createState() => _ExtraClassScheduleCardState();
}

class _ExtraClassScheduleCardState extends State<ExtraClassScheduleCard> {

  Future<void> deleteLectureById(id) async {
    // Reference to the 'Extra Lectures' collection
    CollectionReference extraLectures = FirebaseFirestore.instance.collection('classes');

    try {
      Navigator.of(context).pop();
      showLoading(context);
      // Search for documents with the specified 'id'
      QuerySnapshot snapshot = await extraLectures.where('id', isEqualTo: id).get();

      // Check if any document was found
      if (snapshot.docs.isNotEmpty) {
        // Loop through all found documents and delete them
        for (var doc in snapshot.docs) {
          await doc.reference.delete();

          Navigator.of(context).pop(); // Close the loading
          showCustomSnackBar(context,"Extra Class deleted successfully", isSuccess: true);
          context.go('/Dashboard');
        }
      } else {
        Navigator.of(context).pop(); // Close the loading
        showCustomSnackBar(context,"No Class found with id $id", isSuccess: false);

      }
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading
      showCustomSnackBar(context,"Error deleting class: $e", isSuccess: false);
      print("Error deleting class: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isPast = isTimestampInThePast(widget.lecData["start_date"]);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0x80808080), // 55% opacity for #808080
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(38),
              offset: Offset(0, 4),
              blurRadius: 5,
              spreadRadius: 0,
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lecData['name'],
                  style: TextStyle(
                    fontSize: widget.isDesktop ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF192A51), // Dark Blue
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  getDateFromTimestamp(widget.lecData['start_date']).toString(),
                  style: TextStyle(
                    fontSize: widget.isDesktop ? 14 : 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5F6D7E), // Soft Gray
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                TimeColumn(date: formatTimestamp(widget.lecData["start_date"], widget.lecData["end_date"])), // Custom widget for the time and icons
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(
                          color: Colors.black.withAlpha(38),
                          width: 1.0,
                        ),
                      ),
                      surfaceTintColor: Colors.white,
                      elevation: 4,
                      color: Color(0xffF2F4F8),
                      shadowColor: Color(0xff192A51).withOpacity(0.5),
                      clipBehavior: Clip.hardEdge,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Course code: ',
                                          style: TextStyle(
                                            color: Color(0xFF192A51),
                                            fontSize: widget.isDesktop ? 14 : 12,
                                          ),
                                        ),
                                        TextSpan(
                                          text: widget.lecData['course_code'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF192A51),
                                            fontSize: widget.isDesktop ? 16 : 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Room: ',
                                          style: TextStyle(
                                            color: Color(0xFF192A51),
                                            fontSize: widget.isDesktop ? 14 : 12,
                                          ),
                                        ),
                                        TextSpan(
                                          text: widget.lecData['room'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF192A51),
                                            fontSize: widget.isDesktop ? 16 : 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Student number: ',
                                          style: TextStyle(
                                            color: Color(0xFF192A51),
                                            fontSize: widget.isDesktop ? 14 : 12,
                                          ),
                                        ),
                                        TextSpan(
                                          text: widget.lecData['students']?.length.toString() ?? '0',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF192A51),
                                            fontSize: widget.isDesktop ? 16 : 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            !isPast ?
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => CreateEditClassDialog(
                                        isEdit: true,
                                        lecData: widget.lecData,
                                      ),
                                    );
                                  },
                                  icon: CustomIconWidget(icon: Icons.mode_edit_outlined, size: widget.isDesktop ? 25 : 22,),
                                ),
                                IconButton(
                                  onPressed: (){
                                    _showDeleteConfirmationDialog(widget.lecData['course_code']);
                                  },
                                  icon: CustomIconWidget(icon: Icons.delete_outline, size: widget.isDesktop ? 25 : 20,),
                                ),
                              ],
                            ):
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Text(
                                'Passed',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: widget.isDesktop ? 14 : 12,
                                  fontWeight: widget.isDesktop ? FontWeight.w500 : FontWeight.w400, // Regular
                                  height: 1.4, // Line height = 140%
                                  color: const Color(0x80192A51), // 50% opacity
                                ),
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isTimestampInThePast(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    DateTime now = DateTime.now();
    return date.isBefore(now);
  }

  void _showDeleteConfirmationDialog( String code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text("Are you sure you want to delete this class?\n\nCourse Code: '$code'"),

          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF192A51),
                shape: StadiumBorder(),
              ),
              child: Text('Cancel', style: TextStyle(color: Colors.white),),
            ),
            SizedBox(width: 10),
            OutlinedButton(
              onPressed: (){deleteLectureById(widget.lecData['id']);},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
                shape: StadiumBorder(),
              ),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
