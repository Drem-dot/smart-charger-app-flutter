import 'package:flutter/material.dart';
import 'package:smart_charger_app/presentation/screens/map_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:smart_charger_app/domain/repositories/i_geocoding_repository.dart';
import 'package:smart_charger_app/data/repositories/geocoding_repository_impl.dart';

Future<void> main() async {
  // Đảm bảo Flutter binding đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  // Tải các biến môi trường
  await dotenv.load(fileName: ".env");
  
  runApp(
    Provider<IGeocodingRepository>(
      create: (_) => GeocodingRepositoryImpl(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapPage(),
    );
  }
}
