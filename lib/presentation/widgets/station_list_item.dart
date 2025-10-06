// lib/presentation/widgets/station_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';
import 'package:smart_charger_app/presentation/bloc/map_control_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/navigation_cubit.dart';
import 'package:smart_charger_app/presentation/bloc/station_selection_bloc.dart';
import 'package:smart_charger_app/presentation/map/widgets/directions_button_lego.dart';

class StationListItem extends StatelessWidget {
  final StationEntity station;
  final Position? currentUserPosition;

  const StationListItem({
    super.key,
    required this.station,
    required this.currentUserPosition,
  });

   @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isAvailable = station.status.toLowerCase() == 'available';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      clipBehavior: Clip.antiAlias, // Giúp hiệu ứng InkWell đẹp hơn
      child: InkWell( // <-- BỌC BẰNG INKWELL
        onTap: () {
          // 1. Gửi lệnh focus
          context.read<StationSelectionBloc>().add(StationSelected(station));
          // 2. Gửi lệnh di chuyển camera
          context.read<MapControlBloc>().add(CameraMoveRequested(station.position, 16.0));
          // 3. Quay về tab bản đồ
          context.read<NavigationCubit>().changeTab(BottomNavItem.map.index);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HÀNG TRÊN CÙNG ---
              Row(
                children: [
                  Icon(Icons.ev_station, color: theme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  if (station.distanceInKm != null)
                    Text('${station.distanceInKm!.toStringAsFixed(1)} km', style: theme.textTheme.bodySmall),
                  const Spacer(),
                  _buildStatusTag(isAvailable),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${station.ratingsAverage.toStringAsFixed(1)} (${station.ratingsQuantity})',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // --- TÊN VÀ ĐỊA CHỈ ---
              Text(
                station.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                station.address,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // --- HÀNG CÁC NÚT BẤM ---
              SizedBox(
                          width: double.infinity, // Đảm bảo nút chiếm toàn bộ chiều rộng
                          child: DirectionsButtonLego(destination: station.position),
                        ),],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusTag(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        isAvailable ? 'Available' : 'In Use',
        style: TextStyle(
          color: isAvailable ? Colors.green.shade800 : Colors.orange.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}