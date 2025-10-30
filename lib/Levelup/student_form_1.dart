import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_club/Levelup/home_project.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController schoolController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  bool isLoading = true;
  int nameLimit = 12;
  // final interestController = TextEditingController();
  // final awardsController = TextEditingController();

  run_func() async {
    String nameText = "";
    String schoolText = "";
    String gradeText = "";
    final user_data = await FirebaseFirestore.instance
        .collection("profile")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    final data = user_data.data();
    if (data != null && user_data != null) {
      nameText = data["name"];
      schoolText = data["school"];
      gradeText = data["grade"];
    }
    nameController = TextEditingController(text: nameText);
    schoolController = TextEditingController(text: schoolText);
    gradeController = TextEditingController(text: gradeText);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    run_func();
  }

  @override
  void dispose() {
    nameController.dispose();
    schoolController.dispose();
    gradeController.dispose();
    // interestController.dispose();
    // awardsController.dispose();
    super.dispose();
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
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color.fromRGBO(118, 251, 166, 1),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: SingleChildScrollView(
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 140.h),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_add_alt_1_rounded,
                                  color: Colors.white,
                                  size: 40.sp,
                                ),
                                SizedBox(height: 25.h),
                                Text(
                                  "Just one more step! Tell us a bit about yourself",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 30.h),

                                // Name Field with Label
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 8.w,
                                        bottom: 8.h,
                                      ),
                                      child: Text(
                                        "Name",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    _buildInputField(
                                      'Name',
                                      nameController,
                                      maxLimit: nameLimit,
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20.h),

                                // School Field with Label
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 8.w,
                                        bottom: 8.h,
                                      ),
                                      child: Text(
                                        "School",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    _buildInputField(
                                      'School',
                                      schoolController,
                                      maxLimit: 34,
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20.h),

                                // Grade Field with Label
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 8.w,
                                        bottom: 8.h,
                                      ),
                                      child: Text(
                                        "Grade",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    _buildInputField('Grade', gradeController),
                                  ],
                                ),

                                SizedBox(height: 30.h),

                                // Continue Button
                                Center(
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
                                      await FirebaseFirestore.instance
                                          .collection("profile")
                                          .doc(
                                            FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .email,
                                          )
                                          .set({
                                            "name": nameController.text.trim(),
                                            "school": schoolController.text
                                                .trim(),
                                            "grade": gradeController.text
                                                .trim(),
                                          }, SetOptions(merge: true));
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomePage2(),
                                        ),
                                      );
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
                                SizedBox(height: 40.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String hint,
    TextEditingController controller, {
    int? maxLimit,
  }) {
    bool isGradeField = hint.toLowerCase() == "grade";

    return TextField(
      controller: controller,

      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp),
      cursorColor: Colors.white,
      keyboardType: isGradeField ? TextInputType.number : TextInputType.text,
      inputFormatters: [
        if (isGradeField) ...[
          FilteringTextInputFormatter.digitsOnly,
          GradeInputFormatter(min: 5, max: 12),
        ],
        if (maxLimit != null) LengthLimitingTextInputFormatter(maxLimit),
      ],
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        hintText: "Enter $hint",
        hintStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14.sp),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        fillColor: Colors.white10,
        filled: true,
      ),
    );
  }
}

class GradeInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  GradeInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue; // allow deleting

    // Reject non-numeric input
    final int? value = int.tryParse(newValue.text);
    if (value == null) return oldValue;

    // Allow partially typed numbers (like "1" for 12)
    if (value > max) return oldValue;

    return newValue;
  }
}
