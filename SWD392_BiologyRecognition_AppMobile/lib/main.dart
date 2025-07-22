import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/notification_service.dart';
import 'Screens/biology_search.dart';
import 'Screens/home.dart';
import 'Screens/profileMenu.dart';
import 'Screens/recognition.dart';
import 'Screens/login.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔧 Load environment variables TRƯỚC
  await dotenv.load(fileName: ".env");

  // 🔥 Initialize Firebase + OneSignal SAU
  await NotificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bio Recognition App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}

class MainScreen extends StatefulWidget {
  // Thêm initialIndex để chọn tab khởi đầu
  final int initialIndex;

  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Dùng giá trị từ constructor
  }

  void goToProfileTab() {
    setState(() {
      _currentIndex = 3;
    });
  }

  void goToRecognitionTab() {
    setState(() {
      _currentIndex = 2;
    });
  }

  void goToBiologyResearchTab() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Phần code không đổi
    final List<Widget> _screens = [
      HomeScreen(
        onUserIconTap: goToProfileTab,
        onRecognitionTap: goToRecognitionTab,
        onBiologyResearchTap: goToBiologyResearchTab,
      ),
      BiologySearchTab(onUserIconTap: goToProfileTab),
      RecognitionScreen(onUserIconTap: goToProfileTab),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
    );
  }
}
