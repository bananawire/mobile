import 'package:mobile/iam/domain/model/valueobjects/google_id_token.valueobject.dart';

class AuthenticateWithGoogleCommand {
  final GoogleIdToken idToken;

  const AuthenticateWithGoogleCommand({
    required this.idToken,
  });
}
