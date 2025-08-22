import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../domain/entities/geocoding_result_entity.dart';
import '../../../domain/repositories/i_geocoding_repository.dart';
import '../../bloc/map_control_bloc.dart';
import '../../bloc/point_selection_bloc.dart';
import '../../bloc/route_bloc.dart';
import '../../bloc/station_selection_bloc.dart';
import '../../bloc/stations_on_route_bloc.dart';
import 'station_list_sheet.dart';

class DirectionsLego extends StatefulWidget {
  final Position? currentUserPosition;
  const DirectionsLego({super.key, this.currentUserPosition});

  @override
  State<DirectionsLego> createState() => _DirectionsLegoState();
}

class _DirectionsLegoState extends State<DirectionsLego> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  late final IGeocodingRepository _geocodingRepository;

  @override
  void initState() {
    super.initState();
    _geocodingRepository = context.read<IGeocodingRepository>();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  // --- HÀM _showStationsList ĐÃ ĐƯỢC CẬP NHẬT HOÀN TOÀN ---
  void _showStationsList(BuildContext context) {
    final routeState = context.read<RouteBloc>().state;
    if (routeState is! RouteSuccess || routeState.route == null) return;

    // Bắn event mới để tìm kiếm và lọc
    context.read<StationsOnRouteBloc>().add(FindStationsForRoute(routeState.route!));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: BlocProvider.of<StationsOnRouteBloc>(context)),
            BlocProvider.value(value: BlocProvider.of<MapControlBloc>(context)),
            BlocProvider.value(value: BlocProvider.of<StationSelectionBloc>(context)),
          ],
          // Lắng nghe StationsOnRouteBloc để hiển thị loading và kết quả
          child: BlocBuilder<StationsOnRouteBloc, StationsOnRouteState>(
            builder: (sheetContext, state) {
              return PointerInterceptor(
                child: StationListSheet(
                  title: 'Trạm sạc trên lộ trình',
                  stations: state.stations,
                  isLoading: state.status == StationsOnRouteStatus.loading,
                  // Tắt hoàn toàn slider
                  showSlider: false,
                  // Cung cấp các giá trị giả và hàm rỗng vì không dùng đến
                  radius: 0,
                  onRadiusChanged: (_) {},
                  onRadiusChangeEnd: (_) {},
                ),
              );
            },
          ),
        );
      },
    );
  }

  // --- CÁC HÀM KHÁC KHÔNG CÓ THAY ĐỔI LỚN ---
  Widget _buildPointInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required PointType pointType,
    required String? currentName,
  }) {
    // ... (Giữ nguyên không đổi)
    final key = ValueKey(currentName ?? hintText);
    return Row(
      children: [
        Expanded(
          child: TypeAheadField<GeocodingResult>(
            key: key,
            suggestionsCallback: (query) async {
              if (query.trim().isEmpty) return [];
              return await _geocodingRepository.search(query);
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion.name),
                subtitle: Text(suggestion.address, maxLines: 1, overflow: TextOverflow.ellipsis),
              );
            },
            onSelected: (result) {
              controller.text = result.name;
              final event = pointType == PointType.origin
                  ? OriginUpdated(position: result.latLng, name: result.name)
                  : DestinationUpdated(position: result.latLng, name: result.name);
              context.read<RouteBloc>().add(event);
            },
            builder: (context, controller, focusNode) {
              if (currentName != null && controller.text != currentName) {
                controller.text = currentName;
              }
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  prefixIcon: Icon(icon),
                  hintText: hintText,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              );
            },
          ),
        ),
        _buildPointMenuButton(context, pointType),
      ],
    );
  }

  Widget _buildPointMenuButton(BuildContext context, PointType type) {
    // ... (Giữ nguyên không đổi)
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'current_location') {
          final position = widget.currentUserPosition;
          if (position != null) {
            final latLng = LatLng(position.latitude, position.longitude);
            final name = 'Vị trí của bạn';
            final event = type == PointType.origin
                ? OriginUpdated(position: latLng, name: name)
                : DestinationUpdated(position: latLng, name: name);
            context.read<RouteBloc>().add(event);
          }
        } else if (value == 'select_on_map') {
          context.read<PointSelectionBloc>().add(SelectionStarted(type));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'current_location',
          child: ListTile(leading: Icon(Icons.my_location), title: Text('Vị trí của bạn')),
        ),
        const PopupMenuItem<String>(
          value: 'select_on_map',
          child: ListTile(leading: Icon(Icons.map_outlined), title: Text('Chọn trên bản đồ')),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (Hàm build chính không đổi)
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        final bool canFindRoute = state.originPosition != null && state.destinationPosition != null;
        final bool hasRoute = state is RouteSuccess;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildPointInputField(
                        controller: _originController,
                        hintText: 'Chọn điểm bắt đầu',
                        icon: Icons.trip_origin,
                        pointType: PointType.origin,
                        currentName: state.originName,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildPointInputField(
                        controller: _destinationController,
                        hintText: 'Chọn điểm kết thúc',
                        icon: Icons.location_on,
                        pointType: PointType.destination,
                        currentName: state.destinationName,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_vert),
                  tooltip: 'Đảo ngược',
                  onPressed: () => context.read<RouteBloc>().add(RoutePointsSwapped()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canFindRoute ? () => context.read<RouteBloc>().add(DirectionsFetched()) : null,
                      child: const Text('Tìm đường'),
                    ),
                  ),
                  if (hasRoute) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.ev_station_outlined, size: 20),
                        label: const Text('Tìm trên đường'),
                        onPressed: () => _showStationsList(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}