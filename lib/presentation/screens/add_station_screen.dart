import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../domain/entities/geocoding_result_entity.dart';
import '../../domain/repositories/i_geocoding_repository.dart';
import '../bloc/add_station_bloc.dart';

class AddStationScreen extends StatefulWidget {
  const AddStationScreen({super.key});

  @override
  State<AddStationScreen> createState() => _AddStationScreenState();
}

class _AddStationScreenState extends State<AddStationScreen> {
  // --- Controllers & Keys ---
  final _formKey = GlobalKey<FormState>();
  final _mapControllerCompleter = Completer<GoogleMapController>();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _hoursController = TextEditingController();
  final _pricingController = TextEditingController();
  final _operatorController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final List<XFile> _selectedImages = []; 

  // --- State ---
  LatLng? _selectedPosition;
  Marker? _pinMarker;
  final Set<String> _selectedConnectorTypes = {};
  final Set<double> _selectedPowerKw = {};

  // --- Data ---
  // Dữ liệu này được lấy từ stationModel.js của bạn
  final List<String> _availableConnectors = [
    'CCS_COMBO_1', 'CCS_COMBO_2', 'CHADEMO', 'TYPE_1', 'TYPE_2', 'TESLA_PROPRIETARY', 'OTHER'
  ];
  final List<double> _availablePowers = [7.4, 11.0, 22.0, 50.0, 120.0, 180.0, 350.0];

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _hoursController.dispose();
    _pricingController.dispose();
    _operatorController.dispose();
    super.dispose();
  }

  /// Cập nhật vị trí của ghim và di chuyển camera
  void _updatePinLocation(LatLng position) async {
    setState(() {
      _selectedPosition = position;
      _pinMarker = Marker(
        markerId: const MarkerId('selected_pin'),
        position: position,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() => _selectedPosition = newPosition);
        },
      );
    });

    final controller = await _mapControllerCompleter.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }
  
  /// Gửi form sau khi validate
  void _submitForm() {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();
    
    if (_selectedPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng chọn một vị trí trên bản đồ.'))
        );
        return;
    }

    if (_formKey.currentState!.validate()) {
        final formData = {
            'name': _nameController.text,
            'address': _addressController.text,
            'power_kw': _selectedPowerKw.toList(),
            'connector_types': _selectedConnectorTypes.toList(),
            'operating_hours': _hoursController.text,
            'pricing_details': _pricingController.text,
            'network_operator': _operatorController.text,
            'owner_name': _ownerNameController.text,
            'owner_phone': _ownerPhoneController.text,
            // 'status' sẽ được backend tự đặt là 'pending_review'
        };
        _selectedImages.map((xfile) => File(xfile.path)).toList();
        context.read<AddStationBloc>().add(
        FormSubmitted(formData, _selectedPosition!, _selectedImages)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddStationBloc, AddStationState>(
      listener: (context, state) {
        if (state is AddStationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã thêm trạm "${state.newStation.name}" thành công!')),
          );
          Navigator.of(context).pop();
        }
        if (state is AddStationFailure) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${state.error}'), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Thêm Trạm Sạc Mới'),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Bản đồ Mini ---
                      _buildMiniMap(),
                      const SizedBox(height: 24),
                      
                      // --- Các trường thông tin ---
                      _buildAddressTypeAhead(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Tên trạm sạc *'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên' : null,
                      ),
                      const SizedBox(height: 24),
                      
                      _buildSectionTitle('Loại cổng sạc'),
                      _buildChipSelector<String>(_availableConnectors, _selectedConnectorTypes, (type) => type),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Công suất (kW)'),
                      _buildChipSelector<double>(_availablePowers, _selectedPowerKw, (power) => '$power kW'),
                      const SizedBox(height: 24),
                      
                      TextFormField(controller: _hoursController, decoration: const InputDecoration(labelText: 'Giờ hoạt động (ví dụ: 24/7)')),
                      const SizedBox(height: 16),
                      TextFormField(controller: _pricingController, decoration: const InputDecoration(labelText: 'Chi tiết giá')),
                      const SizedBox(height: 16),
                      TextFormField(controller: _operatorController, decoration: const InputDecoration(labelText: 'Nhà cung cấp mạng lưới')),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Thông tin cho Quản trị viên'),
TextFormField(
  controller: _ownerNameController,
  decoration: const InputDecoration(labelText: 'Tên chủ trạm *'),
  validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên chủ trạm' : null,
),
const SizedBox(height: 16),
TextFormField(
  controller: _ownerPhoneController,
  decoration: const InputDecoration(labelText: 'Số điện thoại chủ trạm *'),
  keyboardType: TextInputType.phone, // Bàn phím số
  validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
),
const SizedBox(height: 24),

// --- THÊM MỚI: UI UPLOAD ẢNH ---
_buildSectionTitle('Hình ảnh trạm sạc (tùy chọn)'),
_buildImagePicker(),
const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: state is AddStationInProgress ? null : _submitForm,
                        child: const Text('Gửi thông tin'),
                      ),
                    ],
                  ),
                ),
              ),
              // Lớp phủ loading
              if (state is AddStationInProgress)
                PointerInterceptor(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _buildMiniMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Vị trí trên bản đồ *'),
        const Text('Nhấn để đặt ghim hoặc kéo ghim để chọn vị trí chính xác.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(21.028511, 105.804817),
                zoom: 14,
              ),
              markers: _pinMarker != null ? {_pinMarker!} : {},
              onTap: _updatePinLocation,
              onMapCreated: _mapControllerCompleter.complete,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTypeAhead() {
    return TypeAheadField<GeocodingResult>(
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ *',
            hintText: 'Bắt đầu nhập để tìm kiếm...',
          ),
          validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập địa chỉ' : null,
        );
      },
      suggestionsCallback: (query) {
        if (query.isEmpty) return [];
        return context.read<IGeocodingRepository>().search(query);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.name),
          subtitle: Text(suggestion.address),
        );
      },
      onSelected: (suggestion) {
        // Cập nhật cả text và vị trí trên bản đồ
        _addressController.text = suggestion.address;
        _updatePinLocation(suggestion.latLng);
      },
      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Không tìm thấy địa điểm nào.'),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildChipSelector<T>(List<T> allItems, Set<T> selectedItems, String Function(T) labelBuilder) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: allItems.map((item) {
        final isSelected = selectedItems.contains(item);
        return FilterChip(
          label: Text(labelBuilder(item)),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                selectedItems.add(item);
              } else {
                selectedItems.remove(item);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Future<void> _pickImages() async {
  if (_selectedImages.length >= 4) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bạn chỉ có thể chọn tối đa 4 ảnh.'))
    );
    return;
  }
  final ImagePicker picker = ImagePicker();
  // Lấy nhiều ảnh cùng lúc
  final List<XFile> images = await picker.pickMultiImage(
    limit: 4 - _selectedImages.length, // Giới hạn số lượng có thể chọn thêm
  );

  if (images.isNotEmpty) {
    setState(() {
      _selectedImages.addAll(images);
    });
  }
}

// Widget UI để hiển thị ảnh đã chọn và nút thêm ảnh
Widget _buildImagePicker() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          ..._selectedImages.asMap().entries.map((entry) {
            int index = entry.key;
            XFile imageXFile = entry.value;
            return Stack(
              children: [
                _CrossPlatformImage(imageFile: imageXFile, size: 80),
                
                Positioned(
                  top: -8,
                  right: -8,
                  child: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedImages.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            );
          }),
          if (_selectedImages.length < 4)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Icon(Icons.add_a_photo, color: Colors.grey),
              ),
            ),
        ],
      ),
    ],
  );
}

}

class _CrossPlatformImage extends StatelessWidget {
  final XFile imageFile;
  final double size;

  const _CrossPlatformImage({required this.imageFile, required this.size});

  Future<Uint8List> _getImageBytes() {
    return imageFile.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: kIsWeb
          // --- XỬ LÝ CHO WEB ---
          ? FutureBuilder<Uint8List>(
              future: _getImageBytes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  );
                }
                // Hiển thị loading trong khi đọc bytes
                return Container(
                  width: size,
                  height: size,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            )
          // --- XỬ LÝ CHO MOBILE (ANDROID/IOS) ---
          : Image.file(
              File(imageFile.path),
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
    );
  }
}