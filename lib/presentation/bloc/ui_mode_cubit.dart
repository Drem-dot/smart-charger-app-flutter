// lib/presentation/bloc/ui_mode_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

// Enum định nghĩa các chế độ giao diện của màn hình bản đồ
enum UIMode { exploring, routing }

class UIModeCubit extends Cubit<UIMode> {
  // Trạng thái ban đầu là "Khám phá"
  UIModeCubit() : super(UIMode.exploring);

  /// Chuyển sang chế độ Tìm đường
  void showRouting() => emit(UIMode.routing);

  /// Quay trở lại chế độ Khám phá
  void showExploring() => emit(UIMode.exploring);
}