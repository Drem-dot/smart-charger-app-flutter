// lib/presentation/widgets/station_carousel_card.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';
import 'package:smart_charger_app/presentation/map/widgets/directions_button_lego.dart';

class StationCarouselCard extends StatelessWidget {
  final StationEntity station;
  final VoidCallback onTap;
  final Position? currentUserPosition;

  const StationCarouselCard({
    super.key,
    required this.station,
    required this.onTap,
    this.currentUserPosition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 160, // Đặt chiều cao cố định cho card
          padding: const EdgeInsets.all(12.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- HÀNG TRÊN CÙNG - SỬ DỤNG DỮ LIỆU THẬT ---
                        Row(
                          children: [
                            Icon(Icons.ev_station, color: theme.primaryColor, size: 18),
                            const SizedBox(width: 6),
                            // Hiển thị khoảng cách nếu có
                            if (station.distanceInKm != null)
                              Text(
                                '${station.distanceInKm!.toStringAsFixed(1)} km',
                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                              ),
                            
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  '${station.ratingsAverage.toStringAsFixed(1)} (${station.ratingsQuantity})',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        
                        // --- TÊN VÀ ĐỊA CHỈ ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                station.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Flexible(
                                child: Text(
                                  station.address,
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // --- HÀNG DƯỚI CÙNG ---
                        SizedBox(
                          width: double.infinity, // Đảm bảo nút chiếm toàn bộ chiều rộng
                          child: DirectionsButtonLego(destination: station.position),
                        ),],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}