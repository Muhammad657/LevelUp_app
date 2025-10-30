import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_club/notifiers.dart';
import 'package:flutter_club/Levelup/collegesList.dart';
import 'package:flutter_club/Levelup/scholarship_rec.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CollegeResearchPage extends StatefulWidget {
  const CollegeResearchPage({super.key});

  @override
  State<CollegeResearchPage> createState() => _CollegeResearchPageState();
}

class _CollegeResearchPageState extends State<CollegeResearchPage>
    with SingleTickerProviderStateMixin {
  List colleges = [];
  ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isRefresshing = true;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  Future<void> addSampleCollegesToFirebase() async {
    final firestore = FirebaseFirestore.instance;

    // try {
    //   for (var college in sampleColleges) {
    //     await firestore
    //         .collection('colleges')
    //         .doc(college["name"].toString())
    //         .set(college);
    //   }
    //   print(
    //     'Successfully added ${sampleColleges.length} sample colleges to Firebase!',
    //   );
    // } catch (e) {
    //   print('Error adding sample colleges: $e');
    // }
    _loadColleges();
    _loadFollowedColleges();
    setState(() {
      isRefresshing = false;
    });
  }

  Map<String, dynamic> _activeFilters = {
    'location': '',
    'size': '',
    'majors': '',
    'acceptanceRate': '',
    'cost': '',
    'testOptional': null,
    'studentPopulation': '',
    'campusSetting': '',
    'tuitionRange': RangeValues(0, 100000),
    'acceptanceRateRange': RangeValues(0, 100),
    'avgGPARange': RangeValues(0.0, 4.0),
    'satScoreRange': RangeValues(400, 1600),
    'financialAid': null,
    'publicPrivate': '',
    'specializedPrograms': '',
  };

  List<DocumentSnapshot> _colleges = [];
  List<DocumentSnapshot> _filteredColleges = [];
  List<DocumentSnapshot> _selectedColleges = [];
  bool _isLoading = true;
  bool _showFilters = false;
  Set<String> _followedColleges = Set<String>();
  bool _filtersApplied = false;

  void _debugState() {
    print('=== DEBUG STATE ===');
    print('_followedColleges: $_followedColleges');
    print('_followedColleges type: ${_followedColleges.runtimeType}');
    print('_followedColleges length: ${_followedColleges.length}');
    print('colleges list length: ${colleges.length}');
    print('Current user: ${FirebaseAuth.instance.currentUser?.email}');
    print('===================');
  }

  @override
  void initState() {
    super.initState();

    _debugState();
    addSampleCollegesToFirebase();
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

  Future<void> _loadColleges() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('colleges')
          .get();
      print(querySnapshot.docs.length);

      setState(() {
        _colleges = querySnapshot.docs;
        _filteredColleges = _colleges;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading colleges: $e');
      setState(() {
        _isLoading = false;
      });
    }
    _debugMIT();
  }

  Future<void> _loadFollowedColleges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('user_follows')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final collegeList = doc.data()!['list'] as List? ?? [];
          setState(() {
            colleges = collegeList.map((item) {
              final collegeData = item as Map<String, dynamic>;
              return {
                "collegeName": collegeData['collegeName'] ?? 'Unknown',
                "lvl": collegeData['level'] ?? 'R',
                "dtype": collegeData["dtype"],
                "deadline": collegeData["deadline"],
                "link": collegeData["link"],
              };
            }).toList();
          });
          print('Loaded ${colleges.length} followed colleges');
        }
      } catch (e) {
        print('Error loading followed colleges: $e');
      }
    }
  }

  Future<void> _toggleFollowCollege(
    String collegeId,
    String collegeName,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Check if already following by looking in our local colleges list
      bool isFollowing = colleges.any(
        (college) => college["collegeName"] == collegeName,
      );

      if (!isFollowing) {
        // Show dialog to add college
        _showAddCollegeDialog(collegeName: collegeName);
      } else {
        // Remove from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('user_follows')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          List<dynamic> currentList = userDoc.data()!['list'] as List? ?? [];

          // Remove the college
          currentList.removeWhere(
            (item) => item is Map && item['collegeName'] == collegeName,
          );

          // Update Firestore
          await FirebaseFirestore.instance
              .collection('user_follows')
              .doc(user.uid)
              .set({'list': currentList}, SetOptions(merge: true));
        }

        // Remove from local state
        setState(() {
          colleges.removeWhere(
            (college) => college["collegeName"] == collegeName,
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
                    'Unfollowed $collegeName',
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
      print('Error toggling follow: $e');
    }
  }

  void _debugFollowState(String collegeId, String collegeName) {
    print('=== DEBUG FOLLOW STATE ===');
    print('College: $collegeName');
    print('College ID: $collegeId');
    print('_followedColleges: $_followedColleges');
    print('Contains collegeId: ${_followedColleges.contains(collegeId)}');
    print('Global colleges count: ${colleges.length}');
    print('==========================');
  }

  void _showAddCollegeDialog({String collegeName = ''}) {
    String selectedLevel = 'R'; // Default to Reach

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.blueAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Add College',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 20),

              // College Name Display (not editable)
              Text(
                'College Name',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: Text(
                  collegeName,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Level Selection
              Text(
                'Admission Level',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedLevel,
                  dropdownColor: Color(0xFF1E293B),
                  style: GoogleFonts.spaceGrotesk(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'R',
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Reach',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'T',
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Target',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'S',
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Safety',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedLevel = value;
                    }
                  },
                ),
              ),

              SizedBox(height: 30),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        try {
                          bool success = await _addCollegeToFirestore(
                            collegeName,
                            selectedLevel,
                          );
                          if (success && mounted) {
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          print('Error in dialog button: $e');
                          // Don't pop on error
                        }
                      },
                      child: Text(
                        'ADD COLLEGE',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
  }

  Future<bool> _addCollegeToFirestore(String collegeName, String level) async {
    try {
      print('=== PROPER FIREBASE WAY ===');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      print('Adding college: $collegeName');

      // Get the current document
      final userDoc = await FirebaseFirestore.instance
          .collection('user_follows')
          .doc(user.uid)
          .get();

      print('Document exists: ${userDoc.exists}');

      List<dynamic> collegeList = [];

      List<dynamic> allCollegeList = [];
      final allcollegedata = await FirebaseFirestore.instance
          .collection('colleges')
          .get();

      // If document exists, get the current list
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        collegeList = data['list'] as List? ?? [];
        print("collegeList: ${allcollegedata.docs}");
        print('Found existing list with ${collegeList.length} colleges');
      }

      // Create new college data

      String link = "noLink";
      String deadline = "No deadline found";
      String dtype = "no dtype found";
      for (var data in allcollegedata.docs) {
        final item = data.data() as Map;
        print(" item here man: $item");
        if (item['name'] == collegeName) {
          deadline = item["deadline"];
          print("deadline: ${item["deadline"]}");
          print("deadline: $deadline");
          link = item["link"];
          print("link: $link");
          dtype = item["dtype"];
          print("dtype: $dtype");
        }
        print("in the else for ${item["name"]}");
      }
      final newCollege = {
        'collegeName': collegeName,
        'level': level,
        'deadline': deadline,
        'link': link,
        'dtype': dtype,
        // 'addedAt': FieldValue.serverTimestamp(),
      };

      // Check if college already exists to avoid duplicates
      bool alreadyExists = collegeList.any(
        (item) => item is Map && item['collegeName'] == collegeName,
      );

      if (alreadyExists) {
        print('College already exists in list');
        return true; // Already added, so return success
      }

      // Add to the list
      collegeList.add(newCollege);
      print('Added to list, new length: ${collegeList.length}');
      print("${collegeList}");

      // Set the entire document (overwrite)
      print('Setting document...');
      await FirebaseFirestore.instance
          .collection('user_follows')
          .doc(user.uid)
          .set({
            'list': [...collegeList],
          });

      print('Document set successfully!');

      // Update local state
      if (mounted) {
        setState(() {
          colleges.add({
            "collegeName": collegeName,
            "lvl": level,
            "dtype": "RD",
            "deadline": "Not set",
          });
        });
        print('Local state updated');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF00FF88)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Now following $collegeName',
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
      print('=== COLLEGE ADDED SUCCESSFULLY ===');
      return true;
    } catch (e) {
      print('=== ERROR: $e ===');
      print('Error type: ${e.runtimeType}');
      return false;
    }
  }

  void _applyFilters() {
    print('=== APPLYING FILTERS ===');
    print('Search text: "${_searchController.text}"');
    print('Initial college count: ${_colleges.length}');

    List<DocumentSnapshot> filtered = List.from(_colleges);

    // Search filter - improved version
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      final searchTerms = searchText.toLowerCase().split(RegExp(r'\s+'));
      final nonEmptySearchTerms = searchTerms
          .where((term) => term.isNotEmpty)
          .toList();

      if (nonEmptySearchTerms.isNotEmpty) {
        filtered = filtered.where((college) {
          final data = college.data() as Map<String, dynamic>;
          final name = data['name']?.toString().toLowerCase() ?? '';
          final location = data['location']?.toString().toLowerCase() ?? '';
          final majors = (data['majors'] as List? ?? [])
              .map((m) => m.toString().toLowerCase())
              .join(' ');

          final specializedPrograms =
              (data['specializedPrograms'] as List? ?? [])
                  .map((p) => p.toString().toLowerCase())
                  .join(' ');

          // Check if ALL search terms match in ANY field
          return nonEmptySearchTerms.every(
            (term) =>
                name.contains(term) ||
                location.contains(term) ||
                majors.contains(term) ||
                specializedPrograms.contains(term),
          );
        }).toList();
      }
    }

    print('After search: ${filtered.length} colleges');

    // Apply other filters only if they have non-default values
    // Tuition range filter
    final tuitionRange = _activeFilters['tuitionRange'] as RangeValues;
    if (tuitionRange.start > 0 || tuitionRange.end < 100000) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        final tuitionValue = data['tuitionAmount'];

        if (tuitionValue == null) return true; // Include null values

        final tuition = _safeParseDouble(tuitionValue);
        return tuition >= tuitionRange.start && tuition <= tuitionRange.end;
      }).toList();
    }

    // Acceptance rate range filter - handle various formats
    final acceptanceRange =
        _activeFilters['acceptanceRateRange'] as RangeValues;
    if (acceptanceRange.start > 0 || acceptanceRange.end < 100) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        final acceptanceRateValue = data['acceptanceRate'];

        if (acceptanceRateValue == null) return true;

        // Handle different acceptance rate formats
        double acceptanceRate;
        if (acceptanceRateValue is num) {
          acceptanceRate = acceptanceRateValue.toDouble();
        } else {
          final acceptanceRateStr = acceptanceRateValue.toString();
          // Remove non-numeric characters except decimal point
          final cleanRate = acceptanceRateStr.replaceAll(
            RegExp(r'[^0-9.]'),
            '',
          );
          acceptanceRate = double.tryParse(cleanRate) ?? 0.0;
        }

        return acceptanceRate >= acceptanceRange.start &&
            acceptanceRate <= acceptanceRange.end;
      }).toList();
    }

    // GPA range filter
    final gpaRange = _activeFilters['avgGPARange'] as RangeValues;
    if (gpaRange.start > 0.0 || gpaRange.end < 4.0) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        final gpaValue = data['avgGPA'];

        if (gpaValue == null) return true;

        final gpa = _safeParseDouble(gpaValue);
        return gpa >= gpaRange.start && gpa <= gpaRange.end;
      }).toList();
    }

    // SAT range filter
    final satRange = _activeFilters['satScoreRange'] as RangeValues;
    if (satRange.start > 400 || satRange.end < 1600) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        final satValue = data['satScore'];

        if (satValue == null) return true;

        final sat = _safeParseDouble(satValue);
        return sat >= satRange.start && sat <= satRange.end;
      }).toList();
    }

    // Test optional filter
    if (_activeFilters['testOptional'] != null) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        final testOptional = data['testOptional'];
        return testOptional == _activeFilters['testOptional'];
      }).toList();
    }

    // Financial aid filter
    if (_activeFilters['financialAid'] != null) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        final financialAid = data['financialAidAvailable'];
        return financialAid == _activeFilters['financialAid'];
      }).toList();
    }

    // Text-based filters (only apply if they have values)
    if (_activeFilters['location']!.isNotEmpty) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        final location = data['location']?.toString().toLowerCase() ?? '';
        final filterLocation = _activeFilters['location']!.toLowerCase();

        // Use contains for partial matching (e.g., "massachu" should match "Massachusetts")
        return location.contains(filterLocation);
      }).toList();
    }

    if (_activeFilters['size']!.isNotEmpty) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        final size = data['size']?.toString().toLowerCase() ?? '';
        return size == _activeFilters['size']!.toLowerCase();
      }).toList();
    }

    if (_activeFilters['majors']!.isNotEmpty) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        if (data['majors'] is List) {
          final majors = (data['majors'] as List)
              .map((m) => m.toString().toLowerCase())
              .toList();
          return majors.any(
            (major) => major.contains(_activeFilters['majors']!.toLowerCase()),
          );
        }
        return false;
      }).toList();
    }

    if (_activeFilters['campusSetting']!.isNotEmpty) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        final setting = data['campusSetting']?.toString().toLowerCase() ?? '';
        return setting.contains(_activeFilters['campusSetting']!.toLowerCase());
      }).toList();
    }

    if (_activeFilters['studentPopulation']!.isNotEmpty) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        final population =
            data['studentPopulation']?.toString().toLowerCase() ?? '';
        return population.contains(
          _activeFilters['studentPopulation']!.toLowerCase(),
        );
      }).toList();
    }

    if (_activeFilters['publicPrivate']!.isNotEmpty) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        final type = data['publicPrivate']?.toString().toLowerCase() ?? '';
        return type == _activeFilters['publicPrivate']!.toLowerCase();
      }).toList();
    }

    if (_activeFilters['specializedPrograms']!.isNotEmpty) {
      filtered = filtered.where((college) {
        final data = college.data() as Map<String, dynamic>;
        if (data['specializedPrograms'] is List) {
          final programs = (data['specializedPrograms'] as List)
              .map((p) => p.toString().toLowerCase())
              .toList();
          return programs.any(
            (program) => program.contains(
              _activeFilters['specializedPrograms']!.toLowerCase(),
            ),
          );
        }
        return false;
      }).toList();
    }

    print('Final filtered count: ${filtered.length} colleges');

    // Debug: Check if MIT is in filtered results
    final mitInResults = filtered.any((college) {
      final data = college.data() as Map<String, dynamic>;
      return data['name']?.toString().contains('MIT') ?? false;
    });
    print('MIT in results: $mitInResults');

    setState(() {
      _filteredColleges = filtered;
      _filtersApplied = _hasActiveFilters;
      _showFilters = false;
    });
    _debugFilterResults();
  }

  // Add this helper method to safely parse numeric values
  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }

  void _debugMIT() {
    try {
      final mit = _colleges.firstWhere((college) {
        final data = college.data() as Map<String, dynamic>;
        return data['name']?.toString().contains('MIT') ?? false;
      });

      final data = mit.data() as Map<String, dynamic>;
      print('=== MIT DEBUG INFO ===');
      print('Name: ${data['name']}');
      print('Location: ${data['location']}');
      print('Majors: ${data['majors']}');
      print('Acceptance Rate: ${data['acceptanceRate']}');
      print('Tuition: ${data['tuition']}');
      print('Tuition Amount: ${data['tuitionAmount']}');
      print('Avg GPA: ${data['avgGPA']}');
      print('SAT: ${data['satScore']}');
      print('Test Optional: ${data['testOptional']}');
      print('=====================\n');
    } catch (e) {
      print('MIT not found in colleges list');
    }
  }

  void _clearFilters() {
    setState(() {
      _activeFilters = {
        'location': '',
        'size': '',
        'majors': '',
        'acceptanceRate': '',
        'cost': '',
        'testOptional': null,
        'studentPopulation': '',
        'campusSetting': '',
        'tuitionRange': RangeValues(0, 100000),
        'acceptanceRateRange': RangeValues(0, 100),
        'avgGPARange': RangeValues(0.0, 4.0),
        'satScoreRange': RangeValues(400, 1600),
        'financialAid': null,
        'publicPrivate': '',
        'specializedPrograms': '',
      };
      _searchController.clear();
      _filteredColleges = _colleges;
      _filtersApplied = false;
    });
  }

  bool get _hasActiveFilters {
    final hasSearch = _searchController.text.isNotEmpty;
    final hasTextFilters = _activeFilters.entries.any((entry) {
      if (entry.key.endsWith('Range') ||
          entry.key == 'testOptional' ||
          entry.key == 'financialAid') {
        return false; // These are handled separately
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
        _activeFilters['testOptional'] != null ||
        _activeFilters['financialAid'] != null;

    return hasSearch || hasTextFilters || hasRangeFilters || hasBooleanFilters;
  }

  RangeValues _getDefaultRange(String key) {
    switch (key) {
      case 'tuitionRange':
        return RangeValues(0, 100000);
      case 'acceptanceRateRange':
        return RangeValues(0, 100);
      case 'avgGPARange':
        return RangeValues(0.0, 4.0);
      case 'satScoreRange':
        return RangeValues(400, 1600);
      default:
        return RangeValues(0, 100);
    }
  }

  void _debugFilterResults() {
    print('=== FILTER DEBUG INFO ===');
    print('Total colleges: ${_colleges.length}');
    print('Filtered colleges: ${_filteredColleges.length}');

    // Check MIT specifically
    try {
      final mit = _colleges.firstWhere((college) {
        final data = college.data() as Map<String, dynamic>;
        return data['name']?.toString().contains('MIT') ?? false;
      });

      final data = mit.data() as Map<String, dynamic>;
      print('MIT found in source: YES');
      print('MIT acceptance rate: ${data['acceptanceRate']}');
      print('MIT location: ${data['location']}');

      final mitInFiltered = _filteredColleges.contains(mit);
      print('MIT in filtered results: $mitInFiltered');

      if (!mitInFiltered) {
        print('MIT was filtered out - checking why:');

        // Check each filter condition
        final acceptanceRate = _safeParseDouble(data['acceptanceRate'] ?? '0');
        final acceptanceRange =
            _activeFilters['acceptanceRateRange'] as RangeValues;
        print('MIT acceptance: $acceptanceRate, Range: $acceptanceRange');
        print(
          'Within acceptance range: ${acceptanceRate >= acceptanceRange.start && acceptanceRate <= acceptanceRange.end}',
        );

        final location = data['location']?.toString().toLowerCase() ?? '';
        final locationFilter = _activeFilters['location']!.toLowerCase();
        print('MIT location: $location, Filter: $locationFilter');
        print('Location match: ${location.contains(locationFilter)}');

        final searchText = _searchController.text.toLowerCase();
        print('Search text: "$searchText"');
        print(
          'Search match: ${data['name']?.toString().toLowerCase().contains(searchText) ?? false}',
        );
      }
    } catch (e) {
      print('MIT not found in source colleges');
    }
    print('=====================');
  }

  void _toggleCollegeSelection(DocumentSnapshot college) {
    setState(() {
      if (_selectedColleges.contains(college)) {
        _selectedColleges.remove(college);
      } else if (_selectedColleges.length < 2) {
        _selectedColleges.add(college);
      }
    });
  }

  void _navigateToCollegeProfile(DocumentSnapshot college) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollegeProfilePage(
          college: college,
          isFollowing: _followedColleges.contains(college.id),
          onFollowToggle: () =>
              _toggleFollowCollege(college.id, college['name']),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: isRefresshing
          ? Scaffold(body: Center(child: CircularProgressIndicator()))
          : Scaffold(
              // Add this to your Scaffold, after the body
              // floatingActionButton: Container(
              //   margin: EdgeInsets.only(
              //     bottom: 80.h,
              //   ), // Position above bottom navigation if you have one
              //   child: FloatingActionButton(
              //     onPressed: () => _navigateToScholarships(context),
              //     backgroundColor: Color.fromRGBO(255, 193, 7, 1),
              //     child: Icon(Icons.school_rounded, color: Colors.white),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(16.r),
              //     ),
              //   ),
              // ),
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
                        // Header - simplified without comparison
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Explore Colleges",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "Find your perfect college match",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(width: 20.w),
                            // Alternative that matches your app's color scheme
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: Colors.transparent,
                                border: Border.all(
                                  color: Color.fromRGBO(118, 251, 166, 0.8),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(118, 251, 166, 0.3),
                                    blurRadius: 6.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12.r),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12.r),
                                  onTap: () => _navigateToScholarships(context),
                                  splashColor: Color.fromRGBO(
                                    118,
                                    251,
                                    166,
                                    0.3,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 8.h,
                                    ),
                                    child: Text(
                                      "Find Scholarships",
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Color.fromRGBO(118, 251, 166, 1),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Removed the comparison button
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
                                // In the search bar, update the decoration:
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    _applyFilters();
                                  },
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        "Search colleges, majors, locations...",
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
                                // Update the filter button:
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
                        // Replace your current filters panel with this animated version:
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
                                  '${_filteredColleges.length} colleges found',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Color(0xFF00E676),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),

                        // Colleges List
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
                                        'Loading colleges...',
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white70,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _filteredColleges.isEmpty
                              ? Center(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.school_outlined,
                                          color: Colors.white54,
                                          size: 80.sp,
                                        ),
                                        SizedBox(height: 20.h),
                                        Text(
                                          'No colleges found',
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
                                  itemCount: _filteredColleges.length,
                                  itemBuilder: (context, index) {
                                    final college = _filteredColleges[index];
                                    final data =
                                        college.data() as Map<String, dynamic>;
                                    final isSelected = _selectedColleges
                                        .contains(college);
                                    final consistentCollegeId = college['name']
                                        .toString()
                                        .replaceAll(' ', '_')
                                        .toLowerCase();
                                    final isFollowing = colleges.any(
                                      (college) =>
                                          college["collegeName"] ==
                                          data['name'],
                                    );
                                    // In the ListView.builder, replace the entire return widget with:
                                    // Replace the current ListView.builder return widget with:
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
                                              _navigateToCollegeProfile(
                                                college,
                                              ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.w),
                                            child: Row(
                                              children: [
                                                // Follow Button
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isFollowing
                                                        ? Color.fromRGBO(
                                                            118,
                                                            251,
                                                            166,
                                                            0.2,
                                                          )
                                                        : Colors.transparent,
                                                    border: Border.all(
                                                      color: isFollowing
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
                                                        _toggleFollowCollege(
                                                          college.id,
                                                          college['name'],
                                                        ),
                                                    icon: Icon(
                                                      isFollowing
                                                          ? Icons
                                                                .bookmark_rounded
                                                          : Icons
                                                                .bookmark_border_rounded,
                                                      color: isFollowing
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

                                                // College Info
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
                                                                  'Unknown College',
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
                                                        data['location'] ?? '',
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
                                                          _buildCollegeChip(
                                                            '🎓 ${data['acceptanceRate'] ?? 'N/A'}',
                                                            Color.fromRGBO(
                                                              88,
                                                              75,
                                                              245,
                                                              1,
                                                            ),
                                                          ),
                                                          _buildCollegeChip(
                                                            '💵 ${data['tuition'] ?? 'N/A'}',
                                                            Color.fromRGBO(
                                                              118,
                                                              251,
                                                              166,
                                                              1,
                                                            ),
                                                          ),
                                                          if (data['testOptional'] ==
                                                              true)
                                                            _buildCollegeChip(
                                                              '📝 Test Optional',
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
                                                        _navigateToCollegeProfile(
                                                          college,
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
                        Text(
                          "College Info may be outdated — please confirm key details",
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white70,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCollegeChip(String text, Color color) {
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
              'Filters applied - ${_filteredColleges.length} results',
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
                'Advanced Filters',
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

          // Filter Sections
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 175.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFilterSection('Basic Info', [
                    _buildFilterTextField(
                      'Location',
                      'location',
                      'e.g., California',
                    ),
                    _buildFilterTextField(
                      'Majors',
                      'majors',
                      'e.g., Computer Science',
                    ),
                    _buildSizeDropdown(),
                    _buildPublicPrivateDropdown(),
                  ]),

                  _buildFilterSection('Academic', [
                    _buildRangeSlider(
                      'Acceptance Rate (%)',
                      'acceptanceRateRange',
                      0,
                      100,
                      '${_activeFilters['acceptanceRateRange']!.start.round()}% - ${_activeFilters['acceptanceRateRange']!.end.round()}%',
                    ),
                    _buildRangeSlider(
                      'Average GPA',
                      'avgGPARange',
                      0.0,
                      4.0,
                      '${_activeFilters['avgGPARange']!.start.toStringAsFixed(1)} - ${_activeFilters['avgGPARange']!.end.toStringAsFixed(1)}',
                    ),
                    _buildRangeSlider(
                      'SAT Score',
                      'satScoreRange',
                      400,
                      1600,
                      '${_activeFilters['satScoreRange']!.start.round()} - ${_activeFilters['satScoreRange']!.end.round()}',
                    ),
                    _buildTestOptionalDropdown(),
                  ]),

                  _buildFilterSection('Financial', [
                    _buildRangeSlider(
                      'Annual Tuition (\$)',
                      'tuitionRange',
                      0,
                      100000,
                      '\$${_activeFilters['tuitionRange']!.start.round()} - \$${_activeFilters['tuitionRange']!.end.round()}',
                    ),
                    _buildFinancialAidDropdown(),
                  ]),

                  _buildFilterSection('Campus Life', [
                    _buildFilterTextField(
                      'Campus Setting',
                      'campusSetting',
                      'e.g., Urban, Rural',
                    ),
                    _buildFilterTextField(
                      'Student Population',
                      'studentPopulation',
                      'e.g., Large, Medium',
                    ),
                    _buildFilterTextField(
                      'Specialized Programs',
                      'specializedPrograms',
                      'e.g., Honors, Sports',
                    ),
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
                key == 'avgGPARange' ? 1 : 0,
              ),
              _activeFilters[key]!.end.toStringAsFixed(
                key == 'avgGPARange' ? 1 : 0,
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

  Widget _buildSizeDropdown() {
    return SizedBox(
      width: 305.w,
      child: DropdownButtonFormField<String>(
        value: _activeFilters['size']!.isEmpty ? null : _activeFilters['size'],
        onChanged: (value) {
          setState(() {
            _activeFilters['size'] = value ?? '';
          });
        },
        items: ['', 'Small', 'Medium', 'Large'].map((size) {
          return DropdownMenuItem(
            value: size.isEmpty ? null : size,
            child: Text(
              size.isEmpty ? 'Any Size' : size,
              style: GoogleFonts.spaceGrotesk(
                color: size.isEmpty ? Colors.white54 : Colors.white,
              ),
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'College Size',
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

  Widget _buildPublicPrivateDropdown() {
    return SizedBox(
      width: 305.w,
      child: DropdownButtonFormField<String>(
        value: _activeFilters['publicPrivate']!.isEmpty
            ? null
            : _activeFilters['publicPrivate'],
        onChanged: (value) {
          setState(() {
            _activeFilters['publicPrivate'] = value ?? '';
          });
        },
        items: ['', 'Public', 'Private'].map((type) {
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
          labelText: 'Public/Private',
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

  Widget _buildTestOptionalDropdown() {
    return SizedBox(
      width: 180.w,
      child: DropdownButtonFormField<bool?>(
        value: _activeFilters['testOptional'],
        onChanged: (value) {
          setState(() {
            _activeFilters['testOptional'] = value;
          });
        },
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(
              'Any Test Policy',
              style: GoogleFonts.spaceGrotesk(color: Colors.white54),
            ),
          ),
          DropdownMenuItem(
            value: true,
            child: Text(
              'Test Optional',
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
            ),
          ),
          DropdownMenuItem(
            value: false,
            child: Text(
              'Test Required',
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
            ),
          ),
        ],
        decoration: InputDecoration(
          // labelText: 'Test Policy',
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

  Widget _buildFinancialAidDropdown() {
    return SizedBox(
      width: 305.w,
      child: DropdownButtonFormField<bool?>(
        initialValue: _activeFilters['financialAid'],
        onChanged: (value) {
          setState(() {
            _activeFilters['financialAid'] = value;
          });
        },
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(
              'Any Financial Aid',
              style: GoogleFonts.spaceGrotesk(color: Colors.white54),
            ),
          ),
          DropdownMenuItem(
            value: true,
            child: Text(
              'Financial Aid Available',
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
            ),
          ),
          DropdownMenuItem(
            value: false,
            child: Text(
              'No Financial Aid',
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
            ),
          ),
        ],
        decoration: InputDecoration(
          // labelText: 'Financial Aid',
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

  void _showComparison() {
    if (_selectedColleges.length != 2) return;

    showDialog(
      context: context,
      builder: (context) => CollegeComparisonDialog(
        college1: _selectedColleges[0],
        college2: _selectedColleges[1],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class CollegeComparisonDialog extends StatelessWidget {
  final DocumentSnapshot college1;
  final DocumentSnapshot college2;

  const CollegeComparisonDialog({
    Key? key,
    required this.college1,
    required this.college2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data1 = college1.data() as Map<String, dynamic>;
    final data2 = college2.data() as Map<String, dynamic>;

    return Dialog(
      backgroundColor: Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.compare_arrows_rounded,
                    color: Color(0xFF00E676),
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'College Comparison',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Comparison Table
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Criteria',
                              style: GoogleFonts.spaceGrotesk(
                                color: Color(0xFF00E676),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              data1['name'] ?? 'College 1',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              data2['name'] ?? 'College 2',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Rows
                    _buildComparisonRow(
                      'Location',
                      data1['location'],
                      data2['location'],
                    ),
                    _buildComparisonRow(
                      'Acceptance Rate',
                      data1['acceptanceRate'],
                      data2['acceptanceRate'],
                    ),
                    _buildComparisonRow(
                      'Tuition',
                      data1['tuition'],
                      data2['tuition'],
                    ),
                    _buildComparisonRow(
                      'Student Size',
                      data1['size'],
                      data2['size'],
                    ),
                    _buildComparisonRow(
                      'Avg GPA',
                      data1['avgGPA'],
                      data2['avgGPA'],
                    ),
                    _buildComparisonRow(
                      'SAT Score',
                      data1['satScore'],
                      data2['satScore'],
                    ),
                    _buildComparisonRow(
                      'Test Optional',
                      data1['testOptional'] == true ? 'Yes' : 'No',
                      data2['testOptional'] == true ? 'Yes' : 'No',
                    ),
                    _buildComparisonRow(
                      'Campus Setting',
                      data1['campusSetting'],
                      data2['campusSetting'],
                    ),
                    _buildComparisonRow(
                      'Financial Aid',
                      data1['financialAidAvailable'] == true
                          ? 'Available'
                          : 'Not Available',
                      data2['financialAidAvailable'] == true
                          ? 'Available'
                          : 'Not Available',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3949AB), Color(0xFF1A237E)],
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close Comparison',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
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
    );
  }

  Widget _buildComparisonRow(String label, dynamic value1, dynamic value2) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white70,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value1?.toString() ?? 'N/A',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              value2?.toString() ?? 'N/A',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the CollegeProfilePage class the same as before, but update its styling to match the new theme
class CollegeProfilePage extends StatefulWidget {
  final DocumentSnapshot college;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const CollegeProfilePage({
    Key? key,
    required this.college,
    required this.isFollowing,
    required this.onFollowToggle,
  }) : super(key: key);

  @override
  State<CollegeProfilePage> createState() => _CollegeProfilePageState();
}

class _CollegeProfilePageState extends State<CollegeProfilePage> {
  late bool _currentIsFollowing;
  Set<String> _followedColleges = Set<String>();

  @override
  void initState() {
    super.initState();
    _currentIsFollowing = widget.isFollowing;
    _loadCurrentFollowStatus();
  }

  Future<void> _loadCurrentFollowStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_follows')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final collegeList = doc.data()!['list'] as List? ?? [];

        // Extract college names from the list
        final followedCollegeNames = collegeList
            .where((item) => item is Map<String, dynamic>)
            .map<String>((item) => item['collegeName']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet();

        setState(() {
          _followedColleges = followedCollegeNames;
          _currentIsFollowing = _followedColleges.contains(
            widget.college['name'],
          );
        });

        print(
          'Loaded ${_followedColleges.length} followed colleges in profile page',
        );
        print('Is ${widget.college['name']} followed: $_currentIsFollowing');
      }
    } catch (e) {
      print('Error loading follow status in profile page: $e');
    }
  }

  void _handleFollowToggle() {
    widget.onFollowToggle();
    setState(() {
      _currentIsFollowing = !_currentIsFollowing;

      // Update local followed colleges set
      final collegeName = widget.college['name']?.toString() ?? '';
      if (_currentIsFollowing) {
        _followedColleges.add(collegeName);
      } else {
        _followedColleges.remove(collegeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.college.data() as Map<String, dynamic>;

    return Scaffold(
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF48C4FF).withOpacity(0.25),
              const Color(0xFF2575FC).withOpacity(0.25),
            ],
          ),
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.25),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(50.r),
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
              selectedPageNotifier.value = 4;
              collegeNameNotiifer.value = data["name"] ?? "";
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white.withOpacity(0.95),
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Ask Gradmate',
                  style: GoogleFonts.montserrat(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
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
                              data['name'] ?? 'Unknown College',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              data['location'] ?? '',
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
                          onPressed: _handleFollowToggle,
                          icon: Icon(
                            _currentIsFollowing
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: _currentIsFollowing
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
                    Padding(
                      padding: EdgeInsets.only(left: 25.0.w),
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          _buildStatCard(
                            '🎓',
                            'Acceptance',
                            data['acceptanceRate'].toString() ?? 'N/A',
                          ),
                          _buildStatCard(
                            '💵',
                            'Tuition',
                            data['tuition'] ?? 'N/A',
                          ),
                          _buildStatCard(
                            '📊',
                            'GPA',
                            data['avgGPA']?.toString() ?? 'N/A',
                          ),
                          _buildStatCard(
                            '🎯',
                            'SAT',
                            data['satScore']?.toString() ?? 'N/A',
                          ),
                          _buildStatCard('👥', 'Size', data['size'] ?? 'N/A'),
                          _buildStatCard(
                            '📝',
                            'Tests',
                            data['testOptional'] == true
                                ? 'Optional'
                                : 'Required',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Popular Majors
                    if (data['majors'] is List &&
                        (data['majors'] as List).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Popular Majors',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: (data['majors'] as List).map((major) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3949AB).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(color: Color(0xFF3949AB)),
                                ),
                                child: Text(
                                  major.toString(),
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),

                    // Additional Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          '🏛️ Campus Setting',
                          data['campusSetting'],
                        ),
                        _buildInfoRow(
                          '💰 Financial Aid',
                          data['financialAidAvailable'] == true
                              ? 'Available'
                              : 'Not Available',
                        ),
                        _buildInfoRow(
                          '🎓 Student Population',
                          data['studentPopulation'],
                        ),
                        _buildInfoRow(
                          '🏫 Public/Private',
                          data['publicPrivate'],
                        ),
                        if (data['specializedPrograms'] is List &&
                            (data['specializedPrograms'] as List).isNotEmpty)
                          _buildInfoRow(
                            '🌟 Special Programs',
                            (data['specializedPrograms'] as List).join(', '),
                          ),
                      ],
                    ),
                    SizedBox(height: 20.h),
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

void _navigateToScholarships(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ScholarshipsPage()),
  );
}
