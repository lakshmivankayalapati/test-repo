import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:sliq_pay/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:sliq_pay/src/localization/gen/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- DEBUG ---
  // The following logic is commented out to allow for easy debugging of the
  // welcome screen. Set `hasSeenWelcome` to `false` to always show the
  // welcome carousel on launch, or `true` to skip it.
  //
  // const storage = FlutterSecureStorage();
  // final hasSeenWelcomeValue = await storage.read(key: 'hasSeenWelcome');
  // final hasSeenWelcome = hasSeenWelcomeValue == 'true';
  const hasSeenWelcome = false;

  runApp(ProviderScope(
      child: MyApp(
    hasSeenWelcome: hasSeenWelcome,
  )));
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.grey,
      surface: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Malinton',
        fontWeight: FontWeight.w700,
        fontSize: 32,
        height: 1.25,
        letterSpacing: 0,
      ),
    ),
    // Add other theme properties here
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenWelcome;
  const MyApp({super.key, required this.hasSeenWelcome});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) async {
            if (hasSeenWelcome) {
              // TODO: check if user is logged in
              // if logged in, return '/home'
              // else return '/login'
              return '/signup';
            } else {
              return '/welcome';
            }
          },
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Signup Screen'))),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Login Screen'))),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home Screen'))),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Sliq Pay',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
