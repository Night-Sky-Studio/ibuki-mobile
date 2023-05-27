import 'dart:math';

import 'package:flutter_js/flutter_js.dart';
import 'package:ibuki/classes/extension/types.dart';

class Extension extends ExtensionObject {
    int id = Random().nextInt(999999) + 100000;
    String? name, kind, apiType, baseUrl, tagsSeparator, icon;
    int? rateLimit;
    bool? networkAccess;

    @override
    Extension({
        this.name,
        this.kind,
        this.apiType,
        this.baseUrl,
        this.tagsSeparator,
        this.rateLimit,
        this.networkAccess,
        this.icon
    }); 

    @override
    factory Extension.fromEvalObject(JsEvalResult object) {
        if (object.rawResult is Map) {
            return Extension.fromMap(object.rawResult);
        } else {
            return Extension();
        }
    }

    @override
    factory Extension.fromMap(Map object) {
        return Extension(
            name: object["name"],
            kind: object["kind"],
            apiType: object["api_type"],
            baseUrl: object["base_url"],
            tagsSeparator: object["tags_separator"],
            rateLimit: object["rate_limit"],
            networkAccess: object["network_access"],
            icon: object["icon"]
        );
    }

    // @override
    // void init(JsEvalResult object) {
    //     if (object.rawResult is Map) {
    //         initFromMap(object.rawResult);
    //     } else {
    //         initFromJson(object.stringResult);
    //     }
    // }

    // @override
    // void initFromJson(String json) {
    //     initFromMap(jsonDecode(json));
    // }

    @override
    void initFromMap(Map map) {
        name = map["name"];
        kind = map["kind"];
        apiType = map["api_type"];
        baseUrl = map["base_url"];
        tagsSeparator = map["tags_separator"];
        rateLimit = map["rate_limit"];
        networkAccess = map["network_access"];
        icon = map["icon"];
    }

    bool isEmpty() {
        return name == null || kind == null || apiType == null || baseUrl == null || tagsSeparator == null || rateLimit == null || networkAccess == null;
    }

    @override
    String toString() {
        return "{name: $name, kind: $kind, apiType: $apiType, baseUrl: $baseUrl, tagsSeparator: $tagsSeparator, rateLimit: $rateLimit, networkAccess: $networkAccess}";
    }
}