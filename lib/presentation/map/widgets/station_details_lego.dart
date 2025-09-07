import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_charger_app/presentation/bloc/sheet_drag_state.dart';
import 'package:smart_charger_app/presentation/bloc/station_selection_bloc.dart';
import 'package:smart_charger_app/presentation/map/widgets/station_details_sheet_content.dart';
import 'package:smart_charger_app/presentation/widgets/report_problem_sheet.dart';

class StationDetailsLego extends StatefulWidget {
  final Position? currentUserPosition;
  const StationDetailsLego({super.key,this.currentUserPosition});
  
  @override
  State<StationDetailsLego> createState() => _StationDetailsLegoState();
}

class _StationDetailsLegoState extends State<StationDetailsLego> {
  double? _collapsedSnapHeight;
  final GlobalKey _collapsedContentKey = GlobalKey();

  void _measureCollapsedHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _collapsedContentKey.currentContext;
      if (context != null && mounted) {
        final height = context.size?.height;
        if (height != null && height != _collapsedSnapHeight) {
          setState(() {
            _collapsedSnapHeight = height;
          });
        }
      }
    });
  }

  // --- HÀM _showReportSheet ĐƯỢC GIỮ LẠI ---
  void _showReportSheet(BuildContext context, StationReportInProgress state) {
  final stationSelectionBloc = context.read<StationSelectionBloc>(); // ✅ Lấy bloc tại thời điểm an toàn

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return BlocProvider.value(
        value: stationSelectionBloc,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ReportProblemSheet(station: state.stationToReport),
        ),
      );
    },
  ).whenComplete(() {
    // ✅ Dùng bloc đã lưu, không dùng context.read
    if (mounted) {
      if (stationSelectionBloc.state is StationReportInProgress) {
        stationSelectionBloc.add(StationSelected(state.stationToReport));
      }
    }
  });
}

  @override
  Widget build(BuildContext context) {
    // --- SỬ DỤNG BLOC CONSUMER ĐỂ XỬ LÝ CẢ UI VÀ HÀNH ĐỘNG ---
    return BlocConsumer<StationSelectionBloc, StationSelectionState>(
      // listener sẽ xử lý các hành động không build lại UI
      listener: (context, state) {
  if (state is StationReportInProgress) {
    if (mounted) {
      _showReportSheet(context, state);
    }
  }
  else if (state is StationReportSendSuccess) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cảm ơn bạn đã gửi báo cáo!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
},
      // builder sẽ xây dựng UI
      builder: (context, state) {
        // --- LOGIC HIỂN THỊ DRAGGABLE SHEET ---
        if (state is StationSelectionSuccess) {
          // Kịch bản 1: Chưa đo chiều cao -> Build widget ẩn để đo
          if (_collapsedSnapHeight == null) {
            _measureCollapsedHeight();
            return Offstage(
              child: StationDetailsSheetContent(
                station: state.selectedStation,
                scrollController: ScrollController(),
                collapsedContentKey: _collapsedContentKey,
                currentUserPosition: widget.currentUserPosition,
              ),
            );
          }

          // Kịch bản 2: Đã có chiều cao -> Build DraggableSheet thật
          final screenHeight = MediaQuery.of(context).size.height;
          final collapsedRatio = (_collapsedSnapHeight! + 40) / screenHeight;

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final dragState = context.read<SheetDragState>();
              if (notification is ScrollStartNotification) {
                dragState.startDragging();
              } else if (notification is ScrollEndNotification) {
                dragState.stopDragging();
              }
              return false;
            },
            child: DraggableScrollableSheet(
              initialChildSize: collapsedRatio > 0.8 ? 0.8 : collapsedRatio,
              minChildSize: collapsedRatio > 0.8 ? 0.8 : collapsedRatio,
              maxChildSize: 0.8,
              snap: true,
              snapSizes: [collapsedRatio > 0.8 ? 0.8 : collapsedRatio, 0.8],
              builder: (context, scrollController) {
                return StationDetailsSheetContent(
                  station: state.selectedStation,
                  scrollController: scrollController,
                  collapsedContentKey: GlobalKey(),
                  currentUserPosition: widget.currentUserPosition,
                );
              },
            ),
          );
        }
        
        // Khi không có trạm nào được chọn, reset chiều cao đã đo
        if (_collapsedSnapHeight != null) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
              if(mounted) setState(() => _collapsedSnapHeight = null);
           });
        }
        return const SizedBox.shrink();
      },
    );
  }
}