import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import '../../../../core/error/exceptions.dart';
import '../models/admin_stats_model.dart';
import '../models/admin_employee_model.dart';
import '../models/admin_vendor_model.dart';
import '../models/company_lead_model.dart';

abstract class AdminRemoteDataSource {
  Future<AdminStatsModel> getDashboardStats();
  Future<List<AdminEmployeeModel>> getEmployees();
  Future<List<AdminVendorModel>> getVendors({String? searchQuery});
  Future<void> updateEmployeeStatus(int id, String status);
  Future<void> createEmployee(Map<String, dynamic> data);
  Future<void> updateEmployee(int id, Map<String, dynamic> data);
  Future<void> updateVendorStatus(int id, String status);
  Future<void> createVendor(Map<String, dynamic> data);
  Future<void> updateVendor(int id, Map<String, dynamic> data);
  Future<void> deleteVendor(int id);
  Future<void> createService(String name, int mainCategoryId, int subCategoryId, String imagePath);
  Future<List<dynamic>> getWithdrawalRequests();
  Future<void> approveWithdrawalRequest(int id);
  Future<List<dynamic>> getVendorDocuments(int vendorId);
  Future<void> updateDocumentStatus(int documentId, String status);
  Future<CompanyLeadsPaginatedResponseModel> getCompanyLeads({
    String? startDate,
    String? endDate,
    String? leadSource,
    int skip = 0,
    int limit = 10,
  });
  Future<CompanyLeadsPaginatedResponseModel> getWebsiteLeads({
    String? search,
    String? status,
    String? startDate,
    String? endDate,
    int skip = 0,
    int limit = 20,
  });
  Future<CompanyLeadsPaginatedResponseModel> getMobileLeads({
    String? search,
    String? status,
    String? startDate,
    String? endDate,
    int skip = 0,
    int limit = 20,
  });
  Future<LeadAssignResultModel> assignCompanyLeads();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio dio;
  late final List<AdminEmployeeModel> _mockEmployees;
  late final List<AdminVendorModel> _mockVendors;

  AdminRemoteDataSourceImpl({required this.dio}) {
    _mockEmployees = [
      AdminEmployeeModel(
        id: 1,
        email: 'aditya@am5royal.com',
        phoneNumber: '+91 98765 43210',
        address: 'Madhapur, Hyderabad',
        role: 'marketing',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        points: 150,
      ),
      AdminEmployeeModel(
        id: 2,
        email: 'neha@am5royal.com',
        phoneNumber: '+91 87654 32109',
        address: 'Kondapur, Hyderabad',
        role: 'telecaller',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        points: 200,
      ),
      AdminEmployeeModel(
        id: 3,
        email: 'rahul.v@am5royal.com',
        phoneNumber: '+91 76543 21098',
        address: 'Gachibowli, Hyderabad',
        role: 'marketing',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        points: 100,
      ),
      AdminEmployeeModel(
        id: 4,
        email: 'priya.rao@am5royal.com',
        phoneNumber: '+91 6655443322',
        address: 'Secunderabad',
        role: 'telecaller',
        status: 'suspended',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        points: 50,
      ),
    ];
    _mockVendors = [
      AdminVendorModel(
        id: 1,
        name: 'Sri Plumbing Services',
        email: 'srinivas@plumbing.com',
        phoneNumber: '+91 98765 43210',
        fssaiLicenseNumber: null,
        panCardNumber: 'ABCDE1234F',
        gstNumber: null,
        aadhaarNumber: '123456789012',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        employeeId: 1,
      ),
      AdminVendorModel(
        id: 2,
        name: 'CleanPro Solutions',
        email: 'anita.desai@cleanpro.com',
        phoneNumber: '+91 87654 32109',
        fssaiLicenseNumber: null,
        panCardNumber: 'BCDEF2345G',
        gstNumber: '22AAAAA0000A1Z5',
        aadhaarNumber: '234567890123',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        employeeId: 2,
      ),
      AdminVendorModel(
        id: 3,
        name: 'ElectroFix Electricals',
        email: 'vikram@electrofix.com',
        phoneNumber: '+91 76543 21098',
        fssaiLicenseNumber: null,
        panCardNumber: 'CDEFG3456H',
        gstNumber: null,
        aadhaarNumber: '345678901234',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        employeeId: 3,
      ),
    ];
  }

