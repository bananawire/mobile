import 'package:mobile/iam/domain/model/valueobjects/email_address.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/password.valueobject.dart';

class InitiateRegistrationCommand {
  final EmailAddress email;
  final Password password;

  const InitiateRegistrationCommand({
    required this.email,
    required this.password,
  });
}
