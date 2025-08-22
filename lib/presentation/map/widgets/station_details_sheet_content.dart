// lib/presentation/map/widgets/station_details_sheet_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:smart_charger_app/presentation/map/widgets/directions_button_lego.dart';
import '../../../domain/entities/station_entity.dart';
import '../../bloc/station_selection_bloc.dart';

class StationDetailsSheetContent extends StatelessWidget {
  final StationEntity station;
  const StationDetailsSheetContent({super.key, required this.station});

   @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Phần Header (không đổi) ---
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
                  onPressed: () => context.read<StationSelectionBloc>().add(StationDeselected()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(station.address, style: Theme.of(context).textTheme.bodyMedium),
            const Divider(height: 24),
            
            // --- THAY ĐỔI LỚN: Kết hợp dòng Trạng thái và nút Báo lỗi ---
            Row(
              children: [
                // Dòng "Trạng thái" sẽ chiếm phần lớn không gian
                Expanded(
                  child: _buildInfoRow(
                    context, 
                    Icons.electric_bolt, 
                    'Trạng thái', 
                    station.status.toUpperCase(),
                    valueColor: station.status.toLowerCase() == 'available' ? Colors.green : Colors.orange
                  ),
                ),
                // Nút "Báo cáo vấn đề" nằm ở cuối
                IconButton(
                  icon: const Icon(Icons.report_problem_outlined),
                  tooltip: 'Báo cáo vấn đề',
                  onPressed: () {
                    context.read<StationSelectionBloc>().add(StationReportInitiated());
                  },
                ),
              ],
            ),

            // Các dòng thông tin chi tiết khác giữ nguyên
            _buildConnectorDetailsList(context, station.numConnectorsByPower),
            _buildInfoRow(context, Icons.access_time_filled, 'Giờ hoạt động', station.operatingHours ?? 'Chưa có thông tin'),
            _buildInfoRow(context, Icons.local_parking, 'Chi tiết đỗ xe', station.pricingDetails ?? 'Chưa có thông tin'),
            
            // Nút Dẫn đường ở dưới cùng
            const SizedBox(height: 24),
            Center(
              child: DirectionsButtonLego(
                destination: LatLng(station.lat, station.lon),
              ),
            ),
            const SizedBox(height: 8), 
          ],
        ),
      ),
    );
  }// Widget helper mới để hiển thị danh sách cổng sạc
  Widget _buildConnectorDetailsList(BuildContext context, Map<String, int> connectors) {
    // Sắp xếp các loại công suất từ cao đến thấp
    final sortedKeys = connectors.keys.toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.power, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cổng sạc:', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              // Tạo danh sách Text cho từng loại công suất
              ...sortedKeys.map((power) {
                final count = connectors[power];
                return Text('$count cổng ${power}KW');
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Widget helper cũ được cập nhật để linh hoạt hơn
  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 16),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color))),
        ],
      ),
    );
  }
}