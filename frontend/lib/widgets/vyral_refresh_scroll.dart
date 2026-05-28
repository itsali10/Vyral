import 'package:flutter/material.dart';

/// Lets [RefreshIndicator] fire when the user pulls down at the top, even if
/// the list is short or empty.
const ScrollPhysics vyralRefreshScrollPhysics = AlwaysScrollableScrollPhysics(
  parent: BouncingScrollPhysics(),
);

/// Scrollable area that is always tall enough to pull-to-refresh.
class VyralRefreshScrollView extends StatelessWidget {
  const VyralRefreshScrollView({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: vyralRefreshScrollPhysics,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
