import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Helper/UserHelper.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/services/api_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class RecognitionHistoryScreen extends StatefulWidget {
  @override
  _RecognitionHistoryScreenState createState() =>
      _RecognitionHistoryScreenState();
}

class _RecognitionHistoryScreenState extends State<RecognitionHistoryScreen> {
  List<dynamic> _recognitionHistory = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _errorMessage = '';

  // PAGING PARAMETERS
  int _currentPage = 1;
  int _pageSize = 3;
  bool _hasNextPage = true;
  bool _hasPreviousPage = false;

  @override
  void initState() {
    super.initState();
    _loadRecognitionHistory();
  }

  Future<void> _loadRecognitionHistory({bool isRefresh = false}) async {
    try {
      setState(() {
        if (isRefresh) {
          _currentPage = 1;
          _recognitionHistory = [];
          _hasPreviousPage = false;
          _hasNextPage = true;
        }
        _isLoading = isRefresh || _currentPage == 1;
        _isLoadingMore = !isRefresh && _currentPage > 1;
        _errorMessage = '';
      });

      int userId = await UserHelper.getUserAccountId();

      print(
        'Loading recognition history - Page: $_currentPage, PageSize: $_pageSize, UserId: $userId',
      );

      final response = await ApiService.getData(
        'recognition?userId=$userId&page=$_currentPage&pageSize=$_pageSize',
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> newData = [];

        if (responseData is List) {
          newData = responseData;
        } else {
          newData = [];
        }

        print('Loaded ${newData.length} items for page $_currentPage');

        bool hasNext = newData.length == _pageSize;
        bool hasPrevious = _currentPage > 1;

        setState(() {
          _recognitionHistory = newData;
          _isLoading = false;
          _isLoadingMore = false;
          _hasNextPage = hasNext;
          _hasPreviousPage = hasPrevious;
        });

        print(
          'Page $_currentPage loaded: ${newData.length} items, hasNext: $hasNext, hasPrevious: $hasPrevious',
        );
      } else {
        setState(() {
          _errorMessage =
              'Không thể tải lịch sử nhận diện (${response.statusCode})';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: ${e.toString()}';
        _isLoading = false;
        _isLoadingMore = false;
      });
      print('Error loading recognition history: $e');
    }
  }

  Future<void> _loadNextPage() async {
    if (_hasNextPage && !_isLoadingMore) {
      setState(() {
        _currentPage++;
      });
      await _loadRecognitionHistory();
    }
  }

  Future<void> _loadPreviousPage() async {
    if (_hasPreviousPage && !_isLoadingMore && _currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      await _loadRecognitionHistory();
    }
  }

  Future<void> _refreshHistory() async {
    await _loadRecognitionHistory(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lịch sử nhận diện',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Trang $_currentPage',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
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
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4CAF50)),
            SizedBox(height: 16),
            Text(
              'Đang tải lịch sử nhận diện...',
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

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(24),
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[600],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Có lỗi xảy ra',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              SizedBox(height: 8),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshHistory,
                icon: Icon(Icons.refresh, size: 20),
                label: Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_recognitionHistory.isEmpty) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(24),
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.history, size: 48, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Chưa có lịch sử',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bạn chưa có lịch sử nhận diện nào.\nHãy thử nhận diện một số hình ảnh!',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshHistory,
                icon: Icon(Icons.refresh, size: 20),
                label: Text('Làm mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshHistory,
      color: Color(0xFF4CAF50),
      child: Column(
        children: [
          // HEADER STATISTICS CARD
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4CAF50).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lịch sử nhận diện',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${_recognitionHistory.length} kết quả',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Trang $_currentPage',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // PAGINATION CONTROLS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous button
                    _buildPaginationButton(
                      onPressed: _hasPreviousPage && !_isLoadingMore
                          ? _loadPreviousPage
                          : null,
                      icon: Icons.chevron_left,
                      text: 'Trước',
                      isEnabled: _hasPreviousPage && !_isLoadingMore,
                    ),

                    SizedBox(width: 16),

                    // Page indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Trang $_currentPage',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(width: 16),

                    // Next button
                    _buildPaginationButton(
                      onPressed: _hasNextPage && !_isLoadingMore
                          ? _loadNextPage
                          : null,
                      icon: Icons.chevron_right,
                      text: 'Tiếp',
                      isEnabled: _hasNextPage && !_isLoadingMore,
                      isLoading: _isLoadingMore,
                      isReversed: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // HISTORY LIST
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _recognitionHistory.length,
              itemBuilder: (context, index) {
                final recognition = _recognitionHistory[index];
                return _buildRecognitionCard(recognition, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String text,
    required bool isEnabled,
    bool isLoading = false,
    bool isReversed = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: isEnabled ? Color(0xFF4CAF50) : Colors.grey[400],
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isEnabled ? 2 : 0,
      ),
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF4CAF50),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: isReversed
                  ? [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(icon, size: 18),
                    ]
                  : [
                      Icon(icon, size: 18),
                      SizedBox(width: 4),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
            ),
    );
  }

  Widget _buildRecognitionCard(Map<String, dynamic> recognition, int index) {
    String imageUrl = recognition['imageUrl'] ?? '';
    String artifactName = recognition['artifactName'] ?? 'Không xác định';
    String recognizedAt =
        recognition['recognizedAt'] ?? recognition['recognizeAt'] ?? '';
    double confidenceScore = (recognition['confidenceScore'] ?? 0.0).toDouble();
    String status = recognition['status'] ?? '';
    String aiResult = recognition['aiResult'] ?? '';

    String formattedDate = 'Không có thời gian';
    if (recognizedAt.isNotEmpty) {
      try {
        DateTime dateTime;
        if (recognizedAt.contains('T')) {
          dateTime = DateTime.parse(recognizedAt);
        } else {
          dateTime = DateTime.tryParse(recognizedAt) ?? DateTime.now();
        }
        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
      } catch (e) {
        print('Error parsing date: $e');
        formattedDate = recognizedAt;
      }
    }

    Color confidenceColor = _getConfidenceColor(confidenceScore);
    String confidenceText = '${(confidenceScore * 100).toStringAsFixed(1)}%';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#${(_currentPage - 1) * _pageSize + index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE
                GestureDetector(
                  onTap: () {
                    if (imageUrl.isNotEmpty) {
                      _showFullImage(imageUrl, artifactName);
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF4CAF50).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Color(0xFF4CAF50).withOpacity(0.1),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF4CAF50),
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Tải...',
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: Color(0xFF4CAF50),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[50],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[400],
                                        size: 24,
                                      ),
                                      Text(
                                        'Lỗi ảnh',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Color(0xFF4CAF50).withOpacity(0.1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: Color(0xFF4CAF50),
                                    size: 24,
                                  ),
                                  Text(
                                    'Không có ảnh',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),

                SizedBox(width: 16),

                // DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artifactName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (aiResult.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          'AI: $aiResult',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      SizedBox(height: 12),

                      // BADGES
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: confidenceColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: confidenceColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.analytics,
                                  size: 12,
                                  color: confidenceColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  confidenceText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: confidenceColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  size: 12,
                                  color: _getStatusColor(status),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _getStatusText(status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double score) {
    if (score >= 0.8) return Color(0xFF4CAF50);
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Color(0xFF4CAF50);
      case 'PROCESSING':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Icons.check_circle;
      case 'PROCESSING':
        return Icons.sync;
      case 'FAILED':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'PROCESSING':
        return 'Đang xử lý';
      case 'FAILED':
        return 'Thất bại';
      default:
        return 'Không rõ';
    }
  }

  void _showFullImage(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.zoom_in, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Image
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF4CAF50),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Đang tải hình ảnh...',
                                style: TextStyle(color: Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 48, color: Colors.red),
                              SizedBox(height: 8),
                              Text(
                                'Không thể tải ảnh',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
