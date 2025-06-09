
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

// Function to add data to Firestore
Future<void> addClassData() async {
  final List<Map<String, dynamic>> classes = [
    {
      'id': '754001',
      'course_code': 'CS101',
      'name': 'Introduction to AI',
      'room': '303',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["111111", "222222", "333333", "444444", "555555", "666666", "777777"],
      'start_date': DateTime(2025, 4, 26, 8, 0),
      'end_date': DateTime(2025, 4, 26, 10, 0),
    },
    {
      'id': '754002',
      'course_code': 'CS302',
      'name': 'Database Systems',
      'room': '202',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["222222","444444","666666"],
      'start_date': DateTime(2025, 4, 26, 10, 0),
      'end_date': DateTime(2025, 4, 26, 12, 0),
    },
    {
      'id': '754003',
      'course_code': 'CS101',
      'name': 'Introduction to AI',
      'room': '303',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["111111", "222222", "333333", "444444", "555555", "666666", "777777"],
      'start_date': DateTime(2025, 4, 27, 8, 0),
      'end_date': DateTime(2025, 4, 27, 10, 0),
    },
    {
      'id': '754004',
      'course_code': 'CS102',
      'name': 'Data Structures',
      'room': '303',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["111111", "222222", "333333", "444444", "555555", "666666", "777777"],
      'start_date': DateTime(2025, 4, 27, 10, 0),
      'end_date': DateTime(2025, 4, 27, 12, 0),
    },
    {
      'id': '754005',
      'course_code': 'CS102',
      'name': 'Data Structures',
      'room': '202',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["111111", "222222", "333333", "444444", "555555", "666666", "777777"],
      'start_date': DateTime(2025, 4, 28, 8, 0),
      'end_date': DateTime(2025, 4, 28, 10, 0),
    },
    {
      'id': '754006',
      'course_code': 'CS201',
      'name': 'Machine Learning',
      'room': '303',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["111111", "222222", "333333", "444444"],
      'start_date': DateTime(2025, 4, 28, 10, 0),
      'end_date': DateTime(2025, 4, 28, 12, 0),
    },
    {
      'id': '754007',
      'course_code': 'CS201',
      'name': 'Machine Learning',
      'room': '303',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["111111", "222222", "333333", "444444"],
      'start_date': DateTime(2025, 4, 29, 8, 0),
      'end_date': DateTime(2025, 4, 29, 10, 0),
    },
    {
      'id': '754008',
      'course_code': 'CS202',
      'name': 'Cloud Computing',
      'room': '303',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["444444", "555555", "666666", "777777"],
      'start_date': DateTime(2025, 4, 29, 10, 0),
      'end_date': DateTime(2025, 4, 29, 12, 0),
    },
    {
      'id': '754009',
      'course_code': 'CS202',
      'name': 'Cloud Computing',
      'room': '303',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["111111", "222222", "333333", "444444"],
      'start_date': DateTime(2025, 4, 30, 8, 0),
      'end_date': DateTime(2025, 4, 30, 10, 0),
    },
    {
      'id': '754010',
      'course_code': 'CS301',
      'name': 'Cybersecurity',
      'room': '303',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["111111", "333333",  "555555", "777777"],
      'start_date': DateTime(2025, 4, 30, 10, 0),
      'end_date': DateTime(2025, 4, 30, 12, 0),
    },
    {
      'id': '754011',
      'course_code': 'CS302',
      'name': 'Database Systems',
      'room': '303',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["222222", "444444",  "666666"],
      'start_date': DateTime(2025, 5, 1, 8, 0),
      'end_date': DateTime(2025, 5, 1, 10, 0),
    },
    {
      'id': '754012',
      'course_code': 'CS301',
      'name': 'Cybersecurity',
      'room': '303',
      'type': 'Lecture',
      'teacher_id': '000000',
      'students': ["111111", "333333",  "555555", "777777"],
      'start_date': DateTime(2025, 5, 1, 10, 0),
      'end_date': DateTime(2025, 5, 1, 12, 0),
    },
    {
      'id': '754013',
      'course_code': 'CS301',
      'name': 'Cybersecurity',
      'room': 'online',
      'type': '"Extra Lecture"',
      'teacher_id': '000000',
      'students': ["111111", "333333",  "555555", "777777"],
      'start_date': DateTime(2025, 4, 28, 22, 0),
      'end_date': DateTime(2025, 4, 28, 24, 0),
    },
    {
      'id': '754014',
      'course_code': 'CS302',
      'name': 'Database Systems',
      'room': '303',
      'type': '"Extra Lecture"',
      'teacher_id': '000000',
      'students': ["222222", "444444",  "666666"],
      'start_date': DateTime(2025, 4, 24, 22, 0),
      'end_date': DateTime(2025, 4, 24, 24, 0),
    },
  ];

  try {
    for (var classSession in classes) {
      await firestore.collection('classes').add(classSession);
    }
    print('All class sessions added successfully!');
  } catch (e) {
    print('Error adding class sessions: $e');
  }
}

