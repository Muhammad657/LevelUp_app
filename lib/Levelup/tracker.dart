import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_club/notifiers.dart';
import 'package:flutter_club/Levelup/bloc/login_bloc.dart';
import 'package:flutter_club/Levelup/circularprogressindicator.dart';
import 'package:flutter_club/Levelup/profile.dart';
import 'package:flutter_club/Levelup/styled_activities_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  PageController horizontalController = PageController();
  PageController checklistController = PageController();
  int currentPage = 0;
  final Uri collegeBoard = Uri.parse('https://www.collegeboard.org/');
  final Uri essayEditor = Uri.parse(
    'https://test-ninjas.com/college-essay-editor',
  );
  final Uri ecList = Uri.parse(
    'https://kdcollegeprep.com/extracurricular-activities-160-ideas-how-to-choose-wisely/',
  );

  Map<String, dynamic> data = {};

  String avatar = "lib/showcase_project/images/av8.png";
  List colleges = [];
  List scholarships = [];
  @override
  void initState() {
    super.initState();
    run_func();
    _load_firebasestuff();
  }

  run_func() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("profile")
            .doc(user.email)
            .get();

        if (doc.exists && doc.data() != null) {
          data = doc.data() as Map<String, dynamic>;
          final data2 = doc.data()!;

          // Check if GPA fields are filled
          final gpaW = data2['gpaW']?.toString().trim();
          final gpaUW = data2['gpaUW']?.toString().trim();
          final hasGPA =
              (gpaW != null && gpaW.isNotEmpty) ||
              (gpaUW != null && gpaUW.isNotEmpty);

          // Check if courses are filled
          // final hasCourses =
          //     data['courses'] != null &&
          //     data['courses'] is List &&
          //     (data['courses'] as List).isNotEmpty;

          setState(() {
            _isProfileComplete = hasGPA;
          });

          // Show dialog if profile is incomplete
          if (!_isProfileComplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showIncompleteProfileDialog();
            });
          }
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showIncompleteProfileDialog();
          });
        }
      }

      final avatarData = await FirebaseFirestore.instance
          .collection("avatar")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (avatarData.data() != null) {
        setState(() {
          avatar = avatarData.data()!["image"];
        });
      }

      final collegeFollowingData = await FirebaseFirestore.instance
          .collection("user_follows")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (collegeFollowingData.data() != null) {
        print("here in if");
        setState(() {
          print("data list: ${collegeFollowingData.data()}");
          colleges = collegeFollowingData.data()!["list"] as List;
          print("colleges: $colleges");
          print("data list: ${collegeFollowingData.data()}");
        });
      } else {
        print("here in else");
        setState(() {
          colleges = [];
        });
      }

      final scholarshipFollowingData = await FirebaseFirestore.instance
          .collection("user_saved_scholarships")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (scholarshipFollowingData.data() != null) {
        print("here in if");
        setState(() {
          print("data list: ${scholarshipFollowingData.data()}");
          scholarships = scholarshipFollowingData.data()!["list"] as List;
          print("colleges: $scholarships");
          print("data list: ${scholarshipFollowingData.data()}");
        });
      } else {
        print("here in else");
        setState(() {
          scholarships = [];
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error checking profile: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isLoading = true;
  _load_firebasestuff() async {}

  // Future<void> _checkProfileCompletion() async {

  // }

  bool _isProfileComplete = false;

  void _showIncompleteProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1B1B1B),
          title: Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Text(
              'Profile Incomplete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Padding(
            padding: EdgeInsetsGeometry.all(8.w),
            child: Text(
              'Please complete your profile by filling out your GPA information to access all features.',
              style: TextStyle(color: Colors.white70, fontSize: 16.sp),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                // selectedPageNotifier.value = 2;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
                // BlocProvider.of<LoginBloc>(
                //   context,
                // ).add(IncompleteProfileNavigationEvent());
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_forward, color: Colors.blue),
                  SizedBox(width: 8.w),
                  Text(
                    'Go to Profile',
                    style: TextStyle(color: Colors.blue, fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    print(colleges);
    return Scaffold(
      backgroundColor: Color(0xFF0C1425),
      body: isLoading
          ? TechyLoadingScreen()
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 15),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Back",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 21.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  data["name"] ?? "User",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 22.sp,
                                    letterSpacing: 3,
                                    fontWeight: FontWeight.w900,
                                    color: Color.fromRGBO(89, 187, 125, 1),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                if (state is ChangeAvatarState) {
                                  avatar = state.imageurl;
                                }
                                return InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Profile(),
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(avatar, width: 60.w),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        // Replace the entire External Resources section with this:
                        SizedBox(height: 20.h),
                        Container(
                          height: 365.h,
                          width: screenWidth,
                          child: PageView(
                            controller: horizontalController,
                            onPageChanged: (index) {
                              setState(() => currentPage = index);
                            },
                            children: [
                              // College list page
                              Container(
                                padding: EdgeInsets.only(
                                  right: 8.0,
                                ), // Add padding to separate from next page
                                child: SizedBox(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                          horizontal: 20.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0xFF1E293B,
                                          ).withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Colors.blueAccent
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'Colleges Following',
                                          style: GoogleFonts.michroma(
                                            color: Colors.white,
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.1.w,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          color: Colors.white.withOpacity(0.05),
                                        ),

                                        height: 255.h,
                                        width: screenWidth - 32.0,
                                        child: colleges.isEmpty
                                            ? Center(
                                                child: Text(
                                                  'No colleges added yet',
                                                  style:
                                                      GoogleFonts.spaceGrotesk(
                                                        color: Colors.white54,
                                                        fontSize: 16,
                                                      ),
                                                ),
                                              )
                                            : ListView.builder(
                                                itemCount: colleges.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                      bottom: 12,
                                                    ),
                                                    padding: EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                      color: Color(
                                                        0xFF1E293B,
                                                      ).withOpacity(0.8),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.blueAccent
                                                            .withOpacity(0.2),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // College name only at top
                                                        Text(
                                                          colleges[index]["collegeName"],
                                                          style:
                                                              GoogleFonts.spaceGrotesk(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),

                                                        SizedBox(height: 12),

                                                        // Level and URL button row
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            // Level badge
                                                            Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 6,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: _getLevelColor(
                                                                  colleges[index]["level"],
                                                                ).withOpacity(0.2),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                                border: Border.all(
                                                                  color: _getLevelColor(
                                                                    colleges[index]["level"],
                                                                  ).withOpacity(0.5),
                                                                ),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .school_rounded,
                                                                    size: 12,
                                                                    color: _getLevelColor(
                                                                      colleges[index]["level"],
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 6,
                                                                  ),
                                                                  Text(
                                                                    _getLevelText(
                                                                      colleges[index]["level"],
                                                                    ),
                                                                    style: GoogleFonts.spaceGrotesk(
                                                                      color: _getLevelColor(
                                                                        colleges[index]["level"],
                                                                      ),
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            // URL button
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  colors: [
                                                                    Colors
                                                                        .blueAccent
                                                                        .withOpacity(
                                                                          0.3,
                                                                        ),
                                                                    Colors
                                                                        .lightBlueAccent
                                                                        .withOpacity(
                                                                          0.2,
                                                                        ),
                                                                  ],
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .blueAccent
                                                                      .withOpacity(
                                                                        0.4,
                                                                      ),
                                                                ),
                                                              ),
                                                              child: TextButton.icon(
                                                                onPressed: () async {
                                                                  if (!await launchUrl(
                                                                    Uri.parse(
                                                                      colleges[index]["link"],
                                                                    ),
                                                                    mode: LaunchMode
                                                                        .externalApplication,
                                                                  )) {
                                                                    ScaffoldMessenger.of(
                                                                      context,
                                                                    ).showSnackBar(
                                                                      SnackBar(
                                                                        content: Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.error_rounded,
                                                                              color: Colors.red,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 12.w,
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                'Failed to open url',
                                                                                style: GoogleFonts.orbitron(
                                                                                  color: Colors.white,
                                                                                  fontSize: 12.sp,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  letterSpacing: 0.5,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        backgroundColor:
                                                                            Color(
                                                                              0xFF1A1A2E,
                                                                            ),
                                                                        elevation:
                                                                            10,
                                                                        behavior:
                                                                            SnackBarBehavior.floating,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                            8.r,
                                                                          ),
                                                                          side: BorderSide(
                                                                            color:
                                                                                Colors.red,
                                                                            width:
                                                                                1.5,
                                                                          ),
                                                                        ),
                                                                        duration: Duration(
                                                                          seconds:
                                                                              4,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .open_in_new_rounded,
                                                                  size: 14,
                                                                  color: Colors
                                                                      .blueAccent,
                                                                ),
                                                                label: Text(
                                                                  'Visit Site',
                                                                  style: GoogleFonts.spaceGrotesk(
                                                                    color: Colors
                                                                        .blueAccent,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                style: TextButton.styleFrom(
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            6,
                                                                      ),
                                                                  minimumSize:
                                                                      Size.zero,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        SizedBox(height: 8),

                                                        // Deadline info
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .calendar_today_rounded,
                                                              size: 14,
                                                              color: Colors
                                                                  .blueAccent,
                                                            ),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              "${colleges[index]["dtype"]}: ${colleges[index]["deadline"]}",
                                                              style:
                                                                  GoogleFonts.spaceGrotesk(
                                                                    color: Colors
                                                                        .white70,
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Swipe to view checklist → ',
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white54,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Checklist page
                              Container(
                                padding: EdgeInsets.only(
                                  left: 8.0,
                                ), // Add padding to separate from previous page
                                child: SizedBox(
                                  width:
                                      screenWidth - 16.0, // Account for padding
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Checklist',
                                        style: GoogleFonts.michroma(
                                          color: Colors.white,
                                          fontSize: 28,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10),
                                      GlassContainer.frostedGlass(
                                        color: Colors.white.withOpacity(0.1),
                                        padding: EdgeInsets.all(8),
                                        frostedOpacity: 0.025,
                                        width:
                                            screenWidth -
                                            32.0, // Account for container padding
                                        height: 275,
                                        borderRadius: BorderRadius.circular(30),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: PageView(
                                                controller: checklistController,
                                                children: [
                                                  SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'Freshman',
                                                          style:
                                                              GoogleFonts.michroma(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 25,
                                                              ),
                                                        ),
                                                        CheckBox(
                                                          title:
                                                              'Aim for 3.75 - 4.0 GPA',
                                                        ),
                                                        CheckBox(
                                                          title:
                                                              'Explore interests with any clubs + activities',
                                                        ),
                                                        CheckBox(
                                                          title:
                                                              '0-2 APs and generally high course rigor',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'Sophomore',
                                                          style:
                                                              GoogleFonts.michroma(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 25,
                                                              ),
                                                        ),
                                                        CheckBox(
                                                          title:
                                                              'Maintain high GPA + 1-3 APs + Study for SAT/ACT',
                                                        ),
                                                        CheckBox(
                                                          title:
                                                              'Narrow down activities + try for leadership',
                                                        ),
                                                        CheckBox(
                                                          title:
                                                              'Start at least 1 passion project',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'Junior',
                                                          style:
                                                              GoogleFonts.michroma(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 28,
                                                              ),
                                                        ),
                                                        CheckBox(
                                                          title:
                                                              'Leadership Roles in clubs + high impact in all ECs',
                                                        ),
                                                        CheckBox(
                                                          title:
                                                              'APs (2-5) + focus on good GPA',
                                                        ),
                                                        CheckBox(
                                                          title:
                                                              'Aim for 1480+ on SAT / 33+ on ACT) + College Essay',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            'Senior',
                                                            style:
                                                                GoogleFonts.michroma(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 28,
                                                                ),
                                                          ),
                                                        ),
                                                        CheckBox(
                                                          title:
                                                              'Maintain high GPA + 2-4 more APs',
                                                        ),
                                                        CheckBox(
                                                          title:
                                                              'Relax a little!',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SmoothPageIndicator(
                                              controller: checklistController,
                                              count: 4,
                                              effect: WormEffect(
                                                activeDotColor:
                                                    Colors.blueAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '← Swipe back to college list',
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white54,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 25.h),
                        Container(
                          width: 280,
                          height: 65,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            ),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ActivitiesPage(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_graph_rounded,
                                  color: Colors.blueAccent,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Calculate Chances',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 25.h),

                        Container(
                          padding: EdgeInsets.only(
                            right: 8.0,
                          ), // Add padding to separate from next page
                          child: SizedBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.h,
                                    horizontal: 20.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1E293B).withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blueAccent.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Saved Scholarships',
                                    style: GoogleFonts.michroma(
                                      color: Colors.white,
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.1.w,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: Colors.white.withOpacity(0.05),
                                  ),

                                  height: 255.h,
                                  width: screenWidth - 32.0,
                                  child: scholarships.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No scholarships added yet',
                                            style: GoogleFonts.spaceGrotesk(
                                              color: Colors.white54,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: scholarships.length,
                                          itemBuilder: (context, index) {
                                            final scholarship =
                                                scholarships[index];

                                            return Container(
                                              margin: EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF1E293B,
                                                ).withOpacity(0.8),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.blueAccent
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Scholarship name
                                                  Text(
                                                    scholarship["scholarshipName"] ??
                                                        "Unnamed Scholarship",
                                                    style:
                                                        GoogleFonts.spaceGrotesk(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),

                                                  SizedBox(height: 10),

                                                  // Description
                                                  Text(
                                                    scholarship["description"] ??
                                                        "No description available.",
                                                    style:
                                                        GoogleFonts.spaceGrotesk(
                                                          color: Colors.white70,
                                                          fontSize: 13,
                                                          height: 1.4,
                                                        ),
                                                  ),

                                                  SizedBox(height: 12),

                                                  // Deadline
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .calendar_today_rounded,
                                                        size: 14,
                                                        color:
                                                            Colors.blueAccent,
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      Container(
                                                        width: 170.w,
                                                        child: Text(
                                                          scholarship["deadline"] ??
                                                              "No deadline listed",
                                                          style:
                                                              GoogleFonts.spaceGrotesk(
                                                                color: Colors
                                                                    .white70,
                                                                fontSize: 13,
                                                              ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              Colors.blueAccent
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                              Colors
                                                                  .lightBlueAccent
                                                                  .withOpacity(
                                                                    0.2,
                                                                  ),
                                                            ],
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8.r,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors
                                                                .blueAccent
                                                                .withOpacity(
                                                                  0.4,
                                                                ),
                                                          ),
                                                        ),
                                                        child: TextButton.icon(
                                                          onPressed: () async {
                                                            final url =
                                                                scholarship["link"];
                                                            if (url == null ||
                                                                url.isEmpty) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'No link available',
                                                                  ),
                                                                ),
                                                              );
                                                              return;
                                                            }
                                                            if (!await launchUrl(
                                                              Uri.parse(url),
                                                              mode: LaunchMode
                                                                  .externalApplication,
                                                            )) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Failed to open URL',
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .open_in_new_rounded,
                                                            size: 14.sp,
                                                            color: Colors
                                                                .blueAccent,
                                                          ),
                                                          label: Text(
                                                            'Visit Site',
                                                            style:
                                                                GoogleFonts.spaceGrotesk(
                                                                  color: Colors
                                                                      .blueAccent,
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                          style: TextButton.styleFrom(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12.w,
                                                                  vertical: 6.h,
                                                                ),
                                                            minimumSize:
                                                                Size.zero,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  // SizedBox(height: 12),

                                                  // Visit Link button
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                SizedBox(height: 10),

                                // Header with consistent styling
                                Container(
                                  width: screenWidth,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1E293B).withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blueAccent.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'External Resources',
                                    style: GoogleFonts.michroma(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                SizedBox(height: 15),

                                // Resources container matching your college list style
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  height: 360.h,
                                  width: screenWidth,
                                  child: Column(
                                    children: [
                                      _buildResourceItem(
                                        icon: Icons.school,
                                        title: 'CollegeBoard Website',
                                        subtitle:
                                            'AP Course Help • SAT Study/Registering',
                                        url: collegeBoard,
                                      ),
                                      SizedBox(height: 12),
                                      _buildResourceItem(
                                        icon: Icons.edit_document,
                                        title: 'Essay Editor',
                                        subtitle:
                                            'Professional college essay editing',
                                        url: essayEditor,
                                      ),
                                      SizedBox(height: 12),
                                      _buildResourceItem(
                                        icon: Icons.list_alt,
                                        title: 'Extracurricular Activities',
                                        subtitle:
                                            '160+ ideas and how to choose wisely',
                                        url: ecList,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildResourceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Uri url,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 1),
      ),
      child: ListTile(
        onTap: () async {
          if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
            throw Exception('Could not launch $url');
          }
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent.withOpacity(0.1),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          ),
          child: Icon(icon, color: Colors.blueAccent, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 12),
        ),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent.withOpacity(0.1),
          ),
          child: Icon(
            Icons.arrow_outward_rounded,
            color: Colors.blueAccent,
            size: 16,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case "R":
        return Color(0xFFEF4444); // Red for Reach
      case "T":
        return Color(0xFFF59E0B); // Amber for Target
      case "S":
        return Color(0xFF10B981); // Green for Safety
      default:
        return Color(0xFF6B7280); // Gray for unknown
    }
  }

  String _getLevelText(String level) {
    switch (level) {
      case "R":
        return 'REACH';
      case "T":
        return 'TARGET';
      case "S":
        return 'SAFETY';
      default:
        return 'UNKNOWN';
    }
  }

  Widget _buildLevelRow({
    required Color color,
    required String label,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color indicator
        Container(
          width: 16,
          height: 16,
          margin: EdgeInsets.only(top: 2, right: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// checkbox widget
class CheckBox extends StatefulWidget {
  final String title;

  const CheckBox({super.key, required this.title});

  @override
  State<CheckBox> createState() => Checkbox();
}

class Checkbox extends State<CheckBox> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      fillColor: WidgetStatePropertyAll(Colors.blueAccent),
      side: BorderSide(color: Color.fromARGB(255, 4, 31, 78)),
      checkboxScaleFactor: 1.5,
      title: Text(
        widget.title,
        style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 17.sp),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      value: checked,
      onChanged: (bool? value) {
        setState(() {
          checked = value!;
        });
      },
    );

    // with SingleChildScrollView

    // return Scaffold(
    //   body: SingleChildScrollView(
    //     child: Column(
    //       children: [
    //         Container(width: double.infinity, height: 2000, color: Colors.red),
    //       ],
    //     ),
    //   ),
    // );
  }
}

class _LevelConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color glowColor;
  final Color textColor;

  _LevelConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.glowColor,
    required this.textColor,
  });
}

_LevelConfig _getLevelConfig(String level) {
  // Use the same blue gradient for all levels
  return _LevelConfig(
    backgroundColor: Color(0xFF1F5F8B), // Use the darker blue as base
    borderColor: Color(0xFF00C2FF),
    glowColor: Color(0xFF00C2FF),
    textColor: Colors.white,
  );
}

double _getProgressFactor(String level) {
  switch (level) {
    case "S":
      return 0.9; // Safety - high progress
    case "T":
      return 0.6; // Target - medium progress
    case "R":
      return 0.3; // Reach - low progress
    default:
      return 0.5;
  }
}
