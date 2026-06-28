import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences instance provider.
///
/// The instance is created in `main()` and overridden via
/// `ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)])`.
/// Accessing this provider before the override will throw an [UnimplementedError].
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});
