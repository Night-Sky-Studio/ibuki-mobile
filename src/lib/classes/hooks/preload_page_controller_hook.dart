// import 'package:flutter/widgets.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:preload_page_view/preload_page_view.dart';

// PreloadPageController usePreloadPageController({
//     int initialPage = 0,
//     bool keepPage = true,
//     double viewportFraction = 1.0,
//     List<Object?>? keys,
// }) {
//     return use(
//         _PreloadPageControllerHook(
//             initialPage: initialPage,
//             keepPage: keepPage,
//             viewportFraction: viewportFraction,
//             keys: keys,
//         ),
//     );
// }

// class _PreloadPageControllerHook extends Hook<PreloadPageController> {
//     const _PreloadPageControllerHook({
//         required this.initialPage,
//         required this.keepPage,
//         required this.viewportFraction,
//         List<Object?>? keys,
//     }) : super(keys: keys);

//     final int initialPage;
//     final bool keepPage;
//     final double viewportFraction;

//     @override
//     HookState<PreloadPageController, Hook<PreloadPageController>> createState() =>
//         _PreloadPageControllerHookState();
// }

// class _PreloadPageControllerHookState extends HookState<PreloadPageController, _PreloadPageControllerHook> {
//     late final controller = PreloadPageController(
//         initialPage: hook.initialPage,
//         keepPage: hook.keepPage,
//         viewportFraction: hook.viewportFraction,
//     );

//     @override
//     PreloadPageController build(BuildContext context) => controller;

//     @override
//     void dispose() => controller.dispose();

//     @override
//     String get debugLabel => 'usePreloadPageController';
// }