// lib/presentation/screens/station_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/domain/entities/autocomplete_prediction.dart';
import 'package:smart_charger_app/domain/entities/filter_params.dart';
import 'package:smart_charger_app/domain/repositories/i_geocoding_repository.dart';
import 'package:smart_charger_app/presentation/bloc/nearby_stations_bloc.dart';
import 'package:smart_charger_app/presentation/screens/filter_page.dart';
import 'package:smart_charger_app/presentation/widgets/station_list_item.dart';

class StationListPage extends StatefulWidget  {
  const StationListPage({super.key});

   @override
  State<StationListPage> createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  // --- THÊM MỚI: Các biến trạng thái được chuyển vào đây ---
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Lấy instance của NearbyStationsBloc đã được cung cấp từ AppShell/MapPage
    // để đảm bảo chúng ta làm việc trên cùng một dữ liệu.
    final nearbyStationsBloc = context.read<NearbyStationsBloc>();

    return Scaffold(
      appBar: AppBar(
        // Loại bỏ nút back mặc định vì trang này là một tab chính
        automaticallyImplyLeading: false,
        title: _buildSmartSearchBar(),
        actions: [
          Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
               // 1. Lấy bộ lọc hiện tại từ state
              final currentFilter = context.read<NearbyStationsBloc>().state.filterParams;
              
              // 2. Mở trang FilterPage và chờ kết quả trả về
              final newFilter = await Navigator.push<FilterParams>(
                context,
                MaterialPageRoute(builder: (_) => FilterPage(currentFilter: currentFilter)),
              );

              // 3. Nếu người dùng nhấn "Apply", áp dụng bộ lọc mới
              if (newFilter != null && context.mounted) {
                context.read<NearbyStationsBloc>().add(FilterApplied(newFilter));
              }
              
            },
          ),),
        ],
      ),
      body: BlocBuilder<NearbyStationsBloc, NearbyStationsState>(
        builder: (context, state) {
          if (state.status == NearbyStationsStatus.loading && state.stations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == NearbyStationsStatus.failure) {
            return Center(child: Text('Lỗi: ${state.error}'));
          }
          if (state.stations.isEmpty) {
            return const Center(child: Text('Không tìm thấy trạm sạc nào.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              final position = state.currentUserPosition;
              if (position != null) {
                nearbyStationsBloc.add(FetchNearbyStations(LatLng(position.latitude, position.longitude)));
              }
            },
            child: ListView.builder(
              itemCount: state.stations.length,
              itemBuilder: (context, index) {
                final station = state.stations[index];
                // --- THAY ĐỔI: Sử dụng widget mới ---
                return StationListItem(
                  station: station,
                  currentUserPosition: state.currentUserPosition,
                );},
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmartSearchBar() {
    final geocodingRepo = context.read<IGeocodingRepository>();
    final nearbyStationsBloc = context.read<NearbyStationsBloc>();

    return TypeAheadField<AutocompletePrediction>(
      controller: _searchController,
      suggestionsCallback: (query) {
        return geocodingRepo.getAutocompleteSuggestions(query);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.description),
        );
      },
      onSelected: (suggestion) async {
        _searchController.text = suggestion.description;
        // Lấy tọa độ từ placeId
        final latLng = await geocodingRepo.getLatLngFromPlaceId(suggestion.placeId);
        if (latLng != null && mounted) {
          // Bắn event mới để tìm trạm xung quanh điểm đã chọn
          nearbyStationsBloc.add(FetchStationsAroundPoint(latLng));
        }
      },
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm theo địa điểm...',
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        );
      },
    );
  }

  // Widget này có thể được tách ra file riêng để tái sử dụng
}