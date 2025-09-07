// lib/presentation/screens/filter_page.dart
import 'package:flutter/material.dart';
import 'package:smart_charger_app/domain/entities/filter_params.dart';

class FilterPage extends StatefulWidget {
  final FilterParams currentFilter;
  const FilterPage({super.key, required this.currentFilter});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  // --- State cục bộ cho các lựa chọn ---
  late bool _availableNow;
  late Set<String> _selectedConnectors;
  late RangeValues _powerRange;
  late int _minRating;

  // Dữ liệu giả định
  final List<String> _allConnectors = ['CCS1', 'CCS2', 'Type 1', 'Type 2', 'J1772', 'Mennekes', 'GB/T', 'CHADeMo'];

  @override
  void initState() {
    super.initState();
    // Khởi tạo state từ bộ lọc được truyền vào
    _availableNow = widget.currentFilter.availableNow ?? false;
    _selectedConnectors = Set.from(widget.currentFilter.connectorTypes);
    _powerRange = widget.currentFilter.powerLevel;
    _minRating = widget.currentFilter.minRating;
  }
  
  void _clearFilter() {
    setState(() {
      _availableNow = false;
      _selectedConnectors.clear();
      _powerRange = const RangeValues(0, 350);
      _minRating = 0;
    });
  }

  void _applyFilter() {
    final newFilter = FilterParams(
      availableNow: _availableNow,
      connectorTypes: _selectedConnectors,
      powerLevel: _powerRange,
      minRating: _minRating,
    );
    // Trả về bộ lọc mới cho trang trước đó
    Navigator.pop(context, newFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bộ lọc')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ... (Các phần UI cho ToggleButtons, Checkbox, RangeSlider, Rating...)
          // Ví dụ cho Connector Type
          Text('Loại cổng sạc', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: _allConnectors.map((connector) {
              final isSelected = _selectedConnectors.contains(connector);
              return FilterChip(
                label: Text(connector),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedConnectors.add(connector);
                    } else {
                      _selectedConnectors.remove(connector);
                    }
                  });
                },
              );
            }).toList(),
          ),
          // ... (Các widget lọc khác)
        ],
      ),
      // --- Nút bấm ở dưới cùng ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clearFilter,
                child: const Text('Xóa bộ lọc'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: _applyFilter,
                child: const Text('Áp dụng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}