
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

/// Send email using Mailgun API
Future<void> sendEmail({
  required List<String> recEmails,
  required String drEmail,
  required String drName,
  required String crsNm,
  required String crsCd,
  required String day,
  required String start,
  required String end,
  required String type,
  required String room,
  required String notes,
  required bool isEdit,
}) async {
  final url = Uri.parse('https://api.mailgun.net/v3/sandbox2cca88c626ac4a9189c15ffda442f35d.mailgun.org/messages');
  const apiKey = 'API_KEY';
  final basicAuth = 'Basic ${base64Encode(utf8.encode('api:$apiKey'))}';

  final htmlContent = await getEmailTemplate(
    drName: drName,
    crsNm: crsNm,
    crsCd: crsCd,
    day: day,
    start: start,
    end: end,
    type: type,
    room: room,
    notes: notes,
    isEdit: isEdit,
  );

  final response = await http.post(
    url,
    headers: {
      'Authorization': basicAuth,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'from': 'FaceMark App <postmaster@sandbox2cca88c626ac4a9189c15ffda442f35d.mailgun.org>',
      'to': 'abdelrhman.bekheet@gmail.com',
      'subject': isEdit ? 'Updated Extra Class Information' : 'New Extra Class Notification',
      'html': htmlContent,
    },
  );
  //recEmails.join(',')

  if (response.statusCode == 200) {
    print('Email sent successfully.');
  } else {
    print('Failed to send email: ${response.body}');
  }
}



Future<String> getEmailTemplate({
  required String drName,
  required String crsNm,
  required String crsCd,
  required String day,
  required String start,
  required String end,
  required String type,
  required String room,
  required String notes,
  required bool isEdit,
}) async {
  final htmlTemplate = await rootBundle.loadString('assets/templates/email_template.html');

  const appLogoUrl =
      "https://firebasestorage.googleapis.com/v0/b/facemark-307a2.firebasestorage.app/o/app_logo%2FFaceMark_logo.png?alt=media&token=d29615b8-0183-4427-92c8-a53d58825dcb";

  return htmlTemplate
      .replaceAll('{{appLogo}}', appLogoUrl)
      .replaceAll('{{title}}', isEdit ? 'Updated Extra Class Info' : 'New Extra Class Created')
      .replaceAll('{{drName}}', drName)
      .replaceAll('{{crsNm}}', crsNm)
      .replaceAll('{{crsCd}}', crsCd)
      .replaceAll('{{day}}', day)
      .replaceAll('{{start}}', start)
      .replaceAll('{{end}}', end)
      .replaceAll('{{type}}', type)
      .replaceAll('{{room}}', room)
      .replaceAll('{{notes}}', notes);
}


