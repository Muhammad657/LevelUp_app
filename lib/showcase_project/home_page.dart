import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_club/notifiers.dart';
import 'package:flutter_club/showcase_project/bloc/login_bloc.dart';
import 'package:flutter_club/showcase_project/example2.dart';
import 'package:flutter_club/showcase_project/profile.dart';
import 'package:flutter_club/showcase_project/stats.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:restart_app/restart_app.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  bool _isProfileComplete = false;
  bool _isCheckingProfile = true;

  DateTime _selectedDateTime = DateTime.now();
  run_func() async {
    final profile_data = await FirebaseFirestore.instance
        .collection("profile")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    final profile_data2 = profile_data.data();

    if (profile_data2 != null) {
      data = profile_data2;
      setState(() {
        isLoading = false;
      });
    }
  }

  Map data = {};
  List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    DateTime current = DateTime(
      start.year,
      start.month,
      start.day,
      start.hour,
      start.minute,
      start.second,
    );
    DateTime last = DateTime(
      end.year,
      end.month,
      end.day,
      end.hour,
      end.minute,
      end.second,
    );

    while (current.isBefore(last) || current.isAtSameMomentAs(last)) {
      days.add(current);
      current = current.add(Duration(days: 1));
    }

    return days;
  }

  Future<void> _showResponsiveDialog({
    required BuildContext context,
    required Widget Function(BuildContext, StateSetter) builder,
    String title = '',
  }) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Dialog(
            backgroundColor: Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 24.h),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          // SizedBox(height: 10.h),

                          // Content
                          Expanded(
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return builder(context, setState);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> showEditActivityDialog(
    BuildContext context,
    Map<String, dynamic> activity,
  ) async {
    // Pre-fill form state variables from the activity map
    String _activityType = activity['type'] ?? 'event';
    String _name = activity['name'] ?? '';

    // Handle both old format (date) and new format (startDate)
    DateTime _startDateTime = activity['startDate'] != null
        ? (activity['startDate'] as Timestamp).toDate()
        : (activity['date'] as Timestamp).toDate();

    DateTime _endDateTime = activity['endDate'] != null
        ? (activity['endDate'] as Timestamp).toDate()
        : _startDateTime.add(Duration(hours: 1));

    String _description = activity['description'] ?? '';
    String _priority = activity['priority'] ?? 'medium';
    String _status = activity['status'] ?? 'pending';

    // Create controllers for text fields
    final _nameController = TextEditingController(text: _name);
    final _descriptionController = TextEditingController(text: _description);

    // Store the original document ID for reference
    final String _originalDocId = activity['description'] ?? _description;

    await _showResponsiveDialog(
      context: context,
      title: 'Edit Activity',
      builder: (context, setState) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Dialog(
            backgroundColor: Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity Type Selector (disabled for editing)
                  Text(
                    'Type',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activityType = "event";
                              });
                            },
                            child: ChoiceChip(
                              label: Text(
                                'Event',
                                style: TextStyle(fontSize: 14.sp),
                              ),

                              selected: _activityType == 'event',
                              onSelected: (value) {
                                setState(() {
                                  _activityType = 'event';
                                });
                              },
                              selectedColor: Colors.blueAccent,
                              backgroundColor: Colors.transparent,
                              labelStyle: TextStyle(
                                color: _activityType == 'event'
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activityType = "event";
                              });
                            },
                            child: ChoiceChip(
                              label: Text(
                                'Assignment',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              selected: _activityType == 'assignment',
                              onSelected: (value) {
                                setState(() {
                                  _activityType = 'assignment';
                                });
                              },
                              selectedColor: Colors.blueAccent,
                              backgroundColor: Colors.transparent,
                              labelStyle: TextStyle(
                                color: _activityType == 'assignment'
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Name Field (pre-filled)
                  Text(
                    'Title',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                      maxLines: 1,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        border: InputBorder.none,
                        hintText: 'Enter activity title',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      onChanged: (value) => _name = value,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Start Date and Time (pre-filled)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _activityType == "event" ? 'Begins' : "Due",
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _startDateTime,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: Colors.blueAccent,
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF1E1E1E),
                                    onSurface: Colors.white,
                                  ),
                                  dialogBackgroundColor: Color(0xFF1E1E1E),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (pickedDate != null) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                _startDateTime,
                              ),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: Colors.blueAccent,
                                      onPrimary: Colors.white,
                                      surface: Color(0xFF1E1E1E),
                                      onSurface: Colors.white,
                                    ),
                                    dialogBackgroundColor: Color(0xFF1E1E1E),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedTime != null) {
                              setState(() {
                                _startDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                if (_endDateTime.isBefore(_startDateTime)) {
                                  _endDateTime = _startDateTime.add(
                                    Duration(hours: 1),
                                  );
                                }
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 0.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20.sp,
                                color: Colors.white70,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy - hh:mm a',
                                ).format(_startDateTime),
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  // End Date and Time (for events only, pre-filled)
                  if (_activityType == "event")
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ends",
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _endDateTime,
                              firstDate: _startDateTime,
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: Colors.blueAccent,
                                      onPrimary: Colors.white,
                                      surface: Color(0xFF1E1E1E),
                                      onSurface: Colors.white,
                                    ),
                                    dialogBackgroundColor: Color(0xFF1E1E1E),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate != null) {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                  _endDateTime,
                                ),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: Colors.blueAccent,
                                        onPrimary: Colors.white,
                                        surface: Color(0xFF1E1E1E),
                                        onSurface: Colors.white,
                                      ),
                                      dialogBackgroundColor: Color(0xFF1E1E1E),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedTime != null) {
                                final newEndDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );

                                if (newEndDateTime.isAfter(_startDateTime)) {
                                  setState(() {
                                    _endDateTime = newEndDateTime;
                                  });
                                } else {
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
                                              'End Date must be after Start Date',
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
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20.sp,
                                  color: Colors.white70,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy - hh:mm a',
                                  ).format(_endDateTime),
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 20.h),

                  // Description Field (pre-filled)
                  Text(
                    'Description',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                      maxLines: 3,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        border: InputBorder.none,
                        hintText: 'Enter activity description',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      onChanged: (value) => _description = value,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Priority Selector (pre-filled)
                  Text(
                    'Priority',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.0),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(
                              'High',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            selected: _priority == 'high',
                            onSelected: (selected) =>
                                setState(() => _priority = 'high'),
                            selectedColor: Colors.redAccent,
                            backgroundColor: Colors.transparent,
                            labelStyle: TextStyle(
                              color: _priority == 'high'
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(
                              'Medium',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            selected: _priority == 'medium',
                            onSelected: (selected) =>
                                setState(() => _priority = 'medium'),
                            selectedColor: Colors.orangeAccent,
                            backgroundColor: Colors.transparent,
                            labelStyle: TextStyle(
                              color: _priority == 'medium'
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(
                              'Low',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            selected: _priority == 'low',
                            onSelected: (selected) =>
                                setState(() => _priority = 'low'),
                            selectedColor: Color.fromARGB(255, 54, 138, 97),
                            backgroundColor: Colors.transparent,
                            labelStyle: TextStyle(
                              color: _priority == 'low'
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            backgroundColor: Colors.grey.withOpacity(0.2),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.3),
                                blurRadius: 10.r,
                                offset: Offset(0, 5.h),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () async {
                              if (_name.isEmpty || _description.isEmpty) {
                                Navigator.pop(context);
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
                                            'Please complete all the fields',
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
                                return;
                              }

                              final user = FirebaseAuth.instance.currentUser!;
                              final activitiesRef = FirebaseFirestore.instance
                                  .collection("activities")
                                  .doc(user.uid);

                              // First delete the old document from all dates
                              if (activity['type'] == "event") {
                                // For events, we need to delete from all dates in the original range
                                DateTime originalStartDate =
                                    activity['startDate'] != null
                                    ? (activity['startDate'] as Timestamp)
                                          .toDate()
                                    : (activity['date'] as Timestamp).toDate();

                                DateTime originalEndDate =
                                    activity['endDate'] != null
                                    ? (activity['endDate'] as Timestamp)
                                          .toDate()
                                    : originalStartDate.add(Duration(hours: 1));

                                List<DateTime> originalDates = getDatesInRange(
                                  originalStartDate,
                                  originalEndDate,
                                );

                                for (DateTime date in originalDates) {
                                  await activitiesRef
                                      .collection(
                                        "${date.month}-${date.day}-${date.year}",
                                      )
                                      .doc(_originalDocId)
                                      .delete();
                                }
                              } else {
                                // For assignments, just delete from the original date
                                DateTime originalDate =
                                    (activity['date'] as Timestamp).toDate();
                                await activitiesRef
                                    .collection(
                                      "${originalDate.month}-${originalDate.day}-${originalDate.year}",
                                    )
                                    .doc(_originalDocId)
                                    .delete();
                              }

                              // Now create the updated activity
                              if (_activityType == "event") {
                                final datesInRange = getDatesInRange(
                                  _startDateTime,
                                  _endDateTime,
                                );

                                for (DateTime date in datesInRange) {
                                  final updatedActivity = {
                                    "type": _activityType,
                                    "name": _name,
                                    "description": _description,
                                    "priority": _priority,
                                    "status": _status, // Keep original status
                                    "timestamp": FieldValue.serverTimestamp(),
                                    "date": date,
                                    "startDate": _startDateTime,
                                    "endDate": _endDateTime,
                                    "isMultiDay": datesInRange.length > 1,
                                  };

                                  await activitiesRef
                                      .collection(
                                        "${date.month}-${date.day}-${date.year}",
                                      )
                                      .doc(
                                        _description,
                                      ) // Use description as ID
                                      .set(updatedActivity);
                                }
                              } else {
                                final updatedActivity = {
                                  "type": _activityType,
                                  "name": _name,
                                  "date": _startDateTime,
                                  "description": _description,
                                  "priority": _priority,
                                  "status": _status, // Keep original status
                                  "timestamp": FieldValue.serverTimestamp(),
                                };

                                await activitiesRef
                                    .collection(
                                      "${_startDateTime.month}-${_startDateTime.day}-${_startDateTime.year}",
                                    )
                                    .doc(_description) // Use description as ID
                                    .set(updatedActivity);
                              }

                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            child: Text(
                              'Update',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showCreateActivityDialog(BuildContext context) {
    // Form state variables
    String _activityType = 'event';
    String _name = '';
    DateTime _startDateTime = DateTime.now();
    DateTime _endDateTime = DateTime.now().add(
      Duration(hours: 1),
    ); // Default 1 hour event
    String _description = '';
    String _priority = 'medium';

    _showResponsiveDialog(
      context: context,
      title: 'Create New Activity',
      builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activity Type Selector
              Text(
                'Type',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.0),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text('Event', style: TextStyle(fontSize: 14.sp)),
                        selected: _activityType == 'event',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _activityType = 'event';
                            });
                          }
                        },
                        selectedColor: Colors.blueAccent,
                        backgroundColor: Colors.transparent,
                        labelStyle: TextStyle(
                          color: _activityType == 'event'
                              ? Colors.white
                              : Colors.white70,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ChoiceChip(
                        label: Text(
                          'Assignment',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        selected: _activityType == 'assignment',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _activityType = 'assignment';
                            });
                          }
                        },
                        selectedColor: Colors.blueAccent,
                        backgroundColor: Colors.transparent,
                        labelStyle: TextStyle(
                          color: _activityType == 'assignment'
                              ? Colors.white
                              : Colors.white70,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Name Field
              Text(
                'Title',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                  maxLines: 1,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    border: InputBorder.none,
                    hintText: 'Enter activity title',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  onChanged: (value) => setState(() => _name = value),
                ),
              ),
              SizedBox(height: 20.h),

              // Date and Time Selection - START DATE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _activityType == "event" ? 'Begins' : "Due",
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(
                        context,
                      ).unfocus(); // Unfocus before showing date picker
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _startDateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: Colors.blueAccent,
                                onPrimary: Colors.white,
                                surface: Color(0xFF1E1E1E),
                                onSurface: Colors.white,
                              ),
                              dialogBackgroundColor: Color(0xFF1E1E1E),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_startDateTime),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: Colors.blueAccent,
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF1E1E1E),
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor: Color(0xFF1E1E1E),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedTime != null) {
                          setState(() {
                            _startDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            // Ensure end date is after start date
                            if (_endDateTime.isBefore(_startDateTime)) {
                              _endDateTime = _startDateTime.add(
                                Duration(hours: 1),
                              );
                            }
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20.sp,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy - hh:mm a',
                            ).format(_startDateTime),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),

              if (_activityType == "event")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ends",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () async {
                        FocusScope.of(
                          context,
                        ).unfocus(); // Unfocus before showing date picker
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _endDateTime,
                          firstDate: _startDateTime, // Can't end before start!
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: Colors.blueAccent,
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF1E1E1E),
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor: Color(0xFF1E1E1E),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_endDateTime),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: Colors.blueAccent,
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF1E1E1E),
                                    onSurface: Colors.white,
                                  ),
                                  dialogBackgroundColor: Color(0xFF1E1E1E),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (pickedTime != null) {
                            final newEndDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );

                            if (newEndDateTime.isAfter(_startDateTime)) {
                              setState(() {
                                _endDateTime = newEndDateTime;
                              });
                            } else {
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
                                          'End Date must be after Start Date',
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
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20.sp,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy - hh:mm a',
                              ).format(_endDateTime),
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 20.h),

              // Description Field
              Text(
                'Description',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                  maxLines: 3,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    border: InputBorder.none,
                    hintText: 'Enter activity description',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  onChanged: (value) => setState(() => _description = value),
                ),
              ),
              SizedBox(height: 20.h),

              // Priority Selector
              Text(
                'Priority',
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                height: 50.h,
                decoration: BoxDecoration(
                  // color: Colors.grey.withOpacity(0.0),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text('High', style: TextStyle(fontSize: 14.sp)),
                        selected: _priority == 'high',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _priority = 'high';
                            });
                          }
                        },
                        selectedColor: Colors.redAccent,
                        backgroundColor: Colors.transparent,
                        labelStyle: TextStyle(
                          color: _priority == 'high'
                              ? Colors.white
                              : Colors.white70,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ChoiceChip(
                        label: Text(
                          'Medium',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        selected: _priority == 'medium',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _priority = 'medium';
                            });
                          }
                        },
                        selectedColor: Colors.orangeAccent,
                        backgroundColor: Colors.transparent,
                        labelStyle: TextStyle(
                          color: _priority == 'medium'
                              ? Colors.white
                              : Colors.white70,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ChoiceChip(
                        label: Text('Low', style: TextStyle(fontSize: 14.sp)),
                        selected: _priority == 'low',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _priority = 'low';
                            });
                          }
                        },
                        selectedColor: const Color.fromARGB(255, 54, 138, 97),
                        backgroundColor: Colors.transparent,
                        labelStyle: TextStyle(
                          color: _priority == 'low'
                              ? Colors.white
                              : Colors.white70,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),

              // Action Buttons (outside the scrollable area)
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        backgroundColor: Colors.grey.withOpacity(0.2),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 10.r,
                            offset: Offset(0, 5.h),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () async {
                          FocusScope.of(
                            context,
                          ).unfocus(); // Unfocus before processing
                          if (_name.isEmpty || _description.isEmpty) {
                            Navigator.pop(context);
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
                                        'Please complete all the fields',
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
                            return;
                          }

                          final user = FirebaseAuth.instance.currentUser!;
                          final activitiesRef = FirebaseFirestore.instance
                              .collection("activities")
                              .doc(user.uid);

                          if (_activityType == "event") {
                            final datesInRange = getDatesInRange(
                              _startDateTime,
                              _endDateTime,
                            );

                            for (DateTime date in datesInRange) {
                              final newActivity = {
                                "type": _activityType,
                                "name": _name,
                                "description": _description,
                                "priority": _priority,
                                "status": "pending",
                                "timestamp": DateTime.now(),
                                "date": date,
                                "startDate": _startDateTime,
                                "endDate": _endDateTime,
                                "isMultiDay": datesInRange.length > 1,
                              };

                              // Create unique document ID with date suffix
                              final docId = _description;

                              await activitiesRef
                                  .collection(
                                    "${date.month}-${date.day}-${date.year}",
                                  )
                                  .doc(docId)
                                  .set(newActivity);
                            }
                          } else {
                            // Assignment logic (unchanged)
                            final newActivity = {
                              "type": _activityType,
                              "name": _name,
                              "date": _startDateTime,
                              "description": _description,
                              "priority": _priority,
                              "status": "pending",
                              "timestamp": DateTime.now(),
                            };

                            await activitiesRef
                                .collection(
                                  "${_startDateTime.month}-${_startDateTime.day}-${_startDateTime.year}",
                                )
                                .doc(_description)
                                .set(newActivity);
                          }
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          'Create',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String getStatusDisplay(String type, String status, DateTime activityDate) {
    final now = DateTime.now();
    final isToday =
        activityDate.year == now.year &&
        activityDate.month == now.month &&
        activityDate.day == now.day;

    if (status == 'completed') {
      return type == 'event' ? 'ATTENDED' : 'COMPLETED';
    }

    if (status == 'pending') {
      if (type == 'event') {
        if (isToday) {
          return 'TODAY';
        }
        return activityDate.isAfter(now) ? 'UPCOMING' : 'MISSED';
      } else {
        if (isToday) {
          return activityDate.isAfter(now) ? 'DUE TODAY' : 'OVERDUE';
        }
        return activityDate.isAfter(now) ? 'PENDING' : 'OVERDUE';
      }
    }

    return status.toUpperCase();
  }

  bool isLoading = true;
  @override
  void initState() {
    run_func();
    _checkProfileCompletion();
    super.initState();
  }

  Future<void> _checkProfileCompletion() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("profile")
            .doc(user.email)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;

          // Check if GPA fields are filled
          final gpaW = data['gpaW']?.toString().trim();
          final gpaUW = data['gpaUW']?.toString().trim();
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
            _isCheckingProfile = false;
          });

          // Show dialog if profile is incomplete
          if (!_isProfileComplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showIncompleteProfileDialog();
            });
          }
        } else {
          setState(() {
            _isCheckingProfile = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showIncompleteProfileDialog();
          });
        }
      }
    } catch (e) {
      print("Error checking profile: $e");
      setState(() {
        _isCheckingProfile = false;
      });
    }
  }

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
              'Please complete your profile by filling out your GPA and courses information to access all features.',
              style: TextStyle(color: Colors.white70, fontSize: 16.sp),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                selectedPageNotifier.value = 2;
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
    if (_isCheckingProfile) {
      return Scaffold(
        backgroundColor: Color(0xFF1B1B1B),
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(118, 251, 166, 1),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 48, 196, 255), Color(0xFF2575FC)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.4),
                blurRadius: 12.r,
                offset: Offset(0, 6.h),
                spreadRadius: 1.r,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () async {
              showCreateActivityDialog(context);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35.r),
            ),
            child: Icon(Icons.add, size: 32.sp, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // --- Improved Header Row ---
                    Padding(
                      padding: EdgeInsets.only(
                        right: 20.w,
                        left: 20.w,
                        top: 15.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // This aligns them vertically
                        children: [
                          // LEFT SIDE: Name and welcome message
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisSize: MainAxisSize
                            // .min, // Prevents column from taking full height
                            children: [
                              Text(
                                "Welcome Back",
                                style: GoogleFonts.montserrat(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                data["name"] ?? "User",
                                maxLines: 1,
                                style: GoogleFonts.montserrat(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color.fromRGBO(118, 251, 166, 1),
                                ),
                              ),
                            ],
                          ),
                          // RIGHT SIDE: Grade and Icon
                          Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 27.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.grade,
                                    size: 17.sp,
                                    color: Colors.white70,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    data["grade"] == "9"
                                        ? "Freshman"
                                        : data["grade"] == "10"
                                        ? "Sophomore"
                                        : data["grade"] == "11"
                                        ? "Junior"
                                        : data["grade"] == "12"
                                        ? "Senior"
                                        : "Grade ${data["grade"]}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Inside the Welcome Column, replace the school and grade Text widgets with this:
                    Padding(
                      padding: EdgeInsets.only(left: 25.0.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 14.sp,
                            color: const Color.fromRGBO(88, 75, 245, 1),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            data["school"],
                            style: GoogleFonts.montserrat(
                              fontSize: 17.sp,
                              color: const Color.fromRGBO(88, 75, 245, 1),
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50.h),
                    Padding(
                      padding: EdgeInsetsGeometry.all(0.w),
                      child: ThemingExample(),
                    ),

                    Expanded(
                      child: BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          if (state is ChangeSelectedDateTimeState) {
                            _selectedDateTime = state.selectedDate;
                          }
                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("activities")
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection(
                                  "${_selectedDateTime.month}-${_selectedDateTime.day}-${_selectedDateTime.year}",
                                )
                                .orderBy("date")
                                .snapshots(),

                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator.adaptive(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text("Error: ${snapshot.error}"),
                                );
                              }

                              if (snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Optional icon
                                      Text(
                                        "🏖️", // or "🛌"
                                        style: TextStyle(fontSize: 90.sp),
                                      ),

                                      // Stylish text with gradient
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            LinearGradient(
                                              colors: [
                                                Color(0xFF2575FC),
                                                Color(0xFF2575FC),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ).createShader(
                                              Rect.fromLTWH(
                                                0,
                                                0,
                                                bounds.width,
                                                bounds.height,
                                              ),
                                            ),
                                        child: Text(
                                          "No activities Scheduled!",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors
                                                .white, // gradient will apply over this
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 12.h),

                                      // Optional description
                                      Text(
                                        "Looks like you have a free day!",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14.sp,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final activities = snapshot.data?.docs ?? [];
                              return ListView.builder(
                                itemCount: activities.length,
                                itemBuilder: (context, index) {
                                  final activity = activities[index];
                                  final DateTime activityDate =
                                      (activity['date'] as Timestamp).toDate();
                                  final bool isToday =
                                      activityDate.year ==
                                          DateTime.now().year &&
                                      activityDate.month ==
                                          DateTime.now().month &&
                                      activityDate.day == DateTime.now().day;
                                  final String dateText;
                                  if (activity['type'] == "event") {
                                    final DateTime startDate =
                                        (activity['startDate'] as Timestamp)
                                            .toDate();
                                    final DateTime endDate =
                                        (activity['endDate'] as Timestamp)
                                            .toDate();

                                    // Check if it's same day or multi-day
                                    if (startDate.year == endDate.year &&
                                        startDate.month == endDate.month &&
                                        startDate.day == endDate.day) {
                                      // 24-hour format: "14:00-16:00" (very compact)
                                      dateText =
                                          "Today: ${DateFormat('HH:mm').format(startDate)}-${DateFormat('HH:mm').format(endDate)}";
                                    } else {
                                      // Multi-day: show compact date range
                                      dateText =
                                          "Multi: ${DateFormat('MMM d').format(startDate)}-${DateFormat('d').format(endDate)}";
                                    }
                                  } else {
                                    // Assignment: show due time in 24-hour format for consistency
                                    final DateTime dueDate =
                                        (activity['date'] as Timestamp)
                                            .toDate();
                                    dateText =
                                        "Due: ${DateFormat('HH:mm').format(dueDate)}";
                                  }
                                  Color priorityColor =
                                      activity['priority'] == 'high'
                                      ? Colors.redAccent
                                      : activity['priority'] == 'medium'
                                      ? Colors.orangeAccent
                                      : Colors.greenAccent;

                                  IconData typeIcon =
                                      activity['type'] == 'event'
                                      ? Icons.event
                                      : activity['type'] == 'assignment'
                                      ? Icons.assignment
                                      : Icons.notifications;

                                  // Determine appropriate status wording based on activity type
                                  String status = activity['status'];

                                  String displayStatus = getStatusDisplay(
                                    activity['type'],
                                    activity['status'],
                                    activityDate,
                                  );

                                  Color statusColor =
                                      activity['type'] == 'event'
                                      ? (status == 'attended' ||
                                                status == 'completed'
                                            ? Colors.greenAccent
                                            : status == 'upcoming' ||
                                                  status == 'pending'
                                            ? Colors.orangeAccent
                                            : Colors.redAccent)
                                      : (status == 'completed'
                                            ? Colors.greenAccent
                                            : status == 'pending'
                                            ? Colors.orangeAccent
                                            : Colors.redAccent);

                                  Color statusBgColor =
                                      activity['type'] == 'event'
                                      ? (status == 'attended' ||
                                                status == 'completed'
                                            ? Colors.green.withOpacity(0.2)
                                            : status == 'upcoming' ||
                                                  status == 'pending'
                                            ? Colors.orange.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2))
                                      : (status == 'completed'
                                            ? Colors.green.withOpacity(0.2)
                                            : status == 'pending'
                                            ? Colors.orange.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2));

                                  return Column(
                                    children: [
                                      if (index == 0) SizedBox(height: 30.h),
                                      Dismissible(
                                        key: Key(activity.id),
                                        background: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors
                                                    .redAccent
                                                    .shade200, // matches "high" priority red
                                                Colors.red.shade700,
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.redAccent
                                                    .withOpacity(0.25),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.symmetric(
                                            vertical: 10.h,
                                            horizontal: 20.w,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20.w,
                                          ),
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 30.sp,
                                          ),
                                        ),
                                        secondaryBackground: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.green.shade700,
                                                Colors
                                                    .greenAccent
                                                    .shade200, // matches "completed" green
                                              ],
                                              begin: Alignment.centerRight,
                                              end: Alignment.centerLeft,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(
                                                  0.25,
                                                ),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          alignment: Alignment.centerRight,
                                          margin: EdgeInsets.symmetric(
                                            vertical: 10.h,
                                            horizontal: 20.w,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20.h,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 30.sp,
                                          ),
                                        ),
                                        onDismissed: (direction) async {
                                          try {
                                            final user = FirebaseAuth
                                                .instance
                                                .currentUser!;
                                            final activityData =
                                                activity.data()
                                                    as Map<String, dynamic>;
                                            final activityId = activity.id;

                                            // print(
                                            //   "Attempting to dismiss activity: $activityId",
                                            // );

                                            if (direction ==
                                                DismissDirection.startToEnd) {
                                              // DELETE action
                                              // print("Deleting activity...");

                                              if (activityData["type"] ==
                                                  "event") {
                                                final startDate =
                                                    (activityData['startDate']
                                                            as Timestamp)
                                                        .toDate();
                                                final endDate =
                                                    (activityData['endDate']
                                                            as Timestamp)
                                                        .toDate();
                                                final datesInRange =
                                                    getDatesInRange(
                                                      startDate,
                                                      endDate,
                                                    );

                                                // print(
                                                //   "Multi-day event. Dates in range: ${datesInRange.length}",
                                                // );

                                                for (DateTime date
                                                    in datesInRange) {
                                                  final collectionPath =
                                                      "${date.month}-${date.day}-${date.year}";
                                                  // print(
                                                  //   "Deleting from collection: $collectionPath",
                                                  // );

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("activities")
                                                      .doc(user.uid)
                                                      .collection(
                                                        collectionPath,
                                                      )
                                                      .doc(activityId)
                                                      .delete();
                                                }
                                              } else {
                                                final collectionPath =
                                                    "${activityDate.month}-${activityDate.day}-${activityDate.year}";
                                                // print(
                                                //   "Deleting from collection: $collectionPath",
                                                // );

                                                await FirebaseFirestore.instance
                                                    .collection("activities")
                                                    .doc(user.uid)
                                                    .collection(collectionPath)
                                                    .doc(activityId)
                                                    .delete();
                                              }

                                              // print("Delete successful!");
                                            } else if (direction ==
                                                DismissDirection.endToStart) {
                                              // MARK AS COMPLETE action
                                              // print("Marking as complete...");

                                              if (activityData["type"] ==
                                                  "event") {
                                                final startDate =
                                                    (activityData['startDate']
                                                            as Timestamp)
                                                        .toDate();
                                                final endDate =
                                                    (activityData['endDate']
                                                            as Timestamp)
                                                        .toDate();
                                                final datesInRange =
                                                    getDatesInRange(
                                                      startDate,
                                                      endDate,
                                                    );

                                                // print(
                                                //   "Multi-day event. Dates in range: ${datesInRange.length}",
                                                // );

                                                for (DateTime date
                                                    in datesInRange) {
                                                  final collectionPath =
                                                      "${date.month}-${date.day}-${date.year}";
                                                  // print(
                                                  //   "Updating in collection: $collectionPath",
                                                  // );

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("activities")
                                                      .doc(user.uid)
                                                      .collection(
                                                        collectionPath,
                                                      )
                                                      .doc(activityId)
                                                      .delete();

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("activities")
                                                      .doc(user.uid)
                                                      .collection(
                                                        collectionPath,
                                                      )
                                                      .doc(activityId)
                                                      .set({
                                                        ...activityData,
                                                        "status": "completed",
                                                        "timestamp":
                                                            FieldValue.serverTimestamp(),
                                                      });
                                                }
                                              } else {
                                                final collectionPath =
                                                    "${activityDate.month}-${activityDate.day}-${activityDate.year}";
                                                // print(
                                                //   "Updating in collection: $collectionPath",
                                                // );
                                                await FirebaseFirestore.instance
                                                    .collection("activities")
                                                    .doc(user.uid)
                                                    .collection(collectionPath)
                                                    .doc(activityId)
                                                    .delete();

                                                await FirebaseFirestore.instance
                                                    .collection("activities")
                                                    .doc(user.uid)
                                                    .collection(collectionPath)
                                                    .doc(activityId)
                                                    .set({
                                                      ...activityData,
                                                      "status": "completed",
                                                      "timestamp":
                                                          FieldValue.serverTimestamp(),
                                                    });
                                              }

                                              // print(
                                              //   "Mark as complete successful!",
                                              // );
                                            }
                                          } catch (e) {
                                            // print("ERROR in dismiss: $e");
                                            // Show error to user
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Color(0xFFFF006E),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Expanded(
                                                      child: Text(
                                                        'Unexpected Error Occured.',
                                                        style:
                                                            GoogleFonts.orbitron(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: Color(
                                                  0xFF1A1A2E,
                                                ),
                                                elevation: 10,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
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
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 8.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(
                                              0.05,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16.r,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.15,
                                                ),
                                                blurRadius: 8.r,
                                                offset: Offset(0, 4.h),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              onTap: () async {
                                                await showEditActivityDialog(
                                                  context,
                                                  activity.data()
                                                      as Map<String, dynamic>,
                                                );
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.all(16.w),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Priority indicator bar
                                                    Container(
                                                      width: 4.w,
                                                      height: 80.h,
                                                      decoration: BoxDecoration(
                                                        color: priorityColor,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              2.r,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 16.w),

                                                    // Icon for activity type
                                                    Container(
                                                      padding: EdgeInsets.all(
                                                        8.w,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: priorityColor
                                                            .withOpacity(0.2),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        typeIcon,
                                                        size: 20.sp,
                                                        color: priorityColor,
                                                      ),
                                                    ),
                                                    SizedBox(width: 16.w),

                                                    // Center content
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Type and priority tags
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10.w,
                                                                      vertical:
                                                                          4.h,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .blueAccent
                                                                      .withOpacity(
                                                                        0.2,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8.r,
                                                                      ),
                                                                ),
                                                                child: Text(
                                                                  activity['type']
                                                                      .toString()
                                                                      .toUpperCase(),
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .blueAccent,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        10.sp,
                                                                    letterSpacing:
                                                                        0.5,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 8.w,
                                                              ),
                                                              Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10.w,
                                                                      vertical:
                                                                          4.h,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: priorityColor
                                                                      .withOpacity(
                                                                        0.2,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8.r,
                                                                      ),
                                                                ),
                                                                child: Text(
                                                                  activity['priority']
                                                                      .toString()
                                                                      .toUpperCase(),
                                                                  style: TextStyle(
                                                                    color:
                                                                        priorityColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        8.sp,
                                                                    letterSpacing:
                                                                        0.5,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10.h,
                                                          ),

                                                          // Name
                                                          Text(
                                                            activity['name'],
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize:
                                                                      16.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          SizedBox(height: 6.h),

                                                          // Description
                                                          Text(
                                                            activity['description'],
                                                            style:
                                                                GoogleFonts.montserrat(
                                                                  fontSize:
                                                                      13.sp,
                                                                  color: Colors
                                                                      .white70,
                                                                  height: 1.4,
                                                                ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    SizedBox(width: 12.w),

                                                    // Time and status
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal:
                                                                    10.w,
                                                                vertical: 6.h,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                  0.2,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12.r,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            dateText,
                                                            style:
                                                                GoogleFonts.robotoMono(
                                                                  color: Colors
                                                                      .white70,
                                                                  fontSize:
                                                                      10.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.h),

                                                        // Status indicator - different wording for events vs assignments
                                                        Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal:
                                                                    10.w,
                                                                vertical: 4.h,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                statusBgColor,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8.r,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            displayStatus,
                                                            style: TextStyle(
                                                              color:
                                                                  statusColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 10.sp,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (index == activities.length - 1)
                                        SizedBox(height: 80.h),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
