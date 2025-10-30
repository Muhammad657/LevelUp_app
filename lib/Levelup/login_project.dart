import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_club/widgettree.dart';
import 'package:flutter_club/Levelup/bloc/login_bloc.dart';
import 'package:flutter_club/Levelup/college_rec.dart';
import 'package:flutter_club/Levelup/student_form_1.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  appleSign() async {
    try {
      if (kIsWeb) {
        final provider = OAuthProvider("apple.com");
        print("KIsWeb");
        return await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        print("no KIsWeb");

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            // AppleIDAuthorizationScopes.fullName,
          ],
        );
        if (appleCredential.identityToken == null) {
          throw Exception("Apple identity token is null. Cannot sign in.");
        }

        final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        await FirebaseAuth.instance.signInWithCredential(oauthCredential);

        final profile_data = await FirebaseFirestore.instance
            .collection("profile")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .get();
        final profile_data2 = profile_data.data();

        if (profile_data2 == null ||
            profile_data2["name"] == null ||
            profile_data2["grade"] == null ||
            profile_data2["school"] == null ||
            profile_data2["interests"] == null ||
            profile_data2["awards"] == null ||
            profile_data2["extracurriculars"] == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WidgetTree()),
          );
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF006E)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Unexpected Error Occured. Please try again.',
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
      return null;
    }
  }

  bool showPass = false;
  int _currentPage = 0;

  Future<void> googlesign() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFFF006E)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Google sign in cancelled',
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
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      final profile_data = await FirebaseFirestore.instance
          .collection("profile")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .get();
      final profile_data2 = profile_data.data();
      if (profile_data2 == null ||
          profile_data2["name"] == null ||
          profile_data["grade"] == null ||
          profile_data2["school"] == null ||
          profile_data2["interests"] == null ||
          profile_data2["awards"] == null ||
          profile_data2["extracurriculars"] == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WidgetTree()),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF006E)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Unexpected error occured. Please try again.',
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

  late TextEditingController _emailControllerLogin;
  late TextEditingController _passwordControllerLogin;
  late TextEditingController _emailControllerSignIn;
  late TextEditingController _passwordControllerSignIn;
  late TextEditingController _confirmPasswordControllerSignIn;
  final email_pass_box = Hive.box("email_pass");
  Future<void> login(email, password) async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (user.user != null) {
        email_pass_box.put("email", email);
        email_pass_box.put("pass", password);
        final profile_data = await FirebaseFirestore.instance
            .collection("profile")
            .doc(FirebaseAuth.instance.currentUser!.email)
            .get();
        final profile_data2 = profile_data.data();
        if (profile_data2 == null ||
            profile_data2["name"] == null ||
            profile_data["grade"] == null ||
            profile_data2["school"] == null ||
            profile_data2["interests"] == null ||
            profile_data2["awards"] == null ||
            profile_data2["extracurriculars"] == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WidgetTree()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF006E)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'ACCESS DENIED: ${e.message}',
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
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future register(email, password, confirmPass) async {
    if (password.text.trim() != confirmPass.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF006E)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Passwords dont match',
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

      return;
    } else {
      try {
        final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );
        if (user.user != null) {
          EmailOTP.sendOTP(email: email.text.trim());
          bool verified = await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) =>
                VerifyEmailDialog(email: _emailControllerSignIn.text),
          );
          if (verified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            await FirebaseAuth.instance.currentUser?.delete();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFFF006E)),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Email Verification Failed',
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
            return;
          }
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFFF006E)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Unexpected Error Occured While Signing Up',
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
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _emailControllerLogin = TextEditingController();
    _passwordControllerLogin = TextEditingController();
    _emailControllerSignIn = TextEditingController();
    _passwordControllerSignIn = TextEditingController();
    _confirmPasswordControllerSignIn = TextEditingController();

    final email = email_pass_box.get("email");
    final password = email_pass_box.get("pass");
    if (email_pass_box.get("remember") == true) {
      if (email != null && password != null) {
        login(email, password);
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }

    super.initState();
  }

  bool isLoading = true;
  bool remember = false;
  @override
  void dispose() {
    _emailControllerLogin.dispose();
    _passwordControllerLogin.dispose();
    super.dispose();
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        // Simple clean divider
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.white.withOpacity(0.3),
                  thickness: 3.w,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Text(
                  "OR CONTINUE WITH",
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.white.withOpacity(0.3),
                  thickness: 3.w,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 40.h),

        // Your social buttons...
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGlassSocialButton(
              onTap: googlesign,
              icon: Image.asset(
                "lib/showcase_project/images/google_logo.png",
                height: 28.h,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
            SizedBox(width: 50.w),
            _buildGlassSocialButton(
              onTap: appleSign,
              icon: Icon(Icons.apple, color: Colors.white, size: 32.sp),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 30.h),
      ],
    );
  }

  // Glassmorphism Social Button
  Widget _buildGlassSocialButton({
    required VoidCallback onTap,
    required Widget icon,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 60.w,
        height: 60.w,
        decoration: BoxDecoration(
          gradient: gradient,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20.r,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 5.r,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(1.0),
            child: icon,
          ),
        ),
      ),
    );
  }

  // Enhanced Continue Button for PageView
  Widget _buildContinueButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Add your continue logic here
          },
          borderRadius: BorderRadius.circular(15.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F5F8B), Color(0xFF00C2FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00C2FF).withOpacity(0.4),
                  blurRadius: 15.r,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "CONTINUE",
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(width: 10.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(118, 251, 166, 1),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          // backgroundColor: Color.fromARGB(255, 225, 196, 253),
          body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 30.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.only(
                                left: 20.w,
                                right: 20.w,
                              ),
                              child: Container(
                                child: ClipRRect(
                                  child: Image.asset(
                                    "lib/showcase_project/images/leveltuff_logo2.png",
                                    height: 200.h,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: PageView.builder(
                            onPageChanged: (int page) {
                              setState(() {
                                _currentPage = page;
                              });
                            },
                            scrollDirection: Axis.horizontal,
                            itemCount: 2,
                            itemBuilder: (context, index) => index == 1
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      // top: 20.h,
                                      left: 20.w,
                                      right: 20.w,
                                    ),
                                    child: Container(
                                      height: 50.h,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20.h,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        color: Colors.transparent,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            "SIGN UP",
                                            style: GoogleFonts.orbitron(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 24.sp,
                                              letterSpacing: 3.0,
                                            ),
                                          ),

                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: 30.h,
                                              right: 40.w,
                                              left: 40.w,
                                              bottom: 10.h,
                                            ),
                                            child: TextField(
                                              controller:
                                                  _emailControllerSignIn,
                                              style: GoogleFonts.poppins(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                fontSize: 14.sp,
                                              ),
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 8.w,
                                                      vertical: 12.h,
                                                    ),
                                                hintText: "Email",

                                                hintStyle: GoogleFonts.poppins(
                                                  color: Color.fromRGBO(
                                                    255,
                                                    255,
                                                    255,
                                                    1,
                                                  ),
                                                  fontSize: 14.sp,
                                                ),

                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10.r,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10.r,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                fillColor: Colors.transparent,
                                                filled: true,
                                              ),
                                            ),
                                          ),

                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 40.w,
                                            ),
                                            child: BlocBuilder<LoginBloc, LoginState>(
                                              builder: (context, state) {
                                                if (state is ShowPassState) {
                                                  showPass = state.value;
                                                }
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: 10.h,
                                                      ),
                                                      child: TextField(
                                                        controller:
                                                            _passwordControllerSignIn,
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  Color.fromRGBO(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    1,
                                                                  ),
                                                              fontSize: 14.sp,
                                                            ),
                                                        obscureText: !showPass,
                                                        obscuringCharacter: "•",
                                                        decoration: InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 8.w,
                                                                vertical: 12.h,
                                                              ),
                                                          hintText: "Password",

                                                          hintStyle:
                                                              GoogleFonts.poppins(
                                                                color:
                                                                    Color.fromRGBO(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      1,
                                                                    ),
                                                                fontSize: 14.sp,
                                                              ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10.r,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                              ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10.r,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                              ),
                                                          fillColor: Colors
                                                              .transparent,
                                                          filled: true,
                                                        ),
                                                      ),
                                                    ),
                                                    TextField(
                                                      controller:
                                                          _confirmPasswordControllerSignIn,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color:
                                                                Color.fromRGBO(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  1,
                                                                ),
                                                            fontSize: 14.sp,
                                                          ),
                                                      obscureText: !showPass,
                                                      obscuringCharacter: "•",
                                                      decoration: InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 8.w,
                                                              vertical: 12.h,
                                                            ),
                                                        hintText:
                                                            "Confirm Password",

                                                        hintStyle:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  Color.fromRGBO(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    1,
                                                                  ),
                                                              fontSize: 14.sp,
                                                            ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10.r,
                                                                  ),
                                                              borderSide:
                                                                  BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                            ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10.r,
                                                                  ),
                                                              borderSide:
                                                                  BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                            ),
                                                        fillColor:
                                                            Colors.transparent,
                                                        filled: true,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                          // SizedBox(height: 10.h),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 40.w,
                                              vertical: 20.h,
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () async {
                                                  await register(
                                                    _emailControllerSignIn,
                                                    _passwordControllerSignIn,
                                                    _confirmPasswordControllerSignIn,
                                                  );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                splashColor: Color(
                                                  0xFF00C2FF,
                                                ).withOpacity(0.3),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 10.h,
                                                    horizontal: 20.w,
                                                  ),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFF00C2FF),
                                                        Color(0xFF1F5F8B),
                                                      ],
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(
                                                          0xFF00C2FF,
                                                        ).withOpacity(0.5),
                                                        blurRadius: 15.r,
                                                        offset: Offset(0, 5),
                                                      ),
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        blurRadius: 10.r,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.3),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "SIGN UP",
                                                      style:
                                                          GoogleFonts.orbitron(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 13.sp,
                                                            letterSpacing: 2.0,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // SizedBox(height: 20.h),
                                        ],
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                      top: 20.h,
                                      left: 20.w,
                                      right: 20.w,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        // vertical: 10.h,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        color: Colors.transparent,
                                      ),
                                      child: Stack(
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(height: 10.h),
                                              Text(
                                                "LOG IN",
                                                style: GoogleFonts.orbitron(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 24.sp,
                                                  letterSpacing: 3.0,
                                                ),
                                              ),

                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: 30.h,
                                                  right: 40.w,
                                                  left: 40.w,
                                                  bottom: 10.h,
                                                ),
                                                child: TextField(
                                                  controller:
                                                      _emailControllerLogin,
                                                  style: GoogleFonts.poppins(
                                                    color: Color.fromRGBO(
                                                      255,
                                                      255,
                                                      255,
                                                      1,
                                                    ),
                                                    fontSize: 14.sp,
                                                  ),
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8.w,
                                                          vertical: 12.h,
                                                        ),
                                                    hintText: "Email",

                                                    hintStyle:
                                                        GoogleFonts.poppins(
                                                          color: Color.fromRGBO(
                                                            255,
                                                            255,
                                                            255,
                                                            1,
                                                          ),
                                                          fontSize: 14.sp,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10.r,
                                                              ),
                                                          borderSide:
                                                              BorderSide(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10.r,
                                                              ),
                                                          borderSide:
                                                              BorderSide(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        ),
                                                    fillColor:
                                                        Colors.transparent,
                                                    filled: true,
                                                  ),
                                                ),
                                              ),

                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 40.w,
                                                ),
                                                child: BlocBuilder<LoginBloc, LoginState>(
                                                  builder: (context, state) {
                                                    if (state
                                                        is ShowPassState) {
                                                      showPass = state.value;
                                                    }
                                                    return Stack(
                                                      children: [
                                                        TextField(
                                                          controller:
                                                              _passwordControllerLogin,
                                                          style: GoogleFonts.poppins(
                                                            color:
                                                                Color.fromRGBO(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  1,
                                                                ),
                                                            fontSize: 14.sp,
                                                          ),
                                                          obscureText:
                                                              !showPass,
                                                          obscuringCharacter:
                                                              "•",
                                                          decoration: InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      8.w,
                                                                  vertical:
                                                                      12.h,
                                                                ),
                                                            hintText:
                                                                "Password",

                                                            hintStyle:
                                                                GoogleFonts.poppins(
                                                                  color:
                                                                      Color.fromRGBO(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        1,
                                                                      ),
                                                                  fontSize:
                                                                      14.sp,
                                                                ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10.r,
                                                                  ),
                                                              borderSide:
                                                                  BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10.r,
                                                                  ),
                                                              borderSide:
                                                                  BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                            ),
                                                            fillColor: Colors
                                                                .transparent,
                                                            filled: true,
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 7.w,
                                                          bottom: 0.h,
                                                          child: IconButton(
                                                            onPressed: () {
                                                              showPass =
                                                                  !showPass;
                                                              BlocProvider.of<
                                                                    LoginBloc
                                                                  >(context)
                                                                  .add(
                                                                    ShowPassToggleEvent(
                                                                      value:
                                                                          showPass,
                                                                    ),
                                                                  );
                                                            },
                                                            icon: showPass
                                                                ? Icon(
                                                                    CupertinoIcons
                                                                        .eye_slash,
                                                                    size: 20.sp,
                                                                    color: Colors
                                                                        .white,
                                                                  )
                                                                : Icon(
                                                                    CupertinoIcons
                                                                        .eye,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 20.sp,
                                                                  ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Padding(
                                              //   padding: EdgeInsets.only(
                                              //     right: 20.0.w,
                                              //     top: 19.h,
                                              //   ),
                                              //   child: Align(
                                              //     alignment:
                                              //         Alignment.topRight,
                                              //     child: Material(
                                              //       color:
                                              //           Colors.transparent,
                                              //       child: InkWell(
                                              //         onTap: () async {
                                              //           await showForgotPasswordDialog(
                                              //             context,
                                              //           );
                                              //         },
                                              //         splashColor:
                                              //             Color.fromRGBO(
                                              //               255,
                                              //               255,
                                              //               255,
                                              //               0.1,
                                              //             ),
                                              //         child: Text(
                                              //           "Forgot Password?",
                                              //           style: GoogleFonts.lexendDeca(
                                              //             color:
                                              //                 Color.fromRGBO(
                                              //                   255,
                                              //                   255,
                                              //                   255,
                                              //                   0.7,
                                              //                 ),
                                              //             fontSize: 14.sp,
                                              //             fontWeight:
                                              //                 FontWeight
                                              //                     .bold,
                                              //           ),
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              // SizedBox(height: 30.h),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 40.w,
                                                  vertical: 30.h,
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      await login(
                                                        _emailControllerLogin
                                                            .text
                                                            .trim(),
                                                        _passwordControllerLogin
                                                            .text
                                                            .trim(),
                                                      );
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                    splashColor: Color(
                                                      0xFF00C2FF,
                                                    ).withOpacity(0.3),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 10.h,
                                                            horizontal: 20.w,
                                                          ),
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                              colors: [
                                                                Color(
                                                                  0xFF00C2FF,
                                                                ),
                                                                Color(
                                                                  0xFF1F5F8B,
                                                                ),
                                                              ],
                                                              begin: Alignment
                                                                  .centerLeft,
                                                              end: Alignment
                                                                  .centerRight,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.r,
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Color(
                                                              0xFF00C2FF,
                                                            ).withOpacity(0.5),
                                                            blurRadius: 15.r,
                                                            offset: Offset(
                                                              0,
                                                              5,
                                                            ),
                                                          ),
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                            blurRadius: 10.r,
                                                            offset: Offset(
                                                              0,
                                                              3,
                                                            ),
                                                          ),
                                                        ],
                                                        border: Border.all(
                                                          color: Colors.white
                                                              .withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "LOG IN",
                                                          style:
                                                              GoogleFonts.orbitron(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 13.sp,
                                                                letterSpacing:
                                                                    2.0,
                                                              ),
                                                        ),
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
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(2, (index) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: _currentPage == index ? 24.w : 8.w,
                              height: 8.h,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                gradient: _currentPage == index
                                    ? LinearGradient(
                                        colors: [
                                          Color(0xFF00C2FF),
                                          Color(0xFF1F5F8B),
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.3),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            );
                          }),
                        ),

                        SizedBox(height: 40.h),

                        // SizedBox(height: 50.h),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     SizedBox(
                        //       width: 40.h,
                        //       child: Divider(color: Colors.white, thickness: 2),
                        //     ),
                        //     SizedBox(width: 10.w),
                        //     Text(
                        //       "Or Continue With",
                        //       style: GoogleFonts.poppins(
                        //         color: Colors.white,
                        //         fontSize: 13.sp,
                        //       ),
                        //     ),
                        //     SizedBox(width: 10.w),
                        //     SizedBox(
                        //       width: 40.h,
                        //       child: Divider(color: Colors.white, thickness: 2),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 10.h),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     IconButton(
                        //       onPressed: () async {
                        //         await googlesign();
                        //       },
                        //       style: ButtonStyle(
                        //         backgroundColor: WidgetStatePropertyAll(
                        //           Colors.white,
                        //         ),
                        //       ),
                        //       icon: Image.asset(
                        //         "lib/showcase_project/images/google_logo.png",
                        //         height: 30.h,
                        //       ),
                        //     ),
                        //     SizedBox(width: 50.w),
                        //     GestureDetector(
                        //       onTap: () async {
                        //         await appleSign(); // your Apple sign-in function
                        //       },
                        //       child: Container(
                        //         // width: 50.w,
                        //         // height: 50.w,
                        //         decoration: BoxDecoration(
                        //           shape: BoxShape.circle,
                        //           color: Colors.white,
                        //         ),
                        //         child: Center(
                        //           child: ClipOval(
                        //             child: Image.network(
                        //               "https://www.tailorbrands.com/wp-content/uploads/2021/01/apple_logo_1988.jpg",
                        //               width: 45.w,
                        //               height: 45.w,
                        //               fit: BoxFit.cover,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 30.h),
                        _buildSocialLoginSection(),
                      ],
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
}

