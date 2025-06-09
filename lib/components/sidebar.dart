import 'package:facemark/custom_widgets/custom_icon_widget.dart';
import 'package:facemark/custom_widgets/custom_snack_bar.dart';
import 'package:facemark/custom_widgets/logout_dialog.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

bool isMenu = true;

class Sidebar extends StatefulWidget {
  final Function() toggleMenu;

  const Sidebar({super.key,  required this.toggleMenu});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedRoute = '';

  void _logout() async {
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

  String getCurrentRoute(BuildContext context) {
    return GoRouter.of(context).routerDelegate.currentConfiguration.matches.last.matchedLocation;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedRoute = getCurrentRoute(context);
    //print("Current Route: ${selectedRoute}");

  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    isMenu = screenWidth < 800 ? false : isMenu;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isMenu ? 250 : 90,
      color: const Color(0xFF192A51),
      child: Column(

        crossAxisAlignment: isMenu ? CrossAxisAlignment.start: CrossAxisAlignment.center,
        children: [
          //app logo
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isMenu ? 8.0 : 4.0),
              child: Image.asset(
                isMenu ? 'assets/images/app_logo/dashoboard-logo.png' : 'assets/images/app_logo/dashoboard-logo-small.png',
                height: 60,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),


          // User Info
          isMenu ?
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 15,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 4,
                            color: Colors.white.withAlpha(64),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[200],
                        child: ClipOval(
                          child: Image.network(
                            userData.image_url,
                            fit: BoxFit.cover,
                            width: 65,
                            height: 65,
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

                    Container(
                      constraints: BoxConstraints(maxWidth: 150),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:  [
                            Text("${userData.first_name} ${userData.last_name}",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Roboto')
                            ),
                            Text("id: ${userData.id}" ,
                                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')
                            ),
                          ],
                        ),
                    ),
                    ],
                ),
                SizedBox(height: 10,),
                const Divider(color: Colors.white54, endIndent: 20, indent: 20,),
              ],
            ),
          ) :
          SizedBox(height: 10),

          if(!isMenu)
            const Divider(color: Colors.white54, endIndent: 20, indent: 20,),

          // Menu Items
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildMenuItem(Icons.dashboard_outlined, "Dashboard", '/Dashboard'),
                _buildMenuItem(Icons.menu_book_outlined, "Courses", '/Courses'),
                if(userData.role == 'teacher') ...[
                  _buildMenuItem(Icons.class_outlined, "Extra Classes", '/Extra-Classes'),
                  _buildMenuItem(Icons.history_edu_outlined, "Attendance History", '/Attendance-History'),
                ]
              ],
            ),
          ),

          // Toggle Menu Button
          Column(
            children: [
              if(screenWidth >= 800)
              Align(
                alignment: isMenu ? Alignment.centerLeft : Alignment.center,
                child: IconButton(
                  icon: CustomIconWidget(icon:isMenu ? Icons.menu_open : Icons.menu, iconColor: const Color(0xFFF5E6E8),size: 30,),
                  onPressed: widget.toggleMenu,
                ),
              ),
              const Divider(color: Colors.white54, endIndent: 30, indent: 30,),
              _buildMenuItem(Icons.settings, "Settings", '/Settings'),
              _buildMenuItem(Icons.logout, "Logout", '/', isLogout: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String route, {bool isLogout = false}) {
    final bool isSelected = selectedRoute == route;
    return InkWell(
      onTap: () {
        if (isLogout) {
          _logout();
        } else {
          context.go(route);
        }
      },
      child: Container(
          alignment: isMenu ? Alignment.centerLeft : Alignment.center,
          height: isMenu ? 45 : 75,
          padding: EdgeInsets.symmetric(horizontal: isMenu ? 10 : 5) ,
          margin: isMenu ? EdgeInsets.only(top: 5,bottom: 5,right: 15): EdgeInsets.only(top: 10,bottom: 10,right: 5, left: 5),
          decoration: BoxDecoration(
          color: isSelected ? Color(0xFFF5E6E8) : Colors.transparent,
          borderRadius: isMenu ? BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ): BorderRadius.circular(20),
        ),
        child: Wrap(
          spacing: 10,
          runSpacing: 5,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center ,
          children: [
            CustomIconWidget(icon: icon, iconColor: isSelected ? const Color(0xFF192A51) : const Color(0xFFF5E6E8), size: isLogout || route == '/Settings' ? 25 : isMenu ? 28 : 35,),
            Text(
              title,
              style: TextStyle(
                fontSize:  !isMenu ? 12 : isLogout || route == '/Settings' ? 14 :  16,
                fontFamily: 'Roboto',
                height: 1.1,
                fontWeight: isSelected ? FontWeight.bold : isMenu ? FontWeight.w500: FontWeight.w300  ,
                color: isSelected ? const Color(0xFF192A51) : const Color(0xFFF5E6E8),
                shadows:  [
                  Shadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    color: isSelected
                        ? Colors.black.withAlpha(64) : Colors.transparent,
                  ),
                ],
              ),
                  textAlign: TextAlign.center,
            ),
          ],
        )
      ),
    );
  }
}
