import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/station_entity.dart';
import '../../domain/services/i_feedback_service.dart'; // <-- BẮT BUỘC

part 'station_selection_event.dart';
part 'station_selection_state.dart';

class StationSelectionBloc extends Bloc<StationSelectionEvent, StationSelectionState> {
  // THÊM MỚI: BLoC cần FeedbackService để gửi email
  final IFeedbackService _feedbackService;

  StationSelectionBloc(this._feedbackService) : super(NoStationSelected()) {
    on<StationSelected>((event, emit) {
      emit(StationSelectionSuccess(event.station));
    });
    
    on<StationDeselected>((event, emit) {
      emit(NoStationSelected());
    });

    // THÊM MỚI: Xử lý khi bắt đầu báo cáo
    on<StationReportInitiated>((event, emit) {
      // Chỉ có thể bắt đầu báo cáo khi đang ở trang chi tiết
      if (state is StationSelectionSuccess) {
        final currentStation = (state as StationSelectionSuccess).selectedStation;
        emit(StationReportInProgress(currentStation));
      }
    });

    // THÊM MỚI: Xử lý khi gửi báo cáo
    on<StationReportSubmitted>((event, emit) async {
      // Chỉ có thể gửi khi đang ở trang báo cáo
      if (state is StationReportInProgress) {
        final station = (state as StationReportInProgress).stationToReport;
        
        try {
          // Gọi service để gửi email (hoặc API)
          await _feedbackService.sendReportEmail(
            station: station, 
            reason: event.reason, 
            // Sửa lại để truyền cả details, nếu sếp dùng API
            phoneNumber: event.phoneNumber
          );
          
          // Gửi thành công, phát ra 2 state liên tiếp
          emit(StationReportSendSuccess());
          emit(NoStationSelected()); // Đóng tất cả và reset

        } catch (e) {
          // Nếu lỗi, có thể phát ra state lỗi hoặc giữ nguyên state để người dùng thử lại
          // Ở đây ta quay lại form báo cáo
          emit(StationReportInProgress(station));
        }
      }
    });
  }
}