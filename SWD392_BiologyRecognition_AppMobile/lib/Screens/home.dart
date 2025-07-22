import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/custom_app_bar.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Widgets/footerpage.dart';
import '../Helper/UserHelper.dart'; // Import UserHelper

class HomeScreen extends StatefulWidget {
  // Chuyển sang StatefulWidget
  final VoidCallback? onUserIconTap;
  final VoidCallback? onRecognitionTap;
  final VoidCallback? onBiologyResearchTap;

  const HomeScreen({
    Key? key,
    this.onUserIconTap,
    this.onRecognitionTap,
    this.onBiologyResearchTap,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String username = 'Học sinh'; // Giá trị mặc định
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Gọi hàm lấy username khi khởi tạo

    // Animation cho welcome section
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    // Animation cho cards
    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // KHỞI TẠO ANIMATIONS SAU KHI ĐÃ CÓ CONTROLLERS
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    _animationController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  // Hàm lấy username từ UserHelper
  Future<void> _loadUsername() async {
    String name = await UserHelper.getUserName();
    setState(() {
      username = name; // Cập nhật state khi có username từ SharedPreferences
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        username: username, // Sử dụng username đã lấy được
        onUserIconTap: widget.onUserIconTap,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // Green 500
              Color(0xFF66BB6A), // Green 400
              Color(0xFF81C784), // Green 300
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // WELCOME SECTION với Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 3,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER SECTION với icon và title
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF4CAF50),
                                        Color(0xFF66BB6A),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                          0xFF4CAF50,
                                        ).withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.science,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Khám phá Sinh học',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                      Text(
                                        'Công nghệ AI tiên tiến',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Decorative element
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4CAF50).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFF4CAF50),
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),

                            // MAIN CONTENT với tip và features preview
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50).withOpacity(0.1),
                                    Color(0xFF66BB6A).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFF4CAF50).withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.tips_and_updates,
                                        color: Color(0xFF4CAF50),
                                        size: 24,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Nhận diện sinh vật chỉ với một cú chạm!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  // Quick features list
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildQuickFeature(
                                        Icons.camera_alt,
                                        'Chụp ảnh',
                                        onTap: widget
                                            .onRecognitionTap, // Navigate to recognition
                                      ),
                                      _buildQuickFeature(
                                        Icons.search,
                                        'Tra cứu',
                                        onTap: widget
                                            .onBiologyResearchTap, // Navigate to biology_search
                                      ),
                                      _buildQuickFeature(
                                        Icons.history,
                                        'Lịch sử',
                                        onTap: widget
                                            .onUserIconTap, // Navigate to history
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // FEATURES SECTION với Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Tính năng chính',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // FEATURE CARDS với Animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        // CARD 1: NHẬN DIỆN SINH VẬT
                        _buildFeatureCard(
                          title: 'Nhận diện sinh vật',
                          subtitle: 'Sử dụng AI để nhận diện các loài sinh vật',
                          description:
                              'Chụp ảnh hoặc tải lên hình ảnh để nhận diện tự động các loài động vật, thực vật với độ chính xác cao.',
                          icon: Icons.camera_alt,
                          gradient: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          onTap: widget.onRecognitionTap,
                        ),

                        SizedBox(height: 20),

                        // CARD 2: TRA CỨU SINH VẬT
                        _buildFeatureCard(
                          title: 'Tra cứu sinh vật',
                          subtitle: 'Tìm hiểu chi tiết về các loài sinh vật',
                          description:
                              'Khám phá cơ sở dữ liệu phong phú về động vật, thực vật với thông tin chi tiết và hình ảnh.',
                          icon: Icons.search,
                          gradient: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                          onTap: widget.onBiologyResearchTap,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // STATISTICS SECTION
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.analytics,
                                color: Color(0xFF4CAF50),
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Số liệu thống kê',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  '1000+',
                                  'Loài động vật',
                                  Icons.pets,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  '500+',
                                  'Loài thực vật',
                                  Icons.local_florist,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  '75%',
                                  'Độ chính xác',
                                  Icons.verified,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  '24/7',
                                  'Hỗ trợ',
                                  Icons.support_agent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: FooterPage(currentIndex: 0),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Nhấn để trải nghiệm',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4CAF50).withOpacity(0.1),
            Color(0xFF66BB6A).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF4CAF50), size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFeature(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          // Thêm hover effect
          border: Border.all(
            color: Color(0xFF4CAF50).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Color(0xFF4CAF50), size: 24),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
