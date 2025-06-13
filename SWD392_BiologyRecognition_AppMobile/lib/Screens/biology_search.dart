import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Widgets/footerpage.dart';
import 'custom_app_bar.dart';

class BiologySearchTab extends StatelessWidget {
  final VoidCallback? onUserIconTap;
  const BiologySearchTab({Key? key, this.onUserIconTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(username: 'User123', onUserIconTap: onUserIconTap),
      body: Center(child: Text('Biology Search Screen')),
      bottomNavigationBar: FooterPage(currentIndex: 1),
    );
  }
}