// Function to add data to Firestore
Future<void> addCourseData() async {
  final List<Map<String, dynamic>> courses = [
    {
      "code": "CS101",
      "name": "Introduction to AI",
      "hours": 4,
      "students_id": ["111111", "222222", "333333", "444444", "555555", "666666", "777777"],
      "teachers_id": ["000000", "101010", "202020", "303030"],
      "term_code": "3"
    },
    {
      "code": "CS102",
      "name": "Data Structures",
      "hours": 4,
      "students_id": ["111111", "222222", "333333", "444444", "555555", "666666", "777777"],
      "teachers_id": ["000000", "202020", "303030"],
      "term_code": "2"
    },
    {
      "code": "CS201",
      "name": "Machine Learning",
      "hours": 4,
      "students_id": ["111111", "222222", "333333", "444444"],
      "teachers_id": ["000000", "101010"],
      "term_code": "2"
    },
    {
      "code": "CS202",
      "name": "Cloud Computing",
      "hours": 4,
      "students_id": ["444444", "555555", "666666", "777777"],
      "teachers_id": ["000000", "101010", "303030"],
      "term_code": "2"
    },
    {
      "code": "CS301",
      "name": "Cybersecurity",
      "hours": 2,
      "students_id": ["111111", "333333", "555555", "777777"],
      "teachers_id": ["000000", "101010", "303030"],
      "term_code": "2"
    },
    {
      "code": "CS302",
      "name": "Database Systems",
      "hours": 3,
      "students_id": ["222222", "444444", "666666"],
      "teachers_id": ["000000", "202020"],
      "term_code": "3"
    },
  ];

  try {
    for (var course in courses) {
      await firestore.collection('courses').add(course);
    }
    print('All courses added successfully!');
  } catch (e) {
    print('Error adding courses: $e');
  }
}

// Function to add 7 Students data to Firestore
Future<void> add7StudentsData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Full list of users
  final List<Map<String, dynamic>> users = [
    // Students
    {'email': 'Abdelrahmanabdelnaby04@gmail.com', 'first_name': 'Abdelrahman', 'last_name': 'abdelnaby', 'id': '111111', 'uid': 'F48ITVqCTISwmN3pJWH2ILzkvJ12', 'role': 'student', 'attendance_rates': [], 'index': '1'},
    {'email': 'hala464069@gmail.com', 'first_name': 'hala', 'last_name': 'gamal', 'id': '222222', 'uid': 'l5bxZmZj8MZc3MH6m1DJ82jZwor1', 'role': 'student', 'attendance_rates': [], 'index': '2'},
    {'email': 'janamagdy480@gmail.com', 'first_name': 'jana', 'last_name': 'magdy', 'id': '333333', 'uid': 'sBAEgzvg7Na47zSYJ14JXBACbUF3', 'role': 'student', 'attendance_rates': [], 'index': '3'},
    {'email': 'magdaramadan188@gmail.com', 'first_name': 'Magda', 'last_name': 'ramadan', 'id': '444444', 'uid': 'iqIAhnLdkqMv8BJl19XFZZcXAfU2', 'role': 'student', 'attendance_rates': [], 'index': '4'},
    {'email': 'mariamelharash@gmail.com', 'first_name': 'mariam', 'last_name': 'omar', 'id': '555555', 'uid': 'wua7g6uJkOVLkgjS5Jvfyw8os8x2', 'role': 'student', 'attendance_rates': [], 'index': '5'},
    {'email': 'passantadel255@gmail.com', 'first_name': 'Passant', 'last_name': 'Adel', 'id': '666666', 'uid': '6xo73uHSarZDFq80xhAESm7uoA93', 'role': 'student', 'attendance_rates': [], 'index': '6'},
    {'email': 'joex071@gmail.com', 'first_name': 'Youssef', 'last_name': 'Mohammed', 'id': '666666', 'uid': 'A1Pjskmc2nT1ZuYAuB5rdXGTB2D3', 'role': 'student', 'attendance_rates': [], 'index': '7'},
  ];

  // Iterate through the users and add them to Firestore
  for (var user in users) {
    try {
      // Prepare the document data
      final userDoc = {
        'first_name': user['first_name'],
        'last_name': user['last_name'],
        'email': user['email'],
        //'id': (100000 + (Random().nextInt(900000))).toString(),
        'role': user['role'],
        'index': user['index'],
        if (user['role'] == 'student') 'attendance_rates': user['attendance_rates'], // Add attendance_rates for students
        'created_at': FieldValue.serverTimestamp(), // Set created_at to the current server time
      };

      // Save to Firestore using 'uid' as the document ID
      await firestore.collection('users').doc(user['uid']).update(userDoc);

      print("User ${user['email']} with UID ${user['uid']} added successfully.");
    } catch (e) {
      print("Error adding user ${user['email']} with UID ${user['uid']}: $e");
    }
  }
}

