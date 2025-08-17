import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:smart_charger_app/domain/repositories/i_settings_repository.dart';
import 'package:smart_charger_app/domain/repositories/i_station_repository.dart';

import '../../bloc/map_control_bloc.dart';
import '../../bloc/station_selection_bloc.dart';
import '../../bloc/nearby_stations_bloc.dart';
import 'station_list_sheet.dart'; // Tái sử dụng widget chung

class NearbyStationsLego extends StatelessWidget {
  final Position? currentUserPosition;
  const NearbyStationsLego({super.key, this.currentUserPosition});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NearbyStationsBloc(
        context.read<IStationRepository>(),
        context.read<ISettingsRepository>(),
      )..add(LoadInitialRadius()),
      child: _NearbyStationsView(currentUserPosition: currentUserPosition),
    );
  }
}

class _NearbyStationsView extends StatelessWidget {
  final Position? currentUserPosition;
  const _NearbyStationsView({this.currentUserPosition});

  void _showStationsList(BuildContext context) {
    // ... (logic showStationsList giữ nguyên)
    final position = currentUserPosition;
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy vị trí hiện tại.')),
      );
      return;
    }

    final latLng = LatLng(position.latitude, position.longitude);
    context.read<NearbyStationsBloc>().add(FetchNearbyStations(latLng));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: BlocProvider.of<NearbyStationsBloc>(context),
            ),
            BlocProvider.value(
              value: BlocProvider.of<MapControlBloc>(context),
            ),
            BlocProvider.value(
              value: BlocProvider.of<StationSelectionBloc>(context),
            ),
          ],
          child: BlocBuilder<NearbyStationsBloc, NearbyStationsState>(
            builder: (sheetContext, state) {
              return PointerInterceptor(
                child: StationListSheet(
                  title: 'Trạm sạc gần đây',
                  stations: state is NearbyStationsSuccess ? state.stations : [],
                  radius: state.radius,
                  isLoading: state is NearbyStationsLoading,
                  onRadiusChanged: (newRadius) {
                    sheetContext.read<NearbyStationsBloc>().add(RadiusChanged(newRadius));
                  },
                  onRadiusChangeEnd: (newRadius) {
                    sheetContext.read<NearbyStationsBloc>().add(RadiusChangeCompleted(latLng));
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI: Xóa bỏ Positioned, chỉ trả về nút bấm được bọc bởi PointerInterceptor
    return PointerInterceptor(
      child: FloatingActionButton(
        heroTag: 'nearby_stations_button',
        tooltip: 'Tìm trạm gần đây',
        onPressed: () => _showStationsList(context),
        child: const Icon(Icons.share_location),
      ),
    );
  }
}