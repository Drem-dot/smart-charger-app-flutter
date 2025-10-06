import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_charger_app/l10n/app_localizations.dart';
import 'package:smart_charger_app/presentation/bloc/sheet_drag_state.dart';
import 'package:smart_charger_app/presentation/bloc/station_selection_bloc.dart';
import 'package:smart_charger_app/presentation/map/widgets/station_details_sheet_content.dart';
import 'package:smart_charger_app/presentation/widgets/report_problem_sheet.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class StationDetailsLego extends StatefulWidget {
  final Position? currentUserPosition;
  const StationDetailsLego({super.key,this.currentUserPosition});
  
  @override
  State<StationDetailsLego> createState() => _StationDetailsLegoState();
}

class _StationDetailsLegoState extends State<StationDetailsLego> {
  // Key này sẽ được giữ nguyên trong suốt vòng đời của State
  final GlobalKey _collapsedContentKey = GlobalKey();
  double? _collapsedSnapHeight;

  void _measureCollapsedHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _collapsedContentKey.currentContext;
      if (context != null && mounted) {
        final height = context.size?.height;
        // Chỉ setState nếu chiều cao thay đổi và lớn hơn 0
        if (height != null && height > 0 && height != _collapsedSnapHeight) {
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.reportSendSuccess),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
},
      // builder sẽ xây dựng UI
      builder: (context, state) {
        if (state is StationSelectionSuccess) {
          // Kịch bản 1: Chưa có chiều cao -> Build widget ẩn để đo
          if (_collapsedSnapHeight == null) {
            _measureCollapsedHeight();
            return Offstage(
              // Dùng lại key đã khai báo
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
          // Lấy chiều cao của vùng an toàn ở dưới (dành cho home bar của iPhone)
          final bottomSafeArea = MediaQuery.of(context).padding.bottom;

          // Tổng chiều cao cần hiển thị = Chiều cao nội dung + Padding + Chiều cao AppShell + Vùng an toàn
          final totalVisibleHeight = _collapsedSnapHeight! + 40 + kBottomNavigationBarHeight + bottomSafeArea;
          
          final collapsedRatio = totalVisibleHeight / screenHeight;
          // --- KẾT THÚC LOGIC MỚI ---
          
          final initialSize = collapsedRatio.clamp(0.1, 0.9); // Giữ nguyên dòng này

          // Giới hạn tỷ lệ để không quá lớn hoặc quá nhỏ
          collapsedRatio.clamp(0.1, 0.9);

          return NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              context.read<SheetDragState>();
              return false; // Trả về false để không can thiệp vào notification
            },
            child: NotificationListener<ScrollNotification>(
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
                initialChildSize: initialSize,
                minChildSize: initialSize,
                maxChildSize: 0.9, // Tăng max lên một chút để có nhiều không gian hơn
                snap: true,
                snapSizes: [initialSize, 0.9],
                builder: (context, scrollController) {
                  // --- GIẢI PHÁP VẤN ĐỀ 1: THÊM POINTERINTERCEPTOR Ở ĐÂY ---
                  return PointerInterceptor(
                    child: StationDetailsSheetContent(
                      station: state.selectedStation,
                      scrollController: scrollController,
                      // GIẢI PHÁP VẤN ĐỀ 2: SỬ DỤNG LẠI KEY ĐÃ KHAI BÁO
                      // Mặc dù không còn cần thiết để đo, nhưng truyền đúng key vẫn tốt hơn
                      collapsedContentKey: _collapsedContentKey,
                      currentUserPosition: widget.currentUserPosition,
                    ),
                  );
                },
              ),
            ),
          );
        }

        // Khi không có trạm nào được chọn, reset chiều cao đã đo
        if (_collapsedSnapHeight != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _collapsedSnapHeight = null);
          });
        }
        return const SizedBox.shrink();
      },
    );
  }
}