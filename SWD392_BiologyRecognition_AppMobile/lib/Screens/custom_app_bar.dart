import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final VoidCallback? onUserIconTap;

  const CustomAppBar({Key? key, required this.username, this.onUserIconTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text('Xin chào @$username'),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(Icons.account_circle, size: 32),
          onPressed: onUserIconTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
