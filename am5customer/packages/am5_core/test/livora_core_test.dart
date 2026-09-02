import 'package:flutter_test/flutter_test.dart';
import 'package:am5_core/am5_core.dart';

void main() {
  test('email validator', () {
    expect(AuthValidators.email(null), isNotNull);
    expect(AuthValidators.email('bad'), isNotNull);
    expect(AuthValidators.email('a@b.com'), isNull);
  });

  test('password validator', () {
    expect(AuthValidators.password('short'), isNotNull);
    expect(AuthValidators.password('SecurePass1'), isNull);
  });
}
