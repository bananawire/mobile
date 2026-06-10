import 'package:mobile/devices/domain/model/valueobjects/claim_token.valueobject.dart';
import 'package:mobile/devices/domain/model/valueobjects/space_id.valueobject.dart';

class ClaimDeviceToSpaceCommand {
  final ClaimToken claimToken;
  final SpaceId spaceId;

  ClaimDeviceToSpaceCommand({
    required this.claimToken,
    required this.spaceId,
  });
}
