part of 'station_selection_bloc.dart';

abstract class StationSelectionState extends Equatable {
  const StationSelectionState();
  @override
  List<Object?> get props => [];
}

class NoStationSelected extends StationSelectionState {}

class StationSelectionSuccess extends StationSelectionState {
  final StationEntity selectedStation;
  const StationSelectionSuccess(this.selectedStation);
  @override
  List<Object> get props => [selectedStation];
}

// THÊM MỚI: State khi người dùng đang điền form báo cáo
class StationReportInProgress extends StationSelectionState {
  final StationEntity stationToReport;
  const StationReportInProgress(this.stationToReport);
  @override
  List<Object> get props => [stationToReport];
}

// THÊM MỚI: State tạm thời để kích hoạt popup/snackbar thành công
class StationReportSendSuccess extends StationSelectionState {}