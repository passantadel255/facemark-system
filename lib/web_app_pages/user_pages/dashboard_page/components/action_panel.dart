 import 'package:facemark/web_app_pages/user_pages/extra_classes/create_edit_class_dialog.dart';
import 'package:flutter/material.dart';


class ActionPanel extends StatelessWidget {
  const ActionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          "Action Panel",
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

        // Action Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(64),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: Image.asset("assets/images/app_components/add-class-calendar-icon.png", scale: 0.8,),
            title: Text(
              "Schedule New Extra Class",
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios, // Arrow icon on the right
              color: const Color(0xFF192A51),
            ),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => CreateEditClassDialog(
                  isEdit: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
