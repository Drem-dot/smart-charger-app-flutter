import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../domain/entities/station_entity.dart';
import '../../bloc/map_control_bloc.dart';
import '../../bloc/station_selection_bloc.dart';

class StationListSheet extends StatelessWidget {
  final String title;
  final List<StationEntity> stations;
  final double radius;
  final bool isLoading;
  final Function(double) onRadiusChanged;
  final Function(double) onRadiusChangeEnd;
  final bool showSlider;

  const StationListSheet({
    super.key,
    required this.title,
    required this.stations,
    required this.radius,
    required this.isLoading,
    required this.onRadiusChanged,
    required this.onRadiusChangeEnd,
    required this.showSlider, 
  });

  @override
  Widget build(BuildContext context) {
    // --- THAY ĐỔI Ở ĐÂY ---
    // Bọc toàn bộ widget bằng một Container để tạo nền và bo góc.
    return Container(
      decoration: BoxDecoration(
        // Sử dụng màu của theme để tương thích với cả Light/Dark mode
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16.0,
          8.0,
          16.0,
          16.0,
        ), // Giảm padding top một chút
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // (Tùy chọn) Thêm một tay nắm kéo (drag handle) cho đẹp
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // --- Phần Header và Slider (Không đổi) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (showSlider) ...[
              Text(
                'Trong vòng ${radius.toStringAsFixed(1)} km',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Slider(
                value: radius,
                min: 1.0,
                max: 10.0,
                divisions: 9,
                label: '${radius.toStringAsFixed(1)} km',
                onChanged: onRadiusChanged,
                onChangeEnd: onRadiusChangeEnd,
              ),
            ],

            const Divider(),

            // --- Phần Danh sách (Không đổi) ---
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            if (!isLoading && stations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Không tìm thấy trạm sạc nào.'),
                ),
              ),

            if (!isLoading && stations.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    return ListTile(
                      leading: const Icon(Icons.ev_station),
                      title: Text(station.name),
                      subtitle: Text(
                        station.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        // --- THAY ĐỔI THỨ TỰ Ở ĐÂY ---

                        // BƯỚC 1: Gửi event "chọn" trạm.
                        // Điều này sẽ kích hoạt StationClusterLego vẽ lại icon focus.
                        context.read<StationSelectionBloc>().add(
                          StationSelected(station),
                        );

                        // BƯỚC 2: Di chuyển camera.
                        context.read<MapControlBloc>().add(
                          CameraMoveRequested(
                            LatLng(station.lat, station.lon),
                            16.0,
                          ),
                        );

                        // BƯỚC 3: Đóng sheet.
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
