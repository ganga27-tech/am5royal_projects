import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class GrowthApi {
  GrowthApi(this._client);

  final ApiClient _client;

  Future<List<SupportTicket>> listTickets() async {
    try {
      final response = await _client.dio.get('/engagement/tickets');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => SupportTicket.fromAm5Ticket(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<SupportTicket> createTicket({
    required String subject,
    required String body,
    String category = 'general',
  }) async {
    try {
      final response = await _client.dio.post(
        '/engagement/ticket',
        queryParameters: {
          'title': subject,
          'description': body,
          'ticketType': category,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return SupportTicket(
        id: data['ticketId']?.toString() ?? '',
        ticketCode: data['ticketNumber'] as String? ?? '',
        subject: subject,
        category: category,
        priority: 'normal',
        status: 'open',
        createdAt: DateTime.now().toUtc().toIso8601String(),
        messages: [
          SupportMessage(
            id: '1',
            body: body,
            isStaff: false,
            createdAt: DateTime.now().toUtc().toIso8601String(),
          ),
        ],
      );
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<SupportTicket> getTicket(String id) async {
    final tickets = await listTickets();
    return tickets.firstWhere(
      (t) => t.id == id,
      orElse: () => throw const Failure('Ticket not found'),
    );
  }

  Future<SupportTicket> addMessage(String id, String body) async {
    throw const Failure('Ticket replies are not available yet.');
  }

  Future<List<MembershipPlan>> listPlans() async {
    return const [];
  }

  Future<MembershipStatus> membershipStatus() async {
    return const MembershipStatus(active: false, status: 'inactive');
  }

  Future<MembershipStatus> subscribe(String planId) async {
    throw const Failure('Membership is not available yet.');
  }

  Future<ReferralInfo> referralInfo() async {
    try {
      final response = await _client.dio.get('/auth/customer/me');
      final data = response.data as Map<String, dynamic>;
      final id = data['id']?.toString() ?? '0';
      final code = 'AM5$id';
      return ReferralInfo(
        code: code,
        shareMessage: 'Hi! Join AM5 Royal with my referral code $code and enjoy premium home services.',
        referrerBonus: 100,
        refereeBonus: 100,
        redemptionsCount: 0,
      );
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<Invoice>> listInvoices() async {
    try {
      final response = await _client.dio.get('/orders/');
      final list = response.data as List<dynamic>;
      return list.map((entry) {
        final json = entry as Map<String, dynamic>;
        final orderId = json['orderId']?.toString() ?? '';
        final amount = json['finalAmount'] ?? json['totalAmount'] ?? 0;
        final total = amount is num ? amount.toDouble() : double.tryParse('$amount') ?? 0;
        return Invoice(
          id: orderId,
          invoiceNumber: 'INV-$orderId',
          bookingId: orderId,
          serviceName: json['service_name'] as String? ?? 'Service',
          subtotalAmount: total,
          discountAmount: 0,
          totalAmount: total,
          currency: 'INR',
          status: (json['status'] as String? ?? 'issued').toLowerCase(),
          issuedAt: json['orderdate']?.toString() ?? '',
        );
      }).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<SupportTicket>> adminListTickets() async {
    throw const Failure('Admin support is not available in the customer app.');
  }

  Future<SupportTicket> adminReply(String id, String body) async {
    throw const Failure('Admin support is not available in the customer app.');
  }

  Future<SupportTicket> adminUpdateTicket(String id, Map<String, dynamic> body) async {
    throw const Failure('Admin support is not available in the customer app.');
  }

  Future<List<MembershipPlan>> adminListPlans() async {
    throw const Failure('Admin membership is not available in the customer app.');
  }

  Future<MembershipPlan> adminCreatePlan(Map<String, dynamic> body) async {
    throw const Failure('Admin membership is not available in the customer app.');
  }

  Future<List<Invoice>> adminListInvoices() async {
    throw const Failure('Admin invoices are not available in the customer app.');
  }
}
