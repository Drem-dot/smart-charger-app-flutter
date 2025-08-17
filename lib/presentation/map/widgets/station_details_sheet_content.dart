import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart'; // Import package
import '../../../domain/entities/station_entity.dart';
import '../../bloc/station_selection_bloc.dart';

class StationDetailsSheetContent extends StatelessWidget {
  final StationEntity station;
  const StationDetailsSheetContent({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI: Bọc toàn bộ Container bằng PointerInterceptor
    return PointerInterceptor(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Chỉ chiếm chiều cao cần thiết
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    station.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // Bắn event để đóng
                    context.read<StationSelectionBloc>().add(StationDeselected());
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(station.address, style: Theme.of(context).textTheme.bodyMedium),
            const Divider(height: 32),
            // Thêm các thông tin chi tiết khác ở đây...
            _buildInfoRow(Icons.power, 'Công suất', '${station.powerKw.join(', ')} kW'),
            _buildInfoRow(Icons.ev_station, 'Loại cổng', station.connectorTypes.join(', ')),
            _buildInfoRow(Icons.info_outline, 'Trạng thái', station.status),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}