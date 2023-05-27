import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ibuki/classes/extension/booru.dart';
import 'package:ibuki/classes/helpers.dart';
import 'package:path_provider/path_provider.dart';

class Account {
    int id = Random().nextInt(999999) + 100000;
    String username, password;
    bool isApiKey = false;
    Account({required this.username, required this.password, this.isApiKey = false});
}

class BooruEntry {
    int id = Random().nextInt(999999) + 100000;
    String path;
    BooruEntry({required this.path});
    @override String toString() => path;
}

/// Settings class
/// 
/// Settings should be loaded in the following sequence
/// - Check if settings file exists
/// - It does:
/// -- Load settings
/// - It doesn't:
/// -- Create settings file
/// -- Transfer pre-packaged boorus to settings directory
/// -- Init settings
/// -- Save settings to file
class Settings {
    final db = GetStorage();
    List<String> paths = []; 
    List<Account> accounts = [];

    List<Booru> boorus = [];

    int limit = 20;
    int activeBooruId = -1;

    Booru get activeBooru => boorus.firstWhere((element) => element.id == activeBooruId);

    Settings();

    /// Gets application support directory to store settings file
    Future<String> get _settingsDirectory async => (await getApplicationSupportDirectory()).path; 

    /// Extracts assets from the package to the settings directory
    _extractAssets(BuildContext? context) async {
        String safebooruScriptContent = await loadAsset(null, "assets/scripts/Safebooru.js");
        String danbooruScriptContent = await loadAsset(null, "assets/scripts/Danbooru.js");

        File safebooruScriptFile = File("${await _settingsDirectory}/Safebooru.js");
        File danbooruScriptFile = File("${await _settingsDirectory}/Danbooru.js");

        await danbooruScriptFile.writeAsString(danbooruScriptContent);
        await safebooruScriptFile.writeAsString(safebooruScriptContent);
    }

    _loadBoorus() async {
        for (var entry in paths) {
            File booruScript = File(entry);
            String booruScriptContent = await booruScript.readAsString();
            Booru booru = Booru(booruScriptContent);

            boorus.add(booru);
        }
    }

    /// Function is being called when settings file doesn't exist
    init(BuildContext? context) async {
        db.erase();
        accounts.clear();

        /// Extract assets
        await _extractAssets(context);
        /// Add Safebooru.js to paths
        paths.add("${await _settingsDirectory}/Danbooru.js");
        paths.add("${await _settingsDirectory}/Safebooru.js");

        // Load boorus
        await _loadBoorus();

        activeBooruId = boorus[1].id;
        limit = 20;

        /// Save settings
        await save();
    }

    load() async {
        if (db.hasData("paths")) {
            paths = json.decode(db.read("paths"));
        }
        if (db.hasData("accounts")) {
            accounts = json.decode(db.read("accounts"));
        }
        if (db.hasData("limit")) {
            limit = db.read("limit");
        }

        // Load boorus
        await _loadBoorus();
    }

    save() async {
        db.write("paths", json.encode(paths));
        db.write("accounts", json.encode(accounts));
        db.write("limit", limit);
    }
}