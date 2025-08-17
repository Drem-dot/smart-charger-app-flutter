abstract class ISettingsRepository {
  Future<void> saveSearchRadius(double radius);
  Future<double> getSearchRadius();
}