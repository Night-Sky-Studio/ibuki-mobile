import 'package:flutter/material.dart';

class MaterialIconButton extends StatelessWidget {
    final Widget icon;
    final VoidCallback onPressed;
    final Color? color;
    final double? size;
    
    const MaterialIconButton({super.key, required this.icon, required this.onPressed, this.color, this.size = 48});

    @override
    Widget build(BuildContext context) {
        return Material(color: Colors.transparent, shape: const CircleBorder(),
            child: InkWell(customBorder: const CircleBorder(),
                onTap: onPressed,
                child: Padding(padding: const EdgeInsets.all(16), child: icon),
            ),
        );
    }
}