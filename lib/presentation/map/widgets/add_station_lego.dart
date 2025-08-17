import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:smart_charger_app/domain/repositories/i_station_repository.dart';
import 'package:smart_charger_app/presentation/screens/add_station_screen.dart';
import '../../bloc/add_station_bloc.dart';

class AddStationLego extends StatelessWidget {
  const AddStationLego({super.key});

  @override
  Widget build(BuildContext context) {
    // Lego này tự cung cấp BLoC chuyên dụng của nó
    return BlocProvider(
      create: (context) => AddStationBloc(context.read<IStationRepository>()),
      child: const _AddStationButton(),
    );
  }
}

class _AddStationButton extends StatelessWidget {
  const _AddStationButton();

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: FloatingActionButton(
        heroTag: 'add_station_button',
        tooltip: 'Thêm trạm sạc mới',
        onPressed: () {
          // Reset BLoC về trạng thái ban đầu trước khi mở màn hình mới
          context.read<AddStationBloc>().add(AddStationReset());
          
          Navigator.of(context).push(
            MaterialPageRoute(
              // Cung cấp instance BLoC hiện có cho màn hình mới
              builder: (_) => BlocProvider.value(
                value: BlocProvider.of<AddStationBloc>(context),
                child: const AddStationScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}