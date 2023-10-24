import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:webview_flutter/webview_flutter.dart';

class _WebViewControllerHook extends Hook<WebViewController> {
    const _WebViewControllerHook({required this.url});
    final String url;

    @override
    _WebViewControllerHookState createState() => _WebViewControllerHookState(url: url);
}

class _WebViewControllerHookState extends HookState<WebViewController, _WebViewControllerHook> {
    _WebViewControllerHookState({required this.url});

    late final WebViewController controller;
    final String url;

    @override
    void initHook() {
        super.initHook();

        controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(NavigationDelegate(
                onProgress: (progress) {
                    if (progress == 100) {
                        controller.runJavaScript("""for (let item of document.getElementsByTagName("video")) {
    item.setAttribute("playsinline", "true")
    item.setAttribute("loop", "true")
    item.setAttribute("controls", "true")
    item.setAttribute("autoplay", "true")
}""");
                    }
                }
            ))
            ..loadRequest(Uri.parse(url));
    }

    @override
    void dispose() async {
        super.dispose();
        await controller.clearCache();
    }
    
    @override
    WebViewController build(BuildContext context) {
        return controller;
    }
}

WebViewController useWebViewController(String url) {
    return use(_WebViewControllerHook(url: url));
}