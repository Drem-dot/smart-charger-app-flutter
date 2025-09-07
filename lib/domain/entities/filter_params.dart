// lib/domain/entities/filter_params.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // Import để dùng RangeValues

class FilterParams extends Equatable {
  final bool? availableNow;
  final bool? accessible24h;
  final Set<String> connectorTypes;
  final RangeValues powerLevel;
  final int minRating;

  const FilterParams({
    this.availableNow,
    this.accessible24h,
    this.connectorTypes = const {},
    this.powerLevel = const RangeValues(0, 350), // Mặc định từ 0 đến 350 kW
    this.minRating = 0, // Mặc định là không lọc theo rating
  });
  
  // Constructor rỗng để tạo bộ lọc mặc định
  const FilterParams.empty()
      : availableNow = null,
        accessible24h = null,
        connectorTypes = const {},
        powerLevel = const RangeValues(0, 350),
        minRating = 0;

  FilterParams copyWith({
    bool? availableNow,
    bool? accessible24h,
    Set<String>? connectorTypes,
    RangeValues? powerLevel,
    int? minRating,
  }) {
    return FilterParams(
      availableNow: availableNow ?? this.availableNow,
      accessible24h: accessible24h ?? this.accessible24h,
      connectorTypes: connectorTypes ?? this.connectorTypes,
      powerLevel: powerLevel ?? this.powerLevel,
      minRating: minRating ?? this.minRating,
    );
  }

  @override
  List<Object?> get props => [
        availableNow,
        accessible24h,
        connectorTypes,
        powerLevel,
        minRating,
      ];
}