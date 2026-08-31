class JobOpeningModel {
  JobOpeningModel({
    required this.id,
    required this.title,
    required this.category,
    required this.department,
    required this.employmentType,
    required this.location,
    required this.experienceYears,
    required this.description,
    required this.keySkills,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String category;
  final String department;
  final String employmentType;
  final String location;
  final String experienceYears;
  final String description;
  final List<String> keySkills;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory JobOpeningModel.fromJson(Map<String, dynamic> json) {
    return JobOpeningModel(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      department: json['department'] as String,
      employmentType: json['employment_type'] as String,
      location: json['location'] as String,
      experienceYears: json['experience_years'] as String,
      description: json['description'] as String,
      keySkills: (json['key_skills'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class JobApplicationModel {
  JobApplicationModel({
    required this.id,
    required this.applicationReference,
    required this.jobOpeningId,
    required this.jobTitle,
    required this.jobCategory,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.currentLocation,
    required this.totalExperience,
    required this.noticePeriod,
    required this.resumeUrl,
    required this.resumeFileName,
    required this.resumeFileSize,
    required this.coverLetter,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String applicationReference;
  final int jobOpeningId;
  final String jobTitle;
  final String jobCategory;
  final String fullName;
  final String email;
  final String phone;
  final String currentLocation;
  final String totalExperience;
  final String noticePeriod;
  final String resumeUrl;
  final String resumeFileName;
  final int resumeFileSize;
  final String? coverLetter;
  final String status;
  final DateTime createdAt;

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] as int,
      applicationReference: json['application_reference'] as String,
      jobOpeningId: json['job_opening_id'] as int,
      jobTitle: json['job_title'] as String,
      jobCategory: json['job_category'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      currentLocation: json['current_location'] as String,
      totalExperience: json['total_experience'] as String,
      noticePeriod: json['notice_period'] as String,
      resumeUrl: json['resume_url'] as String,
      resumeFileName: json['resume_file_name'] as String,
      resumeFileSize: json['resume_file_size'] as int? ?? 0,
      coverLetter: json['cover_letter'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class HrApplicationsResponseModel {
  HrApplicationsResponseModel({
    required this.total,
    required this.items,
  });

  final int total;
  final List<JobApplicationModel> items;

  factory HrApplicationsResponseModel.fromJson(Map<String, dynamic> json) {
    return HrApplicationsResponseModel(
      total: json['total'] as int? ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => JobApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
