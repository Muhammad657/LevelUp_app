import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_club/showcase_project/bloc/login_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemingExample extends StatefulWidget {
  const ThemingExample({super.key});

  @override
  State<ThemingExample> createState() => _NewWidgetExampleState();
}

class _NewWidgetExampleState extends State<ThemingExample> {
  DateTime _selectedDate = DateTime.now();
  DateTime now = DateTime.now();

  // Dark theme colors
  final Color background = const Color(0xFF121212);
  final Color primary = const Color.fromARGB(255, 53, 126, 183);
  final Color secondary = const Color.fromARGB(255, 45, 124, 185); // green
  final Color accent = const Color(0xFF40C4FF); // cyan
  final Color unselectedBorder = const Color(0xFF444444);
  final Color unselectedText = Color(0xFFB0BEC5);

  Color get activeColor {
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      return secondary; // today
    }
    return primary; // other selected
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Positioned(
        //   top: 15,
        //   left: 6,
        //   child: Container(
        //     width: 193,
        //     height: 30,
        //     decoration: BoxDecoration(
        //       color:
        //           // _selectedDate.day == now.day
        //           const Color.fromARGB(255, 53, 126, 183),
        //       // : Color.fromARGB(255, 123, 21, 225),
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //   ),
        // ),
        Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: background,
            colorScheme: ColorScheme.dark(
              onSurface: Colors.white,
              primary: activeColor,
              secondary: secondary,
            ),
          ),
          child: Builder(
            builder: (context) {
              return EasyTheme(
                data: EasyTheme.of(context).copyWith(
                  timelineOptions: TimelineOptions(height: 100.h),

                  // 📅 Year text styles
                  yearStyle: WidgetStatePropertyAll(
                    GoogleFonts.roboto(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      letterSpacing: 1.2.w,
                    ),
                  ),
                  currentYearStyle: WidgetStatePropertyAll(
                    GoogleFonts.roboto(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5.w,
                    ),
                  ),

                  // 📆 Month text styles
                  monthStyle: WidgetStatePropertyAll(
                    GoogleFonts.robotoMono(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  currentMonthStyle: WidgetStatePropertyAll(
                    GoogleFonts.robotoMono(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  // 🗓️ Day number styles
                  dayTopElementStyle: WidgetStatePropertyAll(
                    GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),

                  currentDayTopElementStyle: WidgetStatePropertyAll(
                    GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  // dayTopElementStyle: WidgetStatePropertyAll(
                  //   GoogleFonts.poppins(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  dayMiddleElementStyle: WidgetStatePropertyAll(
                    GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  currentDayMiddleElementStyle: WidgetStatePropertyAll(
                    GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),

                  // Borders + colors (same as before)
                  dayBorder: WidgetStatePropertyAll(
                    BorderSide(color: Colors.transparent),
                  ),
                  dayForegroundColor: WidgetStatePropertyAll(Colors.white),
                  currentDayForegroundColor: WidgetStatePropertyAll(
                    Colors.cyanAccent,
                  ),
                  currentDayBorder: WidgetStatePropertyAll(
                    BorderSide(color: secondary),
                  ),
                  currentMonthForegroundColor: WidgetStatePropertyAll(
                    Colors.cyanAccent,
                  ),
                  currentMonthBorder: WidgetStatePropertyAll(
                    BorderSide(color: accent),
                  ),
                  
                ),
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    if (state is ChangeSelectedDateTimeState) {
                      _selectedDate = state.selectedDate;
                    }
                    return EasyDateTimeLinePicker(
                      firstDate: DateTime(2024, 3, 18),
                      
                      lastDate: DateTime(2030, 3, 18),
                      focusedDate: _selectedDate,
                      onDateChange: (selectedDate) {
                        BlocProvider.of<LoginBloc>(context).add(
                          ChangeSelectedDateEvent(selectedTime: selectedDate),
                        );
                        // setState(() {
                        //   _selectedDate = selectedDate;
                        // });
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
