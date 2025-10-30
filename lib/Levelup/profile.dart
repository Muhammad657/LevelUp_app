import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_club/Levelup/bloc/login_bloc.dart';
import 'package:flutter_club/Levelup/courses.dart';
import 'package:flutter_club/Levelup/stats.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController satR = TextEditingController();
  TextEditingController satM = TextEditingController();
  String imageurl = "lib/showcase_project/images/av8.png";
  bool isLoading = true;
  String text = "Muhammad Hegde\n11th Grade\nAndover High School";
  String interestText = 'Political Science, Arson, Gooning';

  @override
  void initState() {
    super.initState();
    run_func();
  }

  run_func() async {
    final profile_data = await FirebaseFirestore.instance
        .collection("profile")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    final profile_data2 = profile_data.data();
    print(profile_data2);
    if (profile_data2 != null) {
      setState(() {
        text =
            "${profile_data2["name"]}\n${profile_data2["grade"]}th Grade\n${profile_data2["school"]}";
        interestText = "${List.from(profile_data2["interests"]).join(", ")}";
        isLoading = false;
        return;
      });
    }

    final avatarData = await FirebaseFirestore.instance
        .collection("avatar")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (avatarData.data() != null) {
      setState(() {
        imageurl = avatarData.data()!["image"];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
          ),
        ),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(118, 251, 166, 1),
                ),
              )
            : SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      if (state is ChangeAvatarState) {
                        imageurl = state.imageurl;
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'My Profile',
                              style: GoogleFonts.michroma(
                                color: Colors.white,
                                fontSize: 32.sp,
                              ),
                            ),

                            SizedBox(height: 30.h),
                            SizedBox(
                              height: 345.h,
                              width: double.infinity.w,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 15.h,
                                    left: 125.w,
                                    child: Container(
                                      width: 140.w,
                                      height: 140.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,

                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xff374b81),
                                            Color(0xff2a3b6b),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color: Colors.black.withOpacity(
                                        //       0.3,
                                        //     ),
                                        //     blurRadius: 10,
                                        //     offset: Offset(0, 4),
                                        //   ),
                                        // ],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          imageurl,

                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 160.h,
                                    left: 20.w,
                                    child: GlassContainer.frostedGlass(
                                      borderWidth: 0.w,
                                      frostedOpacity: 0.05,
                                      borderRadius: BorderRadius.circular(40),
                                      width: 345.w,
                                      height: 150.h,

                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: 25.w,
                                          // t0.w,
                                          left: 25.w,
                                          // 0.w,
                                        ),
                                        child: Column(
                                          spacing: 5,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              text,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.spaceGrotesk(
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 21.sp,
                                                  fontWeight: FontWeight.w300,
                                                  wordSpacing: 3.w,
                                                ),
                                              ),
                                            ),
                                            // Text(
                                            //   interestText,
                                            //   style: GoogleFonts.spaceGrotesk(
                                            //     fontSize: 17.sp,
                                            //     color: Colors.blue,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: 40.h),
                            GlassContainer.frostedGlass(
                              width: 240.w,
                              height: 65.h,
                              borderWidth: 0,
                              frostedOpacity: 0.01,
                              borderRadius: BorderRadius.circular(50),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    Colors.grey.withOpacity(0.1),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Stats(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Academic Stats',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 22.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 25.h),
                            GlassContainer.frostedGlass(
                              width: 240.w,
                              height: 65.h,
                              borderWidth: 0.w,
                              frostedOpacity: 0.01,
                              borderRadius: BorderRadius.circular(50.r),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    Colors.grey.withOpacity(0.1),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Courses(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'School Courses',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 22.sp,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
