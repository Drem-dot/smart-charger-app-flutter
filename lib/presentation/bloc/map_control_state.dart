part of 'map_control_bloc.dart';

abstract class MapControlState extends Equatable {
  const MapControlState();

  @override
  List<Object> get props => [];
}

class MapControlInitial extends MapControlState {}

class MapCameraUpdate extends MapControlState {
  final CameraUpdate cameraUpdate;
  // Thêm một ID ngẫu nhiên để buộc BlocBuilder/Listener nhận diện sự thay đổi
  // ngay cả khi CameraUpdate giống hệt nhau.
  final int id;

  MapCameraUpdate(this.cameraUpdate) : id = Random().nextInt(999999);

  @override
  List<Object> get props => [cameraUpdate, id];
}