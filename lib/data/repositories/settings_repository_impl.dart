import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/i_settings_repository.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  static const _radiusKey = 'search_radius_km';
  static const _defaultRadius = 2.0; // Bán kính mặc định là 2km

  @override
  Future<double> getSearchRadius() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_radiusKey) ?? _defaultRadius;
    } catch (e) {
      return _defaultRadius;
    }
  }

  @override
  Future<void> saveSearchRadius(double radius) async {
    
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_radiusKey, radius);
   
  }
}