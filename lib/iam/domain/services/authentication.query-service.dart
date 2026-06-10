import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/failure.dart';
import 'package:mobile/iam/domain/model/queries/verify_token.query.dart';
import 'package:mobile/iam/interfaces/rest/resources/token_verification_resource.resource.dart';

abstract class AuthenticationQueryService {
  Future<Either<Failure, TokenVerificationResource>> handleVerifyToken(
    VerifyTokenQuery query,
  );
}
