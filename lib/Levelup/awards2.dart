import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_club/widgettree.dart';
import 'package:flutter_club/Levelup/extracurriculars.dart';
import 'package:flutter_club/Levelup/home_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AwardsWon2 extends StatefulWidget {
  const AwardsWon2({super.key});

  @override
  State<AwardsWon2> createState() => _AwardsWon2State();
}

class _AwardsWon2State extends State<AwardsWon2> {
  final TextEditingController _awardController = TextEditingController();
  List _awards = [];
  bool isLoading = true;

  run_func() async {
    final profile_data = await FirebaseFirestore.instance
        .collection("profile")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    final profile_data2 = profile_data.data();
    if (profile_data2 != null && profile_data2["awards"] != null) {
      setState(() {
        profile_data2["awards"] == "No awards"
            ? null
            : _awards = profile_data2["awards"];
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = false;
    });
  }

  void _addAward() {
    if (_awardController.text.trim().isNotEmpty) {
      setState(() {
        _awards.add(_awardController.text.trim());
        _awardController.clear();
      });
    }
  }

  void _removeAward(int index) {
    setState(() {
      _awards.removeAt(index);
    });
  }

  @override
  void initState() {
    run_func();
    super.initState();
  }

  @override
  void dispose() {
    _awardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // Color(0xFF1B1B1B),
                Color(0xFF003153),
                Color(0xFF003153),
              ],
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
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              MediaQuery.of(context).padding.bottom,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 30.h),
                              Text(
                                "What awards have you won?",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                "Add each award one by one (if any)",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Input field for new awards
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _awardController,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Enter award name",
                                        hintStyle: GoogleFonts.poppins(
                                          color: Colors.white54,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white54,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15.w,
                                          vertical: 14.h,
                                        ),
                                      ),
                                      onSubmitted: (_) => _addAward(),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Color(0xFF003153),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 14.h,
                                      ),
                                    ),
                                    onPressed: _addAward,
                                    child: Text("Add"),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // Display added awards with delete option
                              if (_awards.isNotEmpty) ...[
                                Text(
                                  "Your Awards:",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: List.generate(_awards.length, (
                                    index,
                                  ) {
                                    return Chip(
                                      label: Text(
                                        _awards[index],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onDeleted: () => _removeAward(index),
                                      backgroundColor: Color(0xFF0066CC),
                                      deleteIconColor: Colors.white,
                                    );
                                  }),
                                ),
                                SizedBox(
                                  height: 20.h,
                                ), // Added spacing instead of Spacer
                              ],

                              // Add flexible space if needed
                              if (_awards.isEmpty) SizedBox(height: 20.h),

                              // Continue button at the bottom
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.only(bottom: 40.h),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Color(0xFF003153),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 40.w,
                                      vertical: 14.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    // Navigate to next screen with awards list
                                    await FirebaseFirestore.instance
                                        .collection("profile")
                                        .doc(
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .email,
                                        )
                                        .update({
                                          "awards": _awards.isEmpty
                                              ? "No awards"
                                              : _awards,
                                        });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Continue",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
