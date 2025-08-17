import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../bloc/map_control_bloc.dart';
import '../../bloc/route_bloc.dart';

class RoutePolylineLego extends StatefulWidget {
  final void Function(Set<Polyline> polylines) onPolylinesUpdated;

  const RoutePolylineLego({super.key, required this.onPolylinesUpdated});

  @override
  State<RoutePolylineLego> createState() => _RoutePolylineLegoState();
}

class _RoutePolylineLegoState extends State<RoutePolylineLego> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<RouteBloc, RouteState>(
      listener: (context, state) {
        // SỬA LỖI: Chỉ thực hiện logic khi state là RouteSuccess.
        // Dấu `is` sẽ tự động "thăng hạng" kiểu của `state`, cho phép
        // chúng ta truy cập `state.route` một cách an toàn.
        if (state is RouteSuccess) {
          final polyline = Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blueAccent,
            width: 5,
            points: state.route!.polylinePoints, // An toàn để truy cập
            consumeTapEvents: true,
            onTap: () {
              debugPrint("Route tapped!");
            }
          );
          
          // Gọi callback để cập nhật UI của MapView
          widget.onPolylinesUpdated({polyline});

          // Ra lệnh cho camera di chuyển để vừa với lộ trình
          context.read<MapControlBloc>().add(CameraBoundsRequested(state.route!.bounds)); // An toàn để truy cập

        } else if (state is RouteInitial || state is RouteFailure) {
          // Xóa polyline nếu không có lộ trình hoặc có lỗi
          widget.onPolylinesUpdated({});
        }
      },
      child: const SizedBox.shrink(), // Không tự build UI
    );
  }
}