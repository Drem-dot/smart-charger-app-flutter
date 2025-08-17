part of 'station_selection_bloc.dart';

abstract class StationSelectionEvent extends Equatable {
  const StationSelectionEvent();
  @override

  List<Object> get props => [];
}

// Event được bắn khi người dùng chọn một trạm
class StationSelected extends StationSelectionEvent {
  final StationEntity station;
  const StationSelected(this.station);
  @override
  List<Object> get props => [station];
}

// Event được bắn khi người dùng đóng BottomSheet hoặc bỏ chọn
class StationDeselected extends StationSelectionEvent {}