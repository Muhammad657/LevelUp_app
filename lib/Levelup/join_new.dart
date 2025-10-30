import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as dom;
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class JoinNew extends StatefulWidget {
  const JoinNew({super.key});

  @override
  State<JoinNew> createState() => _JoinNewState();
}

class _JoinNewState extends State<JoinNew> {
  String htmlText = """<div style='color:white; padding:16px;'>
          <h2>Sample Recommendations</h2>
          <p>Here are your personalized EC recommendations...</p>
        </div>""";

  bool isLoading = true;
  void runMainFunc() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final profile_data = await FirebaseFirestore.instance
          .collection("profile")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .get();

      if (!mounted) return; // Check after first Firestore call

      final profile_data2 = profile_data.data();
      final data = await FirebaseFirestore.instance
          .collection("recommendations")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (!mounted) return; // Check after second Firestore call

      final data_text = data.data();
      if (data_text == null ||
          data_text["text"] == null && profile_data2 != null) {
        final url = Uri.parse("https://97adb8cd84c8.ngrok-free.app");
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_response":
                "I am currently a ${profile_data2?["grade"]} in school. My current awards  include: ${profile_data2?["awards"]} and my extracurriculars include: ${profile_data2?["extracurriculars"]}I am interested in pursuing college majors in: ${profile_data2?["interests"]}  I am looking for extracurricular opportunities that will help me develop skills in these majors.",
          }),
        );

        if (!mounted) return; // Check after HTTP request

        print("Response: ${response.body}");
        print("Status Code: ${response.statusCode}");
        final data = jsonDecode(response.body);

        await FirebaseFirestore.instance
            .collection("recommendations")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({"text": data["reply"]});

        if (!mounted) return; // Check after Firestore update
      }

      final data2 = await FirebaseFirestore.instance
          .collection("recommendations")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (!mounted) return; // Check before final setState

      final date_text2 = data2.data();

      if (mounted) {
        setState(() {
          htmlText = date_text2!["text"];
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFFF006E)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Failed to load ECs',
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
              side: BorderSide(color: Color(0xFFFF006E), width: 1.5),
            ),
            duration: Duration(seconds: 4),
          ),
        );

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    runMainFunc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: isLoading
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 60.sp,
                          color: Color.fromRGBO(118, 251, 166, 1),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Please wait while we recommend some ECs",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.michroma(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        SizedBox(
                          width: 50.w,
                          height: 50.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 4.w,

                            valueColor: AlwaysStoppedAnimation(
                              Color.fromRGBO(88, 75, 245, 1),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          "Fetching the best matches for you...",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildContentUI(),
          ),
        ),
      ),
    );
  }

  Widget _buildContentUI() {
    return Column(
      children: [
        // Flutter Widget Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Extracurricular Match",
                  style: GoogleFonts.michroma(
                    color: Color.fromRGBO(88, 75, 245, 1),
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("recommendations")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .delete();
                runMainFunc();
              },
              icon: Icon(CupertinoIcons.arrow_counterclockwise, size: 20.sp),
              color: Colors.white,
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // HTML Content for recommendations
        Expanded(
          child: SingleChildScrollView(
            child: Html(
              data: htmlText,
              onLinkTap: (link, attributes, element) async {
                if (link == null) return;

                final Uri uri = Uri.parse(link);
                final launched = await launchUrl(
                  uri,
                  mode: LaunchMode.inAppWebView, // opens Safari
                );

                if (!launched) {
                  debugPrint("Could not launch $uri");
                }
              },

              style: {
                "h2": Style(
                  fontSize: FontSize(16.sp),
                  color: const Color(0xFF764FF5),
                  margin: Margins.symmetric(vertical: 6.h),
                ),
                "p": Style(
                  fontSize: FontSize(10.sp),
                  margin: Margins.symmetric(vertical: 20.h),
                  color: Colors.white,
                ),
                "span": Style(
                  fontSize: FontSize(12.sp),
                  padding: HtmlPaddings.symmetric(
                    horizontal: 4.h,
                    vertical: 4.h,
                  ),
                  // backgroundColor: const Color(
                  //   0x3376FBA6,
                  // ), // rgba(118,251,166,0.2)
                  color: const Color(0xFF76FBA6),
                  // borderRadius: BorderRadius.circular(12.r),
                  margin: Margins.only(right: 4.h, bottom: 4.h),
                ),
                "a": Style(
                  color: const Color(0xFF1E90FF),
                  textDecoration: TextDecoration.underline,
                  textDecorationColor: const Color(0xFF1E90FF),
                ),
              },
            ),
          ),
        ),

        // Flutter Widget Footer
        Padding(
          padding: EdgeInsets.only(top: 16.h),
          child: Column(
            children: [
              // Text(
              //   "Powered by GradMate AI",
              //   style: TextStyle(color: Colors.white54, fontSize: 11.sp),
              // ),
              // SizedBox(height: 4.h),
              Text(
                "Recommendations may not be 100% accurate. Use your own judgment!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // SizedBox(height: 5.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Color.fromRGBO(88, 75, 245, 0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
