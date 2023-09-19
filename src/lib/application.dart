import 'package:flutter/material.dart';
import 'package:ibuki/classes/settings.dart';
import 'package:ibuki/pages/extensions_page.dart';
import 'package:ibuki/pages/main_page.dart';
import 'package:ibuki/pages/more_page.dart';

class Application extends StatelessWidget {
    const Application({super.key, required this.settings});
    final Settings settings;

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context)  {
        const MaterialColor accent = Colors.green;

        return MaterialApp(
            title: "Ibuki",
            theme: ThemeData(
                colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: accent, 
                    accentColor: accent, 
                    brightness: Brightness.light, 
                    // backgroundColor: Colors.transparent
                    backgroundColor: Colors.white
                ),
                pageTransitionsTheme: const PageTransitionsTheme(builders: { TargetPlatform.android: CupertinoPageTransitionsBuilder() }),
            ),
            darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: accent, 
                    accentColor: accent,
                    cardColor: accent,
                    brightness: Brightness.dark, 
                    // backgroundColor: Colors.transparent
                    backgroundColor: Colors.grey[900]
                ),
                pageTransitionsTheme: const PageTransitionsTheme(builders: { TargetPlatform.android: CupertinoPageTransitionsBuilder() }),
            ),
            // home: GestureDetector(
            //     child: MainPage(settings: settings),
                
            // ),
            routes: {
                "/": (context) => MainPage(settings: settings),
                "/more": (context) => MorePage(settings: settings),
                "/extensions": (context) => ExtensionsPage(settings: settings),
            },
            debugShowCheckedModeBanner: false
        );
    }
}
