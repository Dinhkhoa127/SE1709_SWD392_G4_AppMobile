import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/detail_context.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Widgets/footerpage.dart';
import 'custom_app_bar.dart';
import '../Helper/UserHelper.dart';
import '../services/api_service.dart';
import 'dart:convert';

class BiologySearchTab extends StatefulWidget {
  final VoidCallback? onUserIconTap;
  const BiologySearchTab({Key? key, this.onUserIconTap}) : super(key: key);

  @override
  _BiologySearchTabState createState() => _BiologySearchTabState();
}

class _BiologySearchTabState extends State<BiologySearchTab>
    with TickerProviderStateMixin {
  String _userName = 'Loading...';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  // TÁCH 3 LOẠI KẾT QUẢ - CHỈ HIỂN THỊ SUMMARY
  List<dynamic> _topicResults = []; // Topic summary
  List<dynamic> _mediaResults = []; // Media summary
  List<dynamic> _articleResults = []; // Article summary
  String _searchQuery = '';

  // PAGING PARAMETERS
  int _currentPage = 1;
  int _pageSize = 50;

  // ANIMATION CONTROLLERS - KHAI BÁO LATE
  late AnimationController _animationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // KHỞI TẠO ANIMATION CONTROLLERS TRƯỚC
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // SAU ĐÓ MỚI KHỞI TẠO ANIMATIONS
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
        parent: _searchAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // CUỐI CÙNG MỚI START ANIMATIONS
    _animationController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _searchAnimationController.forward();
    });

    // LOAD USER NAME
    _loadUserName();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  // Load tên user từ UserHelper
  Future<void> _loadUserName() async {
    try {
      String userName = await UserHelper.getUserName();
      setState(() {
        _userName = userName.isNotEmpty ? userName : 'User';
      });
    } catch (error) {
      print('Error loading username: $error');
      setState(() {
        _userName = 'User';
      });
    }
  }

  // HÀM GỌI 2 API SONG SONG - SỬA LẠI VỚI PAGING
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _topicResults = [];
        _mediaResults = [];
        _articleResults = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query.trim();
      _currentPage = 1;
    });

    try {
      print(
        'Searching for: $query with page: $_currentPage, pageSize: $_pageSize',
      );

      // GỌI TUẦN TỰ THAY VÌ SONG SONG ĐỂ TRÁNH DBCONTEXT CONFLICT
      List<dynamic> topicData = [];
      List<dynamic> mediaData = [];
      List<dynamic> articleData = [];

      // API 1: Topic (bài học trong sách)
      try {
        print('🔍 Calling Topic API...');
        final topicResponse = await ApiService.getData(
          'topic?artifactName=${Uri.encodeComponent(query)}&page=$_currentPage&pageSize=$_pageSize',
        );

        print('Topic response status: ${topicResponse.statusCode}');
        if (topicResponse.statusCode == 200) {
          final topicJson = jsonDecode(topicResponse.body);
          if (topicJson is List) {
            topicData = topicJson;
          } else if (topicJson is Map<String, dynamic>) {
            topicData = [topicJson];
          }
          print('✅ Topic loaded: ${topicData.length} items');
        } else {
          print('❌ Topic API failed: ${topicResponse.body}');
        }
      } catch (e) {
        print('❌ Topic API error: $e');
      }

      // Delay nhỏ để tránh conflict
      await Future.delayed(Duration(milliseconds: 100));

      // API 2: Artifact với Media + Article
      try {
        print('🔍 Calling Artifact API...');
        final artifactResponse = await ApiService.getData(
          'artifact?name=${Uri.encodeComponent(query)}&includeDetails=true&includeMediaAndArticles=true&page=$_currentPage&pageSize=$_pageSize',
        );

        print('Artifact response status: ${artifactResponse.statusCode}');
        if (artifactResponse.statusCode == 200) {
          final artifactJson = jsonDecode(artifactResponse.body);
          if (artifactJson is List) {
            for (var artifact in artifactJson) {
              if (artifact['mediaList'] != null) {
                mediaData.addAll(artifact['mediaList']);
              }
              if (artifact['articleList'] != null) {
                articleData.addAll(artifact['articleList']);
              }
            }
          } else if (artifactJson is Map<String, dynamic>) {
            mediaData = artifactJson['mediaList'] ?? [];
            articleData = artifactJson['articleList'] ?? [];
          }
          print('✅ Media loaded: ${mediaData.length} items');
          print('✅ Article loaded: ${articleData.length} items');
        } else {
          print('❌ Artifact API failed: ${artifactResponse.body}');
        }
      } catch (e) {
        print('❌ Artifact API error: $e');
      }

      setState(() {
        _topicResults = topicData;
        _mediaResults = mediaData;
        _articleResults = articleData;
        _isLoading = false;
      });

      print('🎉 Search completed successfully!');
    } catch (error) {
      setState(() {
        _topicResults = [];
        _mediaResults = [];
        _articleResults = [];
        _isLoading = false;
      });

      print('Search error: $error');
      _showErrorMessage('Có lỗi xảy ra khi tìm kiếm');
    }
  }

  // Hiển thị thông báo lỗi
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // WIDGET HIỂN THỊ KẾT QUẢ 3 SECTIONS - VỀ LẠI NHU CŨ
  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4CAF50), strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'Đang tìm kiếm...',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchQuery.isEmpty) {
      return _buildEmptySearchState();
    }

    // NẾU TẤT CẢ SECTIONS ĐỀU RỖNG
    if (_topicResults.isEmpty &&
        _mediaResults.isEmpty &&
        _articleResults.isEmpty) {
      return _buildNoResultsState();
    }

    // HIỂN THỊ 3 SECTIONS - VỀ LẠI NHU CŨ
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER KẾT QUẢ
          _buildResultsHeader(),
          SizedBox(height: 20),

          // SECTION 1: BÀI HỌC TRONG SÁCH
          if (_topicResults.isNotEmpty) ...[
            _buildTopicSummarySection(),
            SizedBox(height: 16),
          ],

          // SECTION 2: HÌNH ẢNH/VIDEO
          if (_mediaResults.isNotEmpty) ...[
            _buildMediaSummarySection(),
            SizedBox(height: 16),
          ],

          // SECTION 3: BÀI VIẾT
          if (_articleResults.isNotEmpty) ...[
            _buildArticleSummarySection(),
            SizedBox(height: 16),
          ],

          SizedBox(height: 100), // Space for bottom navigation - VỀ LẠI NHU CŨ
        ],
      ),
    );
  }

  // EMPTY SEARCH STATE - CHỈ XÓA GỢI Ý TÌM KIẾM
  Widget _buildEmptySearchState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4CAF50).withOpacity(0.1),
                        Color(0xFF66BB6A).withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search, size: 64, color: Color(0xFF4CAF50)),
                ),
                SizedBox(height: 24),
                Text(
                  'Khám phá thế giới sinh học',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Nhập tên sinh vật, thực vật hoặc chủ đề để bắt đầu tìm kiếm',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                // XÓA PHẦN _buildQuickSearchSuggestions() Ở ĐÂY
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NO RESULTS STATE
  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 64, color: Colors.orange),
            ),
            SizedBox(height: 24),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Không có kết quả nào cho "$_searchQuery"',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // RESULTS HEADER
  Widget _buildResultsHeader() {
    final totalResults =
        _topicResults.length + _mediaResults.length + _articleResults.length;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4CAF50).withOpacity(0.1),
            Color(0xFF66BB6A).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.search, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kết quả tìm kiếm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  'Tìm thấy $totalResults kết quả cho "$_searchQuery"',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SỬA HÀM NAVIGATION ĐỂ CHỈ TRUYỀN CÁC THAM SỐ CẦN THIẾT
  void _navigateToDetail(String contentType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextContentDetailScreen(
          contentType: contentType,
          searchQuery: _searchQuery,
          artifactName: _searchQuery,
          currentPage: 1,
          pageSize: _pageSize,
          // CHỈ TRUYỀN 3 THAM SỐ MỚI
          allTopicData: _topicResults,
          allMediaData: _mediaResults,
          allArticleData: _articleResults,
        ),
      ),
    );
  }

  // SECTION TOPIC SUMMARY - THIẾT KẾ MỚI
  Widget _buildTopicSummarySection() {
    if (_topicResults.isEmpty) return SizedBox.shrink();
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF4CAF50).withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _navigateToDetail('topic'), // SỬA GỌI HÀM MỚI
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.book, color: Colors.white, size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bài học trong sách',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_topicResults.length} bài học',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    _topicResults.isNotEmpty && _topicResults.first['name'] != null
                        ? _topicResults.first['name']
                        : 'Bài học không có tên',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_topicResults.isNotEmpty && _topicResults.first['chapterName'] != null) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Chương: ${_topicResults.first['chapterName']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // SECTION MEDIA SUMMARY - THIẾT KẾ MỚI
  Widget _buildMediaSummarySection() {
    if (_mediaResults.isEmpty) return SizedBox.shrink();
    final imageCount = _mediaResults
        .where((media) => media['type'] == 'IMAGE')
        .length;
    final videoCount = _mediaResults
        .where((media) => media['type'] == 'VIDEO')
        .length;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple, Colors.purpleAccent],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _navigateToDetail('media'), // SỬA GỌI HÀM MỚI
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.perm_media,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hình ảnh & Video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_mediaResults.length} tài liệu',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      if (imageCount > 0) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '$imageCount ảnh',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (videoCount > 0) SizedBox(width: 8),
                      ],
                      if (videoCount > 0) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '$videoCount video',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // SECTION ARTICLE SUMMARY - THIẾT KẾ MỚI
  Widget _buildArticleSummarySection() {
    if (_articleResults.isEmpty) return SizedBox.shrink();
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange, Colors.orangeAccent],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _navigateToDetail('article'), // SỬA GỌI HÀM MỚI
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.article,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bài viết tham khảo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_articleResults.length} bài viết',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    _articleResults.isNotEmpty && _articleResults.first['title'] != null
                        ? _articleResults.first['title']
                        : 'Bài viết không có tiêu đề',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_articleResults.isNotEmpty && _articleResults.first['content'] != null) ...[
                    SizedBox(height: 8),
                    Text(
                      _articleResults.first['content'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // THAY ĐỔI THÀNH FALSE
      appBar: CustomAppBar(
        username: _userName,
        onUserIconTap: widget.onUserIconTap,
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tap outside
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4CAF50).withOpacity(0.1),
                Color(0xFF66BB6A).withOpacity(0.05),
                Colors.white,
              ],
              stops: [0.0, 0.3, 1.0],
            ),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top -
                    65, // Footer height
              ),
              child: Column(
                children: [
                  // SEARCH BAR - COMPACT HƠN
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(
                        16,
                        4,
                        16,
                        8,
                      ), // Giảm margin top
                      padding: EdgeInsets.all(12), // Giảm padding
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Giảm border radius
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 1,
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
                              Container(
                                padding: EdgeInsets.all(6), // Giảm padding
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4CAF50),
                                      Color(0xFF66BB6A),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 18, // Giảm size
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Tìm kiếm sinh học',
                                style: TextStyle(
                                  fontSize: 16, // Giảm size
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10), // Giảm spacing
                          TextField(
                            controller: _searchController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm sinh vật, thực vật...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        _performSearch('');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF4CAF50),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Color(0xFF4CAF50).withOpacity(0.05),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10, // Giảm padding
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2E7D32),
                            ), // Giảm font
                            onSubmitted: (value) {
                              _performSearch(value);
                            },
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // SEARCH RESULTS
                  _buildSearchResults(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: FooterPage(currentIndex: 1),
    );
  }
}
