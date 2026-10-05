import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/shared/infrastructure/persistence/local/language_local_storage.dart';
import 'package:mobile/shared/application/internal/cubits/locale_cubit.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/iam/application/internal/commandservices/authentication_command_service_impl.dart';
import 'package:mobile/iam/application/internal/queryservices/authentication_query_service_impl.dart';
import 'package:mobile/iam/domain/services/authentication.command-service.dart';
import 'package:mobile/iam/domain/services/authentication.query-service.dart';
import 'package:mobile/iam/infrastructure/api/gateways/authentication.gateway.dart';
import 'package:mobile/iam/infrastructure/api/gateways/authentication_http.gateway.dart';
import 'package:mobile/iam/infrastructure/oauth/google/google_id_token_provider.dart';
import 'package:mobile/iam/infrastructure/oauth/google/google_sign_in_id_token_provider.dart';
import 'package:mobile/iam/infrastructure/persistence/local/registration_session_local_storage.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:mobile/analytics/application/internal/queryservices/analytics_query_service_impl.dart';
import 'package:mobile/analytics/domain/services/analytics.query-service.dart';
import 'package:mobile/analytics/infrastructure/api/gateways/analytics.gateway.dart';
import 'package:mobile/analytics/infrastructure/api/gateways/analytics_http.gateway.dart';
import 'package:mobile/analytics/interfaces/pages/analytics_cubit.dart';
import 'package:mobile/alerts/application/internal/queryservices/alerts_query_service_impl.dart';
import 'package:mobile/alerts/domain/services/alerts.query-service.dart';
import 'package:mobile/alerts/infrastructure/api/gateways/alerts.gateway.dart';
import 'package:mobile/alerts/infrastructure/api/gateways/alerts_http.gateway.dart';
import 'package:mobile/alerts/interfaces/pages/alerts_cubit.dart';
import 'package:mobile/devices/application/internal/commandservices/organizations_command_service_impl.dart';
import 'package:mobile/devices/application/internal/queryservices/organizations_query_service_impl.dart';
import 'package:mobile/devices/domain/services/organizations.command-service.dart';
import 'package:mobile/devices/domain/services/organizations.query-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/organizations.gateway.dart';
import 'package:mobile/devices/infrastructure/api/gateways/organizations_http.gateway.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices.gateway.dart';
import 'package:mobile/devices/infrastructure/api/gateways/devices_http.gateway.dart';
import 'package:mobile/devices/interfaces/pages/organizations/organizations_cubit.dart';
import 'package:mobile/devices/interfaces/pages/space_devices/space_devices_cubit.dart';
import 'package:mobile/devices/application/internal/commandservices/devices_command_service_impl.dart';
import 'package:mobile/devices/domain/services/devices.command-service.dart';
import 'package:mobile/devices/application/internal/queryservices/devices_query_service_impl.dart';
import 'package:mobile/devices/domain/services/devices.query-service.dart';
import 'package:mobile/iam/interfaces/pages/confirm_registration/confirm_registration_cubit.dart';
import 'package:mobile/iam/interfaces/pages/login/login_cubit.dart';
import 'package:mobile/iam/interfaces/pages/register/register_cubit.dart';
import 'package:mobile/iam/interfaces/pages/settings/settings_cubit.dart';
import 'package:mobile/devices/application/internal/commandservices/spaces_command_service_impl.dart';
import 'package:mobile/devices/application/internal/queryservices/spaces_query_service_impl.dart';
import 'package:mobile/devices/domain/services/spaces.command-service.dart';
import 'package:mobile/devices/domain/services/spaces.query-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/spaces.gateway.dart';
import 'package:mobile/devices/infrastructure/api/gateways/spaces_http.gateway.dart';
import 'package:mobile/devices/interfaces/pages/spaces/spaces_cubit.dart';
import 'package:mobile/devices/application/internal/commandservices/device_threshold_command_service_impl.dart';
import 'package:mobile/devices/application/internal/commandservices/device_commands_command_service_impl.dart';
import 'package:mobile/devices/application/internal/queryservices/device_threshold_query_service_impl.dart';
import 'package:mobile/devices/domain/services/device_threshold.command-service.dart';
import 'package:mobile/devices/domain/services/device_threshold.query-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_thresholds.gateway.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_thresholds_http.gateway.dart';
import 'package:mobile/devices/domain/services/device_commands.command-service.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_commands.gateway.dart';
import 'package:mobile/devices/infrastructure/api/gateways/device_commands_http.gateway.dart';
import 'package:mobile/devices/interfaces/pages/device_detail/device_detail_cubit.dart';
import 'package:mobile/devices/application/internal/acl/device_vitals_acl.dart';
import 'package:mobile/evaluation/application/internal/queryservices/telemetry_evaluation_query_service_impl.dart';
import 'package:mobile/evaluation/domain/services/telemetry_evaluation.query-service.dart';
import 'package:mobile/evaluation/infrastructure/api/gateways/telemetry_evaluation.gateway.dart';
import 'package:mobile/evaluation/infrastructure/api/gateways/telemetry_evaluation_http.gateway.dart';
import 'package:mobile/notifications/application/internal/queryservices/notifications_query_service_impl.dart';
import 'package:mobile/notifications/domain/services/notifications.query-service.dart';
import 'package:mobile/notifications/infrastructure/api/gateways/notifications.gateway.dart';
import 'package:mobile/notifications/infrastructure/api/gateways/notifications_http.gateway.dart';
import 'package:mobile/notifications/interfaces/pages/notifications_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator(SharedPreferences sharedPreferences) {
  // Core
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<LanguageLocalStorage>(() => LanguageLocalStorage(sharedPreferences));
  getIt.registerLazySingleton<TokenLocalStorage>(() => TokenLocalStorage());
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(tokenStorage: getIt<TokenLocalStorage>()),
  );
  getIt.registerLazySingleton<RegistrationSessionLocalStorage>(
    () => RegistrationSessionLocalStorage(),
  );
  getIt.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      scopes: const ['email', 'profile', 'openid'],
      serverClientId: ApiConstants.googleServerClientId,
    ),
  );
  getIt.registerLazySingleton<GoogleIdTokenProvider>(
    () => GoogleSignInIdTokenProvider(getIt<GoogleSignIn>()),
  );
  getIt.registerLazySingleton<AuthenticationGateway>(
    () => AuthenticationHttpGateway(getIt<DioClient>().client),
  );

  // Application Services
  getIt.registerLazySingleton<AuthenticationCommandService>(
    () => AuthenticationCommandServiceImpl(
      getIt<AuthenticationGateway>(),
      getIt<TokenLocalStorage>(),
      getIt<RegistrationSessionLocalStorage>(),
    ),
  );

  getIt.registerLazySingleton<AuthenticationQueryService>(
    () => AuthenticationQueryServiceImpl(getIt<AuthenticationGateway>()),
  );

  // Analytics Context
  getIt.registerLazySingleton<AnalyticsGateway>(
    () => AnalyticsHttpGateway(getIt<DioClient>().client, getIt<TokenLocalStorage>()),
  );
  getIt.registerLazySingleton<AnalyticsQueryService>(
    () => AnalyticsQueryServiceImpl(getIt<AnalyticsGateway>()),
  );

  // Alerts Context
  getIt.registerLazySingleton<AlertsGateway>(
    () => AlertsHttpGateway(getIt<DioClient>().client),
  );

  getIt.registerLazySingleton<AlertsQueryService>(
    () => AlertsQueryServiceImpl(getIt<AlertsGateway>()),
  );

  // Notifications Context
  getIt.registerLazySingleton<NotificationsGateway>(
    () => NotificationsHttpGateway(getIt<DioClient>().client),
  );

  getIt.registerLazySingleton<NotificationsQueryService>(
    () => NotificationsQueryServiceImpl(getIt<NotificationsGateway>()),
  );

  // Spaces Context
  getIt.registerLazySingleton<SpacesGateway>(
    () => SpacesHttpGateway(getIt<DioClient>().client),
  );
  getIt.registerLazySingleton<DevicesGateway>(
    () => DevicesHttpGateway(getIt<DioClient>().client),
  );
  getIt.registerLazySingleton<SpacesCommandService>(
    () => SpacesCommandServiceImpl(getIt<SpacesGateway>()),
  );
  getIt.registerLazySingleton<SpacesQueryService>(
    () => SpacesQueryServiceImpl(getIt<SpacesGateway>()),
  );

  // Devices Context (Organizations)
  getIt.registerLazySingleton<OrganizationsGateway>(
    () => OrganizationsHttpGateway(getIt<DioClient>().client),
  );
  getIt.registerLazySingleton<OrganizationsCommandService>(
    () => OrganizationsCommandServiceImpl(getIt<OrganizationsGateway>()),
  );
  getIt.registerLazySingleton<OrganizationsQueryService>(
    () => OrganizationsQueryServiceImpl(getIt<OrganizationsGateway>()),
  );

  // Devices Context (Devices)
  getIt.registerLazySingleton<DevicesQueryService>(
    () => DevicesQueryServiceImpl(getIt<DevicesGateway>()),
  );
  getIt.registerLazySingleton<DevicesCommandService>(
    () => DevicesCommandServiceImpl(getIt<DevicesGateway>()),
  );

  // Device Commands
  getIt.registerLazySingleton<DeviceCommandsGateway>(
    () => DeviceCommandsHttpGateway(getIt<DioClient>().client),
  );
  getIt.registerLazySingleton<DeviceCommandsCommandService>(
    () => DeviceCommandsCommandServiceImpl(getIt<DeviceCommandsGateway>()),
  );

  // Device Thresholds
  getIt.registerLazySingleton<DeviceThresholdsGateway>(
    () => DeviceThresholdsHttpGateway(getIt<DioClient>().client),
  );
  getIt.registerLazySingleton<DeviceThresholdQueryService>(
    () => DeviceThresholdQueryServiceImpl(getIt<DeviceThresholdsGateway>()),
  );
  getIt.registerLazySingleton<DeviceThresholdCommandService>(
    () => DeviceThresholdCommandServiceImpl(getIt<DeviceThresholdsGateway>()),
  );

  // Evaluation Context
  getIt.registerLazySingleton<TelemetryEvaluationGateway>(
    () => TelemetryEvaluationHttpGateway(getIt<DioClient>().client),
  );
  getIt.registerLazySingleton<TelemetryEvaluationQueryService>(
    () => TelemetryEvaluationQueryServiceImpl(getIt<TelemetryEvaluationGateway>()),
  );

  // Devices ACLs
  getIt.registerLazySingleton<DeviceVitalsAcl>(
    () => DeviceVitalsAcl(getIt<TelemetryEvaluationQueryService>()),
  );

  // Interface Controllers (Cubits)
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(
      getIt<AuthenticationCommandService>(),
      getIt<GoogleIdTokenProvider>(),
    ),
  );
  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(
      getIt<AuthenticationCommandService>(),
      getIt<GoogleIdTokenProvider>(),
    ),
  );
  getIt.registerFactory<ConfirmRegistrationCubit>(
    () => ConfirmRegistrationCubit(
      getIt<AuthenticationCommandService>(),
      getIt<RegistrationSessionLocalStorage>(),
    ),
  );

  getIt.registerFactory<AlertsCubit>(
    () => AlertsCubit(
      getIt<AlertsQueryService>(),
    ),
  );

  getIt.registerFactory<AnalyticsCubit>(
    () => AnalyticsCubit(
      getIt<AnalyticsQueryService>(),
      getIt<OrganizationsQueryService>(),
      getIt<SpacesQueryService>(),
      getIt<DevicesQueryService>(),
    ),
  );
  getIt.registerFactory<SpacesCubit>(
    () => SpacesCubit(
      getIt<SpacesQueryService>(),
      getIt<SpacesCommandService>(),
      getIt<DevicesGateway>(),
    ),
  );
  getIt.registerFactory<OrganizationsCubit>(
    () => OrganizationsCubit(
      getIt<OrganizationsQueryService>(),
      getIt<OrganizationsCommandService>(),
    ),
  );

  getIt.registerFactory<SpaceDevicesCubit>(
    () => SpaceDevicesCubit(
      getIt<DevicesQueryService>(),
      getIt<DevicesCommandService>(),
    ),
  );

  getIt.registerFactory<DeviceDetailCubit>(
    () => DeviceDetailCubit(
      getIt<DevicesQueryService>(),
      getIt<DevicesCommandService>(),
      getIt<DeviceThresholdQueryService>(),
      getIt<DeviceThresholdCommandService>(),
      getIt<DeviceVitalsAcl>(),
      getIt<DeviceCommandsCommandService>(),
    ),
  );

  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(
      getIt<AuthenticationCommandService>(),
      getIt<TokenLocalStorage>(),
    ),
  );

  getIt.registerLazySingleton<NotificationsCubit>(
    () => NotificationsCubit(getIt<NotificationsQueryService>()),
  );

  getIt.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(getIt<LanguageLocalStorage>()),
  );
}
