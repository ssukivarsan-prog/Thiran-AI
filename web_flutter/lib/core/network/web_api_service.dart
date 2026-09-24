import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/web_mock_data.dart';
import '../models/web_models.dart';

class DemoAccount {
  final String role;
  final String title;
  final String email;
  final String fullName;
  final String organization;
  final String defaultPassword;
  final String description;
  final List<int> allowedTabs;

  const DemoAccount({
    required this.role,
    required this.title,
    required this.email,
    required this.fullName,
    required this.organization,
    this.defaultPassword = 'password123',
    required this.description,
    required this.allowedTabs,
  });
}

class WebApiService with ChangeNotifier {
  static const String defaultBaseUrl = 'http://127.0.0.1:4000';
  static const List<String> fallbackUrls = [
    'http://127.0.0.1:4000',
    'http://localhost:4000',
    'http://127.0.0.1:8000',
    'http://localhost:8000',
  ];

  String _baseUrl = defaultBaseUrl;
  String? _token;
  String _activeRole = 'ADMINISTRATOR';
  WebUser? _currentUser;

  // In-memory mutable lists for interactive demo changes
  final List<Map<String, dynamic>> _tickets = List<Map<String, dynamic>>.from(WebMockData.getTickets());

  static const List<DemoAccount> demoAccounts = [
    DemoAccount(
      role: 'ADMINISTRATOR',
      title: 'Operations Administrator',
      email: 'admin@thiran.ai',
      fullName: 'Natarajan Ramachandran',
      organization: 'Thiran AI Platform Operations',
      description: 'Full system privileges across all modules, analytics, telemetry, and escalations',
      allowedTabs: [0, 1, 2, 3, 4, 5, 6],
    ),
    DemoAccount(
      role: 'TRAINING_PROVIDER',
      title: 'Vocational Training Partner',
      email: 'training@thiran.ai',
      fullName: 'Dr. K. Senthil Kumar',
      organization: 'Apex Technical Institute (NSDC)',
      description: 'Manage specialized livelihood curricula, student batches, and mentor links',
      allowedTabs: [2, 1, 4],
    ),
    DemoAccount(
      role: 'EMPLOYER',
      title: 'Hiring Enterprise Partner',
      email: 'employer@thiran.ai',
      fullName: 'Pooja Krishnan',
      organization: 'SunVanguard CleanTech Solutions',
      description: 'Create job postings, review AI skill-matched applicants, and track hires',
      allowedTabs: [3, 1],
    ),
    DemoAccount(
      role: 'SUPPORT_WORKER',
      title: 'Field Counselor & Support Lead',
      email: 'support@thiran.ai',
      fullName: 'Shalini Devi',
      organization: 'Gramin Community Center',
      description: 'Triage beneficiary verification, resolve escalation tickets, and manage comms',
      allowedTabs: [1, 6, 5, 4],
    ),
    DemoAccount(
      role: 'MENTOR',
      title: 'Livelihood & Technical Mentor',
      email: 'mentor@thiran.ai',
      fullName: 'Murugan Sundaram',
      organization: 'Renewable Energy Mentorship Guild',
      description: 'Mentor field workers, verify practical experience, and conduct guidance calls',
      allowedTabs: [4, 1],
    ),
  ];

  String get baseUrl => _baseUrl;
  String get activeRole => _currentUser?.role ?? _activeRole;
  WebUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  DemoAccount get activeDemoAccount {
    return demoAccounts.firstWhere(
      (d) => d.role == activeRole,
      orElse: () => demoAccounts.first,
    );
  }

