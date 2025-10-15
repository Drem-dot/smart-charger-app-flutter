// lib/presentation/screens/place_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/domain/entities/geocoding_result_entity.dart';
import 'package:smart_charger_app/domain/repositories/i_geocoding_repository.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:smart_charger_app/domain/entities/autocomplete_prediction.dart';
import 'package:uuid/uuid.dart';

class PlacePickerScreen extends StatefulWidget {
  final LatLng initialPosition;
  const PlacePickerScreen({
    super.key,
    this.initialPosition = const LatLng(21.028511, 105.804817),
  });
  @override
  State<PlacePickerScreen> createState() => _PlacePickerScreenState();
}

class _PlacePickerScreenState extends State<PlacePickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _centerPosition;
  String _currentAddress = "Đang tải...";
  bool _isLoadingAddress = false;
  // Cho thanh tìm kiếm
  final TextEditingController _searchController = TextEditingController();
  String? _sessionToken;
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Lấy vị trí ban đầu
    _onCameraIdle();
  }

  void _onCameraIdle() async {
    if (_mapController == null) return;

    // Lấy tọa độ tâm bản đồ
    final bounds = await _mapController!.getVisibleRegion();
    final center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );

    setState(() {
      _centerPosition = center;
      _isLoadingAddress = true;
    });

    // Gọi API Reverse Geocoding
    final address = await context
        .read<IGeocodingRepository>()
        .getAddressFromLatLng(center);

    if (mounted) {
      setState(() {
        _currentAddress = address ?? "Không tìm thấy địa chỉ";
        _isLoadingAddress = false;
      });
    }
  }

  void _onPlaceSelected(AutocompletePrediction suggestion) async {
    final geocodingRepo = context.read<IGeocodingRepository>();
    final latLng = await geocodingRepo.getLatLngFromPlaceId(
      suggestion.placeId,
      sessionToken: _sessionToken!,
    );

    if (latLng != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
      _searchController.clear();
      FocusScope.of(context).unfocus();
    }
    // Kết thúc session
    setState(() {
      _sessionToken = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: 17,
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onCameraIdle: _onCameraIdle,
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 50.0), // Nâng ghim lên một chút
              child: Icon(Icons.location_pin, color: Colors.red, size: 50),
            ),
          ),

          // Thanh tìm kiếm và AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: _buildSearchBar(),
            ),
          ),

          // Nút Xác nhận và Hiển thị địa chỉ
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _isLoadingAddress
                                ? const LinearProgressIndicator()
                                : Text(
                                    _currentAddress,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (_centerPosition == null || _isLoadingAddress)
                            ? null
                            : () {
                                final result = GeocodingResult(
                                  name: _currentAddress.split(',')[0],
                                  address: _currentAddress,
                                  latLng: _centerPosition!,
                                );
                                Navigator.pop(context, result);
                              },
                        child: const Text("Xác nhận vị trí này"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TypeAheadField<AutocompletePrediction>(
      controller: _searchController,
      suggestionsCallback: (query) {
        _sessionToken ??= const Uuid().v4();
        return context.read<IGeocodingRepository>().getAutocompleteSuggestions(
          query,
          sessionToken: _sessionToken!,
        );
      },
      itemBuilder: (context, suggestion) =>
          ListTile(title: Text(suggestion.description)),
      onSelected: _onPlaceSelected,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: "Tìm kiếm...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        );
      },
    );
  }
}
