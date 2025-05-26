import 'package:flutter/material.dart';

class FrontAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrontAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "테이스트Q",
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
