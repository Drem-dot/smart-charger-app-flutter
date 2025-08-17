part of 'point_selection_bloc.dart';

// Enum để xác định đang chọn điểm đầu hay điểm cuối
enum PointType { origin, destination }

abstract class PointSelectionEvent extends Equatable {
  const PointSelectionEvent();

  @override
  List<Object> get props => [];
}

// Bắn khi người dùng bắt đầu quá trình chọn điểm trên bản đồ
class SelectionStarted extends PointSelectionEvent {
  final PointType type;
  const SelectionStarted(this.type);
  @override
  List<Object> get props => [type];
}

// Bắn khi quá trình chọn điểm bị hủy hoặc hoàn thành
class SelectionFinalized extends PointSelectionEvent {}