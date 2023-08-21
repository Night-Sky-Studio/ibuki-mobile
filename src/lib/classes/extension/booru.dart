import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_js/flutter_js.dart';
import 'package:ibuki/classes/extension/booru_post.dart';
import 'package:ibuki/classes/extension/extension.dart';
import 'package:ibuki/classes/extension/types.dart';

class Booru extends Extension {
    final JavascriptRuntime _runtime = getJavascriptRuntime(xhr: false);

    static const _internalJsCode = """const UserAgent = "IbukiMobile/1.0.0 Ibuki/1.0.0 (Night Sky Studio)"
function url(t) {
    let e = ""
    if ((t.base && ((e += t.base), t.base.endsWith("/") || (e += "/")), t.path && (t.path.startsWith("/") ? (e += t.path.substring(1)) : (e += t.path), t.path.endsWith("/") && (e = e.substring(0, e.length - 1))), t.query)) {
        for (let s of ((e += "?"), t.query)) {
            let n = Object.entries(s)[0];
            "" !== n[1] && (e += n[0] + "=" + n[1] + "&");
        }
        e = e.substring(0, e.length - 1);
    }
    return e
}
function fetch(url, options) {
	options = options || {
        method: "GET"
    };
	return new Promise(async (resolve, reject) => {
        let request = await sendMessage("fetch", JSON.stringify({"url": url, "options": options}))

        const response = () => ({
            ok: ((request.status / 100) | 0) == 2, // 200-299
            statusText: request.statusText,
            status: request.status,
            url: request.responseURL,
            text: () => Promise.resolve(request.responseText),
            json: () => Promise.resolve(request.responseText).then(JSON.parse),
            blob: () => Promise.resolve(new Blob([request.response])),
            clone: response,
            headers: request.headers,
        })

        if (request.ok) resolve(response());
        else reject(response());
        
	});
}""";

    Booru(String script) {
        _runtime.evaluate(_internalJsCode);

        _runtime.onMessage("fetch", (args) async {
            Uri url = Uri.parse(args["url"]);
            Map options = args["options"];
            Map<String, String> headers = (options["headers"] as Map<dynamic, dynamic>).map((key, value) => MapEntry("$key", "$value"));
            http.Response response;

            switch(options["method"]) {
                case "GET":
                response = await http.get(url, headers: headers);
                break;
                case "POST":
                response = await http.post(url, headers: headers, body: options["body"]);
                break;
                case "PUT":
                response = await http.put(url, headers: headers, body: options["body"]);
                break;
                case "DELETE":
                response = await http.delete(url, headers: headers);
                break;
                default:
                throw Exception("Invalid method");
            }

            final json = {
                "ok": response.statusCode >= 200 && response.statusCode < 300,
                "status": response.statusCode,
                "statusText": response.reasonPhrase,
                "headers": jsonEncode(response.headers),
                "body": response.body,
                "responseURL": response.request!.url.toString(),
                "responseText": response.body,
            };

            return json;
        });

        // eval script
        _runtime.evaluate(script);
        JsEvalResult extension = _runtime.evaluate("JSON.stringify(Extension)");
        init(extension);
    }

    JsEvalResult runtimeEval(String code) => _runtime.evaluate(code);
    Future<JsEvalResult> runtimeEvalAsync(String code) async {       
        _runtime.enableHandlePromises(); 

        await Future.delayed(Duration(milliseconds: rateLimit ?? 10));
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

    Future<List<BooruPost>> getPosts({int page = 1, int limit = 20, String search = "", String auth = ":"}) async {
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