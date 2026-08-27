import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_vendor_usecase.dart';
import 'register_vendor_event.dart';
import 'register_vendor_state.dart';

class RegisterVendorBloc
    extends Bloc<RegisterVendorEvent, RegisterVendorState> {
  final RegisterVendorUseCase registerVendorUseCase;

  RegisterVendorBloc({required this.registerVendorUseCase})
      : super(const RegisterVendorState.initial()) {
    on<SubmitVendorRegistration>(_onSubmitVendorRegistration);
  }

  Future<void> _onSubmitVendorRegistration(
    SubmitVendorRegistration event,
    Emitter<RegisterVendorState> emit,
  ) async {
    final req = event.request;

    // 1. First Name
    final firstNameTrim = req.firstName.trim();
    if (firstNameTrim.isEmpty) {
      emit(const RegisterVendorState.validationError('First name is required'));
      return;
    }
    if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(firstNameTrim)) {
      emit(const RegisterVendorState.validationError(
          'First name must contain only letters'));
      return;
    }
    if (firstNameTrim.length < 2) {
      emit(const RegisterVendorState.validationError(
          'First name must be at least 2 characters'));
      return;
    }
    if (firstNameTrim.length > 50) {
      emit(const RegisterVendorState.validationError(
          'First name must not exceed 50 characters'));
      return;
    }

    // 2. Last Name
    final lastNameTrim = req.lastName?.trim() ?? '';
    if (lastNameTrim.isEmpty) {
      emit(const RegisterVendorState.validationError('Last name is required'));
      return;
    }
    if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(lastNameTrim)) {
      emit(const RegisterVendorState.validationError(
          'Last name must contain only letters'));
      return;
    }
    if (lastNameTrim.length > 50) {
      emit(const RegisterVendorState.validationError(
          'Last name must not exceed 50 characters'));
      return;
    }

    // 3. Father Name (when registered under father's name)
    if (req.fatherName != null) {
      final fatherNameTrim = req.fatherName!.trim();
      if (fatherNameTrim.isEmpty) {
        emit(const RegisterVendorState.validationError(
            'Father name is required'));
        return;
      }
      if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(fatherNameTrim)) {
        emit(const RegisterVendorState.validationError(
            'Father name must contain only letters'));
        return;
      }
      if (fatherNameTrim.length < 2) {
        emit(const RegisterVendorState.validationError(
            'Father name must be at least 2 characters'));
        return;
      }
      if (fatherNameTrim.length > 100) {
        emit(const RegisterVendorState.validationError(
            'Father name must not exceed 100 characters'));
        return;
      }
    }

    // 4. Email
    final emailTrim = req.email?.trim() ?? '';
    if (emailTrim.isEmpty) {
      emit(const RegisterVendorState.validationError('Email is required'));
      return;
    }
    if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        .hasMatch(emailTrim)) {
      emit(const RegisterVendorState.validationError(
          'Please enter a valid email address'));
      return;
    }

    // 5. Business Name
    final businessNameTrim = req.businessName.trim();
    if (businessNameTrim.isEmpty) {
      emit(const RegisterVendorState.validationError(
          'Business name is required'));
      return;
    }
    if (businessNameTrim.length < 3) {
      emit(const RegisterVendorState.validationError(
          'Business name must be at least 3 characters'));
      return;
    }
    if (businessNameTrim.length > 100) {
      emit(const RegisterVendorState.validationError(
          'Business name must not exceed 100 characters'));
      return;
    }

    // // 6. Aadhaar Number
    // final aadhaarClean = req.aadhaarNumber.replaceAll(' ', '');
    // if (aadhaarClean.isEmpty) {
    //   emit(const RegisterVendorState.validationError('Aadhaar number is required'));
    //   return;
    // }
    // if (aadhaarClean.length != 12 || !RegExp(r'^\d+$').hasMatch(aadhaarClean)) {
    //   emit(const RegisterVendorState.validationError('Aadhaar number must be 12 digits'));
    //   return;
    // }

    // 7. Address
    final addressTrim = req.address.trim();
    if (addressTrim.isEmpty) {
      emit(const RegisterVendorState.validationError('Address is required'));
      return;
    }
    if (addressTrim.length < 10) {
      emit(const RegisterVendorState.validationError(
          'Please enter a complete address'));
      return;
    }
    if (addressTrim.length > 250) {
      emit(const RegisterVendorState.validationError(
          'Address must not exceed 250 characters'));
      return;
    }

    // 8. City
    final cityTrim = req.city.trim();
    if (cityTrim.isEmpty) {
      emit(const RegisterVendorState.validationError('City is required'));
      return;
    }
    if (cityTrim.length < 2) {
      emit(const RegisterVendorState.validationError(
          'Please enter a valid city'));
      return;
    }

    // 9. State
    final stateTrim = req.state.trim();
    if (stateTrim.isEmpty) {
      emit(const RegisterVendorState.validationError('State is required'));
      return;
    }
    if (stateTrim.length < 2) {
      emit(const RegisterVendorState.validationError(
          'Please enter a valid state'));
      return;
    }

    // 10. Pincode
    final pincodeTrim = req.pincode.trim();
    if (pincodeTrim.isEmpty) {
      emit(const RegisterVendorState.validationError('Pincode is required'));
      return;
    }
    if (pincodeTrim.length != 6 || !RegExp(r'^\d+$').hasMatch(pincodeTrim)) {
      emit(const RegisterVendorState.validationError(
          'Pincode must be 6 digits'));
      return;
    }

    // 11. Service Radius (KM)
    final radius = req.serviceRadiusKm;
    if (radius == null) {
      emit(const RegisterVendorState.validationError(
          'Service radius is required'));
      return;
    }
    if (radius < 1) {
      emit(const RegisterVendorState.validationError(
          'Service radius must be greater than 0'));
      return;
    }
    if (radius > 500) {
      emit(const RegisterVendorState.validationError(
          'Service radius cannot exceed 500 KM'));
      return;
    }

    emit(const RegisterVendorState.loading());
    final result = await registerVendorUseCase(RegisterVendorParams(
      request: event.request,
    ));
    result.fold(
      (failure) => emit(RegisterVendorState.error(failure.message)),
      (response) => emit(RegisterVendorState.success(response)),
    );
  }
}
