import 'package:facemark/custom_widgets/custom_icon_widget.dart';
import 'package:flutter/material.dart';



class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20,),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Container(
            height: 45,
            width: 140,
            decoration: BoxDecoration(
              color: const Color(0xffF2F4F8),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                  color: Colors.black.withAlpha(50),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(icon:Icons.arrow_back,
                    iconColor: const Color(0xff192A51),
                    size: 28,
                  ),
                  SizedBox(width: 15),
                  Text(
                    "Back",
                    style: TextStyle(
                      color: const Color(0xff192A51),
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      shadows:  [
                        Shadow(
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                          color: Colors.black.withAlpha(64),
                        ),
                      ],

                    ),
                    textAlign: TextAlign.center,

                  ),
                  SizedBox(width: 10),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
