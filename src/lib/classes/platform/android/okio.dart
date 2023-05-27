import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Okio {
    static const MethodChannel _channel = MethodChannel('org.nightskystudio.ibuki/okio');

    static Future<bool> saveFile({
         required String tempFilePath,
         required String fileName,
         required int dirType,
         required String dirName,
         required String relativePath,
    }) async {
        final bool? result = await _channel.invokeMethod<bool>('saveFile', {
            "tempFilePath": tempFilePath,
            "fileName": fileName,
            "dirType": 0,
            "dirName": dirName,
            "appFolder": relativePath,
        });
        return result ?? false;
    }
}