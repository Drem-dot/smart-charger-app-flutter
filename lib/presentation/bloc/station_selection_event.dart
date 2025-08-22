part of 'station_selection_bloc.dart';

abstract class StationSelectionEvent extends Equatable {
  const StationSelectionEvent();
  @override
  List<Object?> get props => [];
}

class StationSelected extends StationSelectionEvent {
  final StationEntity station;
  const StationSelected(this.station);
  @override
  List<Object> get props => [station];
}

class StationDeselected extends StationSelectionEvent {}

// THÊM MỚI: Kích hoạt luồng báo cáo
class StationReportInitiated extends StationSelectionEvent {}

// THÊM MỚI: Gửi dữ liệu báo cáo đi
class StationReportSubmitted extends StationSelectionEvent {
  final String reason;
  final String? details;
  final String? phoneNumber;
  const StationReportSubmitted({required this.reason, this.details, this.phoneNumber});
  @override
  List<Object?> get props => [reason, details, phoneNumber];
}