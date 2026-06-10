import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';

class SignOutCommand {
  final AccessToken accessToken;

  const SignOutCommand({required this.accessToken});
}
