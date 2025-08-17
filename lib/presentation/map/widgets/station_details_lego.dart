import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/station_selection_bloc.dart';
import 'station_details_sheet_content.dart';

class StationDetailsLego extends StatefulWidget {
  const StationDetailsLego({super.key});

  @override
  State<StationDetailsLego> createState() => _StationDetailsLegoState();
}

class _StationDetailsLegoState extends State<StationDetailsLego> {
  bool _isSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<StationSelectionBloc, StationSelectionState>(
      listener: (context, state) {
        // ================= SỬA LỖI AN TOÀN =================
        // BƯỚC 1: Lấy tham chiếu đến BLoC và Navigator trước khi có bất kỳ
        // khoảng trống bất đồng bộ nào.
        final bloc = context.read<StationSelectionBloc>();
        final navigator = Navigator.of(context);
        // ==================================================

        if (state is StationSelectionSuccess && !_isSheetOpen) {
          _isSheetOpen = true;
          Scaffold.of(context).showBottomSheet(
            (context) => StationDetailsSheetContent(station: state.selectedStation),
            enableDrag: false, 
          ).closed.whenComplete(() {
            _isSheetOpen = false;
            
            // BƯỚC 2: Kiểm tra mounted như cũ.
            if (!mounted) {
              return; 
            }

            // BƯỚC 3: Sử dụng các tham chiếu đã được lấy trước đó.
            // Biến `context` không còn được sử dụng ở đây nữa, làm cho linter hài lòng.
            if (bloc.state is StationSelectionSuccess) {
              bloc.add(StationDeselected());
            }
          });
        } else if (state is NoStationSelected && _isSheetOpen) {
          // Sử dụng tham chiếu navigator đã được lấy.
          navigator.pop();
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}