class VerifyEmailDialog extends StatefulWidget {
  const VerifyEmailDialog({super.key, required this.email});
  final String email;

  @override
  State<VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends State<VerifyEmailDialog> {
  final List<TextEditingController> _otpControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0A), Color(0xFF001122)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Color(0xFF00C2FF).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF00C2FF).withOpacity(0.2),
              blurRadius: 40.r,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 30.r,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF00C2FF),
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  "EMAIL VERIFICATION",
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Color(0xFF00C2FF).withOpacity(0.5),
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 25.h),

            // OTP Input Section
            Text(
              "ENTER VERIFICATION CODE",
              style: GoogleFonts.rajdhani(
                color: Color(0xFF00C2FF),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: 20.h),

            // OTP Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => _buildTechOtpBox(_otpControllers[index], index),
              ),
            ),

            SizedBox(height: 25.h),

            // Status Text
            Text(
              "SECURITY CODE SENT TO YOUR EMAIL",
              style: GoogleFonts.rajdhani(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 25.h),

            // Verify Button
            _buildTechVerifyButton(),

            SizedBox(height: 15.h),

            // Resend Code
            TextButton(
              onPressed: () {
                EmailOTP.sendOTP(email: widget.email.trim());
              },
              child: Text(
                "RESEND CODE",
                style: GoogleFonts.orbitron(
                  color: Color(0xFF00C2FF).withOpacity(0.8),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechOtpBox(TextEditingController controller, int index) {
    return Container(
      width: 45.w,
      height: 55.h,
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color(0xFF00C2FF), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00C2FF).withOpacity(0.3),
            blurRadius: 8.r,
            offset: Offset(0, 0),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10.r,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: TextField(
              controller: controller,
              cursorColor: Color(0xFF00FF88),
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22.sp,
                letterSpacing: 2.0,
              ),
              onChanged: (value) {
                if (value.length == 1 && index < 4) {
                  FocusScope.of(context).nextFocus();
                } else if (value.isEmpty && index > 0) {
                  FocusScope.of(context).previousFocus();
                }
              },
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Corner dots for tech look
          Positioned(top: 6, left: 6, child: _buildCornerDot()),
          Positioned(top: 6, right: 6, child: _buildCornerDot()),
          Positioned(bottom: 6, left: 6, child: _buildCornerDot()),
          Positioned(bottom: 6, right: 6, child: _buildCornerDot()),
        ],
      ),
    );
  }

  Widget _buildCornerDot() {
    return Container(
      width: 3.w,
      height: 3.w,
      decoration: BoxDecoration(
        color: Color(0xFF00C2FF),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTechVerifyButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isVerifying
            ? null
            : () {
                setState(() => _isVerifying = true);
                Future.delayed(Duration(milliseconds: 1500), () {
                  bool valid = EmailOTP.verifyOTP(
                    otp: _otpControllers.map((c) => c.text).join(),
                  );
                  Navigator.pop(context, valid);
                });
              },
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: _isVerifying
                ? LinearGradient(colors: [Colors.grey, Colors.grey.shade700])
                : LinearGradient(
                    colors: [Color(0xFF00C2FF), Color(0xFF0066FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: _isVerifying
                ? []
                : [
                    BoxShadow(
                      color: Color(0xFF00C2FF).withOpacity(0.4),
                      blurRadius: 15.r,
                      offset: Offset(0, 5),
                    ),
                  ],
            border: Border.all(
              color: _isVerifying ? Colors.grey : Color(0xFF00C2FF),
              width: 1.5,
            ),
          ),
          child: _isVerifying
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "VERIFYING...",
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "VERIFY IDENTITY",
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
