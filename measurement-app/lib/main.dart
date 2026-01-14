import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/app_provider.dart';
import 'providers/settings_provider.dart';
import 'services/sync_service.dart';
import 'services/app_logger.dart';
import 'services/device_id_service.dart';
import 'services/activity_log_service.dart';
import 'services/license_service.dart';
import 'utils/theme.dart';
import 'screens/main_screen.dart';
import 'widgets/system_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Device ID FIRST
  final deviceId = await DeviceIdService.instance.getDeviceId();

  // Initialize Logger
  await AppLogger().initialize();
  await AppLogger().info('MAIN', 'App starting...', 'deviceId=$deviceId');
  await Firebase.initializeApp();

  // Initialize background services
  await ActivityLogService().initialize();
  SyncService().initialize();

  // Initialize License Service (loads cache)
  await LicenseService().initialize();

  // Load settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(MyApp(settingsProvider: settingsProvider));
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
            title: 'Window Measurement',
            debugShowCheckedModeBanner: false,
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
