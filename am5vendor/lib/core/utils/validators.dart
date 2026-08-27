import 'dart:io';

class FormValidators {
  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp _digitsOnly = RegExp(r'^\d+$');
  static final RegExp _indianMobile = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _pincodeRegex = RegExp(r'^[1-9][0-9]{5}$');

  // ─── Name validators ───────────────────────────────────────────────────────

  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (trimmed.length > 50) {
      return 'First name must not exceed 50 characters';
    }
    if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(trimmed)) {
      return 'First name must contain only alphabets and spaces';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 1) {
      return 'Last name is required';
    }
    if (trimmed.length > 50) {
      return 'Last name must not exceed 50 characters';
    }
    if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(trimmed)) {
      return 'Last name must contain only alphabets and spaces';
    }
    return null;
  }

  static String? validateFatherName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Father name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Father name must be at least 2 characters';
    }
    if (trimmed.length > 100) {
      return 'Father name must not exceed 100 characters';
    }
    if (!RegExp(r'^[A-Za-z\s.]+$').hasMatch(trimmed)) {
      return 'Father name can only contain letters, spaces, and dots';
    }
    return null;
  }

  // ─── Contact validators ────────────────────────────────────────────────────

  /// Required 10-digit Indian mobile number (starts with 6-9).
  static String? validateMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final clean = value.trim().replaceAll(RegExp(r'\D'), '');
    if (clean.length != 10) {
      return 'Mobile number must be exactly 10 digits';
    }
    if (!_indianMobile.hasMatch(clean)) {
      return 'Enter a valid 10-digit mobile number (starts with 6-9)';
    }
    return null;
  }

  /// Optional alternate mobile — empty is fine; if provided must be valid.
  static String? validateAltMobile(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final clean = value.trim().replaceAll(RegExp(r'\D'), '');
    if (clean.length != 10) {
      return 'Alternative mobile number must be exactly 10 digits';
    }
    if (!_indianMobile.hasMatch(clean)) {
      return 'Enter a valid 10-digit mobile number (starts with 6-9)';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // ─── Document / Identity validators ───────────────────────────────────────

  /// Aadhaar: required, exactly 12 numeric digits, no spaces/hyphens.
  static String? validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhaar number is required';
    }
    final clean = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!_digitsOnly.hasMatch(clean)) {
      return 'Aadhaar number must contain only digits';
    }
    if (clean.length < 12) {
      return 'Aadhaar number must be exactly 12 digits (${clean.length}/12)';
    }
    if (clean.length > 12) {
      return 'Aadhaar number must be exactly 12 digits';
    }
    return null;
  }

  /// PAN: optional; if entered must match valid Indian PAN format (5 letters, 4 digits, 1 letter).
  /// 4th character represents holder type (P, C, H, F, A, T, B, L, J, G).
  static String? validatePAN(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final pan = value.trim().toUpperCase();
    if (pan.length != 10) {
      return 'PAN must be exactly 10 characters (e.g. ABCDE1234F)';
    }
    // Standard Indian PAN format: 3 alphabets, 4th char holder type, 5th char surname initial/name, 4 numbers, 1 check letter
    final panRegex = RegExp(r'^[A-Z]{3}[PCHFSTBLJGpchfstbljg][A-Z]\d{4}[A-Z]$');
    if (!panRegex.hasMatch(pan)) {
      return 'Invalid PAN number format (e.g. ABCDE1234F)';
    }
    return null;
  }

  /// MSME / Udyam: optional; if entered must match UDYAM-XX-YY-1234567.
  static String? validateMSME(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final msme = value.trim().toUpperCase();
    // Format: UDYAM-AP-12-1234567
    final msmeRegex = RegExp(r'^UDYAM-[A-Z]{2}-\d{2}-\d{7}$');
    if (!msmeRegex.hasMatch(msme)) {
      return 'Invalid MSME format. Expected: UDYAM-AP-12-1234567';
    }
    return null;
  }

  /// USC: optional; if entered must be numeric only (min 6 digits, max 20 digits).
  static String? validateUSC(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final clean = value.trim();
    if (!_digitsOnly.hasMatch(clean)) {
      return 'USC number must contain digits only';
    }
    if (clean.length < 6) {
      return 'USC number must be at least 6 digits';
    }
    if (clean.length > 20) {
      return 'USC number cannot exceed 20 digits';
    }
    return null;
  }

  /// Current Bill Number: optional; if entered must contain valid alphanumeric bill/consumer number format.
  static String? validateCurrentBill(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final clean = value.trim();
    if (clean.length < 5) {
      return 'Current bill number must be at least 5 characters';
    }
    if (clean.length > 25) {
      return 'Current bill number cannot exceed 25 characters';
    }
    final billRegex = RegExp(r'^[A-Za-z0-9\-\/]+$');
    if (!billRegex.hasMatch(clean)) {
      return 'Current bill number contains invalid characters';
    }
    return null;
  }

  // ─── Business validators ───────────────────────────────────────────────────

  static String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional for business
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Business name must be at least 3 characters';
    }
    if (trimmed.length > 100) {
      return 'Business name must not exceed 100 characters';
    }
    return null;
  }

  // ─── Address validators ────────────────────────────────────────────────────

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 10) {
      return 'Please enter a complete address (min 10 characters)';
    }
    if (trimmed.length > 250) {
      return 'Address must not exceed 250 characters';
    }
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) return 'City is required';
    final trimmed = value.trim();
    if (trimmed.length < 2) return 'City name must be at least 2 characters';
    if (!RegExp(r'^[A-Za-z\s.\-]+$').hasMatch(trimmed)) {
      return 'City can only contain letters, spaces, and hyphens';
    }
    return null;
  }

  static String? validateDistrict(String? value) {
    if (value == null || value.trim().isEmpty) return 'District is required';
    final trimmed = value.trim();
    if (trimmed.length < 2)
      return 'District name must be at least 2 characters';
    if (!RegExp(r'^[A-Za-z\s.\-]+$').hasMatch(trimmed)) {
      return 'District can only contain letters, spaces, and hyphens';
    }
    return null;
  }

  static String? validateState(String? value) {
    if (value == null || value.trim().isEmpty) return 'State is required';
    final trimmed = value.trim();
    if (trimmed.length < 2) return 'State name must be at least 2 characters';
    if (!RegExp(r'^[A-Za-z\s.\-]+$').hasMatch(trimmed)) {
      return 'State can only contain letters, spaces, and hyphens';
    }
    return null;
  }

  static String? validateStreet(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.length < 2) return 'Street/Area must be at least 2 characters';
    if (!RegExp(r'^[A-Za-z0-9\s,.\-\/#]+$').hasMatch(trimmed)) {
      return 'Street contains invalid characters';
    }
    return null;
  }

  /// Pincode: required, exactly 6 digits starting 1-9 (cannot start with 0).
  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    final clean = value.trim();
    if (clean.startsWith('0')) {
      return 'Pincode cannot start with 0';
    }
    if (clean.length != 6) {
      return 'Pincode must be exactly 6 digits';
    }
    if (!_pincodeRegex.hasMatch(clean)) {
      return 'Enter a valid 6-digit Indian Pincode (starts 1-9)';
    }
    return null;
  }

  static String? validateServiceRadius(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Service radius is required';
    }
    final radius = int.tryParse(value.trim());
    if (radius == null || radius < 1) {
      return 'Service radius must be greater than 0';
    }
    if (radius > 500) {
      return 'Service radius cannot exceed 500 KM';
    }
    return null;
  }

  // ─── File validators ───────────────────────────────────────────────────────

  static String? validateProfileImage(File? imageFile) {
    if (imageFile == null) return 'Profile image is required';
    final path = imageFile.path.toLowerCase();
    final isSupported = path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp');
    if (!isSupported) {
      return 'Profile image must be in JPG, JPEG, PNG, or WEBP format';
    }
    try {
      final sizeInMb = imageFile.lengthSync() / (1024 * 1024);
      if (sizeInMb > 5.0) {
        return 'Image size must be less than 5 MB';
      }
    } catch (_) {}
    return null;
  }
}
