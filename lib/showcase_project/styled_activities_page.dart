import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_club/showcase_project/circularprogressindicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ==============================
// CONSTANTS & THEME
// ==============================

String? _dialogCategory;
String _dialogLevel = 'B';

class AppColors {
  static const Color primary = Color(0xFF0C1425);
  static const Color secondary = Color(0xFF1E293B);
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color cardBackground = Color(0xFF1E293B);
  static const Color inputBackground = Color(0x103B82F6);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C1425), Color(0xFF1E293B), Color(0xFF0F172A)],
    stops: [0.0, 0.6, 1.0],
  );
}

class AppTextStyles {
  static TextStyle headlineLarge(BuildContext context) =>
      GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle headlineMedium(BuildContext context) =>
      GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle titleLarge(BuildContext context) => GoogleFonts.spaceGrotesk(
    color: AppColors.textPrimary,
    fontSize: 21.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.spaceGrotesk(
    color: AppColors.textPrimary,
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyMedium(BuildContext context) =>
      GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontSize: 16.sp);

  static TextStyle bodySmall(BuildContext context) =>
      GoogleFonts.spaceGrotesk(color: AppColors.textSecondary, fontSize: 14.sp);

  static TextStyle numberLarge(BuildContext context) =>
      GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontSize: 42.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: -1.0,
      );
}

// ==============================
// CUSTOM WIDGETS
// ==============================

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;
  final bool hasBorder;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.glowColor,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: hasBorder
            ? Border.all(
                color: (glowColor ?? AppColors.accent).withOpacity(0.3),
                width: 1.5,
              )
            : null,
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground,
            AppColors.cardBackground.withOpacity(0.9),
          ],
        ),
      ),
      child: child,
    );
  }
}

class AnimatedScoreDisplay extends StatelessWidget {
  final double score;
  final String label;
  final Color color;

  const AnimatedScoreDisplay({
    super.key,
    required this.score,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: score),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Column(
          children: [
            Text(
              value.toStringAsFixed(1),
              style: AppTextStyles.numberLarge(context).copyWith(
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ).createShader(Rect.fromLTWH(0, 0, 100, 100)),
              ),
            ),
            SizedBox(height: 4.h),
            Text(label, style: AppTextStyles.bodySmall(context)),
          ],
        );
      },
    );
  }
}

// ==============================
// INFO DIALOGS CONTENT
// ==============================

class InfoContent {
  static const String howItWorks = '''
🎯 Scoring System:

📊 EC Activities (45 pts):
• Weighted by level: F=1, C=3, B=8, A=12, S=16
• Bonus points for exceptional performance

🎓 GPA (20 pts):
• Uses UW & Weighted GPA (4.0 scale)
• Exponential scaling favors higher GPAs

📝 SAT (25 pts):
• 400-1600 scale with exponential scaling

💡 Final Score:
• EC(45) + GPA(20) + SAT(25) = 90 pts
• Converted to 100-point scale
''';

  static const String activityLevels = '''
🏆 Activity Tiers:

S (16 pts): National recognition, leadership, major impact
A (12 pts): State level, significant achievements  
B (8 pts): School level, consistent involvement
C (3 pts): Regular participation
F (1 pt): Casual involvement

💡 Quality over quantity!
''';

  static const String categoryInfo = '''
📁 EC Categories:

• Passion Projects (20%)
• Research (12%)
• Competitions (10%)
• Internships (10%)
• Organizations (10%)
• Sports (10%)
• Clubs (10%)
• Employment (8%)
• Summer Programs (5%)
• Volunteering (5%)
''';
}

// ==============================
// WIDGETS
// ==============================

class StatsPage extends StatelessWidget {
  final Map<String, dynamic> result;
  const StatsPage({super.key, required this.result});

