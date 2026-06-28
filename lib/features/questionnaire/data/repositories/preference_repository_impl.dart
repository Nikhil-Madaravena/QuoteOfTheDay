import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/preference_entity.dart';
import '../../domain/repositories/preference_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/app_constants.dart';

class PreferenceRepositoryImpl implements PreferenceRepository {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  PreferenceRepositoryImpl({required this.dio, required this.sharedPreferences});

  @override
  Future<PreferenceEntity> getPreferences() async {
    try {
      final token = sharedPreferences.getString(AppConstants.authTokenKey);
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await dio.get('/api/preferences');
      final pref = PreferenceEntity.fromJson(response.data);
      
      // Cache locally
      await sharedPreferences.setString('cached_preferences', json.encode(pref.toJson()));
      
      return pref;
    } catch (e) {
      // Fallback to cache
      final cachedStr = sharedPreferences.getString('cached_preferences');
      if (cachedStr != null) {
        return PreferenceEntity.fromJson(json.decode(cachedStr));
      }
      throw ServerException('Failed to load preferences');
    }
  }

  @override
  Future<PreferenceEntity> savePreferences(PreferenceEntity preferences) async {
    try {
      final token = sharedPreferences.getString(AppConstants.authTokenKey);
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await dio.post('/api/preferences', data: preferences.toJson());
      final pref = PreferenceEntity.fromJson(response.data);

      // Cache locally
      await sharedPreferences.setString('cached_preferences', json.encode(pref.toJson()));

      return pref;
    } catch (e) {
      throw ServerException('Failed to save preferences');
    }
  }
}
