import 'package:flutter/material.dart';

/// App scaffold laid out below the system status bar / notch so top
/// controls stay tappable (Android edge-to-edge, iOS notch, etc.).
class VyralScaffold extends StatelessWidget {
  const VyralScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.extendBody = false,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      left: false,
      right: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        drawer: drawer,
        appBar: appBar,
        extendBody: extendBody,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