  @override
  @override
  Widget build(BuildContext context) {
    final perCat = result['perCategory'] as Map<String, double>? ?? {};

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            _buildAppBar(context),
            SizedBox(height: 20.h),
            _buildHeader(context, 'EC Stats'),
            SizedBox(height: 20.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: _buildStatsContent(context, perCat),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
        ),
      ),
      child: AppBar(
        // backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Statistics', style: AppTextStyles.headlineMedium(context)),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 24.w,
            ),
            onPressed: () => _showVisualInfoDialog(context),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  void _showVisualInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Header
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28.r),
                    topRight: Radius.circular(28.r),
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 28.w,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SCORE BREAKDOWN',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'How your score is calculated',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Interactive Score Visualization
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    _buildScoreMeter(
                      context,
                      'EC Activities',
                      45,
                      Colors.purpleAccent,
                    ),
                    SizedBox(height: 16.h),
                    _buildScoreMeter(context, 'GPA', 20, Colors.greenAccent),
                    SizedBox(height: 16.h),
                    _buildScoreMeter(context, 'SAT', 25, Colors.orangeAccent),

                    SizedBox(height: 24.h),

                    // Total Score Visualization
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.1),
                            Colors.purpleAccent.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL SCORE',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '90 → 100',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Points converted to final score',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.purpleAccent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '→',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Close with Style
              Container(
                padding: EdgeInsets.all(20.w),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 16.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 8,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rocket_launch_rounded, size: 20.w),
                      SizedBox(width: 8.w),
                      Text(
                        'GOT IT!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreMeter(
    BuildContext context,
    String title,
    int points,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded, color: color, size: 20.w),
          ),

          SizedBox(width: 16.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$points points',
                  style: TextStyle(
                    color: color,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Points Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              '$points',
              style: TextStyle(
                color: color,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text(
        title,
        style: AppTextStyles.headlineLarge(context),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, Map<String, double> perCat) {
    return Column(
      children: [
        GradientCard(
          glowColor: AppColors.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildScoreCircle(context, result['ec_final'] ?? 0.0),
              SizedBox(height: 20.h),
              _buildStatItem(context, 'Category Contributions:', isTitle: true),
              SizedBox(height: 16.h),
              ...perCat.entries.map(
                (e) => _buildCategoryItem(context, e.key, e.value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCircle(BuildContext context, double score) {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toStringAsFixed(1),
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '/ 45',
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String text, {
    bool isTitle = false,
  }) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        color: Colors.white,
        fontSize: isTitle ? 18.sp : 16.sp,
        fontWeight: isTitle ? FontWeight.w600 : FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String category,
    double value,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              category,
              style: AppTextStyles.bodyMedium(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Text(
              value.toStringAsFixed(2),
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w600, color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================
// MAIN ACTIVITIES PAGE
// ==============================

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  // ==============================
  // CONSTANTS & CONFIGURATION
  // ==============================

  Widget _buildPulseDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
            ),
          ),
        );
      },
    );
  }

  bool isLoading = true;
  static const double ecMax = 45.0;
  static const double alpha = 0.03;
  static const double fluidityCap = 0.10;

  void initState() {
    super.initState();

    initialize_vars();
  }

  initialize_vars() async {
    final satData = await FirebaseFirestore.instance
        .collection("sat")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    satScore = satData.data()?["sat"] ?? 0;

    final uwgpadata = await FirebaseFirestore.instance
        .collection("uwgpa")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    uwGPA = uwgpadata.data()?["uwgpa"] ?? 0;

    final gpadata = await FirebaseFirestore.instance
        .collection("wgpa")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    wGPA = gpadata.data()?["wgpa"] ?? 0;

    final eclistdata = await FirebaseFirestore.instance
        .collection("eclist")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final dynamic rawActivities = eclistdata.data()?["eclist"];
    if (rawActivities is List) {
      activities = List<Map<String, dynamic>>.from(
        rawActivities.map(
          (item) => item is Map ? Map<String, dynamic>.from(item) : {},
        ),
      );
    } else {
      activities = [];
    }
    uwGPAController = TextEditingController(text: uwGPA.toString());
    wGPAController = TextEditingController(text: wGPA.toString());
    satController = TextEditingController(text: satScore.toString());
    setState(() {
      isLoading = false;
    });
  }

  final Map<String, int> activityWeight = {
    'F': 1,
    'C': 3,
    'B': 8,
    'A': 12,
    'S': 16,
  };

  final Map<int, double> tierFraction = {
    1: 0.2,
    2: 0.4,
    3: 0.6,
    4: 0.8,
    5: 1.0,
  };

  final Map<String, double> categoryBasePct = {
    'Passion Projects': 20,
    'Organizations': 10,
    'Employment': 8,
    'Competitions': 10,
    'Research': 12,
    'Summer Programs': 5,
    'Internships': 10,
    'Volunteering': 5,
    'Sports': 10,
    'Clubs': 10,
  };

  final List<String> ecCategories = [
    'Passion Projects',
    'Organizations',
    'Employment',
    'Competitions',
    'Research',
    'Summer Programs',
    'Internships',
    'Volunteering',
    'Sports',
    'Clubs',
  ];

  // ==============================
  // STATE MANAGEMENT
  // ==============================
  List<Map<String, dynamic>> activities = [];
  final TextEditingController nameController = TextEditingController();

  String? selectedCategory;
  String selectedLevel = 'B';

  // Academic data
  double uwGPA = 0.0;
  double wGPA = 0.0;
  int satScore = 0;

  late TextEditingController uwGPAController;
  late TextEditingController wGPAController;
  late TextEditingController satController;

  // TextEditingController get uwGPAController =>
  //     TextEditingController(text: uwGPA.toString());
  // TextEditingController get wGPAController =>
  //     TextEditingController(text: wGPA.toString());
  // TextEditingController get satController =>
  //     TextEditingController(text: satScore.toString());
  // TextEditingController uwGPAController = TextEditingController(
  //   text: "13".toString(),
  // );
  // TextEditingController wGPAController = TextEditingController();
  // TextEditingController satController = TextEditingController();

  // ==============================
  // BUSINESS LOGIC (UNCHANGED)
  // ==============================

  int tierFromSum(int sum) {
    if (sum >= 24) return 5;
    if (sum >= 15) return 4;
    if (sum >= 12) return 3;
    if (sum >= 7) return 2;
    return 1;
  }

  void _saveAllData() async {
    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please sign in to save data'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.blueAccent.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Animated loading icon
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blueAccent.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blueAccent,
                            ),
                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.blueAccent,
                          size: 12.w,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saving Data',
                        style: GoogleFonts.orbitron(
                          color: Colors.blueAccent,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Uploading to cloud storage...',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white70,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Pulse animation dots
                // Row(
                //   children: [
                //     _buildPulseDot(0),
                //     SizedBox(width: 4.w),
                //     _buildPulseDot(1),
                //     SizedBox(width: 4.w),
                //     _buildPulseDot(2),
                //   ],
                // ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(16.w),
        ),
      );

      // Save all data to Firestore
      await Future.wait([
        // Save SAT score
        FirebaseFirestore.instance.collection("sat").doc(user.uid).set({
          "sat": satScore,
        }),

        // Save UW GPA
        FirebaseFirestore.instance.collection("uwgpa").doc(user.uid).set({
          "uwgpa": uwGPA,
        }),

        // Save Weighted GPA
        FirebaseFirestore.instance.collection("wgpa").doc(user.uid).set({
          "wgpa": wGPA,
        }),

        // Save activities list
        FirebaseFirestore.instance.collection("eclist").doc(user.uid).set({
          "eclist": activities,
        }),
      ]);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF00FF88)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'All data saved successfully!',
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
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.red),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Failed to save data: $e',
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
            side: BorderSide(color: Colors.red, width: 1.5),
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Map<String, int> sumWeightsPerCategory() {
    final Map<String, int> sums = {for (var c in ecCategories) c: 0};
    for (final activity in activities) {
      final cat = activity['ecCategory'] as String;
      final level = activity['activityLevel'] as String? ?? 'B';
      final weight = activityWeight[level] ?? 0;
      sums[cat] = sums[cat]! + weight;
    }
    return sums;
  }

  Map<String, dynamic> computeContributions() {
    final sums = sumWeightsPerCategory();
    final Map<String, int> tiers = {};
    final Map<String, double> baseContrib = {};
    final Map<String, double> bonus = {};
    final Map<String, double> totalContrib = {};
    double grandTotal = 0.0;

    for (final category in ecCategories) {
      final int sum = sums[category] ?? 0;
      final int tier = (sum > 0) ? tierFromSum(sum) : 0;
      tiers[category] = tier;

      final double catMaxPoints = (categoryBasePct[category]! / 100.0) * ecMax;
      final double base = tier == 0
          ? 0.0
          : catMaxPoints * (tierFraction[tier] ?? 0.0);

      final int tierAboveBaseline = max(0, tier - 3);
      double bonusValue = 0.0;
      if (tierAboveBaseline > 0) {
        bonusValue = base * min(alpha * tierAboveBaseline, fluidityCap);
      }
      bonusValue = max(0.0, bonusValue);

      final double total = base + bonusValue;

      baseContrib[category] = base;
      bonus[category] = bonusValue;
      totalContrib[category] = total;
      grandTotal += total;
    }

    grandTotal = grandTotal.clamp(0.0, ecMax);

    return {
      'sums': sums,
      'tiers': tiers,
      'base': baseContrib,
      'bonus': bonus,
      'totalPerCategory': totalContrib,
      'totalEC': grandTotal,
    };
  }

  Map<String, double> computeGpaSatPoints(
    double uwGPA,
    double wGPA,
    double satScore,
  ) {
    const double gamma = 1.5;
    double avgGPA = (uwGPA + wGPA) / 2.0;

    double gpaPoints = 20 * pow(avgGPA / 4.0, gamma).toDouble();
    double satPoints =
        25 * pow((satScore.clamp(400, 1600)) / 1600, gamma).toDouble();

    return {'GPA': gpaPoints.clamp(0, 20), 'SAT': satPoints.clamp(0, 25)};
  }

  void _resetAllData() async {
    setState(() {
      activities.clear();
      nameController.clear();
      uwGPAController.clear();
      wGPAController.clear();
      satController.clear();
      selectedCategory = null;
      selectedLevel = 'B';
      uwGPA = 0.0;
      wGPA = 0.0;
      satScore = 0;
    });

    await FirebaseFirestore.instance
        .collection("sat")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();

    await FirebaseFirestore.instance
        .collection("uwgpa")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();

    await FirebaseFirestore.instance
        .collection("wgpa")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
    await FirebaseFirestore.instance
        .collection("eclist")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF00FF88)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                "All data has been reset!",
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

  // ==============================
  // UI COMPONENTS
  // ==============================

  @override
  Widget build(BuildContext context) {
    final breakdown = computeContributions();
    final totalPerCategory = Map<String, double>.from(
      breakdown['totalPerCategory'] as Map<String, double>,
    );
    final double totalEC = (breakdown['totalEC'] as double?) ?? 0.0;

    final gpaSatPoints = computeGpaSatPoints(uwGPA, wGPA, satScore.toDouble());
    final double gpaPts = gpaSatPoints['GPA'] ?? 0.0;
    final double satPts = gpaSatPoints['SAT'] ?? 0.0;

    final double totalScore = totalEC + satPts + gpaPts;
    final double finalScore = (totalScore / 90.0) * 100.0;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isLoading
          ? SizedBox.shrink()
          : Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.lightBlueAccent,
                    Color(0xFF00C2FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 3,
                    offset: Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: FloatingActionButton(
                onPressed: _saveAllData,
                backgroundColor: Colors.transparent,
                elevation: 0,
                splashColor: Colors.white.withOpacity(0.2),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Icon(Icons.save, color: Colors.white, size: 28.w),
                ),
              ),
            ),
      body: isLoading
          ? TechyLoadingScreen()
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.backgroundGradient,
                  ),
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            children: [
                              _buildScoreOverview(
                                finalScore,
                                totalEC,
                                gpaPts,
                                satPts,
                              ),
                              SizedBox(height: 20.h),
                              _buildGpaSatCard(context),
                              SizedBox(height: 16.h),
                              _buildActivitiesCard(context),
                              SizedBox(height: 16.h),
                              if (activities.isNotEmpty)
                                _buildActivitiesListCard(context),
                              SizedBox(height: 20.h),
                              _buildBreakdownCard(
                                context,
                                totalPerCategory,
                                totalEC,
                              ),
                              SizedBox(height: 16.h),
                            ],
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'EC & Academic Scorer',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium(
              context,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          // REMOVED the save button from here
          IconButton(
            icon: Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
              size: 24.w,
            ),
            onPressed: () => _showCleanInfoDialog(context),
            tooltip: 'How it works',
          ),
          SizedBox(width: 4.w),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 24.w),
            tooltip: 'Reset All',
            onPressed: _resetAllData,
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  void _showCleanInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Center(
                  child: Text(
                    'QUICK GUIDE',
                    style: AppTextStyles.titleLarge(context).copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildGuideItem(
                      context,
                      '1. Add Activities',
                      'Categorize by type and tier (S/A/B/C/F)',
                    ),
                    SizedBox(height: 12.h),
                    _buildGuideItem(
                      context,
                      '2. Enter Academics',
                      'Provide GPA and SAT scores',
                    ),
                    SizedBox(height: 12.h),
                    _buildGuideItem(
                      context,
                      '3. Get Your Score',
                      'See your 0-100 competitiveness score',
                    ),
                    SizedBox(height: 16.h),

                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'SCORING BREAKDOWN',
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniScore(
                                'EC',
                                '45',
                                AppColors.accentPurple,
                              ),
                              _buildMiniScore(
                                'GPA',
                                '20',
                                AppColors.accentGreen,
                              ),
                              _buildMiniScore(
                                'SAT',
                                '25',
                                AppColors.accentOrange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Close
              Container(
                padding: EdgeInsets.all(16.w),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('GOT IT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem(BuildContext context, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.accent,
              size: 18.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniScore(String label, String points, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            points,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _buildScoreOverview(
    double finalScore,
    double totalEC,
    double gpaPts,
    double satPts,
  ) {
    Color scoreColor = finalScore >= 85
        ? AppColors
              .accentGreen // Fixed typo: was 'accentGreen'
        : finalScore >= 70
        ? AppColors.accent
        : finalScore >= 50
        ? AppColors.accentOrange
        : Colors.red;

    return GradientCard(
      glowColor: scoreColor,
      child: Column(
        children: [
          Text(
            'Overall Score',
            style: AppTextStyles.titleLarge(
              context,
            ).copyWith(color: scoreColor),
          ),
          SizedBox(height: 16.h),
          AnimatedScoreDisplay(
            score: finalScore,
            label: 'out of 100',
            color: scoreColor,
          ),
          SizedBox(height: 16.h),
          _buildScoreInterpretation(finalScore, scoreColor),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniScore2('EC', totalEC, 45, AppColors.accentPurple),
              _buildMiniScore2(
                'GPA',
                gpaPts,
                20,
                AppColors.accentGreen,
              ), // Fixed typo
              _buildMiniScore2('SAT', satPts, 25, AppColors.accentOrange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniScore2(String label, double score, double max, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            score.toStringAsFixed(1),
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 4.h),
        Text(label, style: AppTextStyles.bodySmall(context)),
        Text(
          '/$max',
          style: AppTextStyles.bodySmall(
            context,
          ).copyWith(color: AppColors.textSecondary, fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _buildGpaSatCard(BuildContext context) {
    return GradientCard(
      child: Column(
        children: [
          _buildSectionTitleWithInfo(
            context,
            'Academic Scores',
            InfoContent.howItWorks,
          ),
          SizedBox(height: 20.h),
          _buildGpaInputs(context),
          SizedBox(height: 20.h),
          _buildSatInput(context),
        ],
      ),
    );
  }

  Widget _buildGpaInputs(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInputLabel(context, 'UW GPA:'),
            _buildEnhancedNumberInput(
              uwGPAController,
              (v) {
                setState(() {
                  uwGPA = double.tryParse(v) ?? 0.0;
                });
                // Removed the Firebase save call
              },
              hintText: '0.0 - 4.0',
              width: 120.w,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInputLabel(context, 'W GPA:'),
            _buildEnhancedNumberInput(
              wGPAController,
              (v) {
                setState(() {
                  wGPA = double.tryParse(v) ?? 0.0;
                });
                // Removed the Firebase save call
              },
              hintText: '0.0 - 5.0',
              width: 120.w,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'Enter GPA on 4.0 scale',
          style: AppTextStyles.bodySmall(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSatInput(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInputLabel(context, 'SAT Score:'),
            _buildEnhancedNumberInput(
              satController,
              (v) {
                setState(() {
                  satScore = int.tryParse(v) ?? 0;
                });
                // Removed the Firebase save call
              },
              hintText: '400 - 1600',
              width: 140.w,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'SAT Score Range: 400 - 1600',
          style: AppTextStyles.bodySmall(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEnhancedNumberInput(
    TextEditingController controller,
    Function(String) onChanged, { // Keep this for UI updates only
    required String hintText,
    required double width,
  }) {
    return SizedBox(
      height: 50.h,
      width: width,
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.6),
            fontSize: 12.sp,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 12.w,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(16.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent, width: 2),
            borderRadius: BorderRadius.circular(16.r),
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInputLabel(BuildContext context, String text) {
    return Text(
      text,
      style: AppTextStyles.bodyLarge(
        context,
      ).copyWith(fontWeight: FontWeight.w500),
    );
  }

  Widget _buildActivitiesCard(BuildContext context) {
    return GradientCard(
      child: Column(
        children: [
          _buildSectionTitleWithInfo(
            context,
            'Extracurricular Activities',
            InfoContent.activityLevels,
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: () => _openAddDialog(),
            icon: Icon(Icons.add_rounded, color: Colors.white, size: 20.w),
            label: Text(
              'Add Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 2,
              shadowColor: AppColors.accent.withOpacity(0.3),
            ),
          ),
          if (activities.isEmpty) ...[
            SizedBox(height: 20.h),
            Icon(
              Icons.emoji_objects_outlined,
              size: 40.w,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8.h),
            Text(
              'Add your first activity to get started!',
              style: AppTextStyles.bodySmall(
                context,
              ).copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(
    BuildContext context,
    Map<String, double> totalPerCategory,
    double totalEC,
  ) {
    return GradientCard(
      child: Column(
        children: [
          _buildSectionTitleWithInfo(
            context,
            'EC Breakdown',
            InfoContent.categoryInfo,
          ),
          SizedBox(height: 16.h),
          ...ecCategories.map(
            (category) => _buildBreakdownRow(
              context,
              category,
              totalPerCategory[category] ?? 0.0,
            ),
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.white54, height: 1.h),
          SizedBox(height: 12.h),
          _buildTotalRow(
            context,
            'Total ECs',
            '${totalEC.toStringAsFixed(2)} / 45',
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesListCard(BuildContext context) {
    return GradientCard(
      child: Column(
        children: [
          _buildSectionTitle(context, 'Your Activities (${activities.length})'),
          SizedBox(height: 16.h),
          ...activities.asMap().entries.map(
            (entry) => _buildActivityItem(context, entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.titleLarge(context),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSectionTitleWithInfo(
    BuildContext context,
    String title,
    String infoContent,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(title, style: AppTextStyles.titleLarge(context))],
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    double value, {
    String suffix = ' pts', // Add suffix parameter with default value
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium(context)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Text(
              '${value.toStringAsFixed(2)}$suffix', // Use the suffix here
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w600, color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyLarge(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge(
            context,
          ).copyWith(fontWeight: FontWeight.bold, color: AppColors.accent),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    int index,
    Map<String, dynamic> activity,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activity['name'] ?? '',
                  style: AppTextStyles.bodyLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_rounded,
                      color: AppColors.accent,
                      size: 20.w,
                    ),
                    onPressed: () => _openAddDialog(editIndex: index),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_rounded,
                      color: Colors.redAccent,
                      size: 20.w,
                    ),
                    onPressed: () => _deleteActivity(index),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  activity['ecCategory'] ?? '',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Level: ${activity['activityLevel']}',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.accentPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInterpretation(double score, Color color) {
    String interpretation = '';
    if (score >= 85)
      interpretation = '🎯 Excellent - Highly competitive profile';
    else if (score >= 70)
      interpretation = '📈 Strong - Good chances of admission';
    else if (score >= 50)
      interpretation = '📊 Average - Room for improvement';
    else
      interpretation = '💪 Needs work - Focus on key areas';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        interpretation,
        style: AppTextStyles.bodyMedium(
          context,
        ).copyWith(color: color, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ==============================
  // DIALOG MANAGEMENT
  // ==============================

  void _openAddDialog({int? editIndex}) {
    String? dialogCategory = editIndex != null
        ? activities[editIndex]['ecCategory'] as String?
        : null;
    String dialogLevel = editIndex != null
        ? (activities[editIndex]['activityLevel'] as String? ?? 'B')
        : 'B';
    nameController.text = editIndex != null
        ? activities[editIndex]['name'] as String? ?? ''
        : '';

    showDialog(
      context: context,
      builder: (_) =>
          _buildActivityDialog(editIndex, dialogCategory, dialogLevel),
    );
  }

  Widget _buildActivityDialog(int? editIndex, String? category, String level) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: GradientCard(
        padding: EdgeInsets.all(24.w),
        hasBorder: true,
        child: SingleChildScrollView(
          child: _buildDialogContent(editIndex, category, level),
        ),
      ),
    );
  }

  Widget _buildDialogContent(int? editIndex, String? category, String level) {
    return StatefulBuilder(
      builder: (context, setStateDialog) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              editIndex == null ? 'Add Activity' : 'Edit Activity',
              style: AppTextStyles.headlineMedium(context),
            ),
            SizedBox(height: 24.h),
            _buildNameInput(),
            SizedBox(height: 20.h),
            _buildCategoryDropdown(category, setStateDialog),
            SizedBox(height: 20.h),
            _buildLevelDropdown(level, setStateDialog),
            SizedBox(height: 28.h),
            _buildDialogActions(editIndex, category, level),
          ],
        );
      },
    );
  }

  // ... rest of the dialog methods remain the same as your original code
  // (They're already well-structured)

  // ==============================
  // DIALOG MANAGEMENT
  // ==============================

  Widget _buildCategoryDropdown(String? category, Function setStateDialog) {
    return DropdownButtonFormField<String>(
      value: category,
      dropdownColor: AppColors.primary,
      style: TextStyle(fontSize: 16.sp, color: Colors.white),
      decoration: InputDecoration(
        labelText: 'EC Category',
        labelStyle: TextStyle(fontSize: 16.sp, color: Colors.white70),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(isFocused: true),
        filled: true,
        fillColor: AppColors.inputBackground,
      ),
      items: ecCategories
          .map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(c, style: TextStyle(fontSize: 16.sp)),
            ),
          )
          .toList(),
      onChanged: (v) => setStateDialog(() => _dialogCategory = v),
    );
  }

  Widget _buildLevelDropdown(String level, Function setStateDialog) {
    return DropdownButtonFormField<String>(
      value: level,
      dropdownColor: AppColors.primary,
      style: TextStyle(fontSize: 16.sp, color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Activity Level (F/C/B/A/S)',
        labelStyle: TextStyle(fontSize: 16.sp, color: Colors.white70),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(isFocused: true),
        filled: true,
        fillColor: AppColors.inputBackground,
      ),
      items: activityWeight.keys
          .map(
            (lbl) => DropdownMenuItem(
              value: lbl,
              child: Text(lbl, style: TextStyle(fontSize: 16.sp)),
            ),
          )
          .toList(),
      onChanged: (v) => setStateDialog(() => _dialogLevel = v ?? 'B'),
    );
  }

  Widget _buildDialogActions(int? editIndex, String? category, String level) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            nameController.clear();
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            foregroundColor: Colors.white70,
          ),
          child: Text(
            'Cancel',
            style: GoogleFonts.spaceGrotesk(fontSize: 16.sp),
          ),
        ),
        SizedBox(width: 12.w),
        FilledButton(
          onPressed: () => _saveActivity(editIndex, category, level),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
          ),
          child: Text(
            editIndex == null ? 'Add' : 'Save',
            style: GoogleFonts.spaceGrotesk(fontSize: 16.sp),
          ),
        ),
      ],
    );
  }

  InputBorder _inputBorder({bool isFocused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: AppColors.accent, width: isFocused ? 2 : 1),
    );
  }

  void _saveActivity(int? editIndex, String? category, String level) async {
    final name = nameController.text.trim();

    if (name.isEmpty || _dialogCategory == null) {
      // ... existing validation code ...
      return;
    }

    final entry = {
      'name': name,
      'ecCategory': _dialogCategory,
      'activityLevel': _dialogLevel,
    };

    setState(() {
      if (editIndex == null) {
        activities.add(entry);
      } else {
        activities[editIndex] = entry;
      }
    });

    // REMOVED the Firebase save call from here
    // await FirebaseFirestore.instance
    //     .collection("eclist")
    //     .doc(FirebaseAuth.instance.currentUser!.uid)
    //     .set({"eclist": activities});

    nameController.clear();
    Navigator.pop(context);

    // Show success message (but don't say "saved" since it's only local)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF00FF88)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                editIndex == null ? 'Activity added!' : 'Activity updated!',
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
        duration: Duration(
          seconds: 2,
        ), // Shorter duration since not saved to cloud
      ),
    );
  }

  void _deleteActivity(int index) {
    setState(() => activities.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF006E)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Activity Deleted',
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

  Widget _buildNameInput() {
    return TextField(
      controller: nameController,
      style: TextStyle(fontSize: 16.sp, color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Activity name',
        labelStyle: TextStyle(fontSize: 16.sp, color: Colors.white70),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(isFocused: true),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }
}
