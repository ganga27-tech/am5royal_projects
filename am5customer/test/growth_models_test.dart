import 'package:flutter_test/flutter_test.dart';
import 'package:am5_core/am5_core.dart';

void main() {
  test('SupportTicket parses payload', () {
    final t = SupportTicket.fromJson({
      'id': 't1',
      'ticket_code': 'SUP-ABC',
      'subject': 'Help',
      'category': 'general',
      'priority': 'medium',
      'status': 'open',
      'created_at': '2026-08-07T10:00:00Z',
      'messages': [],
    });
    expect(t.ticketCode, 'SUP-ABC');
  });

  test('Invoice parses amounts', () {
    final i = Invoice.fromJson({
      'id': 'i1',
      'invoice_number': 'INV-123',
      'booking_id': 'b1',
      'service_name': 'Clean',
      'subtotal_amount': '300.00',
      'discount_amount': 0,
      'total_amount': 300,
      'currency': 'INR',
      'status': 'issued',
      'issued_at': '2026-08-07T10:00:00Z',
    });
    expect(i.totalAmount, 300);
  });
}
