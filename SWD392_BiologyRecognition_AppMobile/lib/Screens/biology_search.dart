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

class _BiologySearchTabState extends State<BiologySearchTab> {
  String _userName = 'Loading...';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  // TÁCH 3 LOẠI KẾT QUẢ - CHỈ HIỂN THỊ SUMMARY
  List<dynamic> _topicResults = []; // Topic summary
  List<dynamic> _mediaResults = []; // Media summary
  List<dynamic> _articleResults = []; // Article summary
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  // HÀM GỌI 2 API SONG SONG - SỬA LẠI
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
    });

    try {
      print('Searching for: $query');

      // GỌI 2 API SONG SONG
      final results = await Future.wait([
        // API 1: Topic (bài học trong sách)
        ApiService.getData(
          'topic/by-artifactName/${Uri.encodeComponent(query)}',
        ),
        // API 2: Media + Article
        ApiService.getData(
          'artifact/by-name/${Uri.encodeComponent(query)}/with-media-article',
        ),
      ]);

      final topicResponse = results[0];
      final mediaArticleResponse = results[1];

      print('Topic response status: ${topicResponse.statusCode}');
      print('Topic response body: ${topicResponse.body}');
      print(
        'Media+Article response status: ${mediaArticleResponse.statusCode}',
      );
      print('Media+Article response body: ${mediaArticleResponse.body}');

      List<dynamic> topicData = [];
      List<dynamic> mediaData = [];
      List<dynamic> articleData = [];

      // PARSE TOPIC RESPONSE - SỬA LẠI
      if (topicResponse.statusCode == 200) {
        final topicJson = jsonDecode(topicResponse.body);

        // API trả về single object, không phải array
        if (topicJson is Map<String, dynamic>) {
          topicData = [topicJson]; // Wrap trong array để consistent
        } else if (topicJson is List) {
          topicData = topicJson;
        }
      }

      // PARSE MEDIA + ARTICLE RESPONSE - SỬA LẠI
      if (mediaArticleResponse.statusCode == 200) {
        final mediaArticleJson = jsonDecode(mediaArticleResponse.body);

        // API trả về single object với mediaList và articleList
        if (mediaArticleJson is Map<String, dynamic>) {
          mediaData = mediaArticleJson['mediaList'] ?? [];
          articleData = mediaArticleJson['articleList'] ?? [];
        } else if (mediaArticleJson is List) {
          // Nếu trả về array of objects
          for (var item in mediaArticleJson) {
            if (item['mediaList'] != null) {
              mediaData.addAll(item['mediaList']);
            }
            if (item['articleList'] != null) {
              articleData.addAll(item['articleList']);
            }
          }
        }
      }

      setState(() {
        _topicResults = topicData;
        _mediaResults = mediaData;
        _articleResults = articleData;
        _isLoading = false;
      });
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // WIDGET HIỂN THỊ KẾT QUẢ 3 SECTIONS - CHỈ SUMMARY
  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Nhập từ khóa để tìm kiếm',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // NẾU TẤT CẢ SECTIONS ĐỀU RỖNG
    if (_topicResults.isEmpty &&
        _mediaResults.isEmpty &&
        _articleResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả cho "$_searchQuery"',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // HIỂN THỊ 3 SECTIONS - CHỈ SUMMARY
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),

          // SECTION 1: BÀI HỌC TRONG SÁCH - SUMMARY
          if (_topicResults.isNotEmpty) ...[
            _buildSectionHeader(
              'Bài học trong sách',
              Icons.book,
              Colors.green,
              _topicResults.length,
            ),
            _buildTopicSummarySection(),
            SizedBox(height: 20),
          ],

          // SECTION 2: HÌNH ẢNH/VIDEO - SUMMARY
          if (_mediaResults.isNotEmpty) ...[
            _buildSectionHeader(
              'Hình ảnh & Video',
              Icons.perm_media,
              Colors.purple,
              _mediaResults.length,
            ),
            _buildMediaSummarySection(),
            SizedBox(height: 20),
          ],

          // SECTION 3: BÀI VIẾT - SUMMARY
          if (_articleResults.isNotEmpty) ...[
            _buildSectionHeader(
              'Bài viết tham khảo',
              Icons.article,
              Colors.orange,
              _articleResults.length,
            ),
            _buildArticleSummarySection(),
            SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  // HEADER CHO MỖI SECTION
  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color color,
    int count,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // SECTION TOPIC SUMMARY - CHỈ HIỂN THỊ TÊN
  Widget _buildTopicSummarySection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.book, color: Colors.white),
          ),
          title: Text(
            _topicResults
                    .first['name'] ?? // ← SỬA: Dùng 'name' thay vì 'topicName'
                'Bài học không có tên',
            style: TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_topicResults.first['chapterName'] != null)
                Text(
                  'Chương: ${_topicResults.first['chapterName']}',
                  style: TextStyle(color: Colors.green[600], fontSize: 12),
                ),
              Text(
                _topicResults.length > 1
                    ? 'và ${_topicResults.length - 1} bài học khác'
                    : 'Nhấn để xem chi tiết',
                style: TextStyle(color: Colors.green[600]),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Xem chi tiết',
                style: TextStyle(color: Colors.green[600], fontSize: 12),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, color: Colors.green[600], size: 16),
            ],
          ),
          onTap: () {
            // NAVIGATE TO TOPIC DETAIL PAGE
            print('Navigate to Topic Detail Page');
            print(
              'Topic name: ${_topicResults.first['name']}',
            ); // ← SỬA: Dùng 'name'
            print('Topic data: ${_topicResults.first}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TextContentDetailScreen(
                  contentType: 'topic',
                  contentList: _topicResults,
                  searchQuery: _searchQuery,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // SECTION MEDIA SUMMARY - CHỈ HIỂN THỊ SỐ LƯỢNG
  Widget _buildMediaSummarySection() {
    final imageCount = _mediaResults
        .where((media) => media['type'] == 'IMAGE')
        .length;
    final videoCount = _mediaResults
        .where((media) => media['type'] == 'VIDEO')
        .length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple,
            child: Icon(Icons.perm_media, color: Colors.white),
          ),
          title: Text(
            'Tài liệu đa phương tiện',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${imageCount > 0 ? '$imageCount hình ảnh' : ''}${imageCount > 0 && videoCount > 0 ? ', ' : ''}${videoCount > 0 ? '$videoCount video' : ''}',
                style: TextStyle(color: Colors.purple[600]),
              ),
              if (_mediaResults.isNotEmpty &&
                  _mediaResults.first['description'] != null)
                Text(
                  _mediaResults.first['description'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Xem chi tiết',
                style: TextStyle(color: Colors.purple[600], fontSize: 12),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.purple[600],
                size: 16,
              ),
            ],
          ),
          onTap: () {
            // NAVIGATE TO MEDIA DETAIL PAGE
            print('Navigate to Media Detail Page');
            print('Media data: $_mediaResults');
            /*
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MediaDetailScreen(
                  mediaList: _mediaResults,
                  searchQuery: _searchQuery,
                ),
              ),
            );
            */
          },
        ),
      ),
    );
  }

  // SECTION ARTICLE SUMMARY - CHỈ HIỂN THỊ TIÊU ĐỀ CHÍNH
  Widget _buildArticleSummarySection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.article, color: Colors.white),
          ),
          title: Text(
            _articleResults.first['title'] ?? 'Bài viết không có tiêu đề',
            style: TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_articleResults.first['content'] != null)
                Text(
                  _articleResults.first['content'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                _articleResults.length > 1
                    ? 'và ${_articleResults.length - 1} bài viết khác'
                    : 'Nhấn để đọc toàn bộ',
                style: TextStyle(color: Colors.orange[600]),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Xem chi tiết',
                style: TextStyle(color: Colors.orange[600], fontSize: 12),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.orange[600],
                size: 16,
              ),
            ],
          ),
          onTap: () {
            // NAVIGATE TO ARTICLE DETAIL PAGE
            print('Navigate to Article Detail Page');
            print('Article data: $_articleResults');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TextContentDetailScreen(
                  contentType: 'article',
                  contentList: _articleResults,
                  searchQuery: _searchQuery,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        username: _userName,
        onUserIconTap: widget.onUserIconTap,
      ),
      body: Column(
        children: [
          // Search Bar (giữ nguyên)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sinh vật, thực vật...',
                prefixIcon: Icon(Icons.search, color: Colors.green),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onSubmitted: (value) {
                _performSearch(value);
              },
              onChanged: (value) {
                setState(() {});
              },
            ),

            // Search Results - 3 SUMMARY SECTIONS
          ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
      bottomNavigationBar: FooterPage(currentIndex: 1),
    );
  }
}
