import 'package:flutter/material.dart';

class FrontAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarName; // 앱바명

  const FrontAppBar({super.key, required this.appBarName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        appBarName,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.add, color: Colors.black),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none, color: Colors.black),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_vert, color: Colors.black),
        ),
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
