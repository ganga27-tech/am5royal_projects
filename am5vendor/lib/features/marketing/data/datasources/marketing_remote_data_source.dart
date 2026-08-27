import 'package:dio/dio.dart';
import '../../domain/entities/marketing_lead.dart';
import '../../domain/entities/marketing_collateral.dart';
import '../../../../core/error/exceptions.dart';

abstract class MarketingRemoteDataSource {
  Future<MarketingLead> createLead(Map<String, dynamic> leadData);
  Future<List<MarketingLead>> getLeads({bool assignedToMe = false, bool createdByMe = false});
  Future<List<MarketingCollateral>> getCollaterals();
}

class MarketingRemoteDataSourceImpl implements MarketingRemoteDataSource {
  final Dio dio;

  MarketingRemoteDataSourceImpl({required this.dio});

  @override
  Future<MarketingLead> createLead(Map<String, dynamic> leadData) async {
    try {
      final response = await dio.post('/marketing/leads', data: leadData);
      return _mapLeadFromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Failed to create lead');
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<List<MarketingLead>> getLeads({bool assignedToMe = false, bool createdByMe = false}) async {
    try {
      final response = await dio.get(
        '/marketing/leads',
        queryParameters: {
          if (assignedToMe) 'assigned_to_me': true,
          if (createdByMe) 'created_by_me': true,
        },
      );
      return (response.data as List)
          .map((json) => _mapLeadFromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Failed to fetch leads');
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<List<MarketingCollateral>> getCollaterals() async {
    try {
      final response = await dio.get('/marketing/collaterals');
      return (response.data as List)
          .map((json) => _mapCollateralFromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Failed to fetch collaterals');
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  MarketingLead _mapLeadFromJson(Map<String, dynamic> json) {
    return MarketingLead(
      id: json['id'],
      shopName: json['shop_name'],
      contactPerson: json['contact_person'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      shopImageUrl: json['shop_image_url'],
      notes: json['notes'],
      status: json['status'],
      createdByEmployeeId: json['created_by_employee_id'],
      assignedToEmployeeId: json['assigned_to_employee_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  MarketingCollateral _mapCollateralFromJson(Map<String, dynamic> json) {
    return MarketingCollateral(
      id: json['id'],
      title: json['title'],
      collateralType: json['collateral_type'],
      url: json['url'],
      description: json['description'],
      isActive: json['is_active'],
    );
  }
}
