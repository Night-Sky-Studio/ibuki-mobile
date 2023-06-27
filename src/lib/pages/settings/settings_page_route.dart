
import 'package:flutter/widgets.dart';

Route createIbukiSettingsPageRoute({required Widget page}) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const shadow = BoxDecoration(boxShadow: [BoxShadow(blurRadius: 32)]);

            return SlideTransition(
                position: animation.drive(
                    Tween(
                        begin: const Offset(1.0, 0.0), 
                        end: Offset.zero
                    ).chain(CurveTween(curve: Curves.fastOutSlowIn))
                ),
                child: DecoratedBoxTransition(
                    decoration: DecorationTween(
                        begin: shadow,
                        end: shadow
                    ).animate(animation),
                    child: child,
                ),
            );
        },
    );
}