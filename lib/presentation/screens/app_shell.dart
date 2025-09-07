// lib/presentation/screens/app_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_charger_app/presentation/screens/add_station_screen.dart'; // <-- Sử dụng màn hình thêm trạm chi tiết
import 'package:smart_charger_app/presentation/screens/map_page.dart';
import 'package:smart_charger_app/presentation/screens/settings_page.dart';
import 'package:smart_charger_app/presentation/screens/station_list_page.dart';
import '../bloc/navigation_cubit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, BottomNavItem>(
        builder: (context, activeTab) {
          return Scaffold(
            body: IndexedStack(
              index: activeTab.index,
              // --- CẬP NHẬT: Danh sách các trang ---
              children: const [
                MapPage(),
                StationListPage(),
                // Tab "Thêm" sẽ điều hướng đến màn hình chi tiết
                // Chúng ta để một Container trống ở đây, logic sẽ được xử lý trong onTap
                AddStationScreen(),
                SettingsPage(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: activeTab.index,
              onTap: (index) {
                // Logic đặc biệt cho nút "Thêm"
                if (index == 2) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStationScreen()));
                } else {
                  context.read<NavigationCubit>().changeTab(index);
                }
              },
              // THAY ĐỔI: Làm cho thanh điều hướng đẹp hơn
              type: BottomNavigationBarType.fixed, // Để hiển thị label
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              // --- CẬP NHẬT: Các mục ---
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Bản đồ'),
                BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Danh sách'),
                BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Thêm'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Cài đặt'),
              ],
            ),
          );
        },
      ),
    );
  }
}