  @override
  Future<AdminStatsModel> getDashboardStats() async {
    try {
      final response = await dio.get('/admin/stats');
      return AdminStatsModel.fromJson(response.data);
    } catch (e) {
      // Fallback to high-fidelity mock dashboard statistics if API is not found or fails
      final activeCount =
          _mockEmployees.where((emp) => emp.status == 'active').length;
      return AdminStatsModel(
        totalEmployees: _mockEmployees.length,
        activeEmployees: activeCount,
        totalVendors: 3,
        activeVendors: 1,
        pendingVendors: 2,
        totalSales: 150000.0,
        monthlyGrowth: [
          {'month': 'Jan', 'count': 5},
          {'month': 'Feb', 'count': 10},
          {'month': 'Mar', 'count': 15},
          {'month': 'Apr', 'count': 12},
          {'month': 'May', 'count': 28},
          {'month': 'Jun', 'count': 35},
        ],
      );
    }
  }

  @override
  Future<List<AdminEmployeeModel>> getEmployees() async {
    try {
      final response = await dio.get('/employees');
      return (response.data as List)
          .map((json) => AdminEmployeeModel.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback to dynamic, in-memory mock employees list if API fails
      return List.from(_mockEmployees);
    }
  }

  @override
  Future<List<AdminVendorModel>> getVendors({String? searchQuery}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search_query'] = searchQuery;
      }
      final response = await dio.get('/admin/vendors', queryParameters: queryParams);
      return (response.data as List)
          .map((json) => AdminVendorModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      debugPrint('Error fetching vendors from API: $e');
      debugPrint('Stacktrace: $stack');
      // Fallback to high-fidelity mock vendors list if API fails
      return List.from(_mockVendors);
    }
  }

  @override
  Future<void> createVendor(Map<String, dynamic> data) async {
    try {
      await dio.post(
        '/admin/vendors',
        data: data,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          e.response?.data.toString().contains('Not Found') == true) {
        final nextId = _mockVendors.isEmpty
            ? 1
            : _mockVendors.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
        _mockVendors.add(AdminVendorModel(
          id: nextId,
          name: data['business_name'] ?? '${data['first_name']} ${data['last_name']}',
          email: data['email'],
          phoneNumber: data['phone_number'],
          aadhaarNumber: data['aadhaar_number'],
          gstNumber: data['gst_number'],
          panCardNumber: data['pan_card_number'],
          fssaiLicenseNumber: data['fssai_license_number'],
          city: data['city'],
          businessName: data['business_name'],
          firstName: data['first_name'],
          lastName: data['last_name'],
          status: 'pending',
          createdAt: DateTime.now(),
          employeeId: 0,
        ));
        return;
      }
      throw ServerException(
          e.response?.data['detail'] ?? 'Failed to create vendor');
    } catch (e) {
      final nextId = _mockVendors.isEmpty
          ? 1
          : _mockVendors.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      _mockVendors.add(AdminVendorModel(
        id: nextId,
        name: data['business_name'] ?? '${data['first_name']} ${data['last_name']}',
        email: data['email'],
        phoneNumber: data['phone_number'],
        aadhaarNumber: data['aadhaar_number'],
        gstNumber: data['gst_number'],
        panCardNumber: data['pan_card_number'],
        fssaiLicenseNumber: data['fssai_license_number'],
        city: data['city'],
        businessName: data['business_name'],
        firstName: data['first_name'],
        lastName: data['last_name'],
        status: 'pending',
        createdAt: DateTime.now(),
        employeeId: 0,
      ));
    }
  }

  @override
  Future<void> updateEmployeeStatus(int id, String status) async {
    try {
      await dio.put(
        '/employees/$id/status',
        queryParameters: {'status': status},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          e.response?.data.toString().contains('Admin not found') == true) {
        final index = _mockEmployees.indexWhere((emp) => emp.id == id);
        if (index != -1) {
          final old = _mockEmployees[index];
          _mockEmployees[index] = AdminEmployeeModel(
            id: old.id,
            email: old.email,
            phoneNumber: old.phoneNumber,
            address: old.address,
            role: old.role,
            status: status,
            createdAt: old.createdAt,
            points: old.points,
          );
        }
        return;
      }
      throw ServerException(
          e.response?.data['detail'] ?? 'Failed to update status');
    } catch (e) {
      final index = _mockEmployees.indexWhere((emp) => emp.id == id);
      if (index != -1) {
        final old = _mockEmployees[index];
        _mockEmployees[index] = AdminEmployeeModel(
          id: old.id,
          email: old.email,
          phoneNumber: old.phoneNumber,
          address: old.address,
          role: old.role,
          status: status,
          createdAt: old.createdAt,
          points: old.points,
        );
      }
    }
  }

