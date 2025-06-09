import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onDelete;

  const DeleteConfirmationDialog({
    required this.student,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Delete confirmation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF192A51),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Are you sure from delete this student:',
                style: TextStyle(fontSize: 14),
              ),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Name: ${student['name']}\n'
                    'email: ${student['email']}\n'
                    'id: ${student['id']}',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    shape: StadiumBorder(),
                  ),
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
