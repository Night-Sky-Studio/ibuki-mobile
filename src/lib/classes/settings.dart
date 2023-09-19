import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ibuki/classes/extension/booru.dart';
import 'package:ibuki/classes/extension/extension.dart';
import 'package:ibuki/classes/helpers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
    int activeBooruIdx = -1;

    Booru? get activeBooru => _setOrResetActiveBooru(); //_setOrResetActiveBooru();

    Booru? _setOrResetActiveBooru() {
        final result = boorus.elementAtOrNull(activeBooruIdx);
        if (result == null && boorus.isNotEmpty) {
            activeBooruIdx = 0;
            return boorus[0];
        }
        return result;
    }

    Settings();

    /// Gets application support directory to store settings file
    Future<String> get settingsDirectory async => (await getApplicationSupportDirectory()).path; 

    // late final String settingsDirectory;

    /// Extracts assets from the package to the settings directory
    Future<void> _extractAssets(BuildContext? context) async {
        String safebooruScriptContent = await loadAsset(null, "assets/scripts/Safebooru.js");
        String danbooruScriptContent = await loadAsset(null, "assets/scripts/Danbooru.js");

        File safebooruScriptFile = File("${await settingsDirectory}/Safebooru.js");
        File danbooruScriptFile = File("${await settingsDirectory}/Danbooru.js");

        await danbooruScriptFile.writeAsString(danbooruScriptContent);
        await safebooruScriptFile.writeAsString(safebooruScriptContent);
    }

    Future<void> _loadBoorus() async {
        List<String> missing = [];
        for (var entry in paths) {
            File booruScript = File(entry);
            if (!await booruScript.exists()) {
                missing.add(entry);
                continue;   
            }
            String booruScriptContent = await booruScript.readAsString();
            Booru booru = Booru(booruScriptContent);

            boorus.add(booru);
        }
        for (var entry in missing) {
            if (paths.indexOf(entry) == activeBooruIdx) activeBooruIdx = 0;
            paths.remove(entry);
        }
    }

    /// Function is being called when settings file doesn't exist
    Future<void> init(BuildContext? context) async {
        // settingsDirectory = await settingsDirectory;

        db.erase();
        accounts.clear();

        // Extract assets
        await _extractAssets(context);
        // Add Safebooru.js to paths
        paths.add("${await settingsDirectory}/Danbooru.js");
        paths.add("${await settingsDirectory}/Safebooru.js");

        // Load boorus
        await _loadBoorus();

        activeBooruIdx = 0;
        limit = 20;

        // Save settings
        await save();
    }

    Future<bool> tryLoad() async {
        // TODO: Rewrite as try-except call
        if (db.hasData("updated")) {
            await load();
            return true;
        } else {
            return false;
        }
    }

    load() async {
        // settingsDirectory = await settingsDirectory;
        if (db.hasData("paths")) {
            dynamic decoded = json.decode(db.read("paths"));
            paths = decoded is List ? List<String>.from(decoded) : [];
        }
        if (db.hasData("accounts")) {
            dynamic decoded = json.decode(db.read("accounts"));
            accounts = decoded is List<Account> ? decoded : [];
        }
        if (db.hasData("limit")) {
            dynamic decoded = db.read("limit");
            limit = decoded is int ? decoded : 20;
        }

        await _loadBoorus();

        if (db.hasData("activeBooruIdx")) {
            dynamic decoded = db.read("activeBooruIdx");
            activeBooruIdx = decoded is int ? decoded : 0;
        } else {
            activeBooruIdx = 0;
        }
    }

    Future<List<Extension>> getExtensionsFromRepo() async {
        final url = Uri.parse("https://raw.githubusercontent.com/Night-Sky-Studio/ibuki-extensions/release/extensions.min.json");
        final response = await http.get(url);
        if (response.statusCode == 200) {
            List<dynamic> decoded = json.decode(response.body);
            List<Extension> extensions = [];
            for (var extension in decoded) {
                extensions.add(Extension.fromMap(extension));
            }
            return extensions;
        } else {
            throw Exception("Failed to load extensions");
        }
    }

    Future<void> save() async {
        await db.write("updated", DateTime.now().toString());
        await db.write("paths", json.encode(paths));
        await db.write("accounts", json.encode(accounts));
        await db.write("limit", limit);
        await db.write("activeBooruIdx", activeBooruIdx);
        await db.save();
    }

    Future<void> removeBooru(int index) async {
        if (index == activeBooruIdx) activeBooruIdx = 0;
        boorus.removeAt(index);
        await File(paths[index]).delete();
        paths.removeAt(index);
        return save();
    }

    Future<void> installBooru(String path) async {
        paths.add(path);
        File booruScript = File(path);
        String booruScriptContent = await booruScript.readAsString();
        Booru booru = Booru(booruScriptContent);
        boorus.add(booru);
        return save();
    }
}