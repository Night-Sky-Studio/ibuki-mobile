import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

Future<String> loadAsset(BuildContext? context, String asset) async {
    try {
        if (context == null) {
            return await rootBundle.loadString(asset);
        } else {
            return await DefaultAssetBundle.of(context).loadString(asset);
        }
    } catch(e) {
        debugPrint(e.toString());
        return "";
    }
}