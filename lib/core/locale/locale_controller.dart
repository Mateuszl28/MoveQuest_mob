import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Języki obsługiwane przez aplikację. Angielski jest domyślny.
const List<Locale> kSupportedLocales = [Locale('en'), Locale('pl')];

/// Instancja [SharedPreferences] wstrzykiwana w [main] (override).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

/// Provider aktualnego języka aplikacji.
final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

/// Steruje wyborem języka i utrwala go w [SharedPreferences].
///
/// Domyślnie aplikacja jest po angielsku; użytkownik może przełączyć na polski
/// w ustawieniach profilu, a wybór jest zapamiętywany między uruchomieniami.
class LocaleController extends Notifier<Locale> {
  static const String _prefsKey = 'app_locale';
  static const Locale _defaultLocale = Locale('en');

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_prefsKey);
    return _localeForCode(code);
  }

  static Locale _localeForCode(String? code) {
    return kSupportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => _defaultLocale,
    );
  }

  /// Ustawia konkretny język i zapisuje wybór.
  Future<void> setLocale(Locale locale) async {
    if (!kSupportedLocales.contains(locale)) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_prefsKey, locale.languageCode);
    state = locale;
  }

  /// Przełącza między angielskim a polskim.
  Future<void> toggle() {
    final next = state.languageCode == 'en'
        ? const Locale('pl')
        : const Locale('en');
    return setLocale(next);
  }
}
