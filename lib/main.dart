
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feature/form_builder/view/dynamic_form_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'GeoProof',
      title: 'Dynamic Form Demo',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const DynamicFormScreen(),
    );
  }
}
