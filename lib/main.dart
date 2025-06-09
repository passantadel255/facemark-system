import "dart:html" as html show window;

import 'package:facemark/services/firebase_options.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:facemark/web_app_pages/main_pages/forget_password_page.dart';
import 'package:facemark/web_app_pages/main_pages/login_page.dart';
import 'package:facemark/web_app_pages/main_pages/404_not_found_page.dart';
import 'package:facemark/web_app_pages/user_pages/Course_page/courses_page.dart';
import 'package:facemark/web_app_pages/user_pages/attendance_history_page/all_classes_history_page.dart';
import 'package:facemark/web_app_pages/user_pages/dashboard_page/dashboard_page.dart';
import 'package:facemark/web_app_pages/user_pages/extra_classes/extra_classes_page.dart';
import 'package:facemark/web_app_pages/user_pages/settings_page.dart';
import 'package:facemark/custom_widgets/hex_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart' show PathUrlStrategy, setUrlStrategy;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(ResponsiveWrapper(child: MyApp()));

  html.window.onResize.listen((event) {
    // Triggers layout rebuild
    WidgetsBinding.instance.handleMetricsChanged();
  });
}


class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    errorBuilder: (context, state) => const ErrorScreen(),
    routes: <GoRoute>[
      GoRoute(
        routes: <GoRoute>[

          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) =>
                LoginPage(),
          ), //login

          GoRoute(
            path: 'forget-password',
            builder: (BuildContext context, GoRouterState state) =>
            const ForgetPasswordPage(),
          ), //forget password

          GoRoute(
            path: 'Dashboard',
            builder: (BuildContext context, GoRouterState state) =>
            const DashboardPage(),
          ), //Dashboard Page

          GoRoute(
            path: 'Courses',
            builder: (BuildContext context, GoRouterState state) =>
            const CoursesPage(),
          ), //Courses Page

          GoRoute(
            path: 'Attendance-History',
            builder: (BuildContext context, GoRouterState state) =>
            const AttendanceHistoryPage(),
          ), //Attendance History

          GoRoute(
            path: 'Extra-Classes',
            builder: (BuildContext context, GoRouterState state) =>
            const ExtraClassesPage(),
          ), //Extra Classes

          GoRoute(
            path: 'Settings',
            builder: (BuildContext context, GoRouterState state) =>
            const SettingsPage(),
          ), //Settings Page


        ],
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            LoginPage(),


      ),
    ],
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) async {

      // Check if the user is logged in
      bool Auth = await isAuth();
      var role = userData.role;

      if(Auth){
        if(state.fullPath == "/login"  || state.fullPath == "/" ){
          //print("return : /Dashboard");
          return "/Dashboard";
        }
        else
        if((state.fullPath == "/Extra-Classes" || state.fullPath == "/Attendance-History") && role == 'student' && role != 'N/A'){
          //print("Not auth");
          return "/404";
        }
      }else{
        if(state.fullPath == "/Dashboard"  || state.fullPath == "/Courses"   || state.fullPath == "/Attendance-History"   || state.fullPath == "/Extra-Classes"   || state.fullPath == "/Settings" ){
          //print("Not auth");
          return "/404";
        }
      }


      // No redirection needed, return null
      //print("return : ${state.fullPath}");
      return null;
    },
  );


  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'FaceMark',
    theme: ThemeData(
      // Global Theme Settings
      colorScheme: const ColorScheme(
        primary: Color(0xFF192A51), // Dark Blue
        primaryContainer: Color(0xFF36479D), // Muted Blue
        secondary: Color(0xFF967AA1), // Muted Purple
        secondaryContainer: Color(0xFFAAA1C8), // Pale Pink
        surface: Color(0xFFFFFFFF), // White
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF192A51),
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
      textTheme:  TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Montserrat', // Use the variable font
          fontSize: 28,
          fontWeight: FontWeight.bold, // Bold weight
          color: Color(0xFF192A51), // Dark blue fill color
          shadows: [
            BoxShadow(
              color: Color.fromARGB((0.25 * 255).toInt(), 0, 0, 0), // For 25% opacity black
              offset: Offset(0, 4), // X: 0, Y: 4
              blurRadius: 4, // Blur effect
            ),
          ],
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF192A51), // Dark Blue
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Pale Pink Background
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF967AA1), // Muted Purple Button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Rounded corners
        ),
        side: const BorderSide(
          color: Color(0xFF967AA1), // Muted Purple outline for unchecked
          width: 1.5, // Thickness of the border
        ),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF967AA1); // Muted Purple when selected
          }
          return Colors.transparent; // Transparent background when unchecked
        }),
        checkColor: WidgetStateProperty.all(Colors.white), // Checkmark color
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(8.0), // Slimmer scrollbar
        radius: const Radius.circular(10), // Rounded ends of the scrollbar
        thumbColor: WidgetStateProperty.all(
          HexColor("#192A51").withOpacity(0.9), // Dark blue thumb
        ),
        trackColor: WidgetStateProperty.all(
          HexColor("#D5C6E0").withOpacity(0.3), // Light lavender track
        ),
        trackBorderColor: WidgetStateProperty.all(Colors.transparent), // No border for the track
        crossAxisMargin: 4,
        mainAxisMargin: 4,

      ),


    ),
    routerDelegate: _router.routerDelegate,
    routeInformationParser: _router.routeInformationParser,
    routeInformationProvider: _router.routeInformationProvider,
  );
}


class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Rebuild the app on size change
        return child;
      },
    );
  }
}
