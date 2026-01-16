import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/app_provider.dart';
import 'providers/settings_provider.dart';
import 'services/sync_service.dart';
import 'services/app_logger.dart';
import 'services/device_id_service.dart';

import 'services/license_service.dart';
import 'utils/theme.dart';
import 'screens/main_screen.dart';
import 'widgets/system_guard.dart';
import 'utils/logging_navigator_observer.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Device ID FIRST
  final deviceId = await DeviceIdService.instance.getDeviceId();

  // Initialize Logger
  await AppLogger().initialize();
  await AppLogger().info('MAIN', 'App starting...', 'deviceId=$deviceId');
  await Firebase.initializeApp();

  // Initialize background services (LogService is lazy-loaded)
  SyncService().initialize();

  // Initialize License Service (loads cache, checks background)
  LicenseService().initialize();

  // Load settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  // Initialize Shared Intent Listener
  // Listen to media share while the app is starting or is in memory
  ReceiveSharingIntent.instance.getMediaStream().listen(
    (List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleImportFile(value.first.path);
      }
    },
    onError: (err) {
      AppLogger().error('MAIN', 'getMediaStream error: $err');
    },
  );

  // Get the media share which was shared while the app was closed
  ReceiveSharingIntent.instance.getInitialMedia().then((
    List<SharedMediaFile> value,
  ) {
    if (value.isNotEmpty) {
      _handleImportFile(value.first.path);
    }
  });

  runApp(MyApp(settingsProvider: settingsProvider));
}

void _handleImportFile(String path) {
  // We need a context to show dialogs, but main() doesn't have one.
  // We'll store this path in a global key or service to check after app launch
  // For now, let's use a simple global variable or passing it to MyApp
  // A better approach is to use a valid navigator key.
  GlobalParams.importFilePath = path;
}

class GlobalParams {
  static String? importFilePath;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const MyApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Glaze',
            debugShowCheckedModeBanner: false,
            navigatorKey: GlobalParams.navigatorKey,
            navigatorObservers: [LoggingNavigatorObserver()],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(settings.textScale)),
                child: SystemGuard(child: child!),
              );
            },
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
