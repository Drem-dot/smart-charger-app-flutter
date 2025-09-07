import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:smart_charger_app/presentation/bloc/map_control_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/navigation_cubit.dart';
import 'package:smart_charger_app/presentation/bloc/nearby_stations_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/station_selection_bloc.dart';
import 'package:smart_charger_app/presentation/widgets/station_carousel_card.dart';
import 'package:smart_charger_app/presentation/widgets/stroked_text.dart';

class NearbyStationsCarouselLego extends StatelessWidget {
  final Position? currentUserPosition;
  const NearbyStationsCarouselLego({super.key, this.currentUserPosition});

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: BlocBuilder<NearbyStationsBloc, NearbyStationsState>(
        buildWhen: (prev, curr) => prev.status != curr.status || prev.stations != curr.stations,
        builder: (context, state) {
          if (state.status == NearbyStationsStatus.loading) {
            return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
          }

          if (state.status == NearbyStationsStatus.success && state.stations.isNotEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều dọc
                    children: [
                      StrokedText(
                        text: 'Gần bạn',
                        style: Theme.of(context).textTheme.titleLarge!,
                        strokeWidth: 3,
                      ),
                      // --- THAY ĐỔI: Sử dụng GestureDetector và StrokedText ---
                      GestureDetector(
                        onTap: () {context.read<NavigationCubit>().changeTab(BottomNavItem.list.index);},
                        child: StrokedText(
                          text: 'Xem tất cả',
                          // Lấy style từ theme của TextButton để trông giống nút bấm
                          style: Theme.of(context).textButtonTheme.style?.textStyle?.resolve({}) ?? 
                                 TextStyle(
                                   color: Theme.of(context).primaryColor, 
                                   fontWeight: FontWeight.bold
                                 ),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                CarouselSlider.builder(
                  itemCount: state.stations.length,
                  itemBuilder: (context, itemIndex, pageViewIndex) {
                    final station = state.stations[itemIndex];
                    return StationCarouselCard(
                      station: station,
                      currentUserPosition: currentUserPosition,
                      onTap: () {
                        context.read<MapControlBloc>().add(CameraMoveRequested(station.position, 16.0));
                        context.read<StationSelectionBloc>().add(StationSelected(station));
                      },
                    );
                  },
                  options: CarouselOptions(
                    height: 180.0,
                    enlargeCenterPage: true,
                    viewportFraction: 0.85,
                    initialPage: 0,
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}