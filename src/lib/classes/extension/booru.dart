import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_js/extensions/fetch.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:ibuki/classes/extension/booru_post.dart';
import 'package:ibuki/classes/extension/extension.dart';
import 'package:ibuki/classes/extension/types.dart';

class Booru extends Extension {
    final JavascriptRuntime _runtime = getJavascriptRuntime();

    static const _internalJsCode = """const UserAgent="Aster/1.0.0 Ibuki/1.0.0";function url(t){let e="";if(t.base&&(e+=t.base,t.base.endsWith("/")||(e+="/")),t.path&&(t.path.startsWith("/")?e+=t.path.substring(1):e+=t.path,t.path.endsWith("/")&&(e=e.substring(0,e.length-1))),t.query){for(let s of(e+="?",t.query)){let n=Object.entries(s)[0];""!==n[1]&&(e+=n[0]+"="+n[1]+"&")}e=e.substring(0,e.length-1)}return e}""";

    Booru(String script) {
        // Add url() function
        _runtime.evaluate(_internalJsCode);

        // eval script
        _runtime.evaluate(script);
        JsEvalResult extension = _runtime.evaluate("JSON.stringify(Extension)");
        init(extension);
    }

    JsEvalResult runtimeEval(String code) => _runtime.evaluate(code);
    Future<JsEvalResult> runtimeEvalAsync(String code) async {       
        await _runtime.enableFetch();
        _runtime.enableHandlePromises(); 

        var asyncResult = await _runtime.evaluateAsync(code);
        _runtime.executePendingJob();
        
        final promiseResolved = await _runtime.handlePromise(asyncResult);

        // if (promiseResolved.rawResult is List) {
        //     return promiseResolved.rawResult;
        // } else {
        //     return promiseResolved.stringResult;
        // }

        return promiseResolved;
        //return await _runtime.evaluateAsync(code);
    }

    // String getJsFunc(String name, {int page = 1, int limit = 20, String search = "", String auth = ""}) {
    //     String result = "$name({";
    //     if (page != 1) result += "page: $page,";
    //     if (limit != 20) result += "limit: $limit,";
    //     if (search.isNotEmpty) result += "search: \"$search\",";
    //     if (auth.isNotEmpty) result += "auth: \"$auth\",";
    //     if (result.endsWith(",")) {
    //         result = result.substring(0, result.length - 1);
    //     }
    //     result += "})";
    //     return result;
    // }

    String getJsFunc(String name, Map<String, Object?> params) {
        String result = "$name({";

        params.forEach((key, value) {
            if (value != null || value != "") {
                if (value is String) {
                    result += "$key: \"$value\", ";
                } else {
                    result += "$key: $value, ";
                }
            }
        });

        if (result.endsWith(", ")) {
            result = result.substring(0, result.length - 2);
        }

        result += "})";

        return result;
    }

    Future<List<BooruPost>> getPosts({int page = 1, int limit = 20, String search = "", String auth = ""}) async {
        String code = getJsFunc("GetPosts", {"page": page, "limit": limit, "search": search, "auth": auth});
        JsEvalResult posts = await runtimeEvalAsync(code);
        String json = posts.stringResult.replaceAll("\\\"", "\"");

        if (Platform.isMacOS || Platform.isIOS) {
            json = json.substring(0, json.length - 1).substring(1).replaceAll("\\\"", "\"");
        }

        List<dynamic> decoded = jsonDecode(json);
        return decoded.map((e) => BooruPost.map(e)).toList();
    }

    Future<List<BooruPost>> getUserFavorites({int page = 1, int limit = 20, String username = "", String auth = ""}) async {
        String code = getJsFunc("GetUserFavorites", {"page": page, "limit": limit, "username": username, "auth": auth});
        JsEvalResult posts = await runtimeEvalAsync(code);
        String json = posts.stringResult.replaceAll("\\\"", "\"");

        if (Platform.isMacOS || Platform.isIOS) {
            json = json.substring(0, json.length - 1).substring(1).replaceAll("\\\"", "\"");
        }

        List<dynamic> decoded = jsonDecode(json);
        return decoded.map((e) => BooruPost.map(e)).toList();
    }

    Future<List<BooruPost>?> getPostChildren({int id = 0, auth = ""}) async {
        String code = getJsFunc("GetPostChildren", {"id": id, "auth": auth});
        JsEvalResult posts = await runtimeEvalAsync(code);
        try {
            if (posts.stringResult == "null") return null;
            String json = posts.stringResult.replaceAll("\\\"", "\"");

            if (Platform.isMacOS || Platform.isIOS) {
                json = json.substring(0, json.length - 1).substring(1).replaceAll("\\\"", "\"");
            }

            List<dynamic> decoded = jsonDecode(json);
            return decoded.map((e) => BooruPost.map(e)).toList();
        } catch(_) {
            return null;
        }
    }

    Future<List<Tag>?> getTagSuggestion({String search = "", limit = 20}) async {
        String code = getJsFunc("GetTagSuggestion", {"search": search, "limit": limit});
        JsEvalResult tags = await runtimeEvalAsync(code);
        try {
            if (tags.stringResult == "null") return null;
            String json = tags.stringResult.replaceAll("\\\"", "\"");

            if (Platform.isMacOS || Platform.isIOS) {
                json = json.substring(0, json.length - 1).substring(1).replaceAll("\\\"", "\"");
            }

            List<dynamic> decoded = jsonDecode(json);
            return decoded.map((e) => Tag.fromMap(e)).toList();
        } catch(_) {
            return null;
        }
    }
}