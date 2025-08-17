import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

// Đảm bảo rằng bạn đã import đúng đường dẫn đến các file này trong project của bạn
import '../../../domain/entities/geocoding_result_entity.dart';
import '../../../domain/repositories/i_geocoding_repository.dart';
import '../../bloc/map_control_bloc.dart';
import '../../bloc/point_selection_bloc.dart';
import '../../bloc/route_bloc.dart';
import '../../bloc/station_selection_bloc.dart';
import '../../bloc/stations_on_route_bloc.dart';
import 'station_list_sheet.dart'; // Widget hiển thị danh sách trạm trong bottom sheet

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

  /// Hàm hiển thị bottom sheet danh sách các trạm sạc trên lộ trình.
  /// Logic được chuyển từ widget StationsOnRouteLego cũ.
  void _showStationsList(BuildContext context) {
    final routeState = context.read<RouteBloc>().state;
    // Chỉ hoạt động khi đã có kết quả tìm đường thành công (RouteSuccess)
    if (routeState is! RouteSuccess || routeState.route == null) return;

    // Bắn event để StationsOnRouteBloc bắt đầu tìm kiếm các trạm
    context.read<StationsOnRouteBloc>().add(FetchStationsOnRoute(routeState.route!));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép sheet chiếm nhiều không gian hơn
      backgroundColor: Colors.transparent, // Nền trong suốt để bo góc có hiệu lực
      builder: (_) { // (_) là context của BottomSheet
        // Cung cấp các BLoC cần thiết cho cây widget của BottomSheet
        return MultiBlocProvider(
          providers: [
            // Cung cấp instance StationsOnRouteBloc đã có từ MapPage
            BlocProvider.value(value: BlocProvider.of<StationsOnRouteBloc>(context)),
            // Cung cấp các BLoC khác mà StationListSheet có thể cần
            BlocProvider.value(value: BlocProvider.of<MapControlBloc>(context)),
            BlocProvider.value(value: BlocProvider.of<StationSelectionBloc>(context)),
          ],
          child: BlocBuilder<StationsOnRouteBloc, StationsOnRouteState>(
            builder: (sheetContext, state) {
              // PointerInterceptor ngăn các thao tác chạm bị "lọt" xuống bản đồ bên dưới
              return PointerInterceptor(
                child: StationListSheet(
                  title: 'Trạm sạc trên lộ trình',
                  stations: state is StationsOnRouteSuccess ? state.stations : [],
                  radius: state.radius,
                  isLoading: state is StationsOnRouteLoading,
                  onRadiusChanged: (newRadius) {
                    sheetContext.read<StationsOnRouteBloc>().add(RadiusChanged(newRadius));
                  },
                  onRadiusChangeEnd: (newRadius) {
                    if (routeState.route != null) {
                      sheetContext.read<StationsOnRouteBloc>().add(RadiusChangeCompleted(routeState.route!));
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Xây dựng ô nhập liệu cho điểm đầu/cuối với chức năng gợi ý địa điểm.
  Widget _buildPointInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required PointType pointType,
    required String? currentName,
  }) {
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

  /// Xây dựng menu (nút ba chấm) cho phép chọn vị trí hiện tại hoặc chọn trên bản đồ.
  Widget _buildPointMenuButton(BuildContext context, PointType type) {
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
    // Lắng nghe trạng thái của RouteBloc để cập nhật giao diện
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        final bool canFindRoute = state.originPosition != null && state.destinationPosition != null;
        // Nút "Tìm trạm trên đường" chỉ hiển thị khi đã có kết quả tìm đường thành công
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
                // Nút đảo ngược điểm đầu và cuối
                IconButton(
                  icon: const Icon(Icons.swap_vert),
                  tooltip: 'Đảo ngược',
                  onPressed: () => context.read<RouteBloc>().add(RoutePointsSwapped()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Hàng chứa các nút hành động chính
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Nút Tìm đường
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canFindRoute ? () => context.read<RouteBloc>().add(DirectionsFetched()) : null,
                      child: const Text('Tìm đường'),
                    ),
                  ),
                  // Nút "Tìm trạm trên đường" (hiển thị có điều kiện)
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