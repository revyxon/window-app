import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/app_provider.dart';
import 'providers/settings_provider.dart';
import 'services/sync_service.dart';
import 'services/app_logger.dart';
import 'services/device_id_service.dart';

import 'services/license_service.dart';
import 'ui/app_theme.dart';
import 'screens/main_screen.dart';
import 'widgets/system_guard.dart';
import 'utils/logging_navigator_observer.dart';
import 'utils/globals.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Device ID FIRST
  final deviceId = await DeviceIdService.instance.getDeviceId();

  // Initialize Logger
  await AppLogger().initialize();
  await AppLogger().info('MAIN', 'App starting...', 'deviceId=$deviceId');
  await Firebase.initializeApp();

  // Initialize background services (Awaited to ensure registration)
  await SyncService().initialize();

  // Initialize License Service
  await LicenseService().initialize();

  // Load settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  // Initialize Shared Intent Listener
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
  GlobalParams.importFilePath = path;
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
            // Use dynamic theme with accent color and font settings
            theme: AppTheme.lightTheme(settings),
            darkTheme: AppTheme.darkTheme(settings),
            themeMode: settings.themeMode,
            builder: (context, child) {
              final fontMultiplier = settings.fontSizeMultiplier;
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(fontMultiplier)),
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