//code to create the complete users list up to 6@teacher.com and 6@student.com
Future<void> createUsersInFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Full list of users
  final List<Map<String, dynamic>> users = [
    // Teachers
    {'email': '1@teacher.com', 'name': 'teacher 111', 'id': '111111', 'uid': 'IxEsm5NKi8MXnYgjgJJqUuXc6Js2', 'role': 'teacher'},
    {'email': '2@teacher.com', 'name': 'teacher 222', 'id': '222222', 'uid': 'wURmFylDyleBGslRC2F3cCOtQi63', 'role': 'teacher'},
    {'email': '3@teacher.com', 'name': 'teacher 333', 'id': '333333', 'uid': 'nQDlBh4TGthUaja9eHnSfoGWbri1', 'role': 'teacher'},
    {'email': '4@teacher.com', 'name': 'teacher 444', 'id': '444444', 'uid': 'J6aQ4TJF8MRNndYUo51KbjTPYlE3', 'role': 'teacher'},
    {'email': '5@teacher.com', 'name': 'teacher 555', 'id': '555555', 'uid': 'XRmqdPrBr6b9bpWHgDX6yPPTolj2', 'role': 'teacher'},
    {'email': '6@teacher.com', 'name': 'teacher 666', 'id': '666666', 'uid': 'iR1JJhtuvoUxtWKoAALyuP1XOly2', 'role': 'teacher'},

    // Students
    {'email': '1@student.com', 'name': 'student 111', 'id': '111111', 'uid': 'kqF2eyhIq6PxRNa3Gbiel1YMJ193', 'role': 'student', 'attendance_rates': []},
    {'email': '2@student.com', 'name': 'student 222', 'id': '222222', 'uid': 'OzQb6oyl1MUHyVa1RCv7D2yKurz2', 'role': 'student', 'attendance_rates': []},
    {'email': '3@student.com', 'name': 'student 333', 'id': '333333', 'uid': 'eBdl2srrCQgGlBcN5IzlMS0kTwB2', 'role': 'student', 'attendance_rates': []},
    {'email': '4@student.com', 'name': 'student 444', 'id': '444444', 'uid': '8r6RCLMYtRUGPxVhvtH9QT9zHAN2', 'role': 'student', 'attendance_rates': []},
    {'email': '5@student.com', 'name': 'student 555', 'id': '555555', 'uid': 'uiIPVwAgeYaBRmaFfrlVQLQC8Bs2', 'role': 'student', 'attendance_rates': []},
    {'email': '6@student.com', 'name': 'student 666', 'id': '666666', 'uid': 'xL0M3SSjVbO86dvaqeRttlmwEFH3', 'role': 'student', 'attendance_rates': []},
  ];

  // Iterate through the users and add them to Firestore
  for (var user in users) {
    try {
      // Prepare the document data
      final userDoc = {
        'name': user['name'],
        'email': user['email'],
        'uid': user['uid'],
        'role': user['role'],
        if (user['role'] == 'student') 'attendance_rates': user['attendance_rates'], // Add attendance_rates for students
        'created_at': FieldValue.serverTimestamp(), // Set created_at to the current server time
      };

      // Save to Firestore using 'uid' as the document ID
      await firestore.collection('users').doc(user['uid']).set(userDoc);

      print("User ${user['email']} with UID ${user['uid']} added successfully.");
    } catch (e) {
      print("Error adding user ${user['email']} with UID ${user['uid']}: $e");
    }
  }
}