  void setRole(String role) {
    _activeRole = role;
    if (_currentUser != null) {
      final demo = demoAccounts.firstWhere(
        (d) => d.role == role,
        orElse: () => demoAccounts.first,
      );
      _currentUser = WebUser(
        id: _currentUser!.id,
        fullName: demo.fullName,
        email: demo.email,
        role: role,
        phone: _currentUser!.phone,
        token: _token,
        organization: demo.organization,
      );
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password, String? role}) async {
    final cleanEmail = email.trim().toLowerCase();

    // Find matching demo account or infer role
    DemoAccount demo = demoAccounts.firstWhere(
      (d) => d.email.toLowerCase() == cleanEmail || (role != null && d.role == role),
      orElse: () => demoAccounts.first,
    );

    final targetRole = role ?? demo.role;

    for (final testUrl in fallbackUrls) {
      try {
        final res = await http.post(
          Uri.parse('$testUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'role': targetRole, 'phone': cleanEmail.contains('@') ? null : cleanEmail}),
        ).timeout(const Duration(milliseconds: 1200));

        if (res.statusCode == 200) {
          _baseUrl = testUrl;
          final data = jsonDecode(res.body)['data'];
          _token = data['token'];
          final userJson = data['user'] ?? {};
          _currentUser = WebUser(
            id: userJson['id'] ?? 'usr-1',
            fullName: userJson['fullName'] ?? demo.fullName,
            email: userJson['email'] ?? (cleanEmail.isNotEmpty ? cleanEmail : demo.email),
            role: userJson['role'] ?? targetRole,
            phone: userJson['phone'] ?? '+919000000001',
            token: _token,
            organization: demo.organization,
          );
          _activeRole = _currentUser!.role;
          notifyListeners();
          return true;
        }
      } catch (_) {
        // try next
      }
    }

    // Fallback authenticated session
    _token = 'offline-jwt-${DateTime.now().millisecondsSinceEpoch}';
    _currentUser = WebUser(
      id: 'usr-${targetRole.toLowerCase()}-1',
      fullName: demo.fullName,
      email: cleanEmail.isNotEmpty ? cleanEmail : demo.email,
      role: targetRole,
      phone: '+919000000001',
      token: _token,
      organization: demo.organization,
    );
    _activeRole = targetRole;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _token = null;
    _activeRole = 'ADMINISTRATOR';
    notifyListeners();
  }

  bool canAccessTab(int tabIndex) {
    if (_currentUser == null) return false;
    final demo = demoAccounts.firstWhere(
      (d) => d.role == activeRole,
      orElse: () => demoAccounts.first,
    );
    return demo.allowedTabs.contains(tabIndex);
  }

  List<int> getPermittedTabs() {
    final demo = demoAccounts.firstWhere(
      (d) => d.role == activeRole,
      orElse: () => demoAccounts.first,
    );
    return demo.allowedTabs;
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<void> ensureAuth() async {
    if (_token != null) return;
    for (final testUrl in fallbackUrls) {
      try {
        final res = await http.post(
          Uri.parse('$testUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'role': _activeRole}),
        ).timeout(const Duration(milliseconds: 1200));

        if (res.statusCode == 200) {
          _baseUrl = testUrl;
          _token = jsonDecode(res.body)['data']['token'];
          return;
        }
      } catch (_) {
        // try next port
      }
    }
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    await ensureAuth();
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/admin/analytics'), headers: _headers());
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      }
    } catch (e) {
      debugPrint('getAnalytics Error: $e');
    }
    return WebMockData.getAnalytics();
  }

  Future<List<WebBeneficiary>> getBeneficiaries({String? search}) async {
    await ensureAuth();
    try {
      final query = search != null && search.isNotEmpty ? '?search=$search' : '';
      final res = await http.get(Uri.parse('$_baseUrl/api/beneficiaries$query'), headers: _headers());
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body)['data'] as List;
        return list.map((i) => WebBeneficiary.fromJson(i)).toList();
      }
    } catch (e) {
      debugPrint('getBeneficiaries Error: $e');
    }

