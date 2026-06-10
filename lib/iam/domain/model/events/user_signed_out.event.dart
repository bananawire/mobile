import 'package:mobile/iam/domain/model/valueobjects/user_id.valueobject.dart';

class UserSignedOutEvent {
  final UserId userId;
  final DateTime occurredOn;

  const UserSignedOutEvent({
    required this.userId,
    required this.occurredOn,
  });
}
