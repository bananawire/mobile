import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';

class VerifyTokenQuery {
  final AccessToken accessToken;

  const VerifyTokenQuery({required this.accessToken});
}
