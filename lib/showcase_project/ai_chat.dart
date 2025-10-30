import 'dart:convert';

import 'package:flutter_club/notifiers.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_club/showcase_project/bloc/login_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AIChat extends StatefulWidget {
  const AIChat({super.key});

  @override
  State<AIChat> createState() => _AIChatState();
}

class _AIChatState extends State<AIChat> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showTip = false;
  List<DocumentSnapshot>? _cachedMessages;

  // Colors
  static const _primaryColor = Color.fromRGBO(88, 75, 245, 1);
  static const _accentColor = Color.fromRGBO(118, 251, 166, 1);
  static const _backgroundColor = Color(0xFF1B1B1B);
  static const _secondaryBackground = Color(0xFF003153);
  static const _errorColor = Color(0xFFFF006E);
  static const _cardColor = Color(0xFF1A1A2E);

  // Text Styles
  TextStyle get _headerTextStyle =>
      GoogleFonts.michroma(fontSize: 20.sp, fontWeight: FontWeight.w900);

  TextStyle get _bodyTextStyle => GoogleFonts.spaceGrotesk(fontSize: 14.sp);

  TextStyle get _captionTextStyle =>
      GoogleFonts.spaceGrotesk(fontSize: 12.sp, color: Colors.white70);

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    FocusScope.of(context).unfocus();

    if (text.isEmpty || text.length <= 5) {
      _showErrorSnackBar('Text must be more than 5 characters');
      return;
    }

    try {
      final profile_data = await FirebaseFirestore.instance
          .collection("profile")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .get();
      final profile_data2 = profile_data.data();
      if (profile_data2 != null) {
        await FirebaseFirestore.instance
            .collection("gradmate_chat")
            .doc("messages")
            .collection(FirebaseAuth.instance.currentUser!.uid)
            .add({
              "text": text,
              "sender": "user",
              "timestamp": FieldValue.serverTimestamp(),
            });
      }
      // Add loading message immediately
      final loadingDoc = await _addLoadingMessage();

      _scrollToBottom();

      final response = await _makeApiCall(text, profile_data2 ?? {});
      final reply = _parseApiResponse(response);

      // Replace loading message with actual response
      await _updateMessageWithReply(loadingDoc.id, reply);

      _scrollToBottom();
    } catch (e) {
      debugPrint("Error sending message: $e");
      _showErrorSnackBar('Failed to send message. Please try again.');
    }
  }

  Future<Map<String, dynamic>?> _getUserProfileData() async {
    try {
      final profileDoc = await FirebaseFirestore.instance
          .collection("profile")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .get();
      return profileDoc.data();
    } catch (e) {
      debugPrint("Error fetching profile data: $e");
      return null;
    }
  }

  Future<DocumentReference> _addLoadingMessage() {
    return FirebaseFirestore.instance
        .collection("gradmate_chat")
        .doc("messages")
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .add({
          "text": "loading",
          "sender": "ai",
          "timestamp": FieldValue.serverTimestamp(),
        });
  }

  Future<void> _updateMessageWithReply(String docId, String reply) {
    return FirebaseFirestore.instance
        .collection("gradmate_chat")
        .doc("messages")
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .doc(docId)
        .update({"text": reply, "timestamp": FieldValue.serverTimestamp()});
  }

  Future<Map<String, dynamic>?> _getCollegeInfo(String? name) async {
    if (name == null) return null;

    try {
      final collegeDoc = await FirebaseFirestore.instance
          .collection("colleges")
          .doc(name)
          .get();
      return collegeDoc.data();
    } catch (e) {
      debugPrint("Error fetching college data: $e");
      return null;
    }
  }

  Future<http.Response> _makeApiCall(
    String text,
    Map<String, dynamic> profileData,
  ) async {
    final url = Uri.parse(
      "https://levelup-collegeprep-gradmate-ai-chatbot.onrender.com/",
    );

    final collegeData = await _getCollegeInfo(collegeNameNotiifer.value);
    final hasCollegeData =
        collegeNameNotiifer.value != null &&
        collegeNameNotiifer.value!.isNotEmpty &&
        collegeData != null;

    final userMessage = _buildUserMessage(text, profileData, collegeData);

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_response": userMessage,
        "email": FirebaseAuth.instance.currentUser!.email,
      }),
    );
  }

  String _buildUserMessage(
    String text,
    Map<String, dynamic> profileData,
    Map<String, dynamic>? collegeData,
  ) {
    final baseMessage =
        """
I'm a ${profileData["grade"]} in high school, 
with a GPA of ${profileData["gpaUW"] ?? "Unweighted not provided"} 
and weighted of ${profileData["gpaW"] ?? "Weighted not provided"}. 
I'm taking these courses: ${profileData["courses"]}. 
I'm interested in these majors: ${profileData["interests"]}. 
These are my awards: ${profileData["awards"]} 
and here are my extracurriculars: ${profileData["extracurriculars"]}. 
Here's my SAT/ACT Scores: 
SAT Math: ${profileData["SatM"]}, 
SAT Reading and Writing: ${profileData["SatR"]}, 
ACT Math: ${profileData["actM"]}, 
ACT Science: ${profileData["actS"]}, 
ACT Reading: ${profileData["actR"]}, 
ACT English: ${profileData["actE"]}. 
Here's what I want to say: $text
""";

    if (collegeData != null) {
      final collegeInfo = collegeData.entries
          .map((e) => "${e.key}: ${e.value}")
          .join(", ");

      return "The user wants to ask a question about this specific college: $collegeInfo. $baseMessage";
    }

    return baseMessage;
  }

  String _parseApiResponse(http.Response response) {
    final data = jsonDecode(response.body);
    return data["reply"];
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _errorColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: _captionTextStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _cardColor,
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: BorderSide(color: _errorColor, width: 1.5),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text("Grad", style: _headerTextStyle.copyWith(color: _accentColor)),
            Text(
              "Mate",
              style: _headerTextStyle.copyWith(color: _primaryColor),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 35.r,
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Image.asset(
              "lib/showcase_project/images/robot-image.png",
              height: 70.h,
            ),
          ),
        ),
      ],
    );
  }

  // Optional: Add this for extra tech vibe in the background
  Widget _buildTechBackground() {
    return Stack(
      children: [
        // Circuit pattern overlay
        Positioned(
          top: 50.h,
          right: 20.w,
          child: Container(
            width: 4.w,
            height: 4.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF00D4FF).withOpacity(0.6),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00D4FF).withOpacity(0.8),
                  blurRadius: 8.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollegeIndicator() {
    return ValueListenableBuilder<String?>(
      valueListenable: collegeNameNotiifer,
      builder: (context, collegeName, child) {
        if (collegeName == null || collegeName.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: _primaryColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "College: ",
                style: _captionTextStyle.copyWith(fontWeight: FontWeight.w600),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 120.w),
                child: Text(
                  collegeName.length > 20
                      ? '${collegeName.substring(0, 20)}...'
                      : collegeName,
                  style: _captionTextStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => collegeNameNotiifer.value = null,
                child: Icon(Icons.close, size: 16.sp, color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final sender = msg["sender"];
    final text = msg["text"] ?? "";
    final isUser = sender == "user";

    if (isUser) {
      return _buildUserMessageBubble(text);
    } else {
      return _buildAiMessageBubble(msg, text);
    }
  }

  Widget _buildUserMessageBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 8.w),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
        constraints: BoxConstraints(maxWidth: 280.w),
        decoration: BoxDecoration(
          color: _primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Text(text, style: _bodyTextStyle.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildAiMessageBubble(Map<String, dynamic> msg, String text) {
    if (text == "loading") {
      return _buildLoadingIndicator();
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 3.w, horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: _accentColor,
          ),
          child: Html(data: msg["text"], style: _getHtmlStyles()),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(left: 20.w, top: 5.h, bottom: 5.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _accentColor.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: 80.w, // Constrain the width
        ),
        child: SizedBox(
          width: 24.w, // Fixed width for the spinner
          height: 24.h, // Fixed height for the spinner
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 3.w,
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            backgroundColor: _accentColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Map<String, Style> _getHtmlStyles() {
    return {
      "div": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
      ".profile-card": Style(
        backgroundColor: _accentColor,
        padding: HtmlPaddings.all(12.w),
        margin: Margins.only(bottom: 8.h),
        fontSize: FontSize(14.sp),
        color: Colors.black,
        fontFamily: 'sans-serif',
      ),
      "h3": Style(
        margin: Margins.only(top: 0, bottom: 6.h),
        color: _primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: FontSize(16.sp),
      ),
      "p": Style(
        margin: Margins.symmetric(vertical: 4.h),
        fontSize: FontSize(13.sp),
      ),
      "ul": Style(
        padding: HtmlPaddings.only(left: 16.w),
        margin: Margins.all(0),
      ),
      "li": Style(
        margin: Margins.only(bottom: 4.h),
        fontSize: FontSize(13.sp),
      ),
    };
  }

  Widget _buildInputSection() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is ShowTipState) {
          _showTip = state.showTip;
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showTip) _buildTipText(),
              !_showTip ? SizedBox(height: 20.h) : const SizedBox.shrink(),
              _buildInputRow(),
              _buildDisclaimer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: Text(
        "GradMate already knows your GPA, awards, extracurriculars, and intended majors — no need to provide them!",
        style: _captionTextStyle,
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            cursorHeight: 18.h,
            style: _bodyTextStyle.copyWith(fontSize: 15.sp),
            maxLines: null,
            controller: _textController,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              fillColor: Colors.indigo,
              hintText: "Ask GradMate anything about your college journey…",
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 10.w,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: const BorderSide(color: Colors.indigo),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: _accentColor),
              ),
            ),
          ),
        ),
        Column(
          children: [
            IconButton(
              splashColor: _primaryColor,
              onPressed: () async {
                final text = _textController.text;
                _textController.clear();
                await _sendMessage(text);
              },
              icon: Icon(Icons.send, size: 20.sp, color: Colors.white),
            ),
            GestureDetector(
              onTap: () {
                BlocProvider.of<LoginBloc>(
                  context,
                ).add(ShowTipEvent(showTip: _showTip));
              },
              child: Icon(
                _showTip
                    ? CupertinoIcons.info_circle_fill
                    : CupertinoIcons.info_circle,
                color: Colors.white70,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Padding(
      padding: EdgeInsets.only(top: 10.w, right: 5.h, left: 10.w, bottom: 10.h),
      child: Text(
        "GradMate can make mistakes — always double-check advice.",
        style: _captionTextStyle.copyWith(
          fontSize: 11.sp,
          color: Colors.white54,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_backgroundColor, _secondaryBackground],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15.w),
                    child: _buildHeader(),
                  ),
                  SizedBox(height: 20.h),

                  // Messages Stream
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("gradmate_chat")
                          .doc("messages")
                          .collection(FirebaseAuth.instance.currentUser!.uid)
                          .orderBy("timestamp", descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _cachedMessages = snapshot.data!.docs;
                        }

                        if (_cachedMessages != null &&
                            _cachedMessages!.isNotEmpty) {
                          return ListView.builder(
                            padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                            controller: _scrollController,
                            itemCount: _cachedMessages!.length,
                            itemBuilder: (context, index) {
                              final msg =
                                  _cachedMessages![index].data()
                                      as Map<String, dynamic>;
                              return _buildMessageBubble(msg);
                            },
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }

                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.w),
                            child: Text(
                              "Got questions about college? Go ahead and ask!",
                              textAlign: TextAlign.center,
                              style: _bodyTextStyle.copyWith(
                                fontSize: 20.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 15.h),
                  _buildCollegeIndicator(),
                  _buildInputSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
