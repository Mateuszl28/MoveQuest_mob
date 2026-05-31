import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/locale/locale_controller.dart';

/// Nazwa wyświetlana użytkownika (konto lokalne, bez backendu).
///
/// `null` oznacza, że użytkownik nie ustawił własnej nazwy – UI pokazuje
/// wtedy domyślną, zlokalizowaną nazwę.
final profileNameProvider =
    NotifierProvider<ProfileNameController, String?>(ProfileNameController.new);

class ProfileNameController extends Notifier<String?> {
  static const _prefsKey = 'profile_name';

  late SharedPreferences _prefs;

  @override
  String? build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final value = _prefs.getString(_prefsKey);
    return (value == null || value.isEmpty) ? null : value;
  }

  /// Ustawia i zapisuje nazwę użytkownika.
  Future<void> setName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = trimmed;
    await _prefs.setString(_prefsKey, trimmed);
  }
}
