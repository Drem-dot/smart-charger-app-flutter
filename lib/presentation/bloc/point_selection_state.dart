part of 'point_selection_bloc.dart';

abstract class PointSelectionState extends Equatable {
  const PointSelectionState();

  @override
  List<Object> get props => [];
}

// Trạng thái bình thường, không ở chế độ chọn điểm
class PointSelectionInitial extends PointSelectionState {}

// Trạng thái khi người dùng đang trong quá trình chọn một điểm trên bản đồ
class PointSelectionInProgress extends PointSelectionState {
  final PointType type;
  const PointSelectionInProgress(this.type);
  @override
  List<Object> get props => [type];
}