import '../data/careers_api.dart';

/// Validation helpers for the career application form.
abstract final class CareerFormValidators {
  CareerFormValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _nameRegex = RegExp(r"^[a-zA-Z][a-zA-Z\s.'-]*$");

  static final RegExp _indianMobileRegex = RegExp(r'^[6-9]\d{9}$');

  static const Set<String> allowedResumeExtensions = {'pdf', 'doc', 'docx'};

  static const int maxResumeBytes = 5 * 1024 * 1024;

  static const int maxCoverLetterLength = 2000;

  static String? fullName(String? value) {
    final String name = (value ?? '').trim();
    if (name.isEmpty) {
      return 'Full name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (name.length > 200) {
      return 'Name must be 200 characters or less';
    }
    if (!_nameRegex.hasMatch(name)) {
      return 'Name can only contain letters, spaces, and . \' -';
    }
    if (!name.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Enter a valid full name';
    }
    return null;
  }

  static String? email(String? value) {
    final String email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'Email address is required';
    }
    if (email.length > 200) {
      return 'Email must be 200 characters or less';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    final String digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return 'Phone number is required';
    }
    if (digits.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    if (!_indianMobileRegex.hasMatch(digits)) {
      return 'Mobile number must start with 6, 7, 8, or 9';
    }
    return null;
  }

  static String normalizedPhone(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  static String? requiredSelection(String? value, String fieldLabel) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select $fieldLabel';
    }
    return null;
  }

  static String? coverLetter(String? value) {
    final String letter = (value ?? '').trim();
    if (letter.isEmpty) {
      return null;
    }
    if (letter.length < 20) {
      return 'Cover letter must be at least 20 characters if provided';
    }
    if (letter.length > maxCoverLetterLength) {
      return 'Cover letter must be $maxCoverLetterLength characters or less';
    }
    return null;
  }

  static String? resumeFile({
    required String fileName,
    required int fileSize,
  }) {
    final String extension = _fileExtension(fileName);
    if (!allowedResumeExtensions.contains(extension)) {
      return 'Only PDF, DOC, and DOCX files are allowed';
    }
    if (fileSize <= 0) {
      return 'Selected file is empty';
    }
    if (fileSize > maxResumeBytes) {
      return 'Resume must be 5MB or smaller';
    }
    return null;
  }

  static String? resumeRequired(ResumeUploadResult? resume) {
    if (resume == null) {
      return 'Please upload your resume to continue';
    }
    return resumeFile(
      fileName: resume.fileName,
      fileSize: resume.fileSize,
    );
  }

  static String _fileExtension(String fileName) {
    final int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1).toLowerCase();
  }
}
