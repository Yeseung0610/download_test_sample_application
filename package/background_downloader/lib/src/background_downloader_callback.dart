import 'dart:ui';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/cupertino.dart';

@pragma("vm:entry-point")
void callback(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (args.length == 2) {
    final callbackHandle = CallbackHandle.fromRawHandle(int.parse(args[1]));
    final onStart = PluginUtilities.getCallbackFromHandle(callbackHandle);
    if (onStart != null) {
      final task = Task.createFromJsonString(args[0]);
      onStart(task);
    }
  }
}