import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_club/showcase_project/login_project.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeProject extends StatefulWidget {
  const HomeProject({super.key});

  @override
  State<HomeProject> createState() => _HomeProjectState();
}

class _HomeProjectState extends State<HomeProject>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller2;
  late Animatable<Offset> _tween;
  late Animatable<Offset> _tween2;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _tween = Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeInOutBack));
    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _tween2 = Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.bounceInOut));
    _controller.forward();
    _controller2.forward();
    Future.delayed(Duration(seconds: 7), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
              begin: Offset(-1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeIn));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _controller2.drive(_tween2),
              child: Image.asset(
                "lib/showcase_project/images/levelup_logo.png",
                height: 700.h,
              ),
            ),
          ],
        ),
      ),
      // ),
    );
  }
}




// SizedBox(height: 30.h),
                  // Container(
                  //   width: 300.w,
                  //   height: 60.h,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Material(
                  //     borderRadius: BorderRadius.circular(12),
                  //     color: Colors.transparent,
                  //     child: InkWell(
                  //       borderRadius: BorderRadius.circular(12),
                  //       onTap: () {},
                  //       splashColor: Color.fromRGBO(244, 196, 88, 1),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Text(
                  //             "Get Started",
                  //             style: GoogleFonts.sourceCodePro(
                  //               color: Color.fromRGBO(52, 104, 179, 1),
                  //               fontWeight: FontWeight.bold,
                  //               fontSize: 17,
                  //             ),
                  //           ),
                  //           SizedBox(width: 20.w),
                  //           Icon(
                  //             Icons.arrow_forward,
                  //             color: Color.fromRGBO(52, 104, 179, 1),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),