import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ErrorType {
    noExtensions,
    connectionFailed,
    unsupportedExtension,
    unknown,
    unhandledException
}

class IbukiErrorWidget extends StatelessWidget {
    const IbukiErrorWidget({super.key, required this.type, required this.message, required this.body, this.actions});

    final ErrorType type;
    final String message, body;
    final List<Widget>? actions;

    Widget buildErrorIcon() {
        switch(type) {
            case ErrorType.noExtensions:
                return SvgPicture.asset("assets/images/errors/NoInternet 1.svg");
            case ErrorType.connectionFailed:
                return const Icon(Icons.wifi_off_rounded);
            case ErrorType.unsupportedExtension:
                return const Icon(Icons.error_rounded);
            case ErrorType.unknown:
                return const Icon(Icons.error_rounded);
            case ErrorType.unhandledException:
                return const Icon(Icons.error_rounded);
        }
    }

    Widget buildErrorBase(String message, String body) {
        return Center(
            child: Column(children: [
                buildErrorIcon(),
                const SizedBox(height: 8),
                Text(message, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(body, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                if (actions != null) ...actions!
            ]),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Container(child: buildErrorBase(message, body));
    }
}


// Widget errorWidget(ErrorType type, Function callback) {
//     Widget errorBase(String message, String body) { 
//         return Center(
//             child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                     Icon(Icons.error_rounded, color: Colors.red[400]),
//                     const SizedBox(height: 8),
//                     Text(message, style: Theme.of(context).textTheme.headline6),
//                     const SizedBox(height: 8),
//                     Text(body, style: Theme.of(context).textTheme.bodyText1),
//                     const SizedBox(height: 8),
//                     ElevatedButton(
//                         onPressed: () async {
//                             await callback();
//                         }, 
//                         child: const Text("Retry")
//                     )
//                 ],
//             ),
//         ); 
//     }

//     switch(type) {
//         ErrorType.ENoExtensions:
//             return errorBase("No extensions found", "Please install at least one extension to use this app.");
//         ErrorType.EConnectionFailed:
//             return errorBase("Connection failed", "Please check your internet connection and try again.");
//         ErrorType.EUnsupportedExtension:
            
//     }
// }