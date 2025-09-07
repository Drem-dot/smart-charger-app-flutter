import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';
import 'package:smart_charger_app/presentation/bloc/navigation_cubit.dart';
import 'package:smart_charger_app/presentation/bloc/route_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/station_selection_bloc.dart';
import 'package:smart_charger_app/presentation/map/widgets/directions_button_lego.dart';
import 'package:smart_charger_app/presentation/map/widgets/station_review_lego.dart';

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
          BoxShadow(color: Colors.black.withValues ( alpha:  0.15), blurRadius: 10, spreadRadius: 5),
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
  const _SheetCollapsedContent({super.key, required this.station,this.currentUserPosition});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    Text(station.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(station.address, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.read<StationSelectionBloc>().add(StationDeselected()),
              ),
            ],
          ),
          const Divider(height: 24),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(context, Icons.electric_bolt, 'Trạng thái', station.status.toUpperCase(),
                  valueColor: station.status.toLowerCase() == 'available' ? Colors.green : Colors.orange),
              ),
              IconButton(
                icon: const Icon(Icons.report_problem_outlined),
                tooltip: 'Báo cáo vấn đề',
                onPressed: () => context.read<StationSelectionBloc>().add(StationReportInitiated()),
              ),
            ],
          ),
          _buildConnectorDetailsList(context, station.numConnectorsByPower),
          _buildInfoRow(context, Icons.access_time_filled, 'Giờ hoạt động', station.operatingHours ?? 'Chưa có thông tin'),
          _buildInfoRow(context, Icons.local_parking, 'Chi tiết đỗ xe', station.pricingDetails ?? 'Chưa có thông tin'),
          
          const SizedBox(height: 24),
          Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (currentUserPosition != null) {
                          final routeBloc = context.read<RouteBloc>();
                          routeBloc.add(OriginUpdated(
                            position: LatLng(currentUserPosition!.latitude, currentUserPosition!.longitude),
                            name: 'Vị trí của bạn',
                          ));
                          routeBloc.add(DestinationUpdated(
                            position: station.position,
                            name: station.name,
                          ));
                          context.read<NavigationCubit>().changeTab(BottomNavItem.map.index);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  minimumSize: const Size(0, 36),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  foregroundColor: theme.primaryColor,
                                  side: BorderSide(color: theme.primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                ),
                      child: const Text('Xem đường'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DirectionsButtonLego(destination: station.position),
                  ),
                ],
              ),
            ],
      ),
    );
  }
  
  // Các hàm helper được chuyển vào đây
  Widget _buildConnectorDetailsList(BuildContext context, Map<String, int> connectors) {
    final sortedKeys = connectors.keys.toList()..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
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
              const Text('Cổng sạc:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...sortedKeys.map((key) => Text('${connectors[key]} cổng ${key}KW')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 16),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: TextStyle(color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color))),
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