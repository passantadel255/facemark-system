import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facemark/services/email_service.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:facemark/custom_widgets/custom_snack_bar.dart';
import 'package:facemark/custom_widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


class CreateEditClassDialog extends StatefulWidget {
  final bool isEdit;
  final String? CourseCode;
  final Map<String, dynamic>? lecData;

  const CreateEditClassDialog({super.key, required this.isEdit, this.lecData, this.CourseCode});

  @override
  State<CreateEditClassDialog> createState() => _CreateEditClassDialogState();
}

class _CreateEditClassDialogState extends State<CreateEditClassDialog> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  TimeOfDay? _startHour;
  TimeOfDay? _endHour;
  String? _selectedCourseCode;
  String? _roomNumber;
  String? _notes;
  String _section = 'Online';

  bool _sendNotification = false;

  late bool isEdit;
  Map<String, dynamic>? lecData;

  List<Map<String, dynamic>> _courseCodes = [];

  Future<void> _setData() async {
    isEdit = widget.isEdit;
    lecData = widget.lecData;

    await _fetchCoursesData();

    if (isEdit && lecData != null) {
      _selectedCourseCode = lecData!['course_code'];
      // Handle date parsing from either Timestamp or String
      var rawStart = lecData!['start_date'];
      var rawEnd = lecData!['end_date'];

      DateTime? startDate;
      DateTime? endDate;

      if (rawStart is Timestamp) {
        startDate = rawStart.toDate();
      } else if (rawStart is String) {
        try {
          startDate = DateFormat('E dd.MMM.yyyy').parse(rawStart);
        } catch (e) {
          print('Error parsing start_date: $e');
        }
      }

      if (rawEnd is Timestamp) {
        endDate = rawEnd.toDate();
      } else if (rawEnd is String) {
        try {
          endDate = DateFormat('E dd.MMM.yyyy').parse(rawEnd);
        } catch (e) {
          print('Error parsing end_date: $e');
        }
      }

      _selectedDate = startDate;
      _startHour = startDate != null ? TimeOfDay.fromDateTime(startDate) : null;
      _endHour = endDate != null ? TimeOfDay.fromDateTime(endDate) : null;

      _sendNotification = lecData!['send_notification'] ?? false;
      _section = lecData!['room'] == 'Online' ? 'Online' : 'Room';
      _roomNumber = _section == 'Room' ? lecData!['room'] : null;
      _notes = lecData!['notes'];
    } else {
      if (widget.CourseCode != null) {
        _selectedCourseCode = widget.CourseCode;
      } else {
        _selectedCourseCode = _courseCodes.first['code'];
      }
    }

  }

  Future<void> _fetchCoursesData() async {
    try {
      // Get courses where the user is a teacher
      final courseSnap = await FirebaseFirestore.instance
          .collection('courses')
          .where('teachers_id', arrayContains: userData.id)
          .get();

      _courseCodes = courseSnap.docs.map((doc) => {
        'code': doc['code'],
        'name': doc['name'],
        'students': doc['students_id'],
      }).toList();

    } catch (e) {
      print("Error fetching extra classes: $e");
      showCustomSnackBar(context,"Error fetching extra classes: $e", isSuccess: false);
    } finally {
      setState(() {});
    }
  }

  Future<void> _saveData() async {
    showLoading(context);

    final selectedCourse = _courseCodes.firstWhere(
          (course) => course['code'] == _selectedCourseCode,
      orElse: () => {}, // Return an empty Map instead of null
    );

    final List students = selectedCourse.containsKey('students') ? selectedCourse['students'] : [];
    final String selectedCourseName = selectedCourse.containsKey('name') ? selectedCourse['name'] : "N/A";


    final classData = {
      'course_code': _selectedCourseCode,
      'name': selectedCourseName,
      'teacher_id': userData.id,
      'students': students,
      'start_date': Timestamp.fromDate(
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _startHour!.hour, _startHour!.minute),
      ),
      'end_date': Timestamp.fromDate(
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _endHour!.hour, _endHour!.minute),
      ),
      'id': isEdit ? lecData!['id'] : (Random().nextInt(900000) + 100000).toString(),
      'room': _section == 'Room' ? _roomNumber : 'Online',
      'send_notification': _sendNotification,
      'type': 'Extra Lecture',
      'notes': _notes ?? '',
    };

    try {
      if (isEdit) {
        final query = await FirebaseFirestore.instance
            .collection('classes')
            .where('id', isEqualTo: lecData!['id'])
            .get();

        if (query.docs.isNotEmpty) {
          await query.docs.first.reference.update(classData);
        }
      } else {
        await FirebaseFirestore.instance.collection('classes').add(classData);
      }

      if (_sendNotification) {

        final recipients = await getStudentsMails(students);

        print("$recipients");
        await sendEmail(
          recEmails: recipients,
          drName: "Eng. ${userData.first_name} ${userData.last_name}",
          drEmail: "Eng. ${userData.first_name}${userData.last_name}@FaceMark.com",
          crsCd: _selectedCourseCode ?? "N/A",
          crsNm: selectedCourseName,
          day: DateFormat('E dd.MMM.yyyy').format(_selectedDate!),
          start: _startHour!.format(context),
          end: _endHour!.format(context),
          type: _section,
          room: _section == 'Online' ? 'Online' : _roomNumber!,
          notes: _notes ?? '',
          isEdit: isEdit,
        );
      }

      Navigator.of(context).pop(); // Close the loading
      Navigator.of(context).pop(); // Close the add class dialog

      showCustomSnackBar(context,"Extra class ${isEdit ? 'updated' : 'created'} successfully", isSuccess: true);

      context.go('/Dashboard');

    } catch (e) {
      Navigator.of(context).pop(); // Close the loading
      showCustomSnackBar(context,"Error ${isEdit ? 'updating' : 'creating'} extra class: $e", isSuccess: false);

    }
  }

  Future<List<String>> getStudentsMails(List studentsId) async {
    final mails = <String>[];

    if (studentsId.isEmpty) return mails;

    try {
      // Firestore batch query (if IDs are not too many)
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', whereIn: studentsId)
          .get();

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('email')) {
          mails.add(data['email']);
        }
      }
    } catch (e) {
      print('Error fetching students emails: $e');
    }

    return mails;
  }

  @override
  void initState() {
    super.initState();
    _setData();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Extra Class' : 'Add New Extra Class',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF192A51),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _showCancelConfirmationDialog(context);
                    },
                  )
                ],
              ),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildDropdownField(),
                    _buildDateField(),
                    _buildTimeField(label: 'Start Hour', value: _startHour, onPick: (time) => setState(() => _startHour = time)),
                    _buildTimeField(label: 'End Hour', value: _endHour, onPick: (time) => setState(() => _endHour = time)),
                    _buildTypeSelector(),
                    if (_section == 'Room') _buildRoomField(),
                    _buildNotesField(),
                    _buildCheckbox(),
                    const SizedBox(height: 20),
                    _buildActions(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: DropdownButtonFormField<String>(
      value: _selectedCourseCode,
      icon: const Icon(Icons.keyboard_arrow_down_outlined, size: 25, color: Color(0xff192A51)),
      borderRadius: BorderRadius.circular(12),
      decoration: InputDecoration(
        labelText: 'Course Code',
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF5F6D7E)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Please select a course code' : null,
      items: _courseCodes.map<DropdownMenuItem<String>>((course) {
        final code = course['code'];
        final name = course['name'];
        return DropdownMenuItem(
          value: code,
          child: Row(
            children: [
              const Icon(Icons.menu_book, size: 18, color: Color(0xff192A51)),
              const SizedBox(width: 8),
              Text("$code - $name"),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedCourseCode = val),
    ),
  );

  Widget _buildDateField() => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: TextFormField(
      controller: TextEditingController(
        text: _selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
            : '',
      ),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date of Day',
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF5F6D7E)),
        hintText: "DD/MM/YYYY",
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF5F6D7E)),
        prefixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF192A51)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1.5),
        ),
      ),
      validator: (val) => _selectedDate == null ? 'Please select a date' : null,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
    ),
  );

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? value,
    required void Function(TimeOfDay) onPick,
  }) {
    bool isStart = label == 'Start Hour';
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: TextFormField(
          controller: TextEditingController(text: value?.format(context) ?? ''),
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF5F6D7E)),
            hintText: "HH:MM AM/PM",
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF5F6D7E)),
            prefixIcon: Icon(
              isStart ? Icons.more_time_rounded : Icons.access_time,
              color: const Color(0xFF192A51),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF192A51), width: 1.5),
            ),
          ),
          validator: (val) => value == null ? isStart ? 'Please select start time' : 'Please select end time'  : null,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: value ?? TimeOfDay.now(),
            );
            if (picked != null) onPick(picked);
          },
        ),
      ),
    );
  }

  Widget _buildTypeSelector() => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class Type:', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online', style: TextStyle(fontSize: 14)),
                value: 'Online',
                groupValue: _section,
                onChanged: (val) => setState(() => _section = val!),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Room', style: TextStyle(fontSize: 14)),
                value: 'Room',
                groupValue: _section,
                onChanged: (val) => setState(() => _section = val!),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildRoomField() => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextFormField(
      initialValue: _roomNumber,
      decoration: InputDecoration(
        labelText: 'Room Number',
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF5F6D7E)),
        hintText: "enter the room number",
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF5F6D7E)),
        prefixIcon: const Icon(Icons.room_outlined, color: Color(0xFF192A51)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => _section == 'Room' && (val == null || val.isEmpty) ? 'Please enter room number' : null,
      onChanged: (val) => _roomNumber = val,
    ),
  );

  Widget _buildNotesField() => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _notes,
          maxLines: 4,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'type here...',
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF192A51)),
            ),
          ),
          onChanged: (val) => _notes = val,
        ),
      ],
    ),
  );

  Widget _buildCheckbox() => Padding(
    padding: const EdgeInsets.only(top: 15),
    child: Row(
      children: [
        Checkbox(
          value: _sendNotification,
          onChanged: (val) => setState(() => _sendNotification = val!),
        ),
        SizedBox(width: 8),
        Text(
          "Send Notification to Student",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF21272A),
          ),
        ),
      ],
    ),
  );

  Widget _buildActions() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(
        onPressed: () {
          _showCancelConfirmationDialog(context);
        },
        child: const Text(
          'Close',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF192A51),
          ),
        ),
      ),
      const SizedBox(width: 12),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (_selectedDate == null || _startHour == null || _endHour == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please complete all date and time fields')),
              );
              return;
            }

            _showSaveConfirmationDialog(context);
          }
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF192A51),
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          isEdit ? 'Update' : 'Create',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
    ],
  );

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? 'Cancel Update!' : 'Cancel Creation'),
          content:  Text(isEdit ? 'Are you sure you want to cancel Extra Class update?\nYou will lose any edits':'Are you sure you want to cancel Extra Class creation?\nYou will lose any edits'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            OutlinedButton(
              onPressed: (){
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
                shape: StadiumBorder(),
              ),
              child: Text('Close', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showSaveConfirmationDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        String Date = DateFormat('E dd.MMM.yyyy').format(_selectedDate!);
        return AlertDialog(
          title: Text(isEdit ? 'Confirm Update':'Confirm Creation'),
          content: SizedBox(
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you sure you want to ${isEdit ? 'Update':'Create'} this Extra class?'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Code: ',style: TextStyle(fontWeight: FontWeight.w500),),
                      Text('$_selectedCourseCode'),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Day: ',style: TextStyle(fontWeight: FontWeight.w500),),
                      Text(Date),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Start: ',style: TextStyle(fontWeight: FontWeight.w500),),
                      Text(_startHour!.format(context)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('End: ',style: TextStyle(fontWeight: FontWeight.w500),),
                      Text(_endHour!.format(context)),
                    ],
                  ),
                  _section == 'Online'?
                  const Text('Online', style: TextStyle(color: Colors.green))
                      :Text('Room: $_roomNumber',style: const TextStyle(fontWeight: FontWeight.w500),),

                  Row(
                    children: [
                      const Text('Send Notification: ',style: TextStyle(fontWeight: FontWeight.w500, ),),
                      Text(_sendNotification ? 'Yes' : 'No'),
                    ],
                  ),

                ],
              )
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveData();
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192A51),
                elevation: 3,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Confirm',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}