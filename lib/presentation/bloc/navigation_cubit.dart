// lib/presentation/bloc/navigation_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

// THAY ĐỔI: Mở rộng enum
enum BottomNavItem { map, list, addStation, settings }

class NavigationCubit extends Cubit<BottomNavItem> {
  NavigationCubit() : super(BottomNavItem.map);

  void changeTab(int index) {
    switch (index) {
      case 0:
        emit(BottomNavItem.map);
        break;
      case 1:
        emit(BottomNavItem.list);
        break;
      case 2:
        emit(BottomNavItem.addStation);
        break;
      case 3:
        emit(BottomNavItem.settings);
        break;
    }
  }
}