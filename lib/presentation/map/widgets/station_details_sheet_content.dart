import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';
import 'package:smart_charger_app/presentation/bloc/station_selection_bloc.dart';
import 'package:smart_charger_app/presentation/map/widgets/directions_button_lego.dart';
import 'package:smart_charger_app/l10n/app_localizations.dart';
import 'package:smart_charger_app/presentation/map/widgets/station_review_lego.dart';
import 'package:smart_charger_app/presentation/utils/formatters.dart';

class StationDetailsSheetContent extends StatelessWidget {
  final StationEntity station;
  final ScrollController scrollController;
  final GlobalKey collapsedContentKey;
  final Position? currentUserPosition;

  const StationDetailsSheetContent({
    super.key,
    required this.station,
    required this.scrollController,
    required this.collapsedContentKey,
    this.currentUserPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          // Handle kéo
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // --- PHẦN 1: NỘI DUNG THU GỌN ---
          _SheetCollapsedContent(
            key: collapsedContentKey,
            station: station,
            currentUserPosition: currentUserPosition,
          ),

          // --- PHẦN 2: NỘI DUNG MỞ RỘNG (ĐÁNH GIÁ) ---
          _SheetExpandedContent(station: station),
        ],
      ),
    );
  }
}

/// Widget private chứa nội dung hiển thị ở trạng thái thu gọn
class _SheetCollapsedContent extends StatelessWidget {
  final StationEntity station;
  final Position? currentUserPosition;
  const _SheetCollapsedContent({
    super.key,
    required this.station,
    this.currentUserPosition,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Quan trọng để đo chiều cao chính xác
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BẮT ĐẦU NỘI DUNG ĐÃ BỊ THIẾU ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.ev_station,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        if (station.distanceInKm != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              formatDistance(station.distanceInKm!),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),

                    Text(
                      station.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      station.address,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.read<StationSelectionBloc>().add(
                  StationDeselected(),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  context,
                  Icons.electric_bolt,
                  AppLocalizations.of(context)!.sheetStatusLabel,
                  station.status.toUpperCase(),
                  valueColor: station.status.toLowerCase() == 'available'
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.report_problem_outlined),
                tooltip: AppLocalizations.of(context)!.sheetReportProblemTooltip,
                onPressed: () => context.read<StationSelectionBloc>().add(
                  StationReportInitiated(),
                ),
              ),
            ],
          ),
          _buildConnectorDetailsList(context, station.numConnectorsByPower),
          _buildInfoRow(
            context,
            Icons.access_time_filled,
            AppLocalizations.of(context)!.sheetOperatingHoursLabel,
            station.operatingHours ?? AppLocalizations.of(context)!.noInfo,
          ),
          _buildInfoRow(
            context,
            Icons.local_parking,
            AppLocalizations.of(context)!.sheetParkingDetailsLabel,
            station.pricingDetails ?? AppLocalizations.of(context)!.noInfo,
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, // Đảm bảo nút chiếm toàn bộ chiều rộng
            child: DirectionsButtonLego(destination: station.position),
          ),

          
        ],
      ),
    );
  }

  // Các hàm helper được chuyển vào đây
 Widget _buildConnectorDetailsList(BuildContext context, Map<String, int> connectors) {
  if (connectors.isEmpty) {
    return const SizedBox.shrink();
  }

  final powerLevels = connectors.keys.map((key) => int.tryParse(key) ?? 0).toList();
  final bool isLowPowerOnly = powerLevels.every((power) => power <= 3);
  final int totalConnectors = connectors.values.fold(0, (sum, count) => sum + count);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.power,
          color: Theme.of(context).textTheme.bodySmall?.color,
          size: 20,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLowPowerOnly) ...[
                Text(AppLocalizations.of(context)!.sheetConnectorTotalTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(context)!.sheetConnectorInfo(totalConnectors.toString())),
              ] else ...[
                Text(AppLocalizations.of(context)!.sheetConnectorDetailsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                
                // --- SỬA LỖI LOGIC Ở ĐÂY ---
                ...(){ // Sử dụng một hàm ẩn danh để xử lý logic phức tạp
                  // 1. Lọc và Sắp xếp
                  final sortedPowerLevels = powerLevels
                      .where((power) => power > 0)
                      .toList()
                      ..sort((a, b) => b.compareTo(a));
 
                  // 2. Map (Biến đổi) thành các Widget Text
                  return sortedPowerLevels.map((power) {
                    final count = connectors[power.toString()];
                    return Text(AppLocalizations.of(context)!.sheetConnectorPowerInfo(count.toString(), power.toString()));
                  }).toList(); // Chuyển kết quả map thành một List<Widget>
                }(), // Gọi hàm ẩn danh ngay lập tức
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 16),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget private chứa nội dung chỉ hiển thị ở trạng thái mở rộng
class _SheetExpandedContent extends StatelessWidget {
  final StationEntity station;
  const _SheetExpandedContent({required this.station});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: StationReviewLego(station: station),
    );
  }
}
