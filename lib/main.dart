// lib/main.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smart_charger_app/config/constants.dart';
// Import Repositories và Services
import 'package:smart_charger_app/data/repositories/directions_repository_impl.dart';
import 'package:smart_charger_app/data/repositories/geocoding_repository_impl.dart';
import 'package:smart_charger_app/data/repositories/review_repository_impl.dart';
import 'package:smart_charger_app/data/repositories/settings_repository_impl.dart';
import 'package:smart_charger_app/data/repositories/station_repository_impl.dart';
import 'package:smart_charger_app/domain/repositories/i_directions_repository.dart';
import 'package:smart_charger_app/domain/repositories/i_geocoding_repository.dart';
import 'package:smart_charger_app/domain/repositories/i_review_repository.dart';
import 'package:smart_charger_app/domain/repositories/i_settings_repository.dart';
import 'package:smart_charger_app/domain/repositories/i_station_repository.dart';
import 'package:smart_charger_app/domain/services/anonymous_identity_service.dart';
import 'package:smart_charger_app/domain/services/feedback_service_impl.dart';
import 'package:smart_charger_app/domain/services/i_feedback_service.dart';
import 'package:smart_charger_app/l10n/app_localizations.dart';
import 'package:smart_charger_app/presentation/bloc/sheet_drag_state.dart';
import 'package:smart_charger_app/presentation/services/location_service.dart';

// Import BLoCs
import 'package:smart_charger_app/presentation/bloc/add_station_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/map_control_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/nearby_stations_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/point_selection_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/route_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/station_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/station_selection_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/stations_on_route_bloc.dart';

// Import "Bộ vỏ"
import 'package:smart_charger_app/presentation/screens/app_shell.dart';
import 'package:smart_charger_app/presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env"); // Nếu sếp dùng dotenv
    await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- TOÀN BỘ PROVIDER ĐƯỢC "NÂNG" LÊN ĐÂY ---
    return MultiRepositoryProvider(
      providers:  [
        // --- BƯỚC 1: Cung cấp các Service độc lập trước ---
        Provider<Dio>(
          create: (_) => Dio(BaseOptions(baseUrl: AppConfig.baseUrl)),
        ),
        Provider<IFeedbackService>(create: (_) => FeedbackServiceImpl()),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<AnonymousIdentityService>(create: (_) => AnonymousIdentityService()),
        
        // --- BƯỚC 2: Cung cấp các Repository ---
        RepositoryProvider<IStationRepository>(create: (context) => StationRepositoryImpl(context.read<Dio>())),
        RepositoryProvider<IGeocodingRepository>(create: (context) => GeocodingRepositoryImpl(context.read<Dio>())),
        RepositoryProvider<IDirectionsRepository>(create: (context) => DirectionsRepositoryImpl(dio: context.read<Dio>())),
        RepositoryProvider<ISettingsRepository>(create: (_) => SettingsRepositoryImpl()),
        
        // Repository này phụ thuộc vào một Service, nên đặt sau khi Service đã được cung cấp
        RepositoryProvider<IReviewRepository>(
          create: (context) => ReviewRepositoryImpl(
            context.read<Dio>(),
            context.read<AnonymousIdentityService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => MapControlBloc()),
          BlocProvider(create: (context) => PointSelectionBloc()),
          BlocProvider(create: (context) => AddStationBloc(context.read<IStationRepository>())),
          BlocProvider(
            create: (context) => NearbyStationsBloc(
              stationRepository: context.read<IStationRepository>(),
              settingsRepository: context.read<ISettingsRepository>(),
              locationService: context.read<LocationService>(),
            )..add(InitialStationsRequested()),
          ),
          BlocProvider(create: (context) => StationSelectionBloc(context.read<IFeedbackService>())),
          BlocProvider(create: (context) => RouteBloc(context.read<IDirectionsRepository>())),
          BlocProvider(
            create: (context) => StationBloc(
              stationRepository: context.read<IStationRepository>(),
              routeStream: context.read<RouteBloc>().stream,
            ),
          ),
          BlocProvider(
            create: (context) => StationsOnRouteBloc(
              directionsRepository: context.read<IDirectionsRepository>(),
              stationBloc: context.read<StationBloc>(),
              routeBloc: context.read<RouteBloc>(),
            ),
          ),
          ChangeNotifierProvider(create: (_) => SheetDragState()),
        ],
        child: MaterialApp(
          onGenerateTitle: (context) => "Sạc Thông Minh", // Sửa lại để đơn giản hơn
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('vi', ''),
            Locale('en', ''),
          ],
          home: const AppShell(),
        ),
      ),
    );
  }
}