import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import tất cả các dependencies cần thiết
import '../../data/repositories/directions_repository_impl.dart';
import '../../data/repositories/geocoding_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/station_repository_impl.dart';
import '../../domain/repositories/i_directions_repository.dart';
import '../../domain/repositories/i_geocoding_repository.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../../domain/repositories/i_station_repository.dart';
import '../bloc/add_station_bloc.dart'; // Import BLoC mới
import '../bloc/map_control_bloc.dart';
import '../bloc/nearby_stations_bloc.dart';
import '../bloc/point_selection_bloc.dart';
import '../bloc/route_bloc.dart';
import '../bloc/station_bloc.dart';
import '../bloc/station_selection_bloc.dart';
import '../map/map_view.dart';
import '../bloc/stations_on_route_bloc.dart' as stations_on_route;

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio(BaseOptions(baseUrl: 'http://116.118.61.227:3000'));

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IStationRepository>(
          create: (context) => StationRepositoryImpl(dio),
        ),
        RepositoryProvider<IGeocodingRepository>(
          create: (context) => GeocodingRepositoryImpl(),
        ),
        RepositoryProvider<IDirectionsRepository>(
          create: (context) => DirectionsRepositoryImpl(dio: dio),
        ),
        RepositoryProvider<ISettingsRepository>(
          create: (context) => SettingsRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => StationBloc(context.read<IStationRepository>())),
          BlocProvider(create: (context) => StationSelectionBloc()),
          BlocProvider(create: (context) => MapControlBloc()),
          BlocProvider(create: (context) => RouteBloc(context.read<IDirectionsRepository>())),
          BlocProvider(create: (context) => PointSelectionBloc()),
          BlocProvider(
            create: (context) => NearbyStationsBloc(
              context.read<IStationRepository>(),
              context.read<ISettingsRepository>(),
            ),
            
          ),
          BlocProvider(
            create: (context) => stations_on_route.StationsOnRouteBloc(
              context.read<IDirectionsRepository>(),
              context.read<ISettingsRepository>(),
            )..add(stations_on_route.LoadInitialRadius()), // Thêm tiền tố ở đây
          ),BlocProvider(
            create: (context) => AddStationBloc(context.read<IStationRepository>()),
          ),
        ],
        child: const MapView(),
      ),
    );
  }
}