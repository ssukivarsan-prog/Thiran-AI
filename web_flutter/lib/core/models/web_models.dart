class WebBeneficiary {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String preferredLanguage;
  final String educationLevel;
  final String currentWork;
  final String previousExperience;
  final String location;
  final String mobilityConstraints;
  final int completionRate;

  WebBeneficiary({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.preferredLanguage,
    required this.educationLevel,
    required this.currentWork,
    required this.previousExperience,
    required this.location,
    required this.mobilityConstraints,
    required this.completionRate,
  });

  factory WebBeneficiary.fromJson(Map<String, dynamic> json) {
    return WebBeneficiary(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      preferredLanguage: json['preferredLanguage'] ?? 'ta',
      educationLevel: json['educationLevel'] ?? '',
      currentWork: json['currentWork'] ?? '',
      previousExperience: json['previousExperience'] ?? '',
      location: json['location'] ?? '',
      mobilityConstraints: json['mobilityConstraints'] ?? '',
      completionRate: json['completionRate'] ?? 0,
    );
  }
}

class WebKPIs {
  final int activeBeneficiaries;
  final int activeMentors;
  final int trainingCoursesCount;
  final int openOpportunities;
  final int completedPathways;
  final int pendingFollowUps;

  WebKPIs({
    required this.activeBeneficiaries,
    required this.activeMentors,
    required this.trainingCoursesCount,
    required this.openOpportunities,
    required this.completedPathways,
    required this.pendingFollowUps,
  });

  factory WebKPIs.fromJson(Map<String, dynamic> json) {
    return WebKPIs(
      activeBeneficiaries: json['activeBeneficiaries'] ?? 21,
      activeMentors: json['activeMentors'] ?? 10,
      trainingCoursesCount: json['trainingCoursesCount'] ?? 10,
      openOpportunities: json['openOpportunities'] ?? 15,
      completedPathways: json['completedPathways'] ?? 4,
      pendingFollowUps: json['pendingFollowUps'] ?? 1,
    );
  }
}

class WebConversation {
  final String id;
  final String beneficiaryId;
  final String channel;
  final String language;
  final String status;
  final String? escalationReason;
  final List<dynamic> messages;

  WebConversation({
    required this.id,
    required this.beneficiaryId,
    required this.channel,
    required this.language,
    required this.status,
    this.escalationReason,
    required this.messages,
  });

  factory WebConversation.fromJson(Map<String, dynamic> json) {
    return WebConversation(
      id: json['id'] ?? '',
      beneficiaryId: json['beneficiaryId'] ?? '',
      channel: json['channel'] ?? 'MOBILE_APP',
      language: json['language'] ?? 'ta',
      status: json['status'] ?? 'ACTIVE',
      escalationReason: json['escalationReason'],
      messages: json['messages'] ?? [],
    );
  }
}

class WebUser {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String phone;
  final String? token;
  final String organization;
  final String status;

  WebUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone = '',
    this.token,
    this.organization = 'Thiran AI Network',
    this.status = 'ACTIVE',
  });

  factory WebUser.fromJson(Map<String, dynamic> json, {String? token}) {
    return WebUser(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? 'Authorized User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'ADMINISTRATOR',
      phone: json['phone'] ?? '',
      token: token ?? json['token'],
      organization: json['organization'] ?? 'Thiran AI Network',
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'token': token,
      'organization': organization,
      'status': status,
    };
  }
}
