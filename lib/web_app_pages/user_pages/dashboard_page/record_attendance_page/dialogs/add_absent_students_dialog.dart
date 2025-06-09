import 'package:flutter/material.dart';

class AddAbsentStudentsDialog extends StatefulWidget {
  final List absentStudents;
  final Function(List<Map<String, dynamic>>) onConfirm;

  const AddAbsentStudentsDialog({
    required this.absentStudents,
    required this.onConfirm,
    super.key,
  });

  @override
  State<AddAbsentStudentsDialog> createState() => _AddAbsentStudentsDialogState();
}

class _AddAbsentStudentsDialogState extends State<AddAbsentStudentsDialog> {
  final List<Map<String, dynamic>> selected = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Row
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Student',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF192A51)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Student List or "All present" text
            Flexible(
              child: widget.absentStudents.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                itemCount: widget.absentStudents.length,
                itemBuilder: (context, index) {
                  final student = Map<String, dynamic>.from(widget.absentStudents[index]);
                  final isSelected = selected.any((s) => s['id'] == student['id']);

                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        student['image'],
                        fit: BoxFit.cover,
                        width: 65,
                        height: 65,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                    title: Text("Name: ${student['name']}"),
                    subtitle: Text("ID: ${student['id']}"),
                    trailing: Checkbox(
                      value: isSelected,
                      activeColor: const Color(0xFF192A51),
                      onChanged: (value) {
                        setState(() {
                          // Always remove any existing matching item first
                          selected.removeWhere((s) => s['id'] == student['id']);
                          if (value == true) {
                            selected.add(student);
                          }
                        });
                      },
                    ),
                  );
                },
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'All students are present',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF192A51),
                    shadows: [
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

            const SizedBox(height: 12),

            // Confirm button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192A51),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // Ensure no duplicates
                  final uniqueSelected = {
                    for (var s in selected) s['id']: s,
                  }.values.toList();

                  widget.onConfirm(uniqueSelected);
                  Navigator.pop(context);
                },
                child: const Text('Confirm', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
