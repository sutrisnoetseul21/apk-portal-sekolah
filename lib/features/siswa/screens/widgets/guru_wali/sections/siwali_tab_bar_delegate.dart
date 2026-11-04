import 'package:flutter/material.dart';

/// SliverPersistentHeaderDelegate untuk TabBar SI-WALI yang tertancap (pinned)
class SiwaliTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  SiwaliTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(SiwaliTabBarDelegate oldDelegate) {
    return false;
  }
}

