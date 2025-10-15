// lib/presentation/map/widgets/nearby_stations_carousel_lego.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';
import 'package:smart_charger_app/presentation/bloc/carousel_index_cubit.dart';
import 'package:smart_charger_app/presentation/bloc/map_control_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/navigation_cubit.dart';
import 'package:smart_charger_app/presentation/bloc/nearby_stations_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/route_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/station_selection_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/stations_on_route_bloc.dart';
import 'package:smart_charger_app/presentation/widgets/station_carousel_card.dart';
import 'package:smart_charger_app/presentation/widgets/stroked_text.dart';

// ĐỔI THÀNH STATEFULWIDGET ĐỂ QUẢN LÝ CAROUSEL CONTROLLER
class NearbyStationsCarouselLego extends StatefulWidget {
  final Position? currentUserPosition;
  const NearbyStationsCarouselLego({super.key, this.currentUserPosition});

  @override
  State<NearbyStationsCarouselLego> createState() => _NearbyStationsCarouselLegoState();
}

class _NearbyStationsCarouselLegoState extends State<NearbyStationsCarouselLego> {
  // Controller để điều khiển carousel
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: MultiBlocListener(
        listeners: [
          // Lắng nghe RouteBloc để reset index khi có lộ trình mới
          BlocListener<RouteBloc, RouteState>(
            listener: (context, state) {
              context.read<CarouselIndexCubit>().reset();
            },
          ),
          // Lắng nghe NearbyStationsBloc để reset index khi tìm kiếm vị trí mới
          BlocListener<NearbyStationsBloc, NearbyStationsState>(
            // Chỉ lắng nghe khi danh sách trạm thay đổi (không phải status)
            listenWhen: (prev, curr) => prev.stations != curr.stations,
            listener: (context, state) {
              context.read<CarouselIndexCubit>().reset();
            },
          ),
        ],
      // Lắng nghe RouteBloc để quyết định chế độ hiển thị
      child: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, routeState) {
          final bool isRouteMode = routeState is RouteSuccess;

          // Nếu đang ở chế độ tìm đường, lắng nghe StationsOnRouteBloc
          if (isRouteMode) {
            return BlocBuilder<StationsOnRouteBloc, StationsOnRouteState>(
              builder: (context, stationsOnRouteState) {
                if (stationsOnRouteState.status == StationsOnRouteStatus.success && stationsOnRouteState.stations.isNotEmpty) {
                  return _buildCarouselUI(
                    context,
                    title: 'Trạm dọc tuyến', // Yêu cầu 2
                    stations: stationsOnRouteState.stations,
                    isRouteMode: true, // Yêu cầu 3
                  );
                }
                // Hiển thị loading hoặc không hiển thị gì nếu không có trạm
                return const SizedBox.shrink(); 
              },
            );
          } 
          // Nếu không, lắng nghe NearbyStationsBloc như cũ
          else {
            return BlocBuilder<NearbyStationsBloc, NearbyStationsState>(
              buildWhen: (prev, curr) => prev.status != curr.status || prev.stations != curr.stations,
              builder: (context, nearbyState) {
                if (nearbyState.status == NearbyStationsStatus.loading && nearbyState.stations.isEmpty) {
                  return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
                }
                if (nearbyState.status == NearbyStationsStatus.success && nearbyState.stations.isNotEmpty) {
                  return _buildCarouselUI(
                    context,
                    title: 'Gần bạn',
                    stations: nearbyState.stations,
                    isRouteMode: false,
                    showViewAll: true, // Chỉ hiện nút "Xem tất cả" ở chế độ này
                  );
                }
                return const SizedBox.shrink();
              },
            );
          }
        },
      ),
      ),
    );

  }

  // TÁCH UI RA HÀM RIÊNG ĐỂ TÁI SỬ DỤNG
  Widget _buildCarouselUI(
    BuildContext context, {
    required String title,
    required List<StationEntity> stations,
    required bool isRouteMode,
    bool showViewAll = false,
  }) {
     final currentIndex = context.read<CarouselIndexCubit>().state;
    
    // An toàn: Đảm bảo currentIndex không vượt quá giới hạn
    final initialPage = (currentIndex < stations.length) ? currentIndex : 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StrokedText(
                text: title,
                style: Theme.of(context).textTheme.titleLarge!,
                strokeWidth: 3,
              ),
              if (showViewAll) // Chỉ hiển thị nếu được yêu cầu
                GestureDetector(
                  onTap: () {
                    context.read<NavigationCubit>().changeTab(BottomNavItem.list.index);
                  },
                  child: StrokedText(
                    text: 'Xem tất cả',
                    style: Theme.of(context).textButtonTheme.style?.textStyle?.resolve({}) ??
                           TextStyle(
                             color: Theme.of(context).primaryColor,
                             fontWeight: FontWeight.bold,
                           ),
                    strokeWidth: 3,
                  ),
                ),
            ],
          ),
        ),
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: stations.length,
          itemBuilder: (context, itemIndex, pageViewIndex) {
            final station = stations[itemIndex];
            return StationCarouselCard(
              station: station,
              currentUserPosition: widget.currentUserPosition,
              isRouteMode: isRouteMode, // Yêu cầu 3
              onTap: () {
                context.read<StationSelectionBloc>().add(StationSelected(station));
              },
            );
          },
          options: CarouselOptions(
            height: 180.0,
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            enableInfiniteScroll: false,
            initialPage: initialPage,
            // --- YÊU CẦU 4: ĐỒNG BỘ HÓA KHI VUỐT ---
            onPageChanged: (index, reason) {
              context.read<CarouselIndexCubit>().setIndex(index);
              // Chỉ di chuyển camera khi người dùng chủ động vuốt
              if (reason == CarouselPageChangedReason.manual) {
                final station = stations[index];
                context.read<MapControlBloc>().add(
                  CameraMoveRequested(station.position, 17), // Không zoom quá gần
                );
              }
            },
          ),
        ),
      ],
    );
  }
}