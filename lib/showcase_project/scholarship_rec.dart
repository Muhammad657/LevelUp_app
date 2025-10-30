import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_club/showcase_project/circularprogressindicator.dart';
import 'package:flutter_club/showcase_project/scholarshipList.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ScholarshipsPage extends StatefulWidget {
  const ScholarshipsPage({super.key});

  @override
  State<ScholarshipsPage> createState() => _ScholarshipsPageState();
}

class _ScholarshipsPageState extends State<ScholarshipsPage>
    with SingleTickerProviderStateMixin {
  List scholarships = [];
  ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isRefreshing = true;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  Map<String, dynamic> _activeFilters = {
    'type': '',
    'amountRange': RangeValues(0, 50000),
    'deadline': '',
    'eligibility': '',
    'applicationDifficulty': '',
    'renewable': null,
    'essayRequired': null,
    'recommendationLetters': '',
    'gpaRequirement': RangeValues(0.0, 4.0),
    'majorSpecific': '',
    'locationSpecific': '',
    'demographicSpecific': '',
  };

  List<DocumentSnapshot> _scholarships = [];
  List<DocumentSnapshot> _filteredScholarships = [];
  List<DocumentSnapshot> _selectedScholarships = [];
  bool _isLoading = true;
  bool _showFilters = false;
  Set<String> _savedScholarships = Set<String>();
  bool _filtersApplied = false;

  // Sample scholarships data structure
  final List<Map<String, dynamic>> sampleScholarships = [
    {
      "name": "National Merit Scholarship",
      "provider": "National Merit Scholarship Corporation",
      "amount": 2500,
      "deadline": "October 15",
      "type": "Merit-based",
      "eligibility": "High PSAT scores",
      "applicationDifficulty": "Medium",
      "renewable": true,
      "essayRequired": false,
      "recommendationLetters": 0,
      "gpaRequirement": 3.5,
      "majorSpecific": "Any",
      "demographicSpecific": "US Citizens",
      "description": "Prestigious scholarship for top PSAT scorers",
    },
    {
      "name": "Coca-Cola Scholars Program",
      "provider": "Coca-Cola Foundation",
      "amount": 20000,
      "deadline": "October 31",
      "type": "Merit-based",
      "eligibility": "High school seniors with leadership",
      "applicationDifficulty": "High",
      "renewable": true,
      "essayRequired": true,
      "recommendationLetters": 2,
      "gpaRequirement": 3.7,
      "majorSpecific": "Any",
      "demographicSpecific": "US Citizens",
      "description": "For students demonstrating leadership and service",
    },
    {
      "name": "Gates Scholarship",
      "provider": "Bill & Melinda Gates Foundation",
      "amount": 50000,
      "deadline": "September 15",
      "type": "Need-based",
      "eligibility": "Minority, low-income students",
      "applicationDifficulty": "Very High",
      "renewable": true,
      "essayRequired": true,
      "recommendationLetters": 3,
      "gpaRequirement": 3.8,
      "majorSpecific": "Any",
      "demographicSpecific": "Minority, Low-income",
      "description": "Full scholarship for outstanding minority students",
    },
    {
      "name": "STEM Excellence Scholarship",
      "provider": "Google",
      "amount": 10000,
      "deadline": "January 15",
      "type": "Merit-based",
      "eligibility": "STEM majors with projects",
      "applicationDifficulty": "High",
      "renewable": false,
      "essayRequired": true,
      "recommendationLetters": 2,
      "gpaRequirement": 3.6,
      "majorSpecific": "STEM",
      "demographicSpecific": "Any",
      "description":
          "For students pursuing STEM fields with demonstrated projects",
    },
    {
      "name": "Community Service Award",
      "provider": "Rotary Club",
      "amount": 5000,
      "deadline": "March 1",
      "type": "Service-based",
      "eligibility": "Demonstrated community service",
      "applicationDifficulty": "Medium",
      "renewable": false,
      "essayRequired": true,
      "recommendationLetters": 1,
      "gpaRequirement": 3.0,
      "majorSpecific": "Any",
      "demographicSpecific": "Local residents",
      "description": "Recognizing outstanding community service contributions",
    },
  ];

  Future<void> addSampleScholarshipsToFirebase() async {
    final firestore = FirebaseFirestore.instance;

    // try {
    //   for (var scholarship in newScholarshipList) {
    //     await firestore
    //         .collection('scholarships')
    //         .doc(scholarship["name"].toString())
    //         .set(scholarship);
    //   }
    //   print(
    //     'Successfully added ${newScholarshipList.length} sample scholarships to Firebase!',
    //   );
    // } catch (e) {
    //   print('Error adding sample scholarships: $e');
    // }
    _loadSavedScholarships();
    _loadScholarships();

    setState(() {
      isRefreshing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    addSampleScholarshipsToFirebase();
    scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _heightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _onScroll() {
    if (_showFilters && !_animationController.isAnimating) {
      _startHideAnimation();
    }
  }

  void _startHideAnimation() {
    _animationController.reverse().then((_) {
      setState(() {
        _showFilters = false;
      });
    });
  }

  void _showFilterPanel() {
    setState(() {
      _showFilters = true;
    });
    _animationController.forward();
  }

  Future<void> _loadScholarships() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('scholarships')
          .get();
      print('Loaded ${querySnapshot.docs.length} scholarships');

      setState(() {
        _scholarships = querySnapshot.docs;
        _filteredScholarships = _scholarships;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading scholarships: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSavedScholarships() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('user_saved_scholarships')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final scholarshipList = doc.data()!['list'] as List? ?? [];
          setState(() {
            scholarships = scholarshipList.map((item) {
              final scholarshipData = item as Map<String, dynamic>;
              return {
                "scholarshipName":
                    scholarshipData['scholarshipName'] ?? 'Unknown',
                "savedAt": scholarshipData['savedAt'] ?? DateTime.now(),
              };
            }).toList();
          });
          print('Loaded ${scholarships.length} saved scholarships');
        }
      } catch (e) {
        print('Error loading saved scholarships: $e');
      }
    }
  }

  Future<void> _toggleSaveScholarship(
    String scholarshipId,
    String scholarshipName,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      bool isSaved = scholarships.any(
        (scholarship) => scholarship["scholarshipName"] == scholarshipName,
      );

      if (!isSaved) {
        // Save scholarship
        await _saveScholarshipToFirestore(scholarshipName);
      } else {
        // Remove from saved
        await _removeScholarshipFromFirestore(scholarshipName);
      }
    } catch (e) {
      print('Error toggling save scholarship: $e');
    }
  }

  Future<bool> _saveScholarshipToFirestore(String scholarshipName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Get the current user's saved scholarships
      final userDoc = await FirebaseFirestore.instance
          .collection('user_saved_solarships')
          .doc(user.uid)
          .get();

      final stuff = await FirebaseFirestore.instance
          .collection("user_saved_scholarships")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      print("stuff data: ${stuff.data()}");
      print("userdoc data: ${stuff.data()}");
      List savedScholarshipList = [];

      if (stuff.data() != null) {
        print("inside the if for null or not for the data");
        savedScholarshipList = stuff.data()!['list'] as List;
      }
      print("Saved scholarship list $savedScholarshipList");

      // Fetch all scholarships from the collection
      final allScholarshipsSnapshot = await FirebaseFirestore.instance
          .collection('scholarships')
          .get();

      String link = "noLink";
      String description = "No description found";
      bool scholarshipFound = false;
      String deadline = "Deadline not found";

      if (allScholarshipsSnapshot.docs.isEmpty) {
        return false;
      }
      // FIXED: Add null checks and handle missing scholarships
      for (var doc in allScholarshipsSnapshot.docs) {
        final item = doc.data();
        if (item['name'].toString() == scholarshipName) {
          link = item['link']?.toString() ?? "noLink";
          description =
              item['description']?.toString() ?? "No description found";
          scholarshipFound = true;
          deadline = item["deadline"];
          break;
        }
      }

      // If scholarship not found in database, use default values
      if (!scholarshipFound) {
        print('Warning: Scholarship "$scholarshipName" not found in database');
      }

      final newScholarship = {
        'scholarshipName': scholarshipName,
        'link': link,
        'description': description,
        'deadline': deadline,
        // 'savedAt': FieldValue.serverTimestamp(),
      };

      // Check if already saved
      bool alreadyExists = savedScholarshipList.any(
        (item) => item is Map && item['scholarshipName'] == scholarshipName,
      );

      if (alreadyExists) {
        print('Scholarship already saved');
        return true;
      }

      // Add to list and save
      savedScholarshipList.add(newScholarship);

      await FirebaseFirestore.instance
          .collection('user_saved_scholarships')
          .doc(user.uid)
          .set({'list': savedScholarshipList});

      // Update local state with null checks
      if (mounted) {
        setState(() {
          scholarships.add({
            "scholarshipName": scholarshipName,
            "link": link,
            "description": description,
            "savedAt": DateTime.now(),
          });
        });
      }

      // Show success message
      _showSuccessSnackbar('Saved $scholarshipName', context);

      return true;
    } catch (e) {
      print('Error saving scholarship: $e');
      _showErrorSnackbar('Failed to save scholarship', context);
      return false;
    }
  }

  Future<void> _removeScholarshipFromFirestore(String scholarshipName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('user_saved_scholarships')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      List<dynamic> currentList = userDoc.data()!['list'] as List? ?? [];

      currentList.removeWhere(
        (item) => item is Map && item['scholarshipName'] == scholarshipName,
      );

      await FirebaseFirestore.instance
          .collection('user_saved_scholarships')
          .doc(user.uid)
          .set({'list': currentList});

      setState(() {
        scholarships.removeWhere(
          (scholarship) => scholarship["scholarshipName"] == scholarshipName,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF00FF88)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Removed $scholarshipName',
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
  }

  void _applyFilters() {
    List<DocumentSnapshot> filtered = List.from(_scholarships);

    // Search filter
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      final searchTerms = searchText.toLowerCase().split(RegExp(r'\s+'));
      final nonEmptySearchTerms = searchTerms
          .where((term) => term.isNotEmpty)
          .toList();

      if (nonEmptySearchTerms.isNotEmpty) {
        filtered = filtered.where((scholarship) {
          final data = scholarship.data() as Map<String, dynamic>;
          final name = data['name']?.toString().toLowerCase() ?? '';
          final provider = data['provider']?.toString().toLowerCase() ?? '';
          final type = data['type']?.toString().toLowerCase() ?? '';
          final description =
              data['description']?.toString().toLowerCase() ?? '';

          return nonEmptySearchTerms.every(
            (term) =>
                name.contains(term) ||
                provider.contains(term) ||
                type.contains(term) ||
                description.contains(term),
          );
        }).toList();
      }
    }

    // Amount range filter
    final amountRange = _activeFilters['amountRange'] as RangeValues;
    if (amountRange.start > 0 || amountRange.end < 50000) {
      filtered = filtered.where((scholarship) {
        final data = scholarship.data() as Map<String, dynamic>;
        final amount = data['amount'] ?? 0;
        return amount >= amountRange.start && amount <= amountRange.end;
      }).toList();
    }

    // GPA range filter
    final gpaRange = _activeFilters['gpaRequirement'] as RangeValues;
    if (gpaRange.start > 0.0 || gpaRange.end < 4.0) {
      filtered = filtered.where((scholarship) {
        final data = scholarship.data() as Map<String, dynamic>;
        final gpa = data['gpaRequirement'] ?? 0.0;
        return gpa >= gpaRange.start && gpa <= gpaRange.end;
      }).toList();
    }

    // Type filter
    if (_activeFilters['type']!.isNotEmpty) {
      filtered = filtered.where((scholarship) {
        final data = scholarship.data() as Map<String, dynamic>;
        final type = data['type']?.toString().toLowerCase() ?? '';
        return type == _activeFilters['type']!.toLowerCase();
      }).toList();
    }

    // Essay required filter
    if (_activeFilters['essayRequired'] != null) {
      filtered = filtered.where((scholarship) {
        final data = scholarship.data() as Map<String, dynamic>;
        final essayRequired = data['essayRequired'];
        return essayRequired == _activeFilters['essayRequired'];
      }).toList();
    }

    // Renewable filter
    if (_activeFilters['renewable'] != null) {
      filtered = filtered.where((scholarship) {
        final data = scholarship.data() as Map<String, dynamic>;
        final renewable = data['renewable'];
        return renewable == _activeFilters['renewable'];
      }).toList();
    }

    setState(() {
      _filteredScholarships = filtered;
      _filtersApplied = _hasActiveFilters;
      _showFilters = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _activeFilters = {
        'type': '',
        'amountRange': RangeValues(0, 50000),
        'deadline': '',
        'eligibility': '',
        'applicationDifficulty': '',
        'renewable': null,
        'essayRequired': null,
        'recommendationLetters': '',
        'gpaRequirement': RangeValues(0.0, 4.0),
        'majorSpecific': '',
        'locationSpecific': '',
        'demographicSpecific': '',
      };
      _searchController.clear();
      _filteredScholarships = _scholarships;
      _filtersApplied = false;
    });
  }

  bool get _hasActiveFilters {
    final hasSearch = _searchController.text.isNotEmpty;
    final hasTextFilters = _activeFilters.entries.any((entry) {
      if (entry.key.endsWith('Range') ||
          entry.key == 'renewable' ||
          entry.key == 'essayRequired') {
        return false;
      }
      return entry.value.toString().isNotEmpty;
    });

    final hasRangeFilters = _activeFilters.entries.any((entry) {
      if (entry.key.endsWith('Range')) {
        final range = entry.value as RangeValues;
        final defaultRange = _getDefaultRange(entry.key);
        return range.start != defaultRange.start ||
            range.end != defaultRange.end;
      }
      return false;
    });

    final hasBooleanFilters =
        _activeFilters['renewable'] != null ||
        _activeFilters['essayRequired'] != null;

    return hasSearch || hasTextFilters || hasRangeFilters || hasBooleanFilters;
  }

  RangeValues _getDefaultRange(String key) {
    switch (key) {
      case 'amountRange':
        return RangeValues(0, 50000);
      case 'gpaRequirement':
        return RangeValues(0.0, 4.0);
      default:
        return RangeValues(0, 100);
    }
  }

  void _navigateToScholarshipProfile(DocumentSnapshot scholarship) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScholarshipProfilePage(
          scholarship: scholarship,
          isSaved: scholarships.any(
            (s) => s["scholarshipName"] == scholarship['name'],
          ),
          onSaveToggle: () =>
              _toggleSaveScholarship(scholarship.id, scholarship['name']),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: isRefreshing
          ? TechyLoadingScreen()
          : Scaffold(
              body: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10.0.w),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // gradient: LinearGradient(
                                  //   begin: Alignment.topLeft,
                                  //   end: Alignment.bottomRight,
                                  //   colors: [
                                  //     Color.fromRGBO(118, 251, 166, 0.8),
                                  //     Color.fromRGBO(88, 75, 245, 0.8),
                                  //   ],
                                  // ),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Color.fromRGBO(
                                  //       88,
                                  //       75,
                                  //       245,
                                  //       0.4,
                                  //     ),
                                  //     blurRadius: 12.r,
                                  //     offset: Offset(0, 4.h),
                                  //   ),
                                  // ],
                                  color: Colors.blue.shade700,
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  shape: CircleBorder(),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15.r),
                                    onTap: () => Navigator.pop(context),
                                    splashColor: Colors.white.withOpacity(0.2),
                                    child: Padding(
                                      padding: EdgeInsets.all(10.w),
                                      child: Icon(
                                        Icons.arrow_back_rounded,
                                        color: Colors.white,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Find Scholarships",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Discover funding opportunities",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Search and Filter Bar
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) => _applyFilters(),
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        "Search scholarships, providers, types...",
                                    hintStyle: GoogleFonts.montserrat(
                                      color: Colors.white70,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.1),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 16.h,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.r),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(88, 75, 245, 1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.r),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(118, 251, 166, 1),
                                      ),
                                    ),
                                    suffixIcon: Icon(
                                      Icons.search_rounded,
                                      color: Color.fromRGBO(118, 251, 166, 1),
                                      size: 24.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Badge(
                                isLabelVisible:
                                    _hasActiveFilters && _filtersApplied,
                                backgroundColor: Color(0xFF00E676),
                                child: IconButton(
                                  onPressed: () {
                                    if (_showFilters) {
                                      _startHideAnimation();
                                    } else {
                                      _showFilterPanel();
                                    }
                                  },
                                  icon: Icon(
                                    Icons.filter_list_rounded,
                                    color: Colors.white,
                                    size: 24.sp,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Color.fromRGBO(
                                      88,
                                      75,
                                      245,
                                      1,
                                    ),
                                    padding: EdgeInsets.all(12.w),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Active Filters Indicator
                        if (_filtersApplied && _hasActiveFilters)
                          _buildActiveFiltersIndicator(),

                        // Filters Panel
                        if (_showFilters || _animationController.isAnimating)
                          AnimatedBuilder(
                            animation: _heightAnimation,
                            builder: (context, child) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 16.h),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1E1E2E),
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRect(
                                  child: Align(
                                    heightFactor: _heightAnimation.value,
                                    alignment: Alignment.topCenter,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: _buildFiltersPanelContent(),
                          ),

                        // Results Count
                        _filtersApplied
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Text(
                                  '${_filteredScholarships.length} scholarships found',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Color(0xFF00E676),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),

                        // Scholarships List
                        Expanded(
                          child: _isLoading
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 60.w,
                                        height: 60.h,
                                        child:
                                            CircularProgressIndicator.adaptive(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Color(0xFF00E676),
                                                  ),
                                              strokeWidth: 3,
                                            ),
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'Loading scholarships...',
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white70,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _filteredScholarships.isEmpty
                              ? Center(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.attach_money_outlined,
                                          color: Colors.white54,
                                          size: 80.sp,
                                        ),
                                        SizedBox(height: 20.h),
                                        Text(
                                          'No scholarships found',
                                          style: GoogleFonts.spaceGrotesk(
                                            color: Colors.white,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'Try adjusting your filters or search terms',
                                          style: GoogleFonts.spaceGrotesk(
                                            color: Colors.white70,
                                            fontSize: 14.sp,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 20.h),
                                        ElevatedButton(
                                          onPressed: _clearFilters,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF3949AB),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 32.w,
                                              vertical: 12.h,
                                            ),
                                          ),
                                          child: Text(
                                            'Clear all filters',
                                            style: GoogleFonts.spaceGrotesk(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: scrollController,
                                  padding: EdgeInsets.only(bottom: 20.h),
                                  itemCount: _filteredScholarships.length,
                                  itemBuilder: (context, index) {
                                    final scholarship =
                                        _filteredScholarships[index];
                                    final data =
                                        scholarship.data()
                                            as Map<String, dynamic>;
                                    final isSaved = scholarships.any(
                                      (s) =>
                                          s["scholarshipName"] == data['name'],
                                    );

                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 6.h,
                                        horizontal: 8.w,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        color: Colors.grey.withOpacity(0.05),
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
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          onTap: () =>
                                              _navigateToScholarshipProfile(
                                                scholarship,
                                              ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.w),
                                            child: Row(
                                              children: [
                                                // Save Button
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isSaved
                                                        ? Color.fromRGBO(
                                                            118,
                                                            251,
                                                            166,
                                                            0.2,
                                                          )
                                                        : Colors.transparent,
                                                    border: Border.all(
                                                      color: isSaved
                                                          ? Color.fromRGBO(
                                                              118,
                                                              251,
                                                              166,
                                                              1,
                                                            )
                                                          : Colors.white30,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () =>
                                                        _toggleSaveScholarship(
                                                          scholarship.id,
                                                          scholarship['name'],
                                                        ),
                                                    icon: Icon(
                                                      isSaved
                                                          ? Icons
                                                                .bookmark_rounded
                                                          : Icons
                                                                .bookmark_border_rounded,
                                                      color: isSaved
                                                          ? Color.fromRGBO(
                                                              118,
                                                              251,
                                                              166,
                                                              1,
                                                            )
                                                          : Colors.white70,
                                                      size: 20.sp,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints: BoxConstraints(
                                                      minWidth: 40.w,
                                                      minHeight: 40.h,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 16.w),

                                                // Scholarship Info
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              data['name'] ??
                                                                  'Unknown Scholarship',
                                                              style: GoogleFonts.montserrat(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 4.h),
                                                      Text(
                                                        data['provider'] ?? '',
                                                        style:
                                                            GoogleFonts.montserrat(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize: 14.sp,
                                                            ),
                                                      ),
                                                      SizedBox(height: 8.h),
                                                      Wrap(
                                                        spacing: 8.w,
                                                        runSpacing: 4.h,
                                                        children: [
                                                          _buildScholarshipChip(
                                                            '💰 \$${data['amount']?.toString() ?? 'N/A'}',
                                                            Color.fromRGBO(
                                                              88,
                                                              75,
                                                              245,
                                                              1,
                                                            ),
                                                          ),
                                                          _buildScholarshipChip(
                                                            '📅 ${data['deadline'] ?? 'N/A'}',
                                                            Color.fromRGBO(
                                                              118,
                                                              251,
                                                              166,
                                                              1,
                                                            ),
                                                          ),
                                                          _buildScholarshipChip(
                                                            '🎓 ${data['type'] ?? 'N/A'}',
                                                            Color(0xFFFF9800),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),

                                                // Info Button
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Color.fromARGB(
                                                          255,
                                                          48,
                                                          196,
                                                          255,
                                                        ),
                                                        Color(0xFF2575FC),
                                                      ],
                                                    ),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () =>
                                                        _navigateToScholarshipProfile(
                                                          scholarship,
                                                        ),
                                                    icon: Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      color: Colors.white,
                                                      size: 16.sp,
                                                    ),
                                                    padding: EdgeInsets.all(
                                                      10.w,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        SizedBox(height: 10.h),
                        Center(
                          child: Text(
                            "Application deadlines may vary — check official sources",
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white70,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildScholarshipChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActiveFiltersIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Color(0xFF00E676).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt_rounded, color: Color(0xFF00E676), size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Filters applied - ${_filteredScholarships.length} results',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: _clearFilters,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanelContent() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: Color(0xFF00E676), size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Scholarship Filters',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Clear All',
                  style: GoogleFonts.spaceGrotesk(
                    color: Color(0xFF00E676),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFilterSection('Basic Info', [
                    _buildFilterTextField(
                      'Scholarship Type',
                      'type',
                      'e.g., Merit-based, Need-based',
                    ),
                    _buildFilterTextField(
                      'Eligibility',
                      'eligibility',
                      'e.g., STEM, Community Service',
                    ),
                    _buildTypeDropdown(),
                  ]),

                  _buildFilterSection('Financial', [
                    _buildRangeSlider(
                      'Amount Range (\$)',
                      'amountRange',
                      0,
                      50000,
                      '\$${_activeFilters['amountRange']!.start.round()} - \$${_activeFilters['amountRange']!.end.round()}',
                    ),
                    _buildRenewableDropdown(),
                  ]),

                  _buildFilterSection('Requirements', [
                    _buildRangeSlider(
                      'GPA Requirement',
                      'gpaRequirement',
                      0.0,
                      4.0,
                      '${_activeFilters['gpaRequirement']!.start.toStringAsFixed(1)} - ${_activeFilters['gpaRequirement']!.end.toStringAsFixed(1)}',
                    ),
                    _buildEssayRequiredDropdown(),
                  ]),
                ],
              ),
            ),
          ),

          SizedBox(height: 20.h),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF64DD17)],
              ),
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00E676).withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                minimumSize: Size(double.infinity, 56.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Apply Filters',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(spacing: 12.w, runSpacing: 12.h, children: children),
          SizedBox(height: 8.h),
          Divider(color: Colors.white12),
        ],
      ),
    );
  }

  Widget _buildFilterTextField(String label, String key, String hint) {
    return SizedBox(
      width: 300.w,
      child: TextField(
        onChanged: (value) {
          setState(() {
            _activeFilters[key] = value;
          });
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.spaceGrotesk(color: Colors.white70),
          hintStyle: GoogleFonts.spaceGrotesk(color: Colors.white54),
          filled: true,
          fillColor: Color(0xFF2D2D44),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Color(0xFF00E676)),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        style: GoogleFonts.spaceGrotesk(color: Colors.white),
      ),
    );
  }

  Widget _buildRangeSlider(
    String label,
    String key,
    double min,
    double max,
    String valueText,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                valueText,
                style: GoogleFonts.spaceGrotesk(
                  color: Color(0xFF00E676),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          RangeSlider(
            values: _activeFilters[key] as RangeValues,
            min: min,
            max: max,
            divisions: 20,
            labels: RangeLabels(
              _activeFilters[key]!.start.toStringAsFixed(
                key == 'gpaRequirement' ? 1 : 0,
              ),
              _activeFilters[key]!.end.toStringAsFixed(
                key == 'gpaRequirement' ? 1 : 0,
              ),
            ),
            activeColor: Color(0xFF00E676),
            inactiveColor: Colors.white30,
            onChanged: (RangeValues values) {
              setState(() {
                _activeFilters[key] = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return SizedBox(
      width: 305.w,
      child: DropdownButtonFormField<String>(
        value: _activeFilters['type']!.isEmpty ? null : _activeFilters['type'],
        onChanged: (value) {
          setState(() {
            _activeFilters['type'] = value ?? '';
          });
        },
        items:
            [
              '',
              'Merit-based',
              'Need-based',
              'Athletic',
              'Creative',
              'Community Service',
              'Minority',
              'STEM',
            ].map((type) {
              return DropdownMenuItem(
                value: type.isEmpty ? null : type,
                child: Text(
                  type.isEmpty ? 'Any Type' : type,
                  style: GoogleFonts.spaceGrotesk(
                    color: type.isEmpty ? Colors.white54 : Colors.white,
                  ),
                ),
              );
            }).toList(),
        decoration: InputDecoration(
          labelText: 'Scholarship Type',
          labelStyle: GoogleFonts.spaceGrotesk(color: Colors.white70),
          filled: true,
          fillColor: Color(0xFF2D2D44),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Color(0xFF00E676)),
          ),
        ),
        dropdownColor: Color(0xFF1E1E2E),
        style: GoogleFonts.spaceGrotesk(color: Colors.white),
      ),
    );
  }

  Widget _buildRenewableDropdown() {
    return SizedBox(
      width: 305.w,
      child: DropdownButtonFormField<bool?>(
        value: _activeFilters['renewable'],
        onChanged: (value) {
          setState(() {
            _activeFilters['renewable'] = value;
          });
        },
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(
              'Any Renewability',
              style: GoogleFonts.spaceGrotesk(color: Colors.white54),
            ),
          ),
          DropdownMenuItem(
            value: true,
            child: Text(
              'Renewable',
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
            ),
          ),
          DropdownMenuItem(
            value: false,
            child: Text(
              'One-time',
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
            ),
          ),
        ],
        decoration: InputDecoration(
          labelText: 'Renewable',
          labelStyle: GoogleFonts.spaceGrotesk(color: Colors.white70),
          filled: true,
          fillColor: Color(0xFF2D2D44),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Color(0xFF00E676)),
          ),
        ),
        dropdownColor: Color(0xFF1E1E2E),
        style: GoogleFonts.spaceGrotesk(color: Colors.white),
      ),
    );
  }

  Widget _buildEssayRequiredDropdown() {
    return SizedBox(
      width: 305.w,
      child: DropdownButtonFormField<bool?>(
        value: _activeFilters['essayRequired'],
        onChanged: (value) {
          setState(() {
            _activeFilters['essayRequired'] = value;
          });
        },
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(
              'Any Essay Requirement',
              style: GoogleFonts.spaceGrotesk(color: Colors.white54),
            ),
          ),
          DropdownMenuItem(
            value: true,
            child: Text(
              'Essay Required',
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
            ),
          ),
          DropdownMenuItem(
            value: false,
            child: Text(
              'No Essay Required',
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
            ),
          ),
        ],
        decoration: InputDecoration(
          labelText: 'Essay Requirement',
          labelStyle: GoogleFonts.spaceGrotesk(color: Colors.white70),
          filled: true,
          fillColor: Color(0xFF2D2D44),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Color(0xFF00E676)),
          ),
        ),
        dropdownColor: Color(0xFF1E1E2E),
        style: GoogleFonts.spaceGrotesk(color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class ScholarshipProfilePage extends StatefulWidget {
  final DocumentSnapshot scholarship;
  final bool isSaved;
  final VoidCallback onSaveToggle;

  const ScholarshipProfilePage({
    Key? key,
    required this.scholarship,
    required this.isSaved,
    required this.onSaveToggle,
  }) : super(key: key);

  @override
  State<ScholarshipProfilePage> createState() => _ScholarshipProfilePageState();
}

class _ScholarshipProfilePageState extends State<ScholarshipProfilePage> {
  late bool _currentIsSaved;

  @override
  void initState() {
    super.initState();
    _currentIsSaved = widget.isSaved;
  }

  void _handleSaveToggle() {
    widget.onSaveToggle();
    setState(() {
      _currentIsSaved = !_currentIsSaved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.scholarship.data() as Map<String, dynamic>;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(88, 75, 245, 0.8),
                    Color.fromRGBO(118, 251, 166, 0.3),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25.r),
                  bottomRight: Radius.circular(25.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(88, 75, 245, 0.4),
                    blurRadius: 20.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 50.h),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? 'Unknown Scholarship',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              data['provider'] ?? '',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white70,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: IconButton(
                          onPressed: _handleSaveToggle,
                          icon: Icon(
                            _currentIsSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: _currentIsSaved
                                ? Color(0xFF00E676)
                                : Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    Padding(
                      padding: EdgeInsets.only(left: 25.0.w),
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          _buildStatCard(
                            '💰',
                            'Amount',
                            '\$${data['amount']?.toString() ?? 'N/A'}',
                          ),
                          _buildStatCard(
                            '📅',
                            'Deadline',
                            data['deadline'] ?? 'N/A',
                          ),
                          _buildStatCard('🎓', 'Type', data['type'] ?? 'N/A'),
                          _buildStatCard(
                            '⭐',
                            'GPA Req',
                            data['gpaRequirement']?.toString() ?? 'N/A',
                          ),
                          _buildStatCard(
                            '📝',
                            'Essay',
                            data['essayRequired'] == true
                                ? 'Required'
                                : 'Not Required',
                          ),
                          _buildStatCard(
                            '🔄',
                            'Renewable',
                            data['renewable'] == true ? 'Yes' : 'No',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Description
                    if (data['description'] != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            data['description']!,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),

                    // Additional Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('🏆 Eligibility', data['eligibility']),
                        _buildInfoRow(
                          '📊 Application Difficulty',
                          data['applicationDifficulty'],
                        ),
                        _buildInfoRow(
                          '📚 Recommendation Letters',
                          data['recommendationLetters']?.toString() ?? '0',
                        ),
                        _buildInfoRow(
                          '🎯 Major Specific',
                          data['majorSpecific'],
                        ),
                        _buildInfoRow(
                          '👥 Demographic',
                          data['demographicSpecific'],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Apply Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF64DD17)],
                        ),
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00E676).withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          // if (!
                          await launchUrl(
                            Uri.parse(data["link"]),
                            mode: LaunchMode.inAppBrowserView,
                            // )) {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(
                            //       content: Row(
                            //         children: [
                            //           Icon(
                            //             Icons.error_rounded,
                            //             color: Colors.red,
                            //           ),
                            //           SizedBox(width: 12.w),
                            //           Expanded(
                            //             child: Text(
                            //               'Failed to open url',
                            //               style: GoogleFonts.orbitron(
                            //                 color: Colors.white,
                            //                 fontSize: 12.sp,
                            //                 fontWeight: FontWeight.w600,
                            //                 letterSpacing: 0.5,
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       backgroundColor: Color(0xFF1A1A2E),
                            //       elevation: 10,
                            //       behavior: SnackBarBehavior.floating,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(8.r),
                            //         side: BorderSide(
                            //           color: Colors.red,
                            //           width: 1.5,
                            //         ),
                            //       ),
                            //       duration: Duration(seconds: 4),
                            //     ),
                            //   );
                            // }
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          'Apply Now',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Color.fromRGBO(88, 75, 245, 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.montserrat(
              color: Color.fromRGBO(118, 251, 166, 1),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 9.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return SizedBox();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white70,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value.toString(),
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showSuccessSnackbar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF00FF88)),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
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
      duration: Duration(seconds: 2),
    ),
  );
}

void _showErrorSnackbar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_rounded, color: Colors.red),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
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
      // duration: Duration(seconds: 2),
    ),
  );
}
