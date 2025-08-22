import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/station_entity.dart';
import '../../presentation/bloc/station_selection_bloc.dart'; // Import BLoC

class ReportProblemSheet extends StatefulWidget {
  final StationEntity station;
  const ReportProblemSheet({super.key, required this.station});

  @override
  State<ReportProblemSheet> createState() => _ReportProblemSheetState();
}

class _ReportProblemSheetState extends State<ReportProblemSheet> {
  final List<String> _reportReasons = [
    'Trạm không hoạt động/Mất điện',
    'Cổng sạc bị hỏng/Không nhận sạc',
    'Thông tin trên ứng dụng bị sai',
    'Vị trí trên bản đồ không chính xác',
    'Vấn đề về thanh toán',
    'Lý do khác (vui lòng mô tả chi tiết)',
  ];

  String? _selectedReason;
  final _phoneController = TextEditingController();
  final _detailsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // --- THAY ĐỔI QUAN TRỌNG ---
    // Chỉ cần bắn event với dữ liệu từ form
    context.read<StationSelectionBloc>().add(
      StationReportSubmitted(
        reason: _selectedReason!,
        details: _detailsController.text,
        phoneNumber: _phoneController.text,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Báo cáo vấn đề', style: Theme.of(context).textTheme.headlineSmall),
            Text(
              widget.station.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              value: _selectedReason,
              decoration: const InputDecoration(labelText: 'Lý do báo cáo*', border: OutlineInputBorder()),
              items: _reportReasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (value) => setState(() => _selectedReason = value),
              validator: (v) => v == null ? 'Vui lòng chọn một lý do' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _detailsController,
              decoration: const InputDecoration(labelText: 'Chi tiết vấn đề (tùy chọn)', hintText: 'Mô tả thêm...', border: OutlineInputBorder()),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại (tùy chọn)', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitReport,
                icon: const Icon(Icons.send),
                label: const Text('Gửi báo cáo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}