part of 'station_selection_bloc.dart';

abstract class StationSelectionState extends Equatable {
  const StationSelectionState();
  @override
  List<Object> get props => [];
}

// Trạng thái ban đầu, không có trạm nào được chọn
class NoStationSelected extends StationSelectionState {}

// Trạng thái khi một trạm đã được chọn, chứa dữ liệu của trạm đó
class StationSelectionSuccess extends StationSelectionState {
  final StationEntity selectedStation;
  const StationSelectionSuccess(this.selectedStation);
  @override
  List<Object> get props => [selectedStation];
}