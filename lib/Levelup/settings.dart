import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_club/notifiers.dart';
import 'package:flutter_club/Levelup/awards2.dart';
import 'package:flutter_club/Levelup/bloc/login_bloc.dart';
import 'package:flutter_club/Levelup/extracurriculars2.dart';
import 'package:flutter_club/Levelup/home-project2.dart';
import 'package:flutter_club/Levelup/login_project.dart';
import 'package:flutter_club/Levelup/student_form_2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController passwordController = TextEditingController();
  String? userName;
  String? userSchool;
  String? userGrade;
  bool loadingPersonalInfo = true;
  bool showImages = false;
  List<dynamic> userECs = [];
  bool loadingECs = true;
  String? grade = null;

  String selectedAvatar = 'lib/showcase_project/images/av8.png';

  // Add these variables to your state class
  List<String> userInterests = [];
  bool loadingInterests = true;
  // Add these variables to your state class
  List<dynamic> userAwards = [];
  bool loadingAwards = true;

  // Add this to your initStategrad
  @override
  void initState() {
    super.initState();
    _loadUserInterests();
    _loadUserAwards();
    _loadPersonalInfo();
    _loadUserECs(); // Add this line
    // _loadProfilePicture();
  }

  Future<void> deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    final passwordController = TextEditingController();

    // Show confirmation dialog with password field (for email/password users)
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color.fromARGB(255, 15, 57, 92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.providerData.any((p) => p.providerId == 'password')
                    ? 'Please enter your password to confirm. This will permanently delete your account and all your data.'
                    : 'Are you sure you want to permanently delete your account? This will remove all your data.',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              if (user.providerData.any((p) => p.providerId == 'password')) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color.fromARGB(50, 255, 255, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white, fontSize: 16),
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

    if (shouldDelete != true) return;

    try {
      // 1️⃣ Reauthenticate depending on provider
      final providerId = user.providerData[0].providerId;

      if (providerId == 'password') {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: passwordController.text.trim(),
        );
        await user.reauthenticateWithCredential(credential);
      } else if (providerId == 'google.com') {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null)
          throw FirebaseAuthException(
            code: 'cancelled',
            message: 'Google sign-in cancelled.',
          );
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (providerId == 'apple.com') {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email],
        );
        final credential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // 2️⃣ Delete Firestore data
      final uid = user.uid;

      // Delete messages subcollection
      final subcollectionRef = FirebaseFirestore.instance
          .collection("gradmate_chat")
          .doc("messages")
          .collection(uid);
      final snapshots = await subcollectionRef.get();
      for (final doc in snapshots.docs) {
        await doc.reference.delete();
      }

      // Delete other documents
      await FirebaseFirestore.instance
          .collection("profile")
          .doc(user.email)
          .delete();
      await FirebaseFirestore.instance
          .collection("recommendations")
          .doc(uid)
          .delete();
      await FirebaseFirestore.instance
          .collection("user_follows")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      await FirebaseFirestore.instance
          .collection("user_saved_scholarships")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      await FirebaseFirestore.instance
          .collection("sat")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      await FirebaseFirestore.instance
          .collection("wgpa")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      await FirebaseFirestore.instance
          .collection("uwgpa")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      await FirebaseFirestore.instance
          .collection("avatar")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      // 3️⃣ Delete FirebaseAuth user
      await user.delete();

      selectedPageNotifier.value = 0;

      // Navigate to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF006E)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Account deletion cancelled',
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

  Future<void> _loadUserECs() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("profile")
            .doc(user.email)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['extracurriculars'] != null &&
              data['extracurriculars'] is List) {
            setState(() {
              userECs = List<dynamic>.from(data['extracurriculars']);
              loadingECs = false;
            });
          }
        }
        final avatarData = await FirebaseFirestore.instance
            .collection("avatar")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        setState(() {
          if (avatarData.data() != null) {
            selectedAvatar = avatarData.data()!["image"];
          }
        });
      }
    } catch (e) {
      print("Error loading ECs: $e");
      setState(() {
        loadingECs = false;
      });
    }
  }

  Future<void> _loadPersonalInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("profile")
            .doc(user.email)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            userName = data['name']?.toString();
            userSchool = data['school']?.toString();
            userGrade = data['grade']?.toString();
            loadingPersonalInfo = false;
          });
        }
      }
    } catch (e) {
      print("Error loading personal info: $e");
      setState(() {
        loadingPersonalInfo = false;
      });
    }
  }

  Future<void> _loadUserInterests() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("profile")
            .doc(user.email)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['interests'] != null && data['interests'] is List) {
            setState(() {
              userInterests = List<String>.from(data['interests']);
              loadingInterests = false;
            });
          }
        }
      }
    } catch (e) {
      print("Error loading interests: $e");
      setState(() {
        loadingInterests = false;
      });
    }
  }

  Future<void> _loadUserAwards() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("profile")
            .doc(user.email)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['awards'] != null && data['awards'] is List) {
            setState(() {
              userAwards = List<dynamic>.from(data['awards']);
              loadingAwards = false;
            });
            return;
          }
          setState(() {
            userAwards = [];
            loadingAwards = false;
          });
        }
      }
    } catch (e) {
      print("Error loading awards: $e");
      setState(() {
        loadingAwards = false;
      });
    }
  }

  // Sample avatar options
  final List<String> avatarOptions = [
    'lib/showcase_project/images/av1.png',
    'lib/showcase_project/images/av2.png',
    'lib/showcase_project/images/av3.png',
    'lib/showcase_project/images/av4.png',
    'lib/showcase_project/images/av5.png',
    'lib/showcase_project/images/av6.png',
    'lib/showcase_project/images/av7.png',
    'lib/showcase_project/images/av8.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0C1425),

      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
          ),
        ),
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            if (state is ChangeAvatarState) {
              selectedAvatar = state.imageurl;
            }
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Text(
                        'Preferences',
                        style: GoogleFonts.michroma(
                          color: Colors.white,
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Profile Picture Section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 130.w,
                            height: 130.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.tealAccent,
                                width: 3.w,
                              ),
                              gradient: LinearGradient(
                                colors: [Color(0xff374b81), Color(0xff2a3b6b)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10.r,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                selectedAvatar,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                showImages = !showImages;
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.tealAccent,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 8.w,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              backgroundColor: Colors.teal.withOpacity(0.1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, size: 18.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'Edit Profile Picture',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar Selection Grid
                    if (showImages)
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(top: 20.w),
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.blueGrey.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Choose Avatar',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 15.h),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: avatarOptions.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectedAvatar = avatarOptions[index];
                                      BlocProvider.of<LoginBloc>(context).add(
                                        ChangeAvatarEvent(
                                          avatarurl: avatarOptions[index],
                                        ),
                                      );
                                    });
                                    await FirebaseFirestore.instance
                                        .collection("avatar")
                                        .doc(
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,
                                        )
                                        .set({"image": avatarOptions[index]});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            selectedAvatar ==
                                                avatarOptions[index]
                                            ? Colors.tealAccent
                                            : Colors.transparent,
                                        width: 3.w,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 30.r,
                                      backgroundImage: AssetImage(
                                        avatarOptions[index],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 30.h),

                    // Add these variables to your state class

                    // Add this to your initState

                    // Add this function to load personal info

                    // Replace your existing Personal Info section with this:
                    // Personal Info Section
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.blueGrey.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Personal Info',
                                style: GoogleFonts.michroma(
                                  fontSize: 24.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentForm2(),
                                    ),
                                  ).then((_) {
                                    // Reload personal info when returning from edit page
                                    _loadPersonalInfo();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.w,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, size: 16.sp),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'Edit',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          // Username Row
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Username:',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.6),
                                      width: 1.5.w,
                                    ),
                                  ),
                                  child: loadingPersonalInfo
                                      ? CircularProgressIndicator(
                                          color: Colors.blue,
                                          strokeWidth: 1.w,
                                        )
                                      : Text(
                                          userName ?? 'Not set',
                                          style: TextStyle(
                                            color: userName != null
                                                ? Colors.blue.shade200
                                                : Colors.white70,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // Grade Row
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Grade:',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.6),
                                      width: 1.5.w,
                                    ),
                                  ),
                                  child: loadingPersonalInfo
                                      ? CircularProgressIndicator(
                                          color: Colors.blue,
                                          strokeWidth: 2.w,
                                        )
                                      : Text(
                                          userGrade != null
                                              ? userGrade == "9"
                                                    ? "Freshman"
                                                    : userGrade == "10"
                                                    ? "Sophomore"
                                                    : userGrade == "11"
                                                    ? "Junior"
                                                    : userGrade == "12"
                                                    ? "Senior"
                                                    : "Grade $userGrade"
                                              : 'Not set',
                                          style: TextStyle(
                                            color: userGrade != null
                                                ? Colors.blue.shade200
                                                : Colors.white70,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // School Row
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'School:',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.6),
                                      width: 1.5.w,
                                    ),
                                  ),
                                  child: loadingPersonalInfo
                                      ? CircularProgressIndicator(
                                          color: Colors.blue,
                                          strokeWidth: 2.w,
                                        )
                                      : Text(
                                          userSchool ?? 'Not set',
                                          style: TextStyle(
                                            color: userSchool != null
                                                ? Colors.blue.shade200
                                                : Colors.white70,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Add this anywhere in your Settings page Column children
                    SizedBox(height: 30.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 15.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Interests',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10.h),

                          if (loadingInterests)
                            Center(
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            )
                          else if (userInterests.isEmpty)
                            Text(
                              'No interests selected yet',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14.sp,
                                color: Colors.white70,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: userInterests.map((interest) {
                                return Chip(
                                  label: Text(
                                    interest,
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue[700],
                                );
                              }).toList(),
                            ),

                          SizedBox(height: 15.h),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InterestsForm2(),
                                ),
                              ).then((_) {
                                // Reload interests when returning from the interests page
                                _loadUserInterests();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                12,
                                58,
                                104,
                              ),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 25.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Edit Interests',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 15.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Awards & Achievements',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10.h),

                          if (loadingAwards)
                            Center(
                              child: CircularProgressIndicator(
                                color: Colors.green,
                              ),
                            )
                          else if (userAwards.isEmpty)
                            Text(
                              'No awards added yet',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14.sp,
                                color: Colors.white70,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: userAwards.map((award) {
                                return Chip(
                                  label: Text(
                                    award.toString(),
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  backgroundColor: Colors.green[700],
                                );
                              }).toList(),
                            ),

                          SizedBox(height: 15.h),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AwardsWon2(),
                                ),
                              ).then((_) {
                                // Reload awards when returning from the awards page
                                _loadUserAwards();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                31,
                                82,
                                33,
                              ),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 25.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Edit Awards',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 15.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Extracurricular Activities',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10.h),

                          if (loadingECs)
                            Center(
                              child: CircularProgressIndicator(
                                color: Colors.purple,
                              ),
                            )
                          else if (userECs.isEmpty)
                            Text(
                              'No activities added yet',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14.sp,
                                color: Colors.white70,
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: userECs.map((ec) {
                                final activity = Map<String, String>.from(ec);
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '• ${activity["name"]}',
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (activity["description"]?.isNotEmpty ??
                                          false)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: 12.w,
                                            top: 2.h,
                                          ),
                                          child: Text(
                                            activity["description"]!,
                                            style: GoogleFonts.spaceGrotesk(
                                              color: Colors.white70,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                          SizedBox(height: 15.h),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExtracurricularsPage2(),
                                ),
                              ).then((_) {
                                // Reload ECs when returning from the ECs page
                                _loadUserECs();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                70,
                                19,
                                92,
                              ),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 25.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Edit Activities',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SizedBox(height: 30),
                    // Save Button
                    // Center(
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       // Save functionality
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.teal,
                    //       foregroundColor: Colors.white,
                    //       padding: EdgeInsets.symmetric(
                    //         horizontal: 40,
                    //         vertical: 16,
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(20),
                    //       ),
                    //       elevation: 5,
                    //     ),
                    //     child: Text(
                    //       'Save Changes',
                    //       style: GoogleFonts.spaceGrotesk(
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 30.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF2D2D44).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Color(0xFFFF5252).withOpacity(0.3),
                          width: 1.w,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Account Settings',
                                style: GoogleFonts.orbitron(
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5.w,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              // Logout Button
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFF5252).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Color(0xFFFF5252).withOpacity(0.4),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12.r),
                                      onTap: () async {
                                        final shouldLogout = await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: Color(0xFF2D2D44),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.logout_rounded,
                                                  color: Color(0xFFFF5252),
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  'Logout',
                                                  style: GoogleFonts.orbitron(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: Text(
                                              'Are you sure you want to logout?',
                                              style: GoogleFonts.spaceGrotesk(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: Text(
                                                  'Cancel',
                                                  style:
                                                      GoogleFonts.spaceGrotesk(
                                                        color: Colors.white70,
                                                      ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFF5252),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.r,
                                                      ),
                                                ),
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: Text(
                                                    'Logout',
                                                    style:
                                                        GoogleFonts.spaceGrotesk(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (shouldLogout == true) {
                                          await FirebaseAuth.instance.signOut();
                                          selectedPageNotifier.value = 0;
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14.h,
                                          horizontal: 16.w,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.logout_rounded,
                                              color: Color(0xFFFF5252),
                                              size: 18.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              'Logout',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14.sp,
                                                color: Color(0xFFFF5252),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 16.w),

                              // Delete Button
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFF9800).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Color(0xFFFF9800).withOpacity(0.4),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12.r),
                                      onTap: () async {
                                        final shouldDelete = await showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: Color(0xFF2D2D44),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete_forever_rounded,
                                                  color: Color(0xFFFF9800),
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  'Delete Account',
                                                  style: GoogleFonts.orbitron(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: Text(
                                              'This will permanently delete your account and all data.',
                                              style: GoogleFonts.spaceGrotesk(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: Text(
                                                  'Cancel',
                                                  style:
                                                      GoogleFonts.spaceGrotesk(
                                                        color: Colors.white70,
                                                      ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFFF9800),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.r,
                                                      ),
                                                ),
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: Text(
                                                    'Delete',
                                                    style:
                                                        GoogleFonts.spaceGrotesk(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (shouldDelete == true) {
                                          await deleteAccount(context);
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14.h,
                                          horizontal: 16.w,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete_forever_rounded,
                                              color: Color(0xFFFF9800),
                                              size: 18.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              'Delete',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14.sp,
                                                color: Color(0xFFFF9800),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
