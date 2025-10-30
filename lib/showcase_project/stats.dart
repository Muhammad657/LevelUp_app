import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  TextEditingController satR = TextEditingController();
  TextEditingController satM = TextEditingController();
  TextEditingController actR = TextEditingController();
  TextEditingController actM = TextEditingController();
  TextEditingController actS = TextEditingController();
  TextEditingController actE = TextEditingController();
  TextEditingController gpaW = TextEditingController();
  TextEditingController gpaUW = TextEditingController();
  bool isLoading = true;
  run_func() async {
    final profile_data = await FirebaseFirestore.instance
        .collection("profile")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    final profile_data2 = profile_data.data();
    if (profile_data2 != null) {
      setState(() {
        satR = TextEditingController(
          text: profile_data2["satR"]?.toString() ?? '',
        );
        satM = TextEditingController(
          text: profile_data2["satM"]?.toString() ?? '',
        );
        actR = TextEditingController(
          text: profile_data2["actR"]?.toString() ?? '',
        );
        actM = TextEditingController(
          text: profile_data2["actM"]?.toString() ?? '',
        );
        actS = TextEditingController(
          text: profile_data2["actS"]?.toString() ?? '',
        );
        actE = TextEditingController(
          text: profile_data2["actE"]?.toString() ?? '',
        );
        gpaW = TextEditingController(
          text: profile_data2["gpaW"]?.toString() ?? '',
        );
        gpaUW = TextEditingController(
          text: profile_data2["gpaUW"]?.toString() ?? '',
        );
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    run_func();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
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
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsetsGeometry.only(left: 10.w),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_rounded),
                              color: Colors.white,
                              iconSize: 30.sp,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        Text(
                          'Academic Stats',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(12.0.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      25,
                                      15,
                                      25,
                                      20,
                                    ),
                                    child: Column(
                                      spacing: 15.w,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'SAT Scores',
                                          style: GoogleFonts.spaceGrotesk(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 21.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'SAT ERW:',
                                              style: GoogleFonts.spaceGrotesk(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            SizedBox(
                                              height: 45.h,
                                              width: 60.w,
                                              child: TextFormField(
                                                controller: satR,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly, // Allows only digits (0-9)
                                                ],
                                                showCursor: true,
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12.sp,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        vertical: 0.h,
                                                        horizontal: 6.w,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.blue
                                                      .withOpacity(0.05),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              'SAT Math:',
                                              style: GoogleFonts.spaceGrotesk(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            SizedBox(
                                              height: 45.h,
                                              width: 60.w,
                                              child: TextFormField(
                                                controller: satM,
                                                showCursor: true,

                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12.sp,
                                                ),
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly, // Allows only digits (0-9)
                                                ],
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 6.w,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.blue
                                                      .withOpacity(0.05),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                Container(
                                  width: double.infinity, // height: 230.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(40.r),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      25,
                                      15,
                                      25,
                                      20,
                                    ),
                                    child: Column(
                                      spacing: 15.w,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'ACT Scores',
                                          style: GoogleFonts.spaceGrotesk(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 21.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'ACT Reading:',
                                              style: GoogleFonts.spaceGrotesk(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            SizedBox(
                                              height: 45.h,
                                              width: 40.w,
                                              child: TextFormField(
                                                controller: actR,
                                                showCursor: true,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly, // Allows only digits (0-9)
                                                ],
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12.sp,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 6.w,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.blue
                                                      .withOpacity(0.05),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              'ACT Math:',
                                              style: GoogleFonts.spaceGrotesk(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            SizedBox(
                                              height: 45.h,
                                              width: 40.w,
                                              child: TextFormField(
                                                controller: actM,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly, // Allows only digits (0-9)
                                                ],
                                                showCursor: true,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.blue,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 6.w,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.blue
                                                      .withOpacity(0.05),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                          ],
                                        ),
                                        SizedBox(height: 2.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'ACT Science:',
                                              style: GoogleFonts.spaceGrotesk(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            SizedBox(
                                              height: 45.h,
                                              width: 40.w,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly, // Allows only digits (0-9)
                                                ],
                                                controller: actS,
                                                showCursor: true,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.blue,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 6.w,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.blue
                                                      .withOpacity(0.05),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              'ACT English:',
                                              style: GoogleFonts.spaceGrotesk(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            SizedBox(
                                              height: 45.h,
                                              width: 40.w,
                                              child: TextFormField(
                                                controller: actE,
                                                showCursor: true,
                                                keyboardType:
                                                    TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly, // Allows only digits (0-9)
                                                ],
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12.sp,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 6.w,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.blue
                                                      .withOpacity(0.05),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(40.r),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      25,
                                      15,
                                      25,
                                      20,
                                    ),
                                    child: Column(
                                      spacing: 15.w,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'GPA',
                                          style: GoogleFonts.spaceGrotesk(
                                            textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 21.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'GPA(W):',
                                              style: GoogleFonts.spaceGrotesk(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            SizedBox(
                                              height: 45.h,
                                              width: 60.w,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(
                                                    RegExp(r'^\d*\.?\d*$'),
                                                  ),
                                                ],
                                                controller: gpaW,
                                                showCursor: true,
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12.sp,
                                                ),

                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 6.w,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.blue
                                                      .withOpacity(0.05),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              'GPA(UW):',
                                              style: GoogleFonts.spaceGrotesk(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            SizedBox(
                                              height: 45.h,
                                              width: 60.w,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(
                                                    RegExp(r'^\d*\.?\d*$'),
                                                  ),
                                                ],
                                                controller: gpaUW,
                                                showCursor: true,
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12.sp,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 6.w,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: Colors.blue,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10.r,
                                                            ),
                                                      ),
                                                  filled: true,
                                                  fillColor: Colors.blue
                                                      .withOpacity(0.05),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection("profile")
                                    .doc(
                                      FirebaseAuth.instance.currentUser!.email,
                                    )
                                    .update({
                                      "satR": satR.text.trim(),
                                      "satM": satM.text.trim(),
                                      "actR": actR.text.trim(),
                                      "actM": actM.text.trim(),
                                      "actS": actS.text.trim(),
                                      "actE": actE.text.trim(),
                                      "gpaW": gpaW.text.trim(),
                                      "gpaUW": gpaUW.text.trim(),
                                    });

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF00FF88),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            'Data Saved Successfully',
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
                                      borderRadius: BorderRadius.circular(8.r),
                                      side: BorderSide(
                                        color: Color(0xFF00FF88),
                                        width: 1.5,
                                      ),
                                    ),
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              } catch (e) {
                                // Show error message
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
                                            'Failed to save data',
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
                                      borderRadius: BorderRadius.circular(8.r),
                                      side: BorderSide(
                                        color: Color(0xFFFF006E),
                                        width: 1.5,
                                      ),
                                    ),
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 200.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF0066FF),
                                    Color(0xFF00CCFF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(0, 4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Save",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
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
    );
  }
}