    final all = WebMockData.getBeneficiaries();
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      return all.where((b) {
        return b.fullName.toLowerCase().contains(q) ||
            b.location.toLowerCase().contains(q) ||
            b.currentWork.toLowerCase().contains(q) ||
            b.previousExperience.toLowerCase().contains(q) ||
            b.phone.contains(q);
      }).toList();
    }
    return all;
  }

  Future<Map<String, dynamic>> getBeneficiaryDetails(String id) async {
    await ensureAuth();
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/beneficiaries/$id'), headers: _headers());
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      }
    } catch (e) {
      debugPrint('getBeneficiaryDetails Error: $e');
    }

    final all = WebMockData.getBeneficiaries();
    final match = all.firstWhere((b) => b.id == id, orElse: () => all.first);
    return {
      'id': match.id,
      'fullName': match.fullName,
      'phone': match.phone,
      'preferredLanguage': match.preferredLanguage,
      'educationLevel': match.educationLevel,
      'currentWork': match.currentWork,
      'previousExperience': match.previousExperience,
      'location': match.location,
      'mobilityConstraints': match.mobilityConstraints,
      'completionRate': match.completionRate,
      'targetRole': 'Solar PV Technician / Certified Specialist',
      'skills': ['Basic Domestic Wiring', 'Circuit Safety'],
      'skillGaps': ['Solar PV Inverter Wiring', 'Earthing & Lightning Arrestors'],
    };
  }

  Future<List<dynamic>> getCourses() async {
    for (final testUrl in fallbackUrls) {
      try {
        final res = await http.get(Uri.parse('$testUrl/api/training')).timeout(const Duration(milliseconds: 1000));
        if (res.statusCode == 200) {
          final list = jsonDecode(res.body)['data'] as List;
          if (list.isNotEmpty) return list;
        }
      } catch (_) {}
    }
    return WebMockData.getCourses();
  }

  Future<List<dynamic>> getOpportunities() async {
    for (final testUrl in fallbackUrls) {
      try {
        final res = await http.get(Uri.parse('$testUrl/api/opportunities')).timeout(const Duration(milliseconds: 1000));
        if (res.statusCode == 200) {
          final list = jsonDecode(res.body)['data'] as List;
          if (list.isNotEmpty) return list;
        }
      } catch (_) {}
    }
    return WebMockData.getOpportunities();
  }

  Future<List<dynamic>> getMentors() async {
    for (final testUrl in fallbackUrls) {
      try {
        final res = await http.get(Uri.parse('$testUrl/api/mentors')).timeout(const Duration(milliseconds: 1000));
        if (res.statusCode == 200) {
          final list = jsonDecode(res.body)['data'] as List;
          if (list.isNotEmpty) return list;
        }
      } catch (_) {}
    }
    return WebMockData.getMentors();
  }

  Future<List<dynamic>> getConversations() async {
    await ensureAuth();
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/conversations'), headers: _headers());
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body)['data'] as List;
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('getConversations Error: $e');
    }
    return WebMockData.getConversations();
  }

  Future<List<dynamic>> getTickets() async {
    await ensureAuth();
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/admin/tickets'), headers: _headers());
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body)['data'] as List;
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('getTickets Error: $e');
    }
    return _tickets;
  }

  Future<void> resolveTicket(String ticketId, String notes) async {
    await ensureAuth();
    try {
      await http.patch(
        Uri.parse('$_baseUrl/api/admin/tickets/$ticketId'),
        headers: _headers(),
        body: jsonEncode({'status': 'RESOLVED', 'notes': notes}),
      );
    } catch (e) {
      debugPrint('resolveTicket error: $e');
    }

    for (final t in _tickets) {
      if (t['id'] == ticketId) {
        t['status'] = 'RESOLVED';
        t['notes'] = notes;
      }
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> simulateWhatsAppMessage(String phone, String text) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/webhooks/whatsapp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'from': phone, 'message': text}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {
        'status': 'DELIVERED',
        'response': 'வணக்கம்! உங்கள் செய்தி பெறப்பட்டது. திறன் ஆலோசகர் விரைவில் பதிலளிப்பார் (Simulated Response).'
      };
    }
  }

  Future<Map<String, dynamic>> simulateIVRCall(String phone, String speechOrDigit) async {
    try {
      final startRes = await http.post(
        Uri.parse('$_baseUrl/api/webhooks/ivr/call-start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'From': phone}),
      );
      final sid = jsonDecode(startRes.body)['callSid'];
      final inputRes = await http.post(
        Uri.parse('$_baseUrl/api/webhooks/ivr/input'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'CallSid': sid, 'Digits': '1', 'SpeechResult': speechOrDigit}),
      );
      return jsonDecode(inputRes.body);
    } catch (e) {
      return {
        'status': 'CALL_COMPLETED',
        'ttsMessage': 'வணக்கம்! உங்கள் குரல் பதிவு செய்யப்பட்டது. தகுதி சான்றிதழ் விவரங்கள் குறுஞ்செய்தியாக அனுப்பப்படும்.'
      };
    }
  }
}
