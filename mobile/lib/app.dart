import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smartfly/core/localization/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/flight_provider.dart';
import 'providers/personalized_routes_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_client.dart';
import 'services/admin_service.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/chat_service.dart';
import 'services/favorite_service.dart';
import 'services/flight_api_service.dart';
import 'services/recommendation_service.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/loading_widget.dart';

class SmartFlyApp extends StatelessWidget {
  const SmartFlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();
    return MultiProvider(
      providers: [
        Provider.value(value: api),
        Provider(create: (_) => AuthService(api)),
        Provider(create: (_) => FlightApiService(api)),
        Provider(create: (_) => FavoriteService(api)),
        Provider(create: (_) => BookingService(api)),
        Provider(create: (_) => RecommendationService(api)),
        Provider(create: (_) => ChatService(api)),
        Provider(create: (_) => AdminService(api)),
        ChangeNotifierProvider(create: (c) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (c) => LocaleProvider()..load()),
        ChangeNotifierProvider(create: (c) => AuthProvider(c.read<AuthService>())..init()),
        ChangeNotifierProvider(create: (c) => FlightProvider(c.read<FlightApiService>())..loadCities()),
        ChangeNotifierProvider(create: (c) => FavoriteProvider(c.read<FavoriteService>())),
        ChangeNotifierProvider(create: (c) => BookingProvider(c.read<BookingService>())),
        ChangeNotifierProvider(create: (c) => ChatProvider(c.read<ChatService>())),
        ChangeNotifierProvider(create: (c) => PersonalizedRoutesProvider(c.read<ApiClient>())),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, theme, locale, _) {
          return MaterialApp(
            title: 'SmartFly',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.mode,
            locale: locale.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const _RootGate(),
          );
        },
      ),
    );
  }
}

class _RootGate extends StatefulWidget {
  const _RootGate();

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  bool _ready = false;
  bool _onboardingDone = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    while (auth.loading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    final prefs = await SharedPreferences.getInstance();
    _onboardingDone = prefs.getBool('onboarding_done') ?? false;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AppScaffold(body: Center(child: LoadingWidget())),
      );
    }
    final auth = context.watch<AuthProvider>();
    if (!_onboardingDone) return const OnboardingScreen();
    if (auth.isLoggedIn) return const MainShell();
    return const LoginScreen();
  }
}
