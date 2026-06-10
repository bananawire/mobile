import 'package:mobile/iam/domain/model/valueobjects/session_id.valueobject.dart';
import 'package:mobile/iam/domain/model/valueobjects/verification_code.valueobject.dart';

class ConfirmRegistrationCommand {
  final SessionId sessionId;
  final VerificationCode verificationCode;

  const ConfirmRegistrationCommand({
    required this.sessionId,
    required this.verificationCode,
  });
}
