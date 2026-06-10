import 'package:mobile/iam/domain/model/valueobjects/email_address.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/password.valueobject.dart';

class SignInCommand {
  final EmailAddress email;
  final Password password;

  const SignInCommand({
    required this.email,
    required this.password,
  });
}
