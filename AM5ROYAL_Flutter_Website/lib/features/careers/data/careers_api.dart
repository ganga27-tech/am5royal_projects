import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_api_client.dart';

class JobOpening {
  const JobOpening({
    required this.id,
    required this.title,
    required this.category,
    required this.department,
    required this.employmentType,
    required this.location,
    required this.experienceYears,
    required this.description,
    required this.keySkills,
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

  factory JobOpening.fromJson(Map<String, dynamic> json) {
    return JobOpening(
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
    );
  }
}

class ResumeUploadResult {
  const ResumeUploadResult({
    required this.url,
    required this.fileName,
    required this.fileSize,
  });

  final String url;
  final String fileName;
  final int fileSize;

  factory ResumeUploadResult.fromJson(Map<String, dynamic> json) {
    return ResumeUploadResult(
      url: json['url'] as String,
      fileName: json['file_name'] as String,
      fileSize: json['file_size'] as int,
    );
  }
}

class CareersApi {
  CareersApi({ApiClient? client}) : _client = client ?? AppApiClient.instance;

  final ApiClient _client;

  Future<List<JobOpening>> getOpenings() async {
    final list = await _client.getList('/careers/openings');
    return list
        .map((e) => JobOpening.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<JobOpening> getOpening(int id) async {
    final json = await _client.get('/careers/openings/$id');
    return JobOpening.fromJson(json);
  }

  Future<ResumeUploadResult> uploadResume({
    required List<int> bytes,
    required String fileName,
  }) async {
    final json = await _client.postMultipart(
      '/careers/upload-resume',
      fileField: 'file',
      fileName: fileName,
      bytes: bytes,
    );
    return ResumeUploadResult.fromJson(json);
  }

  Future<String> submitApplication({
    required int jobOpeningId,
    required String fullName,
    required String email,
    required String phone,
    required String currentLocation,
    required String totalExperience,
    required String noticePeriod,
    required String resumeUrl,
    required String resumeFileName,
    required int resumeFileSize,
    String? coverLetter,
  }) async {
    final json = await _client.post(
      '/careers/applications',
      body: {
        'job_opening_id': jobOpeningId,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'current_location': currentLocation,
        'total_experience': totalExperience,
        'notice_period': noticePeriod,
        'resume_url': resumeUrl,
        'resume_file_name': resumeFileName,
        'resume_file_size': resumeFileSize,
        if (coverLetter != null && coverLetter.isNotEmpty)
          'cover_letter': coverLetter,
      },
    );
    return json['application_reference'] as String;
  }
}

IconData categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'tech':
      return Icons.code_rounded;
    case 'marketing':
      return Icons.campaign_rounded;
    case 'operations':
      return Icons.verified_user_rounded;
    case 'hr':
      return Icons.groups_rounded;
    default:
      return Icons.work_outline_rounded;
  }
}
