import '../entities/preference_entity.dart';

abstract class PreferenceRepository {
  Future<PreferenceEntity> getPreferences();
  Future<PreferenceEntity> savePreferences(PreferenceEntity preferences);
}
