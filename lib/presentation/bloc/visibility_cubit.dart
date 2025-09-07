// lib/presentation/bloc/visibility_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

/// Một Cubit đơn giản để quản lý trạng thái hiển thị (true/false)
/// của một widget nào đó, ví dụ như Carousel.
class VisibilityCubit extends Cubit<bool> {
  // Trạng thái ban đầu là `true` (hiển thị)
  VisibilityCubit() : super(true);

  /// Hiển thị widget
  void show() => emit(true);

  /// Ẩn widget
  void hide() => emit(false);

  /// Đảo ngược trạng thái hiển thị
  void toggle() => emit(!state);
}