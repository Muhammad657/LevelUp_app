import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  List<Map<String, String?>> courses = [
    {"name": null, "level": null, "grade": null},
  ];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoursesFromFirebase();
  }

  // Function to load courses from Firebase
  Future<void> _loadCoursesFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("profile")
            .doc(user.email)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['courses'] != null && data['courses'] is List) {
            setState(() {
              courses = List<Map<String, String?>>.from(
                data['courses'].map(
                  (course) => Map<String, String?>.from(course),
                ),
              );
              isLoading = false;
            });
            return;
          }
        }
      }

      // If no courses found, keep the default empty course
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error loading courses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to save courses to Firebase
  Future<void> _saveCoursesToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Filter out empty courses (where name is null or empty)
        final nonEmptyCourses = courses
            .where(
              (course) =>
                  course["name"] != null && course["name"]!.trim().isNotEmpty,
            )
            .toList();

        await FirebaseFirestore.instance
            .collection("profile")
            .doc(user.email)
            .update({'courses': nonEmptyCourses});

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF00FF88)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Courses Saved Successfully',
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
              side: BorderSide(color: Color(0xFF00FF88), width: 1.5),
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print("Error saving courses: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF006E)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Failed to save courses. Please try again.',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0C1425),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
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
                  padding: EdgeInsets.all(15.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_rounded),
                          color: Colors.white,
                          iconSize: 30.sp,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Courses',
                        style: GoogleFonts.spaceGrotesk(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 25.h),
                      Expanded(
                        child: ListView.builder(
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 15.0.h),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 130.w,
                                        child: TextFormField(
                                          initialValue: courses[index]["name"],
                                          onChanged: (value) =>
                                              courses[index]["name"] = value,
                                          showCursor: true,
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                          cursorColor: Colors.blue,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 8.h,
                                                  horizontal: 6.w,
                                                ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                                width: 1.5.w,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                                width: 2.w,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            filled: true,
                                            fillColor: Colors.blue.withOpacity(
                                              0.05,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue,
                                              width: 2.w,
                                            ),
                                          ),
                                          child: DropdownButton<String>(
                                            padding: EdgeInsets.only(
                                              left: 22.w,
                                            ),
                                            underline: SizedBox.shrink(),
                                            value: courses[index]["level"],
                                            hint: Text(
                                              "Level",
                                              style: GoogleFonts.manrope(
                                                fontSize: 15.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                            dropdownColor: Color.fromRGBO(
                                              55,
                                              75,
                                              129,
                                              0.98,
                                            ),
                                            style: GoogleFonts.manrope(
                                              fontSize: 13.sp,
                                              color: Colors.white,
                                            ),
                                            items: [
                                              DropdownMenuItem(
                                                value: "Honors",
                                                child: Text("Honors"),
                                              ),
                                              DropdownMenuItem(
                                                value: "AP",
                                                child: Text("AP"),
                                              ),
                                              DropdownMenuItem(
                                                value: "Standard",
                                                child: Text("Standard"),
                                              ),
                                              DropdownMenuItem(
                                                value: "IB",
                                                child: Text("IB"),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                courses[index]["level"] = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue,
                                              width: 2.w,
                                            ),
                                          ),
                                          child: DropdownButton<String>(
                                            padding: EdgeInsets.only(
                                              left: 22.w,
                                            ),
                                            underline: SizedBox.shrink(),
                                            value: courses[index]["grade"],
                                            hint: Text(
                                              "Grade",
                                              style: GoogleFonts.manrope(
                                                fontSize: 15.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                            dropdownColor: Color.fromRGBO(
                                              55,
                                              75,
                                              129,
                                              0.98,
                                            ),
                                            style: GoogleFonts.manrope(
                                              fontSize: 15.sp,
                                              color: Colors.white,
                                            ),
                                            items: [
                                              DropdownMenuItem(
                                                value: "A+",
                                                child: Text("A+"),
                                              ),
                                              DropdownMenuItem(
                                                value: "A",
                                                child: Text("A"),
                                              ),
                                              DropdownMenuItem(
                                                value: "A-",
                                                child: Text("A-"),
                                              ),
                                              DropdownMenuItem(
                                                value: "B+",
                                                child: Text("B+"),
                                              ),
                                              DropdownMenuItem(
                                                value: "B",
                                                child: Text("B"),
                                              ),
                                              DropdownMenuItem(
                                                value: "B-",
                                                child: Text("B-"),
                                              ),
                                              DropdownMenuItem(
                                                value: "C",
                                                child: Text("C"),
                                              ),
                                              DropdownMenuItem(
                                                value: "D",
                                                child: Text("D"),
                                              ),
                                              DropdownMenuItem(
                                                value: "F",
                                                child: Text("F"),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                courses[index]["grade"] = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (index == courses.length - 1)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          courses.add({
                                            "name": null,
                                            "level": null,
                                            "grade": null,
                                          });
                                        });
                                      },
                                      icon: Icon(
                                        size: 55.sp,
                                        Icons.add_box_outlined,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: GestureDetector(
                          onTap:
                              _saveCoursesToFirebase, // Call save function here
                          child: Container(
                            width: 200.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF0066FF), Color(0xFF00CCFF)],
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
    );
  }
}
