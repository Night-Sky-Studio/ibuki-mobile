import 'dart:convert';

import 'package:flutter/material.dart';
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

Widget processIcon(String? icon, {double? size}) {
    if (icon == null || icon == "") return const Icon(Icons.broken_image);
    if (icon.startsWith("http")) return Image(image: NetworkImage(icon), height: size);
    return Image.memory(const Base64Decoder().convert(icon), height: size);
}

class Version implements Comparable<Version> {
    int major = 0;
    int minor = 0;
    int patch = 0;
    int build = 0;

    Version({required this.major, required this.minor, required this.patch, required this.build});

    Version.fromString(String versionString) {
        // TODO: semantic version parsing
        // hint:    split("-")
        //          First half is "M.m.p.b"
        //          Second half is semantic string    
        List<String> v = versionString.split(".");
        if (v.isEmpty) throw const FormatException("Invalid version string");
        major = int.parse(v[0]);
        minor = v.length > 1 ? int.parse(v[1]) : 0;
        patch = v.length > 2 ? int.parse(v[2]) : 0;
        build = v.length > 3 ? int.parse(v[3]) : 0;
    }

    @override
    String toString() => "$major.$minor.$patch.$build";
    
    /// Allows 3 digits for each version part
    @override
    int get hashCode => major * 1000000000 + minor * 1000000 + patch * 1000 + build;

    @override
    bool operator ==(Object other) {
        assert(other is Version);
        return hashCode == other.hashCode;
    }

    bool operator >(Version other) => hashCode > other.hashCode;
    bool operator >=(Version other) => hashCode >= other.hashCode;
    bool operator <(Version other) => hashCode < other.hashCode;
    bool operator <=(Version other) => hashCode <= other.hashCode;

    @override
    int compareTo(Version other) {
        return Comparable.compare(hashCode, other.hashCode);
    }
}

extension ListExtensions<T> on List<T> {
    T? elementAtOrNull(int index) {
        if (index < 0 || index >= length) return null;
        return elementAt(index);
    }
}