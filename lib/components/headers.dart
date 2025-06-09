import 'package:facemark/custom_widgets/custom_icon_widget.dart';
import 'package:facemark/custom_widgets/custom_snack_bar.dart';
import 'package:facemark/custom_widgets/hex_color.dart';
import 'package:facemark/custom_widgets/loading.dart';
import 'package:facemark/custom_widgets/logout_dialog.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class BasicHeader extends StatelessWidget {
  const BasicHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor("#192A51"),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(64), // Black with 25% opacity
            offset: const Offset(0, 4), // X: 0, Y: 4
            blurRadius: 4, // Blur: 4
            spreadRadius: 0, // Spread: 0
          ),
        ],
      ),
      width: double.infinity,
      child: Center(
        child: Image.asset(
          'assets/images/app_logo/header-logo.png',
          height: 70,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}



class HeaderBar extends StatefulWidget {
  final dynamic title;
  final dynamic icon;

  const HeaderBar({super.key, required this.title, required this.icon});

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout(context) async {
    try {
      bool confirmLogout = await showLogoutDialog(context);

      if (confirmLogout) {
        await _auth.signOut();
        userData.clear();

        if (mounted) {
          GoRouter.of(context).go('/'); // Redirect to login page
        }
      }
    } catch (e) {
      // Handle potential errors
      showCustomSnackBar(
        context,
        'Logout failed: ${e.toString()}',
        isSuccess: false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
// Screen dimensions for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine if the screen is mobile or desktop
    final isMobile = screenWidth < 680;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 4,
            color: Colors.black.withAlpha(50),
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CustomIconWidget(icon: widget.icon, size: isMobile ? 25 : 30),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize:  isMobile ? 18 : 22,
                  fontFamily: 'Roboto',
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
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Row(
            children:  [
              //Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 4),
                      blurRadius: 4,
                      color: Colors.black.withAlpha(64),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: Image.network(
                      userData.image_url,
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  ),
                ),

              ),

              if(!isMobile) ...[
              SizedBox(width: 25),
              IconButton(onPressed: (){}, icon: CustomIconWidget(icon: Icons.notifications),),
              IconButton(onPressed: (){context.go("/Settings");}, icon: CustomIconWidget(icon: Icons.settings),),
              IconButton(onPressed: (){_logout(context);}, icon: CustomIconWidget(icon: Icons.logout),),
              ]
            ],
          ),
        ],
      ),
    );
  }
}












class buildappbar extends StatefulWidget {


  const buildappbar({super.key,});



  @override
  State<buildappbar> createState() => _buildappbarState();
}

class _buildappbarState extends State<buildappbar> {

  var isMenu = false;
  var isMainMenuHov = false;
  var isMainMenuOpen = true;

  var Auth = false ;
  var url;
  bool flg1= false,
      flg2 = false,
      flg3 = false,
      flg4 = false,
      flg5 = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth = userData.isAuth;
  }

  signOut() async {
    showLoading(context);
    try{
      await FirebaseAuth.instance.signOut();
      userData.clear();

      context.go("/");
    }catch (e){
      print(e);
    }
  }



  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;


    return AppBar(
      elevation: 0,
      backgroundColor: HexColor('#13132B'),
      title: Container(
        padding: width > 400 ?   const EdgeInsets.only(top: 10) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: (){
                context.go('/');
              },
              child: Image.asset(
                'assets/images/logo/main.png',
                height: width >= 850 ? 45 : width >= 500 ? 40 : 35 ,
              ),
            ),
            const SizedBox(width: 20),
            // InkWell(
            //   onTap: (){
            //     setState(() {
            //       isMainMenuOpen = !isMainMenuOpen;
            //     });
            //   },
            //   onHover: (val){
            //     setState(() {
            //       isMainMenuHov = val;
            //     });
            //   },
            //   child: Icon(
            //     isMainMenuOpen ? Icons.menu_open : Icons.menu,
            //     color: isMainMenuHov ? HexColor("#FE5A01"):HexColor("#ffffff"),
            //     size: 35,
            //   ),
            // ),
          ],
        ),
      ),

      automaticallyImplyLeading: false, // Disable the leading widget
    );
  }
}


