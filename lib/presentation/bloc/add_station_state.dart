part of 'add_station_bloc.dart';

abstract class AddStationState extends Equatable {
  const AddStationState();
  @override
  List<Object> get props => [];
}

// Trạng thái ban đầu, chờ chọn vị trí
class AddStationInitial extends AddStationState {}

// Vị trí đã được xác nhận, sẵn sàng để điền form
class AddStationPositionConfirmed extends AddStationState {
  final LatLng position;
  const AddStationPositionConfirmed(this.position);
  @override
  List<Object> get props => [position];
}

// Đang gửi dữ liệu lên server
class AddStationInProgress extends AddStationState {
  // Vẫn giữ lại vị trí để có thể quay lại form nếu lỗi
  final LatLng position;
  const AddStationInProgress(this.position);
  @override
  List<Object> get props => [position];
}

// Gửi thành công
class AddStationSuccess extends AddStationState {
  final StationEntity newStation;
  const AddStationSuccess(this.newStation);
  @override
  List<Object> get props => [newStation];
}

// Gửi thất bại
class AddStationFailure extends AddStationState {
  final LatLng position; // Giữ vị trí để quay lại form
  final String error;
  const AddStationFailure(this.error, this.position);
  @override
  List<Object> get props => [error, position];
}