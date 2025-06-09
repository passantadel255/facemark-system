
import 'package:facemark/custom_widgets/custom_icon_widget.dart';
import 'package:flutter/material.dart';


class NotificationFeed extends StatelessWidget {
  const NotificationFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          "Notification Feed",
          style: TextStyle(
            fontSize:  18,
            fontFamily: 'Montserrat',
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
        ),
        const SizedBox(height: 8),

        // Notification List
        Container(
          constraints: BoxConstraints(maxHeight: 220, minHeight: 180),
          height: 220,
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            thickness: 6,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(left: 10,right: 20, top: 10, bottom: 10),
              child: Column(
                children: const [
                  NotificationCard(
                    title: "New scheduled class",
                    subtitle: "Class Scheduled",
                    dateTime: "10th Oct, 2:00 PM",
                  ),
                  SizedBox(height: 12), // Spacing between cards
                  NotificationCard(
                    title: "New scheduled class",
                    subtitle: "Class Scheduled",
                    dateTime: "10th Oct, 2:00 PM",
                  ),
                  SizedBox(height: 12), // Spacing between cards
                  NotificationCard(
                    title: "New scheduled class",
                    subtitle: "Class Scheduled",
                    dateTime: "10th Oct, 2:00 PM",
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateTime;

  const NotificationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          CustomIconWidget(
            icon:Icons.calendar_month_outlined,
            size: 24,
          ),
          const SizedBox(width: 12),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF192A51),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  dateTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Close Button
          IconButton(
            onPressed: () {
              // Handle dismiss action here
            },
            icon: const Icon(
              Icons.close,
              color: Color(0xFF192A51),
            ),
          ),
        ],
      ),
    );
  }
}