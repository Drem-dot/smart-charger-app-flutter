// lib/presentation/screens/app_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart'; // <-- THÊM IMPORT
import 'package:smart_charger_app/presentation/screens/add_station_screen.dart';
import 'package:smart_charger_app/presentation/screens/map_page.dart';
import 'package:smart_charger_app/presentation/screens/settings_page.dart';
import 'package:smart_charger_app/presentation/screens/station_list_page.dart';
import '../bloc/navigation_cubit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  // --- TÁCH HÀM XỬ LÝ ĐIỀU HƯỚNG RA RIÊNG ---
  void _onNavItemTapped(BuildContext context, int index) async {
    // Logic đặc biệt cho nút "Thêm"
    if (index == 2) {
      final result = await Navigator.push<StationEntity?>( // Chỉ định kiểu trả về
        context,
        MaterialPageRoute(builder: (_) => const AddStationScreen()),
      );

      // Xử lý kết quả sau khi màn hình AddStationScreen đóng lại
      if (result != null && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar() // Ẩn snackbar cũ nếu có
          ..showSnackBar(
            SnackBar(
              content: Text('"${result.name}" đã được thêm và đang chờ duyệt.'),
              backgroundColor: Colors.green,
            ),
          );
        
      }
    } else {
      context.read<NavigationCubit>().changeTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, BottomNavItem>(
        builder: (context, activeTab) {
          return Scaffold(
            body: IndexedStack(
              // LƯU Ý: activeTab.index sẽ chỉ là 0, 1, hoặc 3.
              // Chúng ta cần một cách map index của BottomNavBar (0,1,3) sang index của IndexedStack (0,1,2)
              index: _mapBottomNavIndexToBodyIndex(activeTab.index),
              children: const [
                MapPage(),         // index 0
                StationListPage(), // index 1
                SettingsPage(),    // index 2 (tương ứng với tab Cài đặt)
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              // SỬA LẠI currentIndex: Nó không còn map 1-1 với IndexedStack nữa
              currentIndex: activeTab.index,
              onTap: (index) => _onNavItemTapped(context, index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Bản đồ'),    // index 0
                BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Danh sách'), // index 1
                BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Thêm'),     // index 2
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Cài đặt'), // index 3
              ],
            ),
          );
        },
      ),
    );
  }

  // --- THÊM HÀM HELPER ĐỂ MAP INDEX ---
  int _mapBottomNavIndexToBodyIndex(int navIndex) {
    if (navIndex <= 1) { // 0 (Bản đồ), 1 (Danh sách)
      return navIndex;
    }
    if (navIndex == 3) { // 3 (Cài đặt) -> map sang index 2 của body
      return 2;
    }
    // Nếu index là 2 (Thêm), chúng ta vẫn giữ index cũ để không bị lỗi out of bounds
    // Mặc dù tab "Thêm" không có body tương ứng, nhưng khi nhấn vào,
    // ta sẽ điều hướng đi nơi khác trước khi state kịp thay đổi.
    // Tuy nhiên, để an toàn, ta nên clamp giá trị.
    if (navIndex > 1) {
        return navIndex -1;
    }
    return navIndex;
  }
}