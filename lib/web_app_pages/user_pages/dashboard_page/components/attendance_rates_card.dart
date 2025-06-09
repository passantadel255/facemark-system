import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AttendanceRatesCard extends StatelessWidget {
  final String courseName;
  final String courseCode;
  final double percentage;

  const AttendanceRatesCard({
    super.key,
    required this.courseName,
    required this.courseCode,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      margin: EdgeInsets.only(top:12, bottom: 30, right: 20, left: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Name and Code
          Text(
            courseName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Roboto',
              color: Color(0xFF192A51),
            ),
          ),
          Text(
            "code: $courseCode",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 35),

          // Circular Progress Indicator
          Center(
            child: CircularPercentIndicator(
              animation: true,
              animationDuration: 1200,
              radius: 55.0,
              lineWidth: 10.0,
              percent: percentage / 100, // Convert to a scale of 0-1
              center: Text(
                "${percentage.toInt()}%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              progressColor: percentage < 50 ? Colors.red : Colors.green,
              backgroundColor: Colors.grey[300]!,
              circularStrokeCap: CircularStrokeCap.round,

            ),
          ),
        ],
      ),
    );
  }
}

