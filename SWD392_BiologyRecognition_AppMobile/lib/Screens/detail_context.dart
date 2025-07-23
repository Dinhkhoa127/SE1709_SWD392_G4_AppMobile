import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/media_detail.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Widgets/footerpage.dart';
import 'custom_app_bar.dart';
import '../Helper/UserHelper.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class TextContentDetailScreen extends StatefulWidget {
  final String contentType; // 'topic' hoặc 'article'
  final String searchQuery;
  final String artifactName;
  final int currentPage;
  final int pageSize;
  
  // THÊM CÁC THAM SỐ MỚI - SỬA LẠI TÊN CHO ĐÚNG
  final List<dynamic>? allTopicData;
  final List<dynamic>? allMediaData;
  final List<dynamic>? allArticleData;

  const TextContentDetailScreen({
    Key? key,
    required this.contentType,
    required this.searchQuery,
    required this.artifactName,
    required this.currentPage,
    required this.pageSize,
    // THÊM THAM SỐ MỚI VÀO CONSTRUCTOR
    this.allTopicData,
    this.allMediaData,
    this.allArticleData,
  }) : super(key: key);

  @override
  _TextContentDetailScreenState createState() =>
      _TextContentDetailScreenState();
}

class _TextContentDetailScreenState extends State<TextContentDetailScreen>
    with TickerProviderStateMixin {
  
  // PAGING SIMULATION - LOAD TẤT CẢ DATA 1 LẦN, PAGINATE Ở FRONTEND
  Map<String, List<dynamic>> _allContentLists = {
    'topic': [],
    'media': [],
    'article': [],
  };

  Map<String, List<dynamic>> _currentPageContent = {
    'topic': [],
    'media': [],
    'article': [],
  };

  Map<String, int> _currentPages = {'topic': 1, 'media': 1, 'article': 1};
  Map<String, int> _totalPages = {'topic': 1, 'media': 1, 'article': 1};

  Map<String, bool> _isLoading = {
    'topic': false,
    'media': false,
    'article': false,
  };

  Map<String, bool> _isInitialized = {
    'topic': false,
    'media': false,
    'article': false,
  };

  int _pageSize = 3; // Luôn paging 3 phần tử mỗi trang ở màn chi tiết
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // KHÔNG lấy _pageSize = widget.pageSize nữa!
    _tabController = TabController(length: 3, vsync: this);

    // SET INITIAL TAB DỰA TRÊN CONTENT TYPE
    if (widget.contentType == 'media') {
      _tabController.index = 1; // Tab Hình ảnh
    } else if (widget.contentType == 'article') {
      _tabController.index = 2; // Tab Bài viết
    } else {
      _tabController.index = 0; // Tab Bài học (mặc định)
    }

    // KIỂM TRA NẾU CÓ DATA TỪ SEARCH THÌ DÙNG, KHÔNG THÌ LOAD API
    if (widget.allTopicData != null || 
        widget.allMediaData != null || 
        widget.allArticleData != null) {
      _loadPreloadedData();
    } else {
      _loadAllContentData();
    }

    // Lắng nghe tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        String contentType = _getContentTypeForTab(_tabController.index);
        if (!_isInitialized[contentType]!) {
          _loadAllContentData();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // LOAD TẤT CẢ DATA 1 LẦN CHO MỖI TAB
  Future<void> _loadAllContentData() async {
    // GỌI TUẦN TỰ THAY VÌ SONG SONG ĐỂ TRÁNH DBCONTEXT CONFLICT
    try {
      print('🔍 Loading content data sequentially...');

      // Load topic first
      await _loadAllDataForType('topic');

      // Delay nhỏ giữa các request
      await Future.delayed(Duration(milliseconds: 200));

      // Load media second
      await _loadAllDataForType('media');

      // Delay nhỏ giữa các request
      await Future.delayed(Duration(milliseconds: 200));

      // Load article last
      await _loadAllDataForType('article');

      // Sau khi load xong, tính toán pagination cho từng tab
      _calculatePaginationForAllTabs();

      print('✅ All content data loaded successfully!');
    } catch (e) {
      print('❌ Error loading content data: $e');
      _showErrorMessage('Có lỗi xảy ra khi tải dữ liệu');
    }
  }

  // LOAD TẤT CẢ DATA CHO 1 CONTENT TYPE
  Future<void> _loadAllDataForType(String contentType) async {
    if (_isLoading[contentType]!) return;

    setState(() {
      _isLoading[contentType] = true;
    });

    try {
      print('Loading ALL $contentType data for: ${widget.artifactName}');

      String apiEndpoint = '';

      if (contentType == 'topic') {
        apiEndpoint =
            'topic?artifactName=${Uri.encodeComponent(widget.artifactName)}';
      } else if (contentType == 'media') {
        // Chỉ load media, không load article cùng lúc
        apiEndpoint =
            'artifact?name=${Uri.encodeComponent(widget.artifactName)}&includeDetails=false&includeMediaAndArticles=true';
      } else if (contentType == 'article') {
        // Chỉ load article, không load media cùng lúc
        apiEndpoint =
            'artifact?name=${Uri.encodeComponent(widget.artifactName)}&includeDetails=false&includeMediaAndArticles=true';
      }

      final response = await ApiService.getData(apiEndpoint);

      print('$contentType API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        List<dynamic> allContentList = [];

        if (contentType == 'topic') {
          // API topic trả về array of topics
          if (jsonData is List) {
            allContentList = jsonData;
          } else if (jsonData is Map<String, dynamic>) {
            allContentList = [jsonData];
          }
        } else if (contentType == 'media') {
          // Chỉ extract media list
          if (jsonData is List) {
            for (var artifact in jsonData) {
              if (artifact['mediaList'] != null) {
                allContentList.addAll(artifact['mediaList']);
              }
            }
          } else if (jsonData is Map<String, dynamic>) {
            allContentList = jsonData['mediaList'] ?? [];
          }
        } else if (contentType == 'article') {
          // Chỉ extract article list
          if (jsonData is List) {
            for (var artifact in jsonData) {
              if (artifact['articleList'] != null) {
                allContentList.addAll(artifact['articleList']);
              }
            }
          } else if (jsonData is Map<String, dynamic>) {
            allContentList = jsonData['articleList'] ?? [];
          }
        }

        print('$contentType - Total items loaded: ${allContentList.length}');

        setState(() {
          _allContentLists[contentType] = allContentList;
          _isLoading[contentType] = false;
          _isInitialized[contentType] = true;
        });
      } else {
        setState(() {
          _allContentLists[contentType] = []; // Set empty list thay vì để null
          _isLoading[contentType] = false;
          _isInitialized[contentType] =
              true; // Mark as initialized even if failed
        });
        print('❌ $contentType API failed: ${response.body}');
      }
    } catch (error) {
      setState(() {
        _allContentLists[contentType] = []; // Set empty list
        _isLoading[contentType] = false;
        _isInitialized[contentType] = true; // Mark as initialized
      });
      print('Error loading $contentType data: $error');
    }
  }

  // HÀM MỚI: LOAD DATA ĐÃ TRUYỀN TỪ SEARCH
  void _loadPreloadedData() {
    print('🔄 Using preloaded data from search...');
    
    setState(() {
      // SỬ DỤNG DATA ĐÃ TRUYỀN TỪ SEARCH
      _allContentLists['topic'] = widget.allTopicData ?? [];
      _allContentLists['media'] = widget.allMediaData ?? [];
      _allContentLists['article'] = widget.allArticleData ?? [];
      
      // MARK TẤT CẢ LÀ ĐÃ INITIALIZED
      _isInitialized['topic'] = true;
      _isInitialized['media'] = true;
      _isInitialized['article'] = true;
      
      // MARK TẤT CẢ LÀ KHÔNG LOADING
      _isLoading['topic'] = false;
      _isLoading['media'] = false;
      _isLoading['article'] = false;
    });

    // TÍNH TOÁN PAGINATION CHO TẤT CẢ TABS
    _calculatePaginationForAllTabs();

    print('✅ Preloaded data loaded successfully!');
    print('📊 Topic: ${_allContentLists['topic']!.length} items');
    print('📊 Media: ${_allContentLists['media']!.length} items');
    print('📊 Article: ${_allContentLists['article']!.length} items');
  }

  // TÍNH TOÁN PAGINATION CHO TẤT CẢ TABS
  void _calculatePaginationForAllTabs() {
    for (String contentType in ['topic', 'media', 'article']) {
      List<dynamic> allContent = _allContentLists[contentType]!;
      int totalItems = allContent.length;
      
      // TÍNH TOÁN SỐ TRANG DỰA TRÊN PAGESIZE
      int totalPages = (totalItems / _pageSize).ceil();
      if (totalPages == 0) totalPages = 1;

      _totalPages[contentType] = totalPages;
      _currentPages[contentType] = 1; // Reset về trang đầu

      // Tính toán content cho trang hiện tại
      _updateCurrentPageContent(contentType);

      print(
        '📊 $contentType - Total items: $totalItems, PageSize: $_pageSize, Total pages: $totalPages',
      );
    }
  }

  // CẬP NHẬT CONTENT CHO TRANG HIỆN TẠI
  void _updateCurrentPageContent(String contentType) {
    List<dynamic> allContent = _allContentLists[contentType]!;
    int currentPage = _currentPages[contentType]!;
    int startIndex = (currentPage - 1) * _pageSize;
    int endIndex = startIndex + _pageSize;

    if (endIndex > allContent.length) {
      endIndex = allContent.length;
    }

    List<dynamic> currentPageContent = allContent.sublist(startIndex, endIndex);
    _currentPageContent[contentType] = currentPageContent;

    print(
      '📄 $contentType - Page $currentPage: ${currentPageContent.length} items (${startIndex + 1}-$endIndex of ${allContent.length})',
    );
  }

  // THAY ĐỔI TRANG
  void _changePage(String contentType, int newPage) {
    if (newPage < 1 || newPage > _totalPages[contentType]!) return;

    setState(() {
      _currentPages[contentType] = newPage;
    });

    _updateCurrentPageContent(contentType);

    print('📖 $contentType - Changed to page $newPage');
  }

  // Hiển thị thông báo lỗi
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết kết quả tìm kiếm'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.green,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  icon: Icon(Icons.book),
                  text: 'Bài học (${_allContentLists['topic']!.length})',
                ),
                Tab(
                  icon: Icon(Icons.perm_media),
                  text: 'Hình ảnh (${_allContentLists['media']!.length})',
                ),
                Tab(
                  icon: Icon(Icons.article),
                  text: 'Bài viết (${_allContentLists['article']!.length})',
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContentTab(
                  'topic',
                  _currentPageContent['topic']!,
                  _isLoading['topic']!,
                  _currentPages['topic']!,
                  _totalPages['topic']!,
                ),
                _buildContentTab(
                  'media',
                  _currentPageContent['media']!,
                  _isLoading['media']!,
                  _currentPages['media']!,
                  _totalPages['media']!,
                ),
                _buildContentTab(
                  'article',
                  _currentPageContent['article']!,
                  _isLoading['article']!,
                  _currentPages['article']!,
                  _totalPages['article']!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicTab() {
    return _buildContentTab(
      'topic',
      _allContentLists['topic']!,
      _isLoading['topic']!,
      _currentPages['topic']!,
      _totalPages['topic']!,
    );
  }

  Widget _buildMediaTab() {
    return _buildContentTab(
      'media',
      _allContentLists['media']!,
      _isLoading['media']!,
      _currentPages['media']!,
      _totalPages['media']!,
    );
  }

  Widget _buildArticleTab() {
    return _buildContentTab(
      'article',
      _allContentLists['article']!,
      _isLoading['article']!,
      _currentPages['article']!,
      _totalPages['article']!,
    );
  }

  // BUILD CONTENT TAB
  Widget _buildContentTab(
    String contentType,
    List<dynamic> contentList,
    bool isLoading,
    int currentPage,
    int totalPages,
  ) {
    Color themeColor = _getThemeColor(contentType);

    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: themeColor));
    }

    if (contentList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(contentType), size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Không có dữ liệu ${_getContentTypeName(contentType)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Content list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: contentList.length,
            itemBuilder: (context, index) {
              return _buildContentItem(contentType, contentList[index], index);
            },
          ),
        ),

        // Pagination controls - LUÔN HIỂN THỊ KHI CÓ DATA
        if (contentList.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Debug info
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Text(
                    'Trang $currentPage/$totalPages',
                    style: TextStyle(color: Colors.blue[800], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous button
                    IconButton(
                      onPressed: currentPage > 1
                          ? () => _changePage(contentType, currentPage - 1)
                          : null,
                      icon: Icon(Icons.chevron_left),
                      color: currentPage > 1 ? themeColor : Colors.grey,
                    ),

                    // Sliding window page numbers
                    ...(() {
                      int startPage = 1;
                      int endPage = totalPages;
                      if (totalPages > 5) {
                        if (currentPage <= 3) {
                          startPage = 1;
                          endPage = 5;
                        } else if (currentPage >= totalPages - 2) {
                          startPage = totalPages - 4;
                          endPage = totalPages;
                        } else {
                          startPage = currentPage - 2;
                          endPage = currentPage + 2;
                        }
                      }
                      return List.generate(endPage - startPage + 1, (index) {
                        int pageNumber = startPage + index;
                        bool isCurrentPage = pageNumber == currentPage;
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => _changePage(contentType, pageNumber),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentPage
                                    ? themeColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isCurrentPage
                                      ? themeColor
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                '$pageNumber',
                                style: TextStyle(
                                  color: isCurrentPage
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: isCurrentPage
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    })(),

                    // Next button
                    IconButton(
                      onPressed: currentPage < totalPages
                          ? () => _changePage(contentType, currentPage + 1)
                          : null,
                      icon: Icon(Icons.chevron_right),
                      color: currentPage < totalPages
                          ? themeColor
                          : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CHAPTER NAME - HIỂN THỊ TRƯỚC (TRÊN CÙNG)
            if (topic['chapterName'] != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  'Chương: ${topic['chapterName']}',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],

            // TOPIC NAME - HIỂN THỊ SAU (DƯỚI CHAPTER)
            Text(
              topic['name'] ?? 'Không có tên',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),

            // DESCRIPTION
            if (topic['description'] != null) ...[
              SizedBox(height: 12),
              Text(
                topic['description'],
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],

            // CONTENT
            if (topic['content'] != null) ...[
              SizedBox(height: 12),
              Text(
                topic['content'],
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard(Map<String, dynamic> media) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media type indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: media['type'] == 'IMAGE'
                    ? Colors.blue[50]
                    : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: media['type'] == 'IMAGE'
                      ? Colors.blue[200]!
                      : Colors.red[200]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    media['type'] == 'IMAGE'
                        ? Icons.image
                        : Icons.video_library,
                    size: 16,
                    color: media['type'] == 'IMAGE'
                        ? Colors.blue[600]
                        : Colors.red[600],
                  ),
                  SizedBox(width: 4),
                  Text(
                    media['type'] == 'IMAGE' ? 'Hình ảnh' : 'Video',
                    style: TextStyle(
                      color: media['type'] == 'IMAGE'
                          ? Colors.blue[600]
                          : Colors.red[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Image preview for IMAGE type
            if (media['type'] == 'IMAGE' && media['url'] != null) ...[
              GestureDetector(
                onTap: () => _showImageFullscreen(media),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: media['url'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: Colors.blue),
                                  SizedBox(height: 8),
                                  Text(
                                    'Đang tải hình ảnh...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            print('Error loading image: $url');
                            print('Error details: $error');
                            return Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Không thể tải hình ảnh',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          httpHeaders: {
                            'User-Agent':
                                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                          },
                        ),
                      ),
                      // Overlay với icon zoom để chỉ ra có thể ấn vào
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Nhấn để xem toàn màn hình',
                style: TextStyle(fontSize: 10, color: Colors.blue[400]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
            ],

            // Description
            if (media['description'] != null) ...[
              Text(
                media['description'],
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  void _showImageFullscreen(Map<String, dynamic> media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text('Xem hình ảnh'),
            actions: [
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () => _showMediaInfo(media),
              ),
            ],
          ),
          body: PhotoView(
            imageProvider: CachedNetworkImageProvider(
              media['url'] ?? '',
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
              },
            ),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(
              tag: media['artifactMediaId'],
            ),
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Không thể tải hình ảnh',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vui lòng thử lại sau',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              );
            },
            loadingBuilder: (context, event) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải hình ảnh...',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMediaInfo(Map<String, dynamic> media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Thông tin ${media['type'] == 'IMAGE' ? 'hình ảnh' : 'video'}',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (media['description'] != null &&
                media['description'].isNotEmpty) ...[
              Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(media['description']),
              SizedBox(height: 8),
            ],
            Text(
              'ID: ${media['artifactMediaId']}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              'Loại: ${media['type']}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (media['url'] != null) ...[
              SizedBox(height: 4),
              Text(
                'URL: ${media['url']}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] ?? 'Không có tiêu đề',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            if (article['content'] != null) ...[
              SizedBox(height: 12),
              Text(
                article['content'],
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
            if (article['description'] != null) ...[
              SizedBox(height: 12),
              Text(
                article['description'],
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getContentTypeForTab(int index) {
    switch (index) {
      case 0:
        return 'topic';
      case 1:
        return 'media';
      case 2:
        return 'article';
      default:
        return 'topic'; // Default to topic if index is unexpected
    }
  }

  Color _getThemeColor(String contentType) {
    switch (contentType) {
      case 'topic':
        return Colors.green;
      case 'media':
        return Colors.purple;
      case 'article':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String contentType) {
    switch (contentType) {
      case 'topic':
        return Icons.book;
      case 'media':
        return Icons.perm_media;
      case 'article':
        return Icons.article;
      default:
        return Icons.info;
    }
  }

  String _getContentTypeName(String contentType) {
    switch (contentType) {
      case 'topic':
        return 'bài học';
      case 'media':
        return 'hình ảnh';
      case 'article':
        return 'bài viết';
      default:
        return 'dữ liệu';
    }
  }

  Map<String, int> _totalItems = {'topic': 0, 'media': 0, 'article': 0};

  Widget _buildContentItem(String contentType, dynamic item, int index) {
    switch (contentType) {
      case 'topic':
        return _buildTopicCard(item);
      case 'media':
        return _buildMediaCard(item);
      case 'article':
        return _buildArticleCard(item);
      default:
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Unknown item type: $contentType'),
          ),
        );
    }
  }
}
