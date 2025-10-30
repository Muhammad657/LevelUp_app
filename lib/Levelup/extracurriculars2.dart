import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_club/widgettree.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ExtracurricularsPage2 extends StatefulWidget {
  const ExtracurricularsPage2({super.key});

  @override
  State<ExtracurricularsPage2> createState() => ExtracurricularsPage2State();
}

class ExtracurricularsPage2State extends State<ExtracurricularsPage2> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, String>> _ecs = [];
  bool isLoading = true;

  run_func() async {
    final profile_data = await FirebaseFirestore.instance
        .collection("profile")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    final profile_data2 = profile_data.data();
    if (profile_data2 != null && profile_data2["extracurriculars"] != null) {
      setState(() {
        _ecs = List<Map<String, String>>.from(
          profile_data2["extracurriculars"].map(
            (ec) => Map<String, String>.from(ec),
          ),
        );
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = false;
    });
  }

  void _addEC() {
    if (_nameController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty) {
      // Truncate description if over 100 characters
      String description = _descriptionController.text.trim();
      if (description.length > 100) {
        description = description.substring(0, 100);
      }

      setState(() {
        _ecs.add({
          "name": _nameController.text.trim(),
          "description": description,
        });
        _nameController.clear();
        _descriptionController.clear();
      });
    }
  }

  void _removeEC(int index) {
    setState(() {
      _ecs.removeAt(index);
    });
  }

  @override
  void initState() {
    run_func();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
              colors: [Color(0xFF003153), Color(0xFF003153)],
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
                        SizedBox(height: 2.h),
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(height: 30.h),
                              SizedBox(height: 30.h),
                              Text(
                                "Extracurricular Activities",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                "Add your extracurricular activities with descriptions",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Input fields for new EC
                              Column(
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Activity Name",
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.white54,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white54,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15.w,
                                        vertical: 14.h,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  TextField(
                                    controller: _descriptionController,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Description",
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.white54,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white54,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15.w,
                                        vertical: 14.h,
                                      ),
                                      suffixText:
                                          '${_descriptionController.text.length}/100',
                                      suffixStyle: GoogleFonts.poppins(
                                        color:
                                            _descriptionController.text.length >
                                                100
                                            ? Colors.red
                                            : Colors.white54,
                                      ),
                                    ),
                                    maxLines: 2,
                                    maxLength: 100,
                                    onChanged: (value) {
                                      setState(
                                        () {},
                                      ); // Update the character counter
                                    },
                                  ),
                                  SizedBox(height: 10.h),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _nameController.text
                                                  .trim()
                                                  .isNotEmpty &&
                                              _descriptionController.text
                                                  .trim()
                                                  .isNotEmpty
                                          ? Colors.white
                                          : Colors.grey,
                                      foregroundColor: Color(0xFF003153),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 14.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed:
                                        _nameController.text
                                                .trim()
                                                .isNotEmpty &&
                                            _descriptionController.text
                                                .trim()
                                                .isNotEmpty
                                        ? _addEC
                                        : null,
                                    child: Text("Add Activity"),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // Display added ECs with delete option
                              if (_ecs.isNotEmpty) ...[
                                Text(
                                  "Your Activities:",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _ecs.length,
                                  itemBuilder: (context, index) {
                                    final ec = _ecs[index];
                                    return Card(
                                      color: Colors.blueGrey.withOpacity(0.2),
                                      margin: EdgeInsets.symmetric(
                                        vertical: 5.h,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          ec["name"]!,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: ec["description"]!.isNotEmpty
                                            ? Text(
                                                ec["description"]!,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white70,
                                                ),
                                              )
                                            : null,
                                        trailing: IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _removeEC(index),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],

                              // Save button
                              if (_ecs.isNotEmpty) ...[
                                SizedBox(height: 20.h),
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
                                          .update({"extracurriculars": _ecs});
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Save & Continue",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 40.h),
                              ],

                              // Continue button - Add this where you want the button to appear
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
    );
  }
}
