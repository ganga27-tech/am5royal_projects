import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';

/// Opens the booking flow (date, time, address) for a service.
void openServiceBooking(BuildContext context, CatalogServiceItem service) {
  final name = Uri.encodeQueryComponent(service.name);
  context.push('/book?service_id=${service.id}&service_name=$name');
}

void openVendorServiceBooking(
  BuildContext context, {
  required String vendorId,
  required String vendorName,
  required VendorServiceOffering service,
}) {
  final params = {
    'professional_id': vendorId,
    'service_id': service.subCategoryId,
    'professional_name': vendorName,
    'service_name': service.title,
  };
  final q = params.entries
      .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');
  context.push('/book?$q');
}

void openServiceBookingById(
  BuildContext context, {
  required String serviceId,
  String? serviceName,
}) {
  final q = serviceName != null ? '&service_name=${Uri.encodeQueryComponent(serviceName)}' : '';
  context.push('/book?service_id=$serviceId$q');
}
