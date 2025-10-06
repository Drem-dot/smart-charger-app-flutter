import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../domain/entities/geocoding_result_entity.dart';
import '../../../domain/repositories/i_geocoding_repository.dart';
import '../../bloc/point_selection_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/route_bloc.dart';

class SpecialSuggestion extends Object {
  final String title;
  final IconData icon;
  final VoidCallback onSelect;

  SpecialSuggestion({
    required this.title,
    required this.icon,
    required this.onSelect,
  });
}

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

  // --- CÁC HÀM KHÁC KHÔNG CÓ THAY ĐỔI LỚN ---
  Widget _buildPointInputField({
    required TextEditingController controller,
    required String hintText,
    required PointType pointType,
    required String? currentName,
  }) {
    final key = ValueKey('point_${pointType}_${currentName ?? ''}');
    final routeBloc = context.read<RouteBloc>();
    final pointSelectionBloc = context.read<PointSelectionBloc>();

    // Tạo danh sách các gợi ý đặc biệt
    final List<SpecialSuggestion> specialSuggestions = [
      SpecialSuggestion(
        title: AppLocalizations.of(context)!.yourLocation,
        icon: Icons.my_location,
        onSelect: () {
          final position = widget.currentUserPosition;
          if (position != null) {
            final latLng = LatLng(position.latitude, position.longitude);
            final name = AppLocalizations.of(context)!.yourLocation;
            final event = pointType == PointType.origin
                ? OriginUpdated(position: latLng, name: name)
                : DestinationUpdated(position: latLng, name: name);
            routeBloc.add(event);
          }
        },
      ),
      SpecialSuggestion(
        title: AppLocalizations.of(context)!.chooseOnMap,
        icon: Icons.map_outlined,
        onSelect: () {
          pointSelectionBloc.add(SelectionStarted(pointType));
        },
      ),
    ];

    return TypeAheadField<dynamic>( // Kiểu dữ liệu bây giờ là `dynamic`
      key: key,
      suggestionsCallback: (query) async {
        // Nếu không có query, chỉ hiển thị các gợi ý đặc biệt
        if (query.trim().isEmpty) {
          return specialSuggestions;
        }
        // Nếu có query, tìm kiếm và thêm các gợi ý đặc biệt vào đầu
        final searchResults = await _geocodingRepository.search(query);
        return [...specialSuggestions, ...searchResults];
      },
      itemBuilder: (context, suggestion) {
        // Xử lý hiển thị cho cả hai loại gợi ý
        if (suggestion is GeocodingResult) {
          return ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(suggestion.name),
            subtitle: Text(suggestion.address, maxLines: 1, overflow: TextOverflow.ellipsis),
          );
        } else if (suggestion is SpecialSuggestion) {
          return ListTile(
            leading: Icon(suggestion.icon),
            title: Text(suggestion.title),
          );
        }
        return const SizedBox.shrink(); // Trường hợp dự phòng
      },
      onSelected: (suggestion) {
        // Xử lý khi chọn
        if (suggestion is GeocodingResult) {
          controller.text = suggestion.name;
          final event = pointType == PointType.origin
              ? OriginUpdated(position: suggestion.latLng, name: suggestion.name)
              : DestinationUpdated(position: suggestion.latLng, name: suggestion.name);
          routeBloc.add(event);
        } else if (suggestion is SpecialSuggestion) {
          // Xóa text trong ô nhập liệu và thực hiện hành động
          controller.clear();
          suggestion.onSelect();
        }
      },
      builder: (context, controller, focusNode) {
        if (currentName != null && controller.text != currentName) {
          controller.text = currentName;
        } else if (currentName == null) {
          controller.clear();
        }
        
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          ),
        );
      },
    );
  }
   @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- CỘT ICON KIỂU GRAB ---
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trip_origin, color: Colors.blue, size: 18),
                  SizedBox(
                    height: 32, // Chiều cao của đường nối
                    width: 2,
                    // Vẽ đường chấm chấm
                    child: ListView.builder(
                      itemCount: 4,
                      itemBuilder: (context, index) => Container(
                        height: 4,
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                ],
              ),
              const SizedBox(width: 12),

              // --- CỘT NHẬP LIỆU ---
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPointInputField(
                      controller: _originController,
                      hintText: AppLocalizations.of(context)!.chooseStartPoint,
                      pointType: PointType.origin,
                      currentName: state.originName,
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildPointInputField(
                      controller: _destinationController,
                      hintText: AppLocalizations.of(context)!.chooseDestination,
                      pointType: PointType.destination,
                      currentName: state.destinationName,
                    ),
                  ],
                ),
              ),
              
              // --- Nút đảo ngược vị trí ---
              IconButton(
                icon: const Icon(Icons.swap_vert),
                tooltip: AppLocalizations.of(context)!.swapTooltip,
                onPressed: () => context.read<RouteBloc>().add(RoutePointsSwapped()),
              ),
            ],
          ),
        );
      },
    );
  }
}