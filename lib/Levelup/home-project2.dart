import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_club/Levelup/awards.dart';
import 'package:flutter_club/Levelup/student_form_1.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class InterestsForm2 extends StatefulWidget {
  const InterestsForm2({super.key});

  @override
  State<InterestsForm2> createState() => InterestsForm2State();
}

class InterestsForm2State extends State<InterestsForm2> {
  Map<String, dynamic> data = {};
  bool isLoading = true;
  List<String> selectedInterests = [];
  // List of all available interests
  run_func() async {
    final profile_data = await FirebaseFirestore.instance
        .collection("profile")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    final data_in = profile_data.data();
    if (data_in != null) {
      print(data_in);
      if (data_in["interests"] != null) {
        setState(() {
          selectedInterests = List.from(data_in["interests"]);
        });
      }
      setState(() {
        data = data_in;
        isLoading = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    run_func();
  }

  final List<String> interests = [
    'Mathematics',
    'Science',
    'Literature',
    'History',
    'Computer Engineering',
    'Art',
    'Music',
    'Sports',
    'Physics',
    'Chemistry',
    'Biology',
    'Economics',
    'Psychology',
    'Foreign Languages',
    'Engineering',
    'Debate',
    'Drama',
    'Journalism',
    'Programming',
    'Robotics',
    'Environmental Science',
    'Political Science',
    'Business',
    'Health & Medicine',
    'Astronomy',
  ];

  // Track selected interests

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color.fromRGBO(118, 251, 166, 1),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),
                      Text(
                        "What are your areas of interest?",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Select up to 3 options",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Selected interests chips
                      if (selectedInterests.isNotEmpty) ...[
                        Wrap(
                          spacing: 8.w,
                          children: selectedInterests.map((interest) {
                            return Chip(
                              label: Text(interest),
                              onDeleted: () {
                                setState(() {
                                  selectedInterests.remove(interest);
                                });
                              },
                              backgroundColor: Color(0xFF0066CC),
                              labelStyle: TextStyle(color: Colors.white),
                              deleteIconColor: Colors.white,
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // Interest selection grid
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15.w,
                                mainAxisSpacing: 15.h,
                                childAspectRatio: 3,
                              ),
                          itemCount: interests.length,
                          itemBuilder: (context, index) {
                            final interest = interests[index];
                            final isSelected = selectedInterests.contains(
                              interest,
                            );

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedInterests.remove(interest);
                                  } else if (selectedInterests.length < 3) {
                                    selectedInterests.add(interest);
                                  } else {
                                    // Show message when trying to select more than 3
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.warning_amber_rounded,
                                              color: Color(0xFFFF006E),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Text(
                                                'You can select upto 3 interests',
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
                                        backgroundColor: Color(0xFF1A1A2E),
                                        elevation: 10,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          side: BorderSide(
                                            color: Color(0xFFFF006E),
                                            width: 1.5,
                                          ),
                                        ),
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFF0066CC)
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    interest,
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 14.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 20.h),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedInterests.isNotEmpty
                                ? Colors.white
                                : Colors.grey,
                            foregroundColor: Color(0xFF003153),
                            padding: EdgeInsets.symmetric(
                              horizontal: 40.w,
                              vertical: 14.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: selectedInterests.isNotEmpty
                              ? () async {
                                  try {
                                    print(selectedInterests);

                                    // Update only the interests field instead of replacing the entire document
                                    await FirebaseFirestore.instance
                                        .collection("profile")
                                        .doc(
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .email,
                                        )
                                        .update({
                                          "interests": selectedInterests,
                                          "lastUpdated":
                                              FieldValue.serverTimestamp(), // Optional: add timestamp
                                        });

                                    print("Interests saved successfully");
                                    Navigator.pop(context);
                                  } catch (e) {
                                    print("Error saving interests: $e");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.warning_amber_rounded,
                                              color: Color(0xFFFF006E),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Text(
                                                'Failed to save interests. Please try again.',
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
                                        backgroundColor: Color(0xFF1A1A2E),
                                        elevation: 10,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          side: BorderSide(
                                            color: Color(0xFFFF006E),
                                            width: 1.5,
                                          ),
                                        ),
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: Text(
                            "Continue",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
