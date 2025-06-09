
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

List<String> formatTimestamp(Timestamp start, Timestamp end) {
  // Convert Timestamp to DateTime
  DateTime startDateTime = start.toDate();
  DateTime endDateTime = end.toDate();

  String startTime = DateFormat('h:mm a').format(DateTime(startDateTime.year, startDateTime.month, startDateTime.day, startDateTime.hour, startDateTime.minute));
  String endTime = DateFormat('h:mm a').format(DateTime(endDateTime.year, endDateTime.month, endDateTime.day, endDateTime.hour, endDateTime.minute));

  return [startTime, endTime];
}

String getDateFromTimestamp(Timestamp timestamp) {
  String date = DateFormat('E dd.MMM.yyyy').format(timestamp.toDate());

  // Create a TimeOfDay object from the hour and minute
  return date;
}

String getTimeFromTimestamp(Timestamp timestamp) {
  // Convert the Timestamp to DateTime
  DateTime dateTime = timestamp.toDate();

  String time = DateFormat('h:mm a').format(DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute));

  return  time;
}

DateTime getDateTimeFromTimestamp(Timestamp timestamp) {
  // Convert the Timestamp to DateTime
  DateTime dateTime = timestamp.toDate();

  // Return only the date part (day, month, year)
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

String getFormattedDate() {
  // Get the current date and time
  DateTime now = DateTime.now();

  // Create a new DateFormat object and use it to format the DateTime object
  String formattedDate = DateFormat('E dd.MMM.yyyy').format(now);

  return formattedDate;
}




