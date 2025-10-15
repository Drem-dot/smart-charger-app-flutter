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
import 'package:smart_charger_app/l10n/app_localizations.dart';
import 'package:smart_charger_app/presentation/widgets/station_list_item.dart';
import 'package:uuid/uuid.dart';

class StationListPage extends StatefulWidget  {
  const StationListPage({super.key});
  

  @override
  State<StationListPage> createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  // --- THÊM MỚI: Các biến trạng thái được chuyển vào đây ---
  final TextEditingController _searchController = TextEditingController();
  String? _sessionToken;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Hàm để bắt đầu một phiên mới
  void _startNewSession() {
    setState(() {
      _sessionToken = const Uuid().v4();
    });
  }

  // Hàm để kết thúc phiên
  void _endSession() {
    setState(() {
      _sessionToken = null;
    });
  }

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
            return Center(child: Text(AppLocalizations.of(context)!.stationListError(state.error ?? AppLocalizations.of(context)!.unknownError)));
          }
          if (state.stations.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.stationListEmpty));
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
        // Nếu chưa có session, tạo mới
        if (_sessionToken == null) {
          _startNewSession();
        }
        return geocodingRepo.getAutocompleteSuggestions(query, sessionToken: _sessionToken!);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.description),
        );
      },
      onSelected: (suggestion) async {
        _searchController.text = suggestion.description;
        
        // Dùng token hiện tại để lấy details
        final latLng = await geocodingRepo.getLatLngFromPlaceId(suggestion.placeId, sessionToken: _sessionToken!);
        
        if (latLng != null && mounted) {
          nearbyStationsBloc.add(FetchStationsAroundPoint(latLng));
        }
        
        // Kết thúc phiên sau khi đã chọn
        _endSession();
      },
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.stationListPageSearchHint,
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