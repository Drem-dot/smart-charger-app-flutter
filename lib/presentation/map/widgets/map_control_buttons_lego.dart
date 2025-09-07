// lib/presentation/map/widgets/map_control_buttons_lego.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/visibility_cubit.dart';

class MapControlButtonsLego extends StatelessWidget {
  final VoidCallback onMoveToLocationPressed;

  const MapControlButtonsLego({
    super.key, 
    required this.onMoveToLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nút Vị trí hiện tại (cần UserLocationLego đã được tái cấu trúc)
        FloatingActionButton(
          heroTag: 'user_location_button', // Thêm heroTag để tránh xung đột
          onPressed: onMoveToLocationPressed,
          mini: true,
          backgroundColor: Colors.white,
          child: Icon(Icons.my_location, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 12),

        // Nút "Xem toàn cảnh" / Ẩn/Hiện Carousel
        FloatingActionButton(
          heroTag: 'toggle_carousel_button',
          onPressed: () {
            context.read<VisibilityCubit>().toggle();
          },
          mini: true,
          backgroundColor: Colors.white,
          child: BlocBuilder<VisibilityCubit, bool>(
            builder: (context, isVisible) {
              return Icon(
                isVisible ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              );
            },
          ),
        ),
      ],
    );
  }
}