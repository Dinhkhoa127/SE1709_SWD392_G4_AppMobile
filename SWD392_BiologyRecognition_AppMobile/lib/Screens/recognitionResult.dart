import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Widgets/footerpage.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Helper/UserHelper.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/services/api_service.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/detail_context.dart';
import 'dart:convert';
import 'recognition.dart';

class RecognitionResultScreen extends StatefulWidget {
  final String imageUrl;

  const RecognitionResultScreen({Key? key, required this.imageUrl})
    : super(key: key);

  @override
  State<RecognitionResultScreen> createState() =>
      _RecognitionResultScreenState();
}

class _RecognitionResultScreenState extends State<RecognitionResultScreen> {
  bool _isLoading = false;
  bool _hasRecognitionResult = false;
  String _errorMessage = '';

  // Kết quả nhận diện
  String _recognizedArtifactName = '';
  String _aiResult = '';
  double _confidenceScore = 0.0;

  // Dữ liệu từ search API (giống biology_search.dart)
  List<dynamic> _artifactMedia = [];
  List<dynamic> _articles = [];
  List<dynamic> _topics = [];

  bool _isLoadingContent = false;
  String _contentErrorMessage = '';

  // PAGING PARAMETERS - GIỐNG biology_search.dart
  int _currentPage = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _performRecognition();
  }

  Future<void> _performRecognition() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasRecognitionResult = false;
    });

    try {
      // Lấy userId
      int userId = await UserHelper.getUserAccountId();

      // Debug print
      print('Sending recognition request with:');
      print('ImageUrl: ${widget.imageUrl}');
      print('UserId: $userId');

      // Gửi request nhận diện
      final response = await ApiService.postData('recognition/recognize', {
        'imageUrl': widget.imageUrl,
        'userId': userId,
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // SỬA: Xử lý cả status 200 và 400
      if (response.statusCode == 200 || response.statusCode == 400) {
        // Parse response
        dynamic responseData = response.body;
        if (responseData is String) {
          responseData = json.decode(responseData);
        }

        print('Parsed response: $responseData');

        // Kiểm tra success trong response
        if (responseData != null && responseData['success'] == true) {
          // Lấy thông tin từ artifact object - NHẬN DIỆN THÀNH CÔNG
          Map<String, dynamic> artifact = {};
          if (responseData['artifact'] != null) {
            artifact = Map<String, dynamic>.from(responseData['artifact']);
          }

          setState(() {
            _recognizedArtifactName = artifact['label']?.toString() ?? '';
            _aiResult = responseData['message']?.toString() ?? '';
            double similarity = 0.0;
            if (artifact['similarity'] != null) {
              if (artifact['similarity'] is int) {
                similarity = (artifact['similarity'] as int).toDouble();
              } else if (artifact['similarity'] is double) {
                similarity = artifact['similarity'] as double;
              } else {
                similarity =
                    double.tryParse(artifact['similarity'].toString()) ?? 0.0;
              }
            }
            _confidenceScore = similarity;
            _hasRecognitionResult = true;
            _isLoading = false;
          });

          print('Recognition results:');
          print('Artifact Name: $_recognizedArtifactName');
          print('AI Result: $_aiResult');
          print('Confidence Score: $_confidenceScore');

          // Tìm kiếm nội dung liên quan
          if (_recognizedArtifactName.isNotEmpty) {
            await _searchRelatedContent(_recognizedArtifactName);
          }
        } else {
          // NHẬN DIỆN THẤT BẠI - status 400 hoặc success = false
          setState(() {
            _errorMessage =
                responseData?['message']?.toString() ?? 'Nhận diện thất bại';
            _isLoading = false;
            _hasRecognitionResult = false;
          });
        }
      } else {
        // Lỗi server khác
        setState(() {
          _errorMessage = 'Lỗi server. Vui lòng thử lại sau.';
          _isLoading = false;
          _hasRecognitionResult = false;
        });
      }
    } catch (e) {
      print('Recognition error: $e');
      setState(() {
        _errorMessage = 'Lỗi kết nối: ${e.toString()}';
        _isLoading = false;
        _hasRecognitionResult = false;
      });
    }
  }

  Future<void> _searchRelatedContent(String artifactName) async {
    setState(() {
      _isLoadingContent = true;
      _contentErrorMessage = '';
    });

    try {
      print('Searching for artifact: $artifactName');
      print('Searching with page: $_currentPage, pageSize: $_pageSize');

      // GỌI TUẦN TỰ
      // API 1: Topic
      final topicResponse = await ApiService.getData(
        'topic?artifactName=${Uri.encodeComponent(artifactName)}&page=$_currentPage&pageSize=$_pageSize',
      );

      List<dynamic> topicData = [];
      if (topicResponse.statusCode == 200) {
        final topicJson = jsonDecode(topicResponse.body);
        if (topicJson is List) {
          topicData = topicJson;
        } else if (topicJson is Map<String, dynamic>) {
          topicData = [topicJson];
        }
      }

      // Delay nhỏ để tránh conflict
      await Future.delayed(Duration(milliseconds: 100));

      // API 2: Artifact
      final artifactResponse = await ApiService.getData(
        'artifact?name=${Uri.encodeComponent(artifactName)}&includeDetails=true&includeMediaAndArticles=true&page=$_currentPage&pageSize=$_pageSize',
      );

      List<dynamic> mediaData = [];
      List<dynamic> articleData = [];
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
      }

      setState(() {
        _topics = topicData;
        _artifactMedia = mediaData;
        _articles = articleData;
        _isLoadingContent = false;
      });
    } catch (error) {
      setState(() {
        _topics = [];
        _artifactMedia = [];
        _articles = [];
        _isLoadingContent = false;
        _contentErrorMessage = 'Có lỗi xảy ra khi tìm kiếm nội dung liên quan';
      });
      print('Search error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả nhận diện'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RecognitionScreen()),
            );
          },
        ),
      ),
      body: widget.imageUrl.isEmpty
          ? _buildErrorState()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(),
                    SizedBox(height: 24),
                    _buildRecognitionSection(),
                    if (_hasRecognitionResult &&
                        _recognizedArtifactName.isNotEmpty) ...[
                      SizedBox(height: 24),
                      _buildContentSections(),
                    ],
                    SizedBox(height: 24),
                    _buildActionButtons(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: FooterPage(currentIndex: 2),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Không thể tải ảnh',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RecognitionScreen()),
              );
            },
            child: Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Không thể tải ảnh',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecognitionSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Kết quả nhận diện AI',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            if (_isLoading)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.purple),
                    SizedBox(height: 16),
                    Text('Đang nhận diện...'),
                  ],
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Column(
                children: [
                  // SỬA: Icon và màu sắc khác nhau tùy loại lỗi
                  Icon(
                    _errorMessage.contains('Không nhận dạng được')
                        ? Icons.search_off
                        : Icons.error,
                    color: _errorMessage.contains('Không nhận dạng được')
                        ? Colors.orange
                        : Colors.red,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    _errorMessage,
                    style: TextStyle(
                      color: _errorMessage.contains('Không nhận dạng được')
                          ? Colors.orange
                          : Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  // SỬA: Thêm gợi ý cho user
                  if (_errorMessage.contains('Không nhận dạng được'))
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Gợi ý:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• Chụp ảnh rõ nét hơn\n• Đảm bảo ánh sáng tốt\n• Chụp gần đối tượng\n• Thử góc chụp khác',
                            style: TextStyle(
                              color: Colors.orange[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _performRecognition,
                        icon: Icon(Icons.refresh),
                        label: Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecognitionScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.camera_alt),
                        label: Text('Chụp lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else if (_hasRecognitionResult)
              Column(
                children: [
                  _buildInfoRow(
                    'Loài được nhận diện',
                    _recognizedArtifactName,
                    Icons.nature,
                    Colors.green,
                  ),
                  if (_aiResult.isNotEmpty)
                    _buildInfoRow(
                      'Kết quả AI',
                      _aiResult,
                      Icons.smart_toy,
                      Colors.blue,
                    ),
                  _buildInfoRow(
                    'Độ tin cậy',
                    '${(_confidenceScore * 100).toStringAsFixed(1)}%',
                    Icons.verified,
                    _getConfidenceColor(_confidenceScore),
                  ),
                  _buildInfoRow(
                    'Thời gian',
                    '${DateTime.now().toString().substring(0, 19)}',
                    Icons.access_time,
                    Colors.grey,
                  ),
                ],
              )
            else
              Center(
                child: Text(
                  'Nhấn "Nhận diện" để bắt đầu',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSections() {
    if (_isLoadingContent) {
      return Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text('Đang tải nội dung liên quan...'),
          ],
        ),
      );
    }

    if (_contentErrorMessage.isNotEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.error, color: Colors.orange),
              SizedBox(height: 8),
              Text(
                _contentErrorMessage,
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
        ),
      );
    }

    // NẾU TẤT CẢ SECTIONS ĐỀU RỖNG
    if (_topics.isEmpty && _artifactMedia.isEmpty && _articles.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Không tìm thấy nội dung liên quan cho "$_recognizedArtifactName"',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // HIỂN THỊ 3 SECTIONS - CHỈ SUMMARY
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION 1: BÀI HỌC TRONG SÁCH - SUMMARY
        if (_topics.isNotEmpty) ...[
          _buildSectionHeader(
            'Bài học trong sách',
            Icons.book,
            Colors.green,
            _topics.length,
          ),
          _buildTopicSummarySection(),
          SizedBox(height: 20),
        ],

        // SECTION 2: HÌNH ẢNH/VIDEO - SUMMARY
        if (_artifactMedia.isNotEmpty) ...[
          _buildSectionHeader(
            'Hình ảnh & Video',
            Icons.perm_media,
            Colors.purple,
            _artifactMedia.length,
          ),
          _buildMediaSummarySection(),
          SizedBox(height: 20),
        ],

        // SECTION 3: BÀI VIẾT - SUMMARY
        if (_articles.isNotEmpty) ...[
          _buildSectionHeader(
            'Bài viết tham khảo',
            Icons.article,
            Colors.orange,
            _articles.length,
          ),
          _buildArticleSummarySection(),
          SizedBox(height: 20),
        ],
      ],
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

  // SECTION TOPIC SUMMARY
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
            _topics.first['name'] ??
                _topics.first['topicName'] ??
                'Bài học không có tên',
            style: TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_topics.first['chapterName'] != null)
                Text(
                  'Chương: ${_topics.first['chapterName']}',
                  style: TextStyle(color: Colors.green[600], fontSize: 12),
                ),
              Text(
                _topics.length > 1
                    ? 'và ${_topics.length - 1} bài học khác'
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
            // NAVIGATE TO UNIFIED DETAIL PAGE VỚI TAB BÀI HỌC
            print('Navigate to Unified Detail Page - Topic Tab');
            print('Topic data: $_topics');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TextContentDetailScreen(
                  contentType: 'topic',
                  searchQuery: _recognizedArtifactName,
                  artifactName: _recognizedArtifactName,
                  currentPage: _currentPage,
                  pageSize: _pageSize,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // SECTION MEDIA SUMMARY
  Widget _buildMediaSummarySection() {
    final imageCount = _artifactMedia
        .where((media) => media['type'] == 'IMAGE')
        .length;
    final videoCount = _artifactMedia
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
              if (_artifactMedia.isNotEmpty &&
                  _artifactMedia.first['description'] != null)
                Text(
                  _artifactMedia.first['description'],
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
            // NAVIGATE TO UNIFIED DETAIL PAGE VỚI TAB HÌNH ẢNH
            print('Navigate to Unified Detail Page - Media Tab');
            print('Media data: $_artifactMedia');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TextContentDetailScreen(
                  contentType: 'media',
                  searchQuery: _recognizedArtifactName,
                  artifactName: _recognizedArtifactName,
                  currentPage: _currentPage,
                  pageSize: _pageSize,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // SECTION ARTICLE SUMMARY
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
            _articles.first['title'] ?? 'Bài viết không có tiêu đề',
            style: TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_articles.first['content'] != null)
                Text(
                  _articles.first['content'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                _articles.length > 1
                    ? 'và ${_articles.length - 1} bài viết khác'
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
            // NAVIGATE TO UNIFIED DETAIL PAGE VỚI TAB BÀI VIẾT
            print('Navigate to Unified Detail Page - Article Tab');
            print('Article data: $_articles');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TextContentDetailScreen(
                  contentType: 'article',
                  searchQuery: _recognizedArtifactName,
                  artifactName: _recognizedArtifactName,
                  currentPage: _currentPage,
                  pageSize: _pageSize,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RecognitionScreen()),
              );
            },
            icon: Icon(Icons.camera_alt),
            label: Text('Chụp ảnh khác'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.imageUrl.isNotEmpty ? _performRecognition : null,
            icon: Icon(Icons.refresh),
            label: Text('Nhận diện lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.7) return Colors.orange;
    return Colors.red;
  }
}
