class BeneficiaryProfileModel {
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
  final String preferredWorkType;
  final bool internetAccess;
  final int completionRate;

  BeneficiaryProfileModel({
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
    required this.preferredWorkType,
    required this.internetAccess,
    required this.completionRate,
  });

  factory BeneficiaryProfileModel.fromJson(Map<String, dynamic> json) {
    return BeneficiaryProfileModel(
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
      preferredWorkType: json['preferredWorkType'] ?? 'ANY',
      internetAccess: json['internetAccess'] ?? true,
      completionRate: json['completionRate'] ?? 0,
    );
  }

  BeneficiaryProfileModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? preferredLanguage,
    String? educationLevel,
    String? currentWork,
    String? previousExperience,
    String? location,
    String? mobilityConstraints,
    String? preferredWorkType,
    bool? internetAccess,
    int? completionRate,
  }) {
    return BeneficiaryProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      educationLevel: educationLevel ?? this.educationLevel,
      currentWork: currentWork ?? this.currentWork,
      previousExperience: previousExperience ?? this.previousExperience,
      location: location ?? this.location,
      mobilityConstraints: mobilityConstraints ?? this.mobilityConstraints,
      preferredWorkType: preferredWorkType ?? this.preferredWorkType,
      internetAccess: internetAccess ?? this.internetAccess,
      completionRate: completionRate ?? this.completionRate,
    );
  }
}

class UserSkillModel {
  final String id;
  final String skillName;
  final String proficiency;
  final String verificationType;
  final String? evidenceDescription;

  UserSkillModel({
    required this.id,
    required this.skillName,
    required this.proficiency,
    required this.verificationType,
    this.evidenceDescription,
  });

  factory UserSkillModel.fromJson(Map<String, dynamic> json) {
    return UserSkillModel(
      id: json['id'] ?? '',
      skillName: json['skillName'] ?? '',
      proficiency: json['proficiency'] ?? 'BEGINNER',
      verificationType: json['verificationType'] ?? 'SELF_DECLARED',
      evidenceDescription: json['evidenceDescription'],
    );
  }
}

class OpportunityModel {
  final String id;
  final String title;
  final String organizationName;
  final String category;
  final String location;
  final String workMode;
  final String compensation;
  final int vacancies;
  final List<String> formalRequirements;
  final List<String> requiredSkills;
  final String applicationDeadline;
  final String status;
  final int? alignmentScore;
  final List<String>? whyShown;
  final List<String>? missingRequirements;

  OpportunityModel({
    required this.id,
    required this.title,
    required this.organizationName,
    required this.category,
    required this.location,
    required this.workMode,
    required this.compensation,
    required this.vacancies,
    required this.formalRequirements,
    required this.requiredSkills,
    required this.applicationDeadline,
    required this.status,
    this.alignmentScore,
    this.whyShown,
    this.missingRequirements,
  });

  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    return OpportunityModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      organizationName: json['organizationName'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      workMode: json['workMode'] ?? 'ONSITE',
      compensation: json['compensation'] ?? '',
      vacancies: json['vacancies'] ?? 1,
      formalRequirements: List<String>.from(json['formalRequirements'] ?? []),
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      applicationDeadline: json['applicationDeadline'] ?? '',
      status: json['status'] ?? 'OPEN',
      alignmentScore: json['alignmentScore'],
      whyShown: json['whyShown'] != null ? List<String>.from(json['whyShown']) : null,
      missingRequirements: json['missingRequirements'] != null ? List<String>.from(json['missingRequirements']) : null,
    );
  }
}

class CourseModel {
  final String id;
  final String title;
  final String providerName;
  final String category;
  final String location;
  final String deliveryMode;
  final int durationWeeks;
  final int capacity;
  final int enrolledCount;
  final List<String> prerequisites;
  final List<String> skillsTaught;
  final String certificationName;
  final String status;

  CourseModel({
    required this.id,
    required this.title,
    required this.providerName,
    required this.category,
    required this.location,
    required this.deliveryMode,
    required this.durationWeeks,
    required this.capacity,
    required this.enrolledCount,
    required this.prerequisites,
    required this.skillsTaught,
    required this.certificationName,
    required this.status,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      providerName: json['providerName'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      deliveryMode: json['deliveryMode'] ?? 'IN_PERSON',
      durationWeeks: json['durationWeeks'] ?? 4,
      capacity: json['capacity'] ?? 30,
      enrolledCount: json['enrolledCount'] ?? 0,
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      skillsTaught: List<String>.from(json['skillsTaught'] ?? []),
      certificationName: json['certificationName'] ?? '',
      status: json['status'] ?? 'OPEN_FOR_ENROLLMENT',
    );
  }
}

class MentorModel {
  final String id;
  final String name;
  final List<String> expertise;
  final List<String> languages;
  final String serviceArea;
  final int yearsOfExperience;
  final String availabilityStatus;
  final String verificationStatus;
  final double rating;
  final int menteesCount;

  MentorModel({
    required this.id,
    required this.name,
    required this.expertise,
    required this.languages,
    required this.serviceArea,
    required this.yearsOfExperience,
    required this.availabilityStatus,
    required this.verificationStatus,
    required this.rating,
    required this.menteesCount,
  });

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    return MentorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      expertise: List<String>.from(json['expertise'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      serviceArea: json['serviceArea'] ?? '',
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      availabilityStatus: json['availabilityStatus'] ?? 'AVAILABLE',
      verificationStatus: json['verificationStatus'] ?? 'VERIFIED',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      menteesCount: json['menteesCount'] ?? 10,
    );
  }
}

class PathwayModel {
  final String id;
  final String beneficiaryId;
  final String targetRole;
  final String currentStage; // CURRENT | GAP | TRAIN | ASSESS | CERTIFY | APPLY
  final int alignmentScore;
  final List<String> satisfiedRequirements;
  final List<String> missingRequirements;
  final String nextAction;
  final int estimatedWeeks;

  PathwayModel({
    required this.id,
    required this.beneficiaryId,
    required this.targetRole,
    required this.currentStage,
    required this.alignmentScore,
    required this.satisfiedRequirements,
    required this.missingRequirements,
    required this.nextAction,
    required this.estimatedWeeks,
  });

  factory PathwayModel.fromJson(Map<String, dynamic> json) {
    return PathwayModel(
      id: json['id'] ?? '',
      beneficiaryId: json['beneficiaryId'] ?? '',
      targetRole: json['targetRole'] ?? 'Vocational Specialist',
      currentStage: json['currentStage'] ?? 'GAP',
      alignmentScore: json['alignmentScore'] ?? 75,
      satisfiedRequirements: List<String>.from(json['satisfiedRequirements'] ?? []),
      missingRequirements: List<String>.from(json['missingRequirements'] ?? []),
      nextAction: json['nextAction'] ?? 'Enroll in recommended skill module',
      estimatedWeeks: json['estimatedWeeks'] ?? 4,
    );
  }
}
