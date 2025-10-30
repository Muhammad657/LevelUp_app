import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_club/notifiers.dart';
import 'package:flutter_club/showcase_project/ai_chat.dart';
import 'package:flutter_club/showcase_project/awards.dart';
import 'package:flutter_club/showcase_project/bloc/login_bloc.dart';
import 'package:flutter_club/showcase_project/college_rec.dart';
import 'package:flutter_club/showcase_project/home_page.dart';
import 'package:flutter_club/showcase_project/join_new.dart';
import 'package:flutter_club/showcase_project/login_project.dart';
import 'package:flutter_club/showcase_project/profile.dart';
import 'package:flutter_club/showcase_project/settings.dart';
import 'package:flutter_club/showcase_project/student_form_1.dart';
import 'package:flutter_club/showcase_project/tracker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

List<Widget> pages = [
  Tracker(),
  JoinNew(),
  CollegeResearchPage(),
  Settings(),
  AIChat(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is IncompleteProfileNavigationState) {
          print("State");
          selectedPageNotifier.value = 2;
        }
        Future.delayed(Duration.zero, () {
          // You might want to add a ResetNavigationEvent to your bloc
          // BlocProvider.of<LoginBloc>(context).add(ResetNavigationEvent());
        });
      },
      child: Scaffold(
        body: Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: selectedPageNotifier,
              builder: (context, value, child) => Scaffold(
                backgroundColor: Color(0xFF003153),
                body: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
                    ),
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: selectedPageNotifier,
                    builder: (BuildContext context, value, Widget? child) {
                      return pages.elementAt(value);
                    },
                  ),
                ),
                bottomNavigationBar: Padding(
                  padding: EdgeInsets.only(
                    left: 25.w,
                    right: 25.w,
                    bottom: 30.h,
                    top: 30.h,
                  ),
                  child: GlassContainer.frostedGlass(
                    width: 350.w,
                    height: 70.h,
                    borderRadius: BorderRadius.circular(40.r),
                    borderColor: Colors.white.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 10.h,
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: selectedPageNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return GNav(
                          gap: 8.w,
                          curve: Curves.easeOutExpo,
                          duration: Duration(milliseconds: 300),
                          activeColor: Colors.white,
                          color: Colors.white.withOpacity(0.7),
                          iconSize: 40.sp,

                          tabBackgroundGradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF584BF5).withOpacity(0.7),
                              Color(0xFF2575FC).withOpacity(0.7),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          selectedIndex: value,
                          onTabChange: (value) =>
                              selectedPageNotifier.value = value,
                          tabs: [
                            GButton(
                              icon: CupertinoIcons.home,
                              // text: 'Home',
                              iconActiveColor: Colors.white,
                            ),

                            GButton(
                              icon: CupertinoIcons.add_circled,
                              // text: 'New ECs',
                              iconActiveColor: Colors.white,
                            ),
                            GButton(
                              icon: Icons.school,
                              iconActiveColor: Colors.white,
                            ),
                            // GButton(
                            //   icon: CupertinoIcons.profile_circled,
                            //   // text: 'Profile',
                            //   iconActiveColor: Colors.white,
                            // ),
                            GButton(
                              icon: CupertinoIcons.settings,
                              // text: 'Settings',
                              iconActiveColor: Colors.white,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 170.w,
              bottom: 80.h,
              child: ValueListenableBuilder(
                valueListenable: selectedPageNotifier,
                builder: (context, value, child) => Container(
                  padding: MediaQuery.of(context).size.width >= 600
                      ? EdgeInsets.all(10.w)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: value == 4
                          ? [Color(0xFF584BF5), Color(0xFF2575FC)]
                          : [
                              Color.fromRGBO(117, 130, 145, 1),
                              Color.fromRGBO(117, 130, 145, 1),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: value == 4
                            ? Color.fromARGB(255, 87, 73, 248).withOpacity(0.4)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: 10.r,
                        spreadRadius: 1.r,
                        offset: Offset(0, 3),
                      ),
                      BoxShadow(
                        color: value == 4
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: 10.r,
                        spreadRadius: 1.r,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    heroTag: "Navbar floating action button",
                    elevation: 0,
                    highlightElevation: 0,

                    shape: CircleBorder(
                      side: BorderSide(color: Colors.transparent),
                    ),
                    onPressed: () {
                      selectedPageNotifier.value = 4;
                    },
                    backgroundColor: Colors.transparent,

                    child: Padding(
                      padding: EdgeInsetsGeometry.all(0.w),
                      child: Icon(
                        CupertinoIcons.sparkles,
                        size: 28.sp,
                        color: value == 4
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
