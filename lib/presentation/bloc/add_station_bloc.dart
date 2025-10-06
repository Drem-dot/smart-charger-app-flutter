
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/station_entity.dart';
import '../../domain/repositories/i_station_repository.dart';
import '../../domain/utils/chunk_calculator.dart';

part 'add_station_event.dart';
part 'add_station_state.dart';

class AddStationBloc extends Bloc<AddStationEvent, AddStationState> {
  final IStationRepository _stationRepository;

  AddStationBloc(this._stationRepository) : super(AddStationInitial()) {
    on<PositionSelected>((event, emit) {
      emit(AddStationPositionConfirmed(event.position));
    });

    on<FormSubmitted>(_onFormSubmitted);

    on<AddStationReset>((event, emit) {
      emit(AddStationInitial());
    });
  }

  Future<void> _onFormSubmitted(FormSubmitted event, Emitter<AddStationState> emit) async {
    emit(AddStationInProgress(event.position));
    try {
      final chunkId = ChunkCalculator.calculateChunkId(event.position);
      final fullStationData = {
        ...event.formData,
        'chunkId': chunkId,
        'location': {
          'type': 'Point',
          'coordinates': [event.position.longitude, event.position.latitude],
        }
      };
      // Sửa lại lời gọi repository
      final newStation = await _stationRepository.createStation(fullStationData, event.images);
      emit(AddStationSuccess(newStation));
    } catch (e) {
      emit(AddStationFailure(e.toString(), event.position));
    }
}}