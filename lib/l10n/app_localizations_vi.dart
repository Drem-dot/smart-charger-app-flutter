// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Sạc Thông Minh';

  @override
  String get navMap => 'Bản đồ';

  @override
  String get navStationList => 'Danh sách';

  @override
  String get navAddStation => 'Thêm';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get searchPlaceholder => 'Tìm trạm sạc theo địa chỉ...';

  @override
  String get directionsTooltip => 'Tìm đường';

  @override
  String get directionsTitle => 'Tìm đường và trạm sạc trên đường';

  @override
  String get directionsButton => 'Dẫn đường';

  @override
  String get cannotOpenMaps => 'Không thể mở ứng dụng Google Maps.';

  @override
  String stationCardDistance(String distance) {
    return '$distance km';
  }

  @override
  String get sheetStationName => 'Tên trạm';

  @override
  String get sheetAddress => 'Địa chỉ';

  @override
  String get sheetStatusLabel => 'Trạng thái';

  @override
  String get sheetConnectorsLabel => 'Cổng sạc';

  @override
  String get sheetOperatingHoursLabel => 'Giờ hoạt động';

  @override
  String get sheetParkingDetailsLabel => 'Chi tiết đỗ xe';

  @override
  String get sheetReportProblemTooltip => 'Báo cáo vấn đề';

  @override
  String get sheetConnectorDetailsTitle => 'Chi tiết cổng sạc:';

  @override
  String get sheetConnectorTotalTitle => 'Số lượng cổng sạc:';

  @override
  String sheetConnectorInfo(String count) {
    return '$count cổng';
  }

  @override
  String sheetConnectorPowerInfo(String count, String power) {
    return '$count cổng ${power}kW';
  }

  @override
  String get noInfo => 'Chưa có thông tin';

  @override
  String get addStationScreenTitle => 'Thêm Trạm Sạc Mới';

  @override
  String get addStationMapLocation => 'Vị trí trên bản đồ *';

  @override
  String get addStationMapHint =>
      'Nhấn để đặt ghim hoặc kéo ghim để chọn vị trí chính xác.';

  @override
  String get addStationNameLabel => 'Tên trạm sạc *';

  @override
  String get addStationNameValidator => 'Vui lòng nhập tên';

  @override
  String get addStationAddressLabel => 'Địa chỉ *';

  @override
  String get addStationAddressHint => 'Bắt đầu nhập để tìm kiếm...';

  @override
  String get addStationAddressValidator => 'Vui lòng nhập địa chỉ';

  @override
  String get addStationNoAddressFound => 'Không tìm thấy địa điểm nào.';

  @override
  String get addStationConnectorType => 'Loại cổng sạc';

  @override
  String get addStationPower => 'Công suất (kW)';

  @override
  String get addStationOperatingHoursHint => 'Giờ hoạt động (ví dụ: 24/7)';

  @override
  String get addStationPricingDetailsHint => 'Chi tiết giá';

  @override
  String get addStationNetworkOperatorHint => 'Nhà cung cấp mạng lưới';

  @override
  String get addStationAdminInfo => 'Thông tin cho Quản trị viên';

  @override
  String get addStationOwnerNameLabel => 'Tên chủ trạm *';

  @override
  String get addStationOwnerNameValidator => 'Vui lòng nhập tên chủ trạm';

  @override
  String get addStationOwnerPhoneLabel => 'Số điện thoại chủ trạm *';

  @override
  String get addStationOwnerPhoneValidator => 'Vui lòng nhập số điện thoại';

  @override
  String get addStationImages => 'Hình ảnh trạm sạc (tùy chọn)';

  @override
  String get addStationTypeTitle => 'Loại trạm *';

  @override
  String get stationTypeCar => 'Ô tô';

  @override
  String get stationTypeBike => 'Xe máy';

  @override
  String get addStationSubmitButton => 'Gửi thông tin';

  @override
  String addStationSuccessMessage(String stationName) {
    return '\"$stationName\" đã được thêm và đang chờ duyệt.';
  }

  @override
  String get addStationMapPinValidator =>
      'Vui lòng chọn một vị trí trên bản đồ.';

  @override
  String get addStationMaxImages => 'Bạn chỉ có thể chọn tối đa 4 ảnh.';

  @override
  String get stationListPageTitle => 'Danh sách trạm sạc';

  @override
  String get stationListPageSearchHint => 'Tìm kiếm theo địa điểm...';

  @override
  String stationListError(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get stationListEmpty => 'Không tìm thấy trạm sạc nào.';

  @override
  String get settingsPageTitle => 'Cài đặt & Thông tin';

  @override
  String get settingsPartnership => 'Giới thiệu hợp tác';

  @override
  String get settingsUserGuide => 'Hướng dẫn sử dụng';

  @override
  String get settingsOwnerGuide => 'Hướng dẫn chủ trạm sạc';

  @override
  String get settingsShareApp => 'Chia sẻ ứng dụng';

  @override
  String get settingsShareAppMessage =>
      'Đây là app tìm kiếm trạm sạc toàn quốc, dữ liệu đầy đủ.  Truy cập link https://sacthongminh.com để tra cứu trạm hoặc cài app Sạc Thông Minh';

  @override
  String get ownerGuideTitle => 'Đưa Trạm Sạc Của Bạn Lên Bản Đồ';

  @override
  String get ownerGuideIntro =>
      'Cảm ơn bạn đã quan tâm đến việc đóng góp cho mạng lưới Sạc Thông Minh. Việc đưa trạm sạc của bạn lên hệ thống của chúng tôi hoàn toàn miễn phí và chỉ mất vài phút.';

  @override
  String get ownerGuideStep1Title => 'Bước 1: Chuẩn bị thông tin';

  @override
  String get ownerGuideStep1Content =>
      'Để quá trình thêm trạm diễn ra thuận lợi, vui lòng chuẩn bị sẵn các thông tin sau:\n• Tên chính xác của trạm sạc.\n• Địa chỉ chi tiết.\n• Vị trí chính xác trên bản đồ (bạn sẽ chọn bằng cách thả ghim).\n• Số lượng và loại cổng sạc (ví dụ: CCS2, Type 2...).\n• Công suất của từng loại cổng (ví dụ: 60kW, 120kW...).\n• Giờ hoạt động (ví dụ: 24/7, 8h - 22h).\n• Chi tiết giá hoặc phí đỗ xe (nếu có).';

  @override
  String get ownerGuideStep2Title => 'Bước 2: Sử dụng tính năng \"Thêm trạm\"';

  @override
  String get ownerGuideStep2Content =>
      '• Từ màn hình bản đồ chính, nhấn vào nút \"Thêm trạm\" (biểu tượng dấu cộng).\n• Một bản đồ nhỏ sẽ hiện ra, hãy di chuyển và nhấn giữ để \"thả ghim\" vào đúng vị trí trạm của bạn, sau đó nhấn \"Xác nhận\".\n• Điền tất cả thông tin đã chuẩn bị ở Bước 1 vào biểu mẫu.\n• Kiểm tra lại mọi thứ và nhấn \"Gửi đi\".';

  @override
  String get ownerGuideStep3Title => 'Bước 3: Chờ duyệt';

  @override
  String get ownerGuideStep3Content =>
      '• Sau khi bạn gửi thông tin, đội ngũ của chúng tôi sẽ tiến hành xác minh.\n• Quá trình này có thể mất từ 1-3 ngày làm việc.\n• Khi được duyệt, trạm sạc của bạn sẽ chính thức xuất hiện trên bản đồ để hàng ngàn người dùng xe điện có thể thấy.\n\nCảm ơn sự đóng góp của bạn!';

  @override
  String get reportSheetTitle => 'Báo cáo vấn đề';

  @override
  String get reportSheetReasonLabel => 'Lý do báo cáo*';

  @override
  String get reportSheetReasonValidator => 'Vui lòng chọn một lý do';

  @override
  String get reportSheetDetailsLabel => 'Chi tiết vấn đề (tùy chọn)';

  @override
  String get reportSheetDetailsHint => 'Mô tả thêm...';

  @override
  String get reportSheetPhoneLabel => 'Số điện thoại (tùy chọn)';

  @override
  String get reportSheetSubmitButton => 'Gửi báo cáo';

  @override
  String get reportReasonStationNotWorking => 'Trạm không hoạt động/Mất điện';

  @override
  String get reportReasonConnectorBroken => 'Cổng sạc bị hỏng/Không nhận sạc';

  @override
  String get reportReasonInfoIncorrect => 'Thông tin trên ứng dụng bị sai';

  @override
  String get reportReasonLocationIncorrect =>
      'Vị trí trên bản đồ không chính xác';

  @override
  String get reportReasonPaymentIssue => 'Vấn đề về thanh toán';

  @override
  String get reportReasonOther => 'Lý do khác (vui lòng mô tả chi tiết)';

  @override
  String get reviewsTitle => 'Đánh giá & Bình luận';

  @override
  String get reviewsImagesTitle => 'Hình ảnh';

  @override
  String get reviewsYourReviewTitle => 'Đánh giá của bạn:';

  @override
  String get reviewsNewCommentHint => 'Viết bình luận của bạn...';

  @override
  String get reviewsEditCommentHint => 'Sửa bình luận của bạn...';

  @override
  String get reviewsSubmitButton => 'Gửi đánh giá';

  @override
  String get reviewsUpdateButton => 'Cập nhật';

  @override
  String get reviewsDeleteButton => 'Xóa';

  @override
  String get reviewsDeleteDialogTitle => 'Xóa đánh giá?';

  @override
  String get reviewsDeleteDialogContent =>
      'Bạn có chắc chắn muốn xóa đánh giá này không?';

  @override
  String get reviewsDialogCancel => 'Hủy';

  @override
  String get reviewsDialogDelete => 'Xóa';

  @override
  String get reviewsRatingValidator => 'Vui lòng chọn số sao.';

  @override
  String get reviewsNoOtherReviews => 'Chưa có đánh giá nào khác.';

  @override
  String reviewsLoadError(String error) {
    return 'Lỗi tải đánh giá: $error';
  }

  @override
  String get unknownError => 'Đã xảy ra lỗi không xác định';

  @override
  String get yourLocation => 'Vị trí của bạn';

  @override
  String get chooseOnMap => 'Chọn trên bản đồ';

  @override
  String get chooseStartPoint => 'Chọn điểm bắt đầu';

  @override
  String get chooseDestination => 'Chọn điểm kết thúc';

  @override
  String get swapTooltip => 'Đảo ngược';

  @override
  String get reportSendSuccess => 'Cảm ơn bạn đã gửi báo cáo!';

  @override
  String get userGuideWelcome => 'Chào mừng bạn đến với Sạc Thông Minh!';

  @override
  String get userGuideIntro =>
      'Ứng dụng giúp bạn dễ dàng tìm kiếm và di chuyển đến các trạm sạc xe điện trên toàn quốc. Dưới đây là hướng dẫn các tính năng chính:';

  @override
  String get userGuideSection1Title => '1. Tìm kiếm và Khám phá';

  @override
  String get userGuideSection1Content =>
      '• Sử dụng thanh tìm kiếm ở trên cùng để nhanh chóng di chuyển bản đồ đến một địa chỉ hoặc thành phố cụ thể.\n• Lướt và zoom bản đồ để khám phá các trạm sạc xung quanh bạn. Các trạm sẽ tự động được tải và hiển thị.';

  @override
  String get userGuideSection2Title => '2. Tìm đường và Xem chi tiết';

  @override
  String get userGuideSection2Content =>
      '• Nhấn vào nút \"Đường đi\" (biểu tượng mũi tên) cạnh thanh tìm kiếm để mở giao diện tìm lộ trình.\n• Chọn điểm bắt đầu và kết thúc bằng cách: dùng vị trí hiện tại, chọn trên bản đồ, hoặc tìm kiếm địa chỉ.\n• Sau khi lộ trình được vẽ, nhấn nút \"Tìm trạm trên đường\" để lọc và chỉ hiển thị các trạm sạc dọc theo tuyến đi của bạn.';

  @override
  String get userGuideSection3Title => '3. Xem Thông tin Trạm sạc';

  @override
  String get userGuideSection3Content =>
      '• Nhấn vào một biểu tượng trạm sạc trên bản đồ để mở bảng thông tin chi tiết.\n• Bảng thông tin sẽ hiển thị đầy đủ: địa chỉ, số lượng cổng sạc, công suất, giờ hoạt động, và chi tiết về giá.';

  @override
  String get userGuideSection4Title => '4. Dẫn đường đến Trạm';

  @override
  String get userGuideSection4Content =>
      '• Trong bảng thông tin chi tiết, nhấn nút \"Dẫn đường\". Ứng dụng sẽ tự động mở Google Maps để bắt đầu chỉ đường cho bạn.';

  @override
  String get userGuideSection5Title => '5. Báo cáo Vấn đề';

  @override
  String get userGuideSection5Content =>
      '• Nếu thông tin trạm sạc không chính xác hoặc gặp vấn đề khi sạc, hãy nhấn vào \"Báo cáo vấn đề\" trong bảng thông tin chi tiết để giúp chúng tôi cải thiện dữ liệu.';
}
