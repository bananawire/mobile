import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/core/di/service_locator.dart';
import 'package:mobile/core/routing/app_router.dart';
import 'package:mobile/iam/domain/model/queries/verify_token.query.dart';
import 'package:mobile/iam/domain/model/valueobjects/access_token.valueobject.dart';
import 'package:mobile/iam/domain/services/authentication.query-service.dart';
import 'package:mobile/iam/infrastructure/auth_session.dart';
import 'package:mobile/iam/infrastructure/persistence/local/token_local_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  setupServiceLocator();

  await _restoreSession();

  runApp(const MyApp());

  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Initialize with your OneSignal App ID from .env
  final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'] ?? 'YOUR_APP_ID';
  OneSignal.initialize(oneSignalAppId);
  // Use this method to prompt for push notifications.
  OneSignal.Notifications.requestPermission(false);
}

Future<void> _restoreSession() async {
  final tokenStorage = getIt<TokenLocalStorage>();
  final token = await tokenStorage.getAccessToken();
  if (token == null || token.isEmpty) {
    AuthSession().setAuthenticated(false);
    return;
  }

  final queryService = getIt<AuthenticationQueryService>();
  final result = await queryService.handleVerifyToken(
    VerifyTokenQuery(accessToken: AccessToken(token)),
  );

  await result.fold(
    (_) async {
      await tokenStorage.clearAll();
      AuthSession().setAuthenticated(false);
    },
    (resource) async {
      if (resource.valid) {
        AuthSession().setAuthenticated(true);
      } else {
        await tokenStorage.clearAll();
        AuthSession().setAuthenticated(false);
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ClairCore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          surface: Color(0xFF121212),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