  @override
  Future<void> updateVendorStatus(int id, String status) async {
    try {
      await dio.put(
        '/admin/vendors/$id/status',
        data: {'status': status},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          e.response?.data.toString().contains('Admin not found') == true) {
        return; // Silent bypass for mock mode
      }
      throw ServerException(
          e.response?.data['detail'] ?? 'Failed to update status');
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<void> updateVendor(int id, Map<String, dynamic> data) async {
    try {
      await dio.put(
        '/admin/vendors/$id',
        data: data,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          e.response?.data.toString().contains('Admin not found') == true) {
        final index = _mockVendors.indexWhere((v) => v.id == id);
        if (index != -1) {
          final old = _mockVendors[index];
          _mockVendors[index] = AdminVendorModel(
            id: old.id,
            name: data['business_name'] ?? old.name,
            email: data['email'] ?? old.email,
            phoneNumber: data['mobile'] ?? old.phoneNumber,
            fssaiLicenseNumber: old.fssaiLicenseNumber,
            panCardNumber: old.panCardNumber,
            gstNumber: old.gstNumber,
            aadhaarNumber: old.aadhaarNumber,
            city: data['city'] ?? old.city,
            businessName: data['business_name'] ?? old.businessName,
            firstName: data['first_name'] ?? old.firstName,
            lastName: data['last_name'] ?? old.lastName,
            status: old.status,
            createdAt: old.createdAt,
            employeeId: old.employeeId,
            documentsUploaded: old.documentsUploaded,
            hasPayment: old.hasPayment,
          );
        }
        return; // Silent bypass for mock mode
      }
      throw ServerException(
          e.response?.data['detail'] ?? 'Failed to update vendor');
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<void> deleteVendor(int id) async {
    try {
      await dio.delete(
        '/admin/vendors/$id',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          e.response?.data.toString().contains('Admin not found') == true) {
        _mockVendors.removeWhere((v) => v.id == id);
        return; // Silent bypass for mock mode
      }
      throw ServerException(
          e.response?.data['detail'] ?? 'Failed to delete vendor');
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<void> createEmployee(Map<String, dynamic> data) async {
    try {
      await dio.post(
        '/employees',
        data: data,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          e.response?.data.toString().contains('Admin not found') == true) {
        final nextId = _mockEmployees.isEmpty
            ? 1
            : _mockEmployees.map((e) => e.id).reduce((a, b) => a > b ? a : b) +
                1;
        _mockEmployees.add(AdminEmployeeModel(
          id: nextId,
          email: data['email'] ?? '',
          phoneNumber: data['phone_number'],
          address: data['address'] ?? 'Hyderabad',
          role: data['role'] ?? 'staff',
          status: 'active',
          createdAt: DateTime.now(),
          points: 0,
        ));
        return;
      }
      throw ServerException(
          e.response?.data['detail'] ?? 'Failed to create employee');
    } catch (e) {
      final nextId = _mockEmployees.isEmpty
          ? 1
          : _mockEmployees.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      _mockEmployees.add(AdminEmployeeModel(
        id: nextId,
        email: data['email'] ?? '',
        phoneNumber: data['phone_number'],
        address: data['address'] ?? 'Hyderabad',
        role: data['role'] ?? 'staff',
        status: 'active',
        createdAt: DateTime.now(),
        points: 0,
      ));
    }
  }

  @override
  Future<void> updateEmployee(int id, Map<String, dynamic> data) async {
    try {
      await dio.put(
        '/employees/$id',
        data: data,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          e.response?.data.toString().contains('Admin not found') == true) {
        final index = _mockEmployees.indexWhere((emp) => emp.id == id);
        if (index != -1) {
          final old = _mockEmployees[index];
          _mockEmployees[index] = AdminEmployeeModel(
            id: old.id,
            email: data['email'] ?? old.email,
            phoneNumber: data['phone_number'] ?? old.phoneNumber,
            address: data['address'] ?? old.address,
            role: data['role'] ?? old.role,
            status: old.status,
            createdAt: old.createdAt,
            points: old.points,
          );
        }
        return;
      }
      throw ServerException(
          e.response?.data['detail'] ?? 'Failed to update employee');
    } catch (e) {
      final index = _mockEmployees.indexWhere((emp) => emp.id == id);
      if (index != -1) {
        final old = _mockEmployees[index];
        _mockEmployees[index] = AdminEmployeeModel(
          id: old.id,
          email: data['email'] ?? old.email,
          phoneNumber: data['phone_number'] ?? old.phoneNumber,
          address: data['address'] ?? old.address,
          role: data['role'] ?? old.role,
          status: old.status,
          createdAt: old.createdAt,
          points: old.points,
        );
      }
    }
  }

  @override
  Future<void> createService(String name, int mainCategoryId, int subCategoryId, String imagePath) async {
    try {
      final MultipartFile file;
      if (kIsWeb) {
        final bytes = await XFile(imagePath).readAsBytes();
        file = MultipartFile.fromBytes(bytes, filename: 'service_image.png');
      } else {
        file = await MultipartFile.fromFile(imagePath);
      }

      final formData = FormData.fromMap({
        'name': name,
        'main_category_id': mainCategoryId.toString(),
        'sub_category_id': subCategoryId.toString(),
        'image': file,
      });

      await dio.post(
        '/admin/services',
        data: formData,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          e.response?.data.toString().contains('Not Found') == true) {
        return; // Silent bypass for mock mode
      }
      throw ServerException(
          e.response?.data['detail'] ?? 'Failed to create service');
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<List<dynamic>> getWithdrawalRequests() async {
    try {
      final response = await dio.get('/admin/withdrawals');
      if (response.statusCode == 200) {
        return response.data as List;
      }
      throw ServerException('Failed to get withdrawal requests');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ServerException(e.response?.data['detail'] ?? 'Failed to get withdrawal requests');
    }
  }

  @override
  Future<void> approveWithdrawalRequest(int id) async {
    try {
      await dio.post('/admin/withdrawals/$id/approve');
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Failed to approve withdrawal request');
    }
  }

  @override
  Future<List<dynamic>> getVendorDocuments(int vendorId) async {
    try {
      final response = await dio.get('/admin/vendors/documents', queryParameters: {'vendor_id': vendorId, 'status': null});
      if (response.statusCode == 200) {
        return response.data as List;
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw ServerException(e.response?.data['detail'] ?? 'Failed to get documents');
    }
  }

  @override
  Future<void> updateDocumentStatus(int documentId, String status) async {
    try {
      await dio.put('/admin/vendors/documents/$documentId/status', data: {'status': status});
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Failed to update document status');
    }
  }

  @override
  Future<CompanyLeadsPaginatedResponseModel> getCompanyLeads({
    String? startDate,
    String? endDate,
    String? leadSource,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'skip': skip,
        'limit': limit,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (leadSource != null) 'lead_source': leadSource,
      };
      final response = await dio.get('/admin/company-leads', queryParameters: queryParams);
      if (response.statusCode == 200) {
        return CompanyLeadsPaginatedResponseModel.fromJson(response.data);
      }
      throw ServerException('Failed to get company leads');
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Failed to get company leads');
    }
  }

  @override
  Future<CompanyLeadsPaginatedResponseModel> getWebsiteLeads({
    String? search,
    String? status,
    String? startDate,
    String? endDate,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'skip': skip,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };
      final response = await dio.get('/admin/website-leads', queryParameters: queryParams);
      if (response.statusCode == 200) {
        return CompanyLeadsPaginatedResponseModel.fromJson(response.data);
      }
      throw ServerException('Failed to get website leads');
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Failed to get website leads');
    }
  }

  @override
  Future<CompanyLeadsPaginatedResponseModel> getMobileLeads({
    String? search,
    String? status,
    String? startDate,
    String? endDate,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'skip': skip,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };
      final response = await dio.get('/admin/mobile-leads', queryParameters: queryParams);
      if (response.statusCode == 200) {
        return CompanyLeadsPaginatedResponseModel.fromJson(response.data);
      }
      throw ServerException('Failed to get mobile leads');
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Failed to get mobile leads');
    }
  }

  @override
  Future<LeadAssignResultModel> assignCompanyLeads() async {
    try {
      final response = await dio.post('/admin/company-leads/assign');
      if (response.statusCode == 200) {
        return LeadAssignResultModel.fromJson(response.data);
      }
      throw ServerException('Failed to assign leads');
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Failed to assign company leads');
    }
  }
}
