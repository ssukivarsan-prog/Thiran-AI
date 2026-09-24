import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../localization/app_strings.dart';
import '../models/models.dart';

enum NetworkState { online, syncing, offline }

class ApiService with ChangeNotifier {
  // Use localhost for Desktop/Web, or 10.0.2.2 for Android emulator
  static const String defaultBaseUrl = 'http://127.0.0.1:8000';
  static const List<String> fallbackUrls = ['http://127.0.0.1:8000', 'http://127.0.0.1:4000', 'http://localhost:8000', 'http://localhost:4000'];
  String _baseUrl = defaultBaseUrl;

  String? _authToken;
  String? _currentUserId;
  BeneficiaryProfileModel? _currentProfile;
  NetworkState _networkState = NetworkState.online;

  String get baseUrl => _baseUrl;
  String? get authToken => _authToken;
  String? get currentUserId => _currentUserId;
  BeneficiaryProfileModel? get currentProfile => _currentProfile;
  NetworkState get networkState => _networkState;

  void setBaseUrl(String url) {
    _baseUrl = url;
    notifyListeners();
  }

  void _setNetworkState(NetworkState state) {
    if (_networkState != state) {
      _networkState = state;
      notifyListeners();
    }
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // Direct login for quick demo persona switching with port discovery
  Future<bool> loginAsRole({String role = 'BENEFICIARY', String? phone}) async {
    for (final testUrl in fallbackUrls) {
      try {
        final res = await http.post(
          Uri.parse('$testUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'role': role, if (phone != null) 'phone': phone}),
        ).timeout(const Duration(milliseconds: 1200));

        if (res.statusCode == 200) {
          _baseUrl = testUrl;
          final data = jsonDecode(res.body)['data'];
          _authToken = data['token'];
          _currentUserId = data['user']['id'];
          _setNetworkState(NetworkState.online);
          await fetchProfile();
          return true;
        }
      } catch (_) {
        // try next fallback
      }
    }
    _setNetworkState(NetworkState.offline);
    _createOfflineMockProfile();
    return true;
  }

  void _createOfflineMockProfile() {
    _currentProfile = BeneficiaryProfileModel(
      id: 'ben-1',
      userId: 'usr-ben-1',
      fullName: 'Arun Kumar',
      phone: '+919840112301',
      preferredLanguage: 'ta',
      educationLevel: '10th Standard',
      currentWork: 'House wiring assistant',
      previousExperience: '2 years informal domestic electrical repair',
      location: 'Tiruchirappalli, Tamil Nadu',
      mobilityConstraints: 'Local district travel OK',
      preferredWorkType: 'WAGE_EMPLOYMENT',
      internetAccess: true,
      completionRate: 85,
    );
    notifyListeners();
  }

  void updateCurrentProfile(BeneficiaryProfileModel updated) {
    _currentProfile = updated;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/auth/me'), headers: _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        if (data['profile'] != null) {
          _currentProfile = BeneficiaryProfileModel.fromJson(data['profile']);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('fetchProfile error: $e');
      if (_currentProfile == null) _createOfflineMockProfile();
    }
  }

  // Get matched opportunities
  Future<List<OpportunityModel>> getMatchedOpportunities() async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/opportunities/match'),
        headers: _headers(),
        body: jsonEncode({'beneficiaryId': _currentProfile?.id ?? 'ben-1'}),
      );
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body)['data'] as List;
        return list.map((item) {
          final opp = OpportunityModel.fromJson(item['opportunity']);
          return OpportunityModel(
            id: opp.id,
            title: opp.title,
            organizationName: opp.organizationName,
            category: opp.category,
            location: opp.location,
            workMode: opp.workMode,
            compensation: opp.compensation,
            vacancies: opp.vacancies,
            formalRequirements: opp.formalRequirements,
            requiredSkills: opp.requiredSkills,
            applicationDeadline: opp.applicationDeadline,
            status: opp.status,
            alignmentScore: item['alignmentScore'],
            whyShown: item['whyShown'] != null ? List<String>.from(item['whyShown']) : null,
            missingRequirements: item['missingRequirements'] != null ? List<String>.from(item['missingRequirements']) : null,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('getMatchedOpportunities error: $e');
    }
    // Fallback cached opportunities
    return _mockOpportunities();
  }

  // Get active pathway
  Future<PathwayModel> getPathway() async {
    try {
      final benId = _currentProfile?.id ?? 'ben-1';
      final res = await http.get(Uri.parse('$_baseUrl/api/pathways/$benId'), headers: _headers());
      if (res.statusCode == 200) {
        return PathwayModel.fromJson(jsonDecode(res.body)['data']);
      }
    } catch (e) {
      debugPrint('getPathway error: $e');
    }
    return PathwayModel(
      id: 'pth-1',
      beneficiaryId: 'ben-1',
      targetRole: 'Solar PV Installation Technician',
      currentStage: 'TRAIN',
      alignmentScore: 78,
      satisfiedRequirements: ['10th Standard or ITI Electrician', 'Local district mobility confirmed'],
      missingRequirements: ['Certified Solar Rooftop Installer (Level 4)', 'Safety Earthing Field Assessment'],
      nextAction: 'Complete prerequisite vocational training module',
      estimatedWeeks: 4,
    );
  }

  // Run What-If Simulation
  Future<Map<String, dynamic>> simulatePathway({
    String? simulatedSkill,
    String? simulatedCourseId,
    String? simulatedWorkType,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/pathways/simulate'),
        headers: _headers(),
        body: jsonEncode({
          'beneficiaryId': _currentProfile?.id ?? 'ben-1',
          'simulatedSkill': simulatedSkill,
          'simulatedCourseId': simulatedCourseId,
          'simulatedWorkType': simulatedWorkType,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      }
    } catch (e) {
      debugPrint('simulatePathway error: $e');
    }
    return {
      'simulatedStage': simulatedCourseId != null ? 'APPLY' : 'ASSESS',
      'projectedAlignmentScore': simulatedCourseId != null ? 92 : 84,
      'formalRequirementsSatisfied': ['Baseline Education Satisfied', 'Simulation: Added Solar PV Certification'],
      'remainingGaps': ['Practical Verification on Site'],
      'estimatedWeeksToJobReady': 2,
    };
  }

  // Get Courses
  Future<List<CourseModel>> getCourses() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/training'), headers: _headers());
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body)['data'] as List;
        return list.map((i) => CourseModel.fromJson(i)).toList();
      }
    } catch (e) {
      debugPrint('getCourses error: $e');
    }
    return _mockCourses();
  }

  // Apply to Course
  Future<bool> applyCourse(String courseId) async {
    try {
      final res = await http.post(Uri.parse('$_baseUrl/api/training/$courseId/apply'), headers: _headers());
      return res.statusCode == 200;
    } catch (e) {
      return true; // cached optimistic
    }
  }

  // Get Mentors
  Future<List<MentorModel>> getMentors() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/mentors'), headers: _headers());
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body)['data'] as List;
        return list.map((i) => MentorModel.fromJson(i)).toList();
      }
    } catch (e) {
      debugPrint('getMentors error: $e');
    }
    return _mockMentors();
  }

  // Request Mentor
  Future<bool> requestMentor(String mentorId, String topic, String message) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/mentors/request'),
        headers: _headers(),
        body: jsonEncode({
          'mentorId': mentorId,
          'topic': topic,
          'message': message,
          'beneficiaryId': _currentProfile?.id ?? 'ben-1',
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      return true;
    }
  }

  // Voice Interview Next Question
  Future<Map<String, dynamic>> getVoiceNextQuestion(String language, List<Map<String, String>> history) async {
    if (_networkState != NetworkState.offline) {
      try {
        final res = await http.post(
          Uri.parse('$_baseUrl/api/beneficiaries/voice-interview/next'),
          headers: _headers(),
          body: jsonEncode({'language': language, 'history': history}),
        ).timeout(const Duration(milliseconds: 1000));
        if (res.statusCode == 200) {
          return jsonDecode(res.body)['data'];
        }
      } catch (e) {
        debugPrint('getVoiceNextQuestion error: $e');
      }
    }

    final qIndex = history.length < 3 ? history.length : 2;
    final qKeys = ['q1_text', 'q2_text', 'q3_text'];
    final tempAppStrings = AppStrings();
    tempAppStrings.setLanguage(language);
    final questionText = tempAppStrings.tr(qKeys[qIndex]);
    final replies = tempAppStrings.getSuggestionsForQuestion(qIndex);

    return {
      'questionId': 'q-${qIndex + 1}',
      'questionText': questionText,
      'language': language,
      'suggestedQuickReplies': replies,
      'isFinalQuestion': history.length >= 2,
    };
  }

  // Complete Voice Interview
  Future<Map<String, dynamic>> completeVoiceInterview(List<Map<String, String>> history, String language) async {
    if (_networkState != NetworkState.offline) {
      try {
        final res = await http.post(
          Uri.parse('$_baseUrl/api/beneficiaries/voice-interview/complete'),
          headers: _headers(),
          body: jsonEncode({
            'history': history,
            'language': language,
            'beneficiaryId': _currentProfile?.id ?? 'ben-1',
          }),
        ).timeout(const Duration(milliseconds: 1000));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body)['data'];
          final summary = data['understoodSummary'];
          if (summary != null && _currentProfile != null) {
            _currentProfile = _currentProfile!.copyWith(
              educationLevel: summary['education'],
              currentWork: summary['currentWork'],
              previousExperience: summary['experience'],
            );
            notifyListeners();
          }
          return data;
        }
      } catch (e) {
        debugPrint('completeVoiceInterview error: $e');
      }
    }

    final edu = (history.isNotEmpty && history[0]['answer'] != null && history[0]['answer']!.isNotEmpty && history[0]['answer'] != 'Skipped')
        ? history[0]['answer']!
        : (language == 'ta' ? '10-ஆம் வகுப்பு' : '10th Standard');
    final work = (history.length > 1 && history[1]['answer'] != null && history[1]['answer']!.isNotEmpty && history[1]['answer'] != 'Skipped')
        ? history[1]['answer']!
        : (language == 'ta' ? 'மின்சார வேலை உதவியாளர்' : 'Field Technical Apprentice');
    final exp = (history.length > 2 && history[2]['answer'] != null && history[2]['answer']!.isNotEmpty && history[2]['answer'] != 'Skipped')
        ? history[2]['answer']!
        : (language == 'ta' ? '2 ஆண்டுகள் அனுபவம்' : '2 years practical wiring');
    final asp = language == 'ta' ? 'சூரிய மின் நிறுவல் வல்லுநர்' : 'Solar Installation Technician';

    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(
        educationLevel: edu,
        currentWork: work,
        previousExperience: exp,
      );
      notifyListeners();
    }

    return {
      'understoodSummary': {
        'education': edu,
        'currentWork': work,
        'experience': exp,
        'aspirations': asp,
        'skills': [
          {'name': language == 'ta' ? 'சூரிய ஒளி மின்கல வயரிங்' : 'Solar PV Inverter Wiring', 'category': 'Renewable Energy', 'proficiency': 'INTERMEDIATE', 'verificationType': 'AI_INFERRED'},
          {'name': language == 'ta' ? 'வீட்டு மின்சார வயரிங்' : 'Basic Domestic Wiring', 'category': 'Electrical', 'proficiency': 'INTERMEDIATE', 'verificationType': 'SELF_DECLARED'}
        ],
      }
    };
  }

  List<OpportunityModel> _mockOpportunities() {
    return [
      OpportunityModel(
        id: 'opp-1',
        title: 'Solar PV Installation Technician (Field)',
        organizationName: 'SunVanguard CleanTech Solutions',
        category: 'Renewable Energy',
        location: 'Tiruchirappalli, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹18,000 - ₹24,000 / month',
        vacancies: 12,
        formalRequirements: ['10th Standard or ITI Electrician', 'Valid two-wheeler license'],
        requiredSkills: ['Solar PV Inverter Wiring'],
        applicationDeadline: '2026-10-30',
        status: 'OPEN',
        alignmentScore: 88,
        whyShown: ['Practical wiring experience aligns with role requirements', 'Located within commute distance'],
        missingRequirements: ['Level-4 Rooftop Solar Certification'],
      ),
      OpportunityModel(
        id: 'opp-2',
        title: 'Community Greenhouse Drone Operator',
        organizationName: 'Gramin Krishi Automation Cooperative',
        category: 'Agri-Tech',
        location: 'Coimbatore, Tamil Nadu',
        workMode: 'ONSITE',
        compensation: '₹20,000 - ₹26,000 / month',
        vacancies: 6,
        formalRequirements: ['12th Pass or Diploma'],
        requiredSkills: ['Agricultural Drone Spray Calibration'],
        applicationDeadline: '2026-11-15',
        status: 'OPEN',
        alignmentScore: 72,
        whyShown: ['Field technical literacy satisfied'],
        missingRequirements: ['Remote Micro-Drone Pilot License'],
      ),
    ];
  }

  List<CourseModel> _mockCourses() {
    return [
      CourseModel(
        id: 'crs-1',
        title: 'Government-Aligned Solar PV Technician Certification',
        providerName: 'National Skill Development Institute',
        category: 'Renewable Energy',
        location: 'Tiruchirappalli Skill Center',
        deliveryMode: 'HYBRID',
        durationWeeks: 6,
        capacity: 30,
        enrolledCount: 22,
        prerequisites: ['10th Pass or basic electrician experience'],
        skillsTaught: ['Solar PV Inverter Wiring'],
        certificationName: 'Certified Solar Rooftop Installer (Level 4)',
        status: 'OPEN_FOR_ENROLLMENT',
      ),
      CourseModel(
        id: 'crs-2',
        title: 'Light EV Battery Diagnostics & Servicing',
        providerName: 'Apex E-Mobility Skill Lab',
        category: 'Electric Mobility',
        location: 'Hosur Training Facility',
        deliveryMode: 'IN_PERSON',
        durationWeeks: 6,
        capacity: 20,
        enrolledCount: 14,
        prerequisites: ['Basic electrical or wiring knowledge'],
        skillsTaught: ['E-Rickshaw Battery Maintenance'],
        certificationName: 'EV Battery Service Specialist',
        status: 'OPEN_FOR_ENROLLMENT',
      ),
    ];
  }

  List<MentorModel> _mockMentors() {
    return [
      MentorModel(
        id: 'men-1',
        name: 'Murugan Sundaram',
        expertise: ['Solar Rooftop Installation', 'Micro-Grid Maintenance'],
        languages: ['Tamil', 'English'],
        serviceArea: 'Tiruchirappalli & Central TN',
        yearsOfExperience: 9,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 4.9,
        menteesCount: 28,
      ),
      MentorModel(
        id: 'men-2',
        name: 'Kavitha Radhakrishnan',
        expertise: ['Industrial Apparel Production', 'Pattern Design'],
        languages: ['Tamil', 'Malayalam'],
        serviceArea: 'Tiruppur & Coimbatore',
        yearsOfExperience: 12,
        availabilityStatus: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        rating: 4.8,
        menteesCount: 44,
      ),
    ];
  }
}
