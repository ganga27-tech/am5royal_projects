import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/vendor_registration_request_model.dart';

part 'register_vendor_event.freezed.dart';

@freezed
class RegisterVendorEvent with _$RegisterVendorEvent {
  const factory RegisterVendorEvent.submit(VendorRegistrationRequestModel request) = SubmitVendorRegistration;
}
