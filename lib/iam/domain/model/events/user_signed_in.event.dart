import 'package:mobile/iam/domain/model/valueobjects/user_id.valueobject.dart';

class UserSignedInEvent {
  final UserId userId;
  final String email;
  final DateTime occurredOn;

  const UserSignedInEvent({
    required this.userId,
    required this.email,
    required this.occurredOn,
  });
}
