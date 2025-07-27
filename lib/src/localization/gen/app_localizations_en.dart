// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeScreenTitle1 => 'Pay Anywhere,\nInstantly & Easily';

  @override
  String get welcomeScreenDescription1 =>
      'From UPI to bank transfer to phone number pay how you want, globally.';

  @override
  String get welcomeScreenTitle2 => 'Your Money.\nOur Protection.';

  @override
  String get welcomeScreenDescription2 =>
      'Your data is encrypted and money is held at world-leading banks. Regulated and certified.';

  @override
  String get welcomeScreenTitle3 => 'What You See Is\nWhat You Pay';

  @override
  String get welcomeScreenDescription3 =>
      'No hidden fees. Mid-market (Google) exchange rates. Low cost, straight to you.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get login => 'Log In';
}
