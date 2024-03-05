import 'package:flutter/material.dart';

import 'download_use_case.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final downloadUseCase = DownloadUseCase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: () => downloadUseCase.startDownload(), child: const Text('Start')),
      ),
    );
  }
}
