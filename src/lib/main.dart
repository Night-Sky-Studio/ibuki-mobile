import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ibuki/classes/settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:window_manager/window_manager.dart';
import 'application.dart';

void main() async {
    await GetStorage.init();
    Settings settings = Settings();
    // await settings.init(null);
    if (!(await settings.tryLoad())) await settings.init(null);

    if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt < 33) {
            Map<Permission, PermissionStatus> statuses = await [
                Permission.storage,
                //add more permission to request here.
            ].request();

            if (!statuses[Permission.storage]!.isGranted) {
                debugPrint("Permission denied.");
                exit(1);
            }
        }
    }

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        WidgetsFlutterBinding.ensureInitialized();

        // await Window.initialize();
        // await Window.setEffect(
        //     effect: WindowEffect.acrylic,
        //     color: const Color(0x22DDDDDD)
        // );

        await windowManager.ensureInitialized();

        WindowOptions options = const WindowOptions(
            size: Size(1280, 720),
            center: true,
        );
        windowManager.waitUntilReadyToShow(options, () async {
            await windowManager.show();
            await windowManager.focus();
        });
    }

    runApp(Application(settings: settings));
}