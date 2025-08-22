import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/station_selection_bloc.dart';
import 'station_details_sheet_content.dart';
import '../../widgets/report_problem_sheet.dart';

class StationDetailsLego extends StatefulWidget {
  const StationDetailsLego({super.key});
  @override
  State<StationDetailsLego> createState() => _StationDetailsLegoState();
}

class _StationDetailsLegoState extends State<StationDetailsLego> {
  bool _isAnySheetOpen = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<StationSelectionBloc, StationSelectionState>(
      listener: (context, state) {
        // Lấy tham chiếu đến các đối tượng cần thiết TRƯỚC async gap
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        if (_isAnySheetOpen) {
          if (navigator.canPop()) {
            navigator.pop();
          }
          _isAnySheetOpen = false;
        }

        Future.delayed(const Duration(milliseconds: 50), () {
          // Luôn kiểm tra `mounted` sau một async gap
          if (!mounted) return;

          // THAY ĐỔI: Các hàm bên dưới sẽ tự sử dụng context của State,
          // không cần truyền `context` từ listener vào nữa.
          if (state is StationSelectionSuccess) {
            _showDetailsSheet(state);
          } else if (state is StationReportInProgress) {
            _showReportSheet(state);
          } else if (state is StationReportSendSuccess) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Cảm ơn bạn đã gửi báo cáo!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      },
      child: const SizedBox.shrink(),
    );
  }

  // THAY ĐỔI: Hàm không còn nhận BuildContext làm tham số
  void _showDetailsSheet(StationSelectionSuccess state) {
    _isAnySheetOpen = true;
    // Sử dụng `context` của State object (an toàn)
    Scaffold.of(context).showBottomSheet(
      (sheetContext) => StationDetailsSheetContent(station: state.selectedStation),
      enableDrag: false,
      elevation: 8.0,
    ).closed.whenComplete(() {
      _isAnySheetOpen = false;
      if (mounted) {
        // Sử dụng `context` của State object (an toàn)
        final bloc = context.read<StationSelectionBloc>();
        if (bloc.state is StationSelectionSuccess &&
            (bloc.state as StationSelectionSuccess).selectedStation.id == state.selectedStation.id) {
          bloc.add(StationDeselected());
        }
      }
    });
  }

  // THAY ĐỔI: Hàm không còn nhận BuildContext làm tham số
  void _showReportSheet(StationReportInProgress state) {
    // Sử dụng `context` của State object để lấy BLoC (an toàn)
    final stationSelectionBloc = context.read<StationSelectionBloc>();

    showModalBottomSheet(
      // Sử dụng `context` của State object (an toàn)
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: stationSelectionBloc,
          child: Padding(
            // Sử dụng `context` của State object để lấy MediaQuery (an toàn)
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ReportProblemSheet(station: state.stationToReport),
          ),
        );
      },
    ).whenComplete(() {
        if (mounted) {
            // Sử dụng `context` của State object (an toàn)
            final bloc = context.read<StationSelectionBloc>();
            if (bloc.state is StationReportInProgress) {
                bloc.add(StationSelected(state.stationToReport));
            }
        }
    });
  }
}