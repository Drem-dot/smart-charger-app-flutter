part of 'add_station_bloc.dart';

abstract class AddStationEvent extends Equatable {
  const AddStationEvent();
  @override
  List<Object> get props => [];
}

// Bắn khi người dùng xác nhận vị trí trên bản đồ mini
class PositionSelected extends AddStationEvent {
  final LatLng position;
  const PositionSelected(this.position);
  @override
  List<Object> get props => [position];
}

// Bắn khi người dùng nhấn nút "Gửi" trên form
class FormSubmitted extends AddStationEvent {
  final Map<String, dynamic> formData;
  final LatLng position;
  final List<XFile> images; 
  const FormSubmitted(this.formData, this.position, this.images);
  @override
  List<Object> get props => [formData, position , images];
}

// Bắn để reset BLoC về trạng thái ban đầu
class AddStationReset extends AddStationEvent {}