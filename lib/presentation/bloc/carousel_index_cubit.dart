// lib/presentation/bloc/carousel_index_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class CarouselIndexCubit extends Cubit<int> {
  // Trạng thái ban đầu là trang 0
  CarouselIndexCubit() : super(0);

  /// Cập nhật index hiện tại
  void setIndex(int newIndex) => emit(newIndex);

  /// Reset index về 0
  void reset() => emit(0);
}