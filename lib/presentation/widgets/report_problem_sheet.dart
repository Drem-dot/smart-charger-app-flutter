import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/station_entity.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/bloc/station_selection_bloc.dart'; // Import BLoC

class ReportProblemSheet extends StatefulWidget {
  final StationEntity station;
  const ReportProblemSheet({super.key, required this.station});

  @override
  State<ReportProblemSheet> createState() => _ReportProblemSheetState();
}

class _ReportProblemSheetState extends State<ReportProblemSheet> {
  late final List<String> _reportReasons;

  @override
  void initState() {
    super.initState();
    _reportReasons = [
      AppLocalizations.of(context)!.reportReasonStationNotWorking,
      AppLocalizations.of(context)!.reportReasonConnectorBroken,
      AppLocalizations.of(context)!.reportReasonInfoIncorrect,
      AppLocalizations.of(context)!.reportReasonLocationIncorrect,
      AppLocalizations.of(context)!.reportReasonPaymentIssue,
      AppLocalizations.of(context)!.reportReasonOther,
    ];
  }

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
            Text(AppLocalizations.of(context)!.reportSheetTitle, style: Theme.of(context).textTheme.headlineSmall),
            Text(
              widget.station.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              value: _selectedReason,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.reportSheetReasonLabel, border: const OutlineInputBorder()),
              items: _reportReasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (value) => setState(() => _selectedReason = value),
              validator: (v) => v == null ? AppLocalizations.of(context)!.reportSheetReasonValidator : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _detailsController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.reportSheetDetailsLabel, hintText: AppLocalizations.of(context)!.reportSheetDetailsHint, border: const OutlineInputBorder()),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.reportSheetPhoneLabel, border: const OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitReport,
                icon: const Icon(Icons.send),
                label: Text(AppLocalizations.of(context)!.reportSheetSubmitButton),
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