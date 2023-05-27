import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MouseButtonGestureRecognizer extends BaseTapGestureRecognizer {
    MouseButtonGestureRecognizer({ super.debugOwner, super.supportedDevices });
    
    GestureTapDownCallback? onTapDown;
    GestureTapUpCallback? onTapUp;
    GestureTapCallback? onTap;
    GestureTapCancelCallback? onTapCancel;
    GestureTapCallback? onSecondaryTap;
    GestureTapDownCallback? onSecondaryTapDown;
    GestureTapUpCallback? onSecondaryTapUp;
    GestureTapCancelCallback? onSecondaryTapCancel;
    GestureTapDownCallback? onTertiaryTapDown;
    GestureTapUpCallback? onTertiaryTapUp;
    GestureTapCancelCallback? onTertiaryTapCancel;

    GestureTapDownCallback? onBackButtonTapDown;
    GestureTapUpCallback? onBackButtonTapUp;
    GestureTapCancelCallback? onBackButtonTapCancel;

    @override
    void handleTapCancel({required PointerDownEvent down, PointerCancelEvent? cancel, required String reason}) {
        // TODO: implement handleTapCancel
    }

    @override
    void handleTapDown({required PointerDownEvent down}) {
        // TODO: implement handleTapDown
    }

    @override
    void handleTapUp({required PointerDownEvent down, required PointerUpEvent up}) {
        // TODO: implement handleTapUp
    }

    @override
    bool isPointerAllowed(PointerDownEvent event) {
        switch (event.buttons) {
            case kPrimaryButton:
                if (onTapDown == null &&
                    onTap == null &&
                    onTapUp == null &&
                    onTapCancel == null) {
                    return false;
                }
                break;
            case kSecondaryButton:
                if (onSecondaryTap == null &&
                    onSecondaryTapDown == null &&
                    onSecondaryTapUp == null &&
                    onSecondaryTapCancel == null) {
                    return false;
                }
                break;
            case kTertiaryButton:
                if (onTertiaryTapDown == null &&
                    onTertiaryTapUp == null &&
                    onTertiaryTapCancel == null) {
                    return false;
                }
                break;
            case kBackMouseButton:
                if (onBackButtonTapDown == null &&
                    onBackButtonTapUp == null &&
                    onBackButtonTapCancel == null) {
                    return false;
                }
                break;
            default:
                return false;
        }
        return super.isPointerAllowed(event);
    }
}

class MouseGestureDetector extends GestureDetector {
    MouseGestureDetector({super.key});
    
}