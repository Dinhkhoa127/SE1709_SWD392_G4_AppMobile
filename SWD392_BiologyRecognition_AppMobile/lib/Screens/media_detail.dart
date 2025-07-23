import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../services/api_service.dart';
import 'dart:convert';

class MediaDetailScreen extends StatefulWidget {
  final String searchQuery;
  final String artifactName;
  final int currentPage;
  final int pageSize;

  const MediaDetailScreen({
    Key? key,
    required this.searchQuery,
    required this.artifactName,
    required this.currentPage,
    required this.pageSize,
  }) : super(key: key);

  @override
  _MediaDetailScreenState createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen>
    with SingleTickerProviderStateMixin {
  late List<dynamic> _images;
  late List<dynamic> _videos;
  Map<String, VideoPlayerController> _videoControllers = {};
  late TabController _tabController;
  
  // PAGING STATE
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = false;
  int _totalPages = 1;
  int _totalItems = 0;
  List<dynamic> _allMediaList = [];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
    _pageSize = widget.pageSize;
    _tabController = TabController(length: 2, vsync: this);
    _loadMediaData();
  }

  @override
  void dispose() {
    // Dispose all video controllers
    _videoControllers.values.forEach((controller) {
      controller.dispose();
    });
    _tabController.dispose();
    super.dispose();
  }

  // LOAD MEDIA DATA FROM API
  Future<void> _loadMediaData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('Loading media data for: ${widget.artifactName} with page: $_currentPage, pageSize: $_pageSize');

      // GỌI API ARTIFACT VỚI PAGING
      final response = await ApiService.getData(
        'artifact?name=${Uri.encodeComponent(widget.artifactName)}&includeDetails=true&includeMediaAndArticles=true&page=$_currentPage&pageSize=$_pageSize',
      );

      print('Media API response status: ${response.statusCode}');
      print('Media API response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        List<dynamic> newMediaList = [];
        
        // API trả về array of artifacts
        if (jsonData is List) {
          for (var artifact in jsonData) {
            if (artifact['mediaList'] != null) {
              newMediaList.addAll(artifact['mediaList']);
            }
          }
        } else if (jsonData is Map<String, dynamic>) {
          newMediaList = jsonData['mediaList'] ?? [];
        }

        setState(() {
          _allMediaList = newMediaList; // Thay thế thay vì addAll
          _totalItems = newMediaList.length;
          _totalPages = (_totalItems / _pageSize).ceil();
          if (_totalPages == 0) _totalPages = 1;
          _isLoading = false;
        });

        _separateMediaTypes();
        _initializeVideoControllers();
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Có lỗi xảy ra khi tải dữ liệu');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading media data: $error');
      _showErrorMessage('Có lỗi xảy ra khi tải dữ liệu');
    }
  }

  // CHANGE PAGE
  Future<void> _changePage(int newPage) async {
    if (newPage < 1 || newPage > _totalPages) return;

    setState(() {
      _currentPage = newPage;
    });

    await _loadMediaData();
  }

  void _separateMediaTypes() {
    _images = _allMediaList
        .where((media) => media['type'] == 'IMAGE')
        .toList();
    _videos = _allMediaList
        .where((media) => media['type'] == 'VIDEO')
        .toList();
  }

  void _initializeVideoControllers() {
    for (var video in _videos) {
      String videoUrl = video['url'] ?? '';
      if (videoUrl.isNotEmpty) {
        VideoPlayerController controller = VideoPlayerController.network(
          videoUrl,
        );
        _videoControllers[video['artifactMediaId'].toString()] = controller;
      }
    }
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
        title: Text(
          'Tài liệu đa phương tiện',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with search info - Thêm SafeArea và padding
          SafeArea(
            child: Container(
              margin: EdgeInsets.only(top: 8), // Thêm margin top
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kết quả tìm kiếm: "${widget.searchQuery}"',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_images.length} hình ảnh, ${_videos.length} video (Trang $_currentPage/$_totalPages)',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Tab bar for Images and Videos
          Container(
            color: Colors.grey[50],
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.purple,
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(
                  icon: Icon(Icons.image),
                  text: 'Hình ảnh (${_images.length})',
                ),
                Tab(
                  icon: Icon(Icons.video_library),
                  text: 'Video (${_videos.length})',
                ),
              ],
            ),
          ),

          // Content based on selected tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildImageGrid(), _buildVideoList()],
            ),
          ),

          // Pagination controls
          if (_totalPages > 1)
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous button
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () => _changePage(_currentPage - 1)
                        : null,
                    icon: Icon(Icons.chevron_left),
                    color: _currentPage > 1 ? Colors.purple : Colors.grey,
                  ),
                  
                  // Page numbers
                  ...List.generate(_totalPages, (index) {
                    int pageNumber = index + 1;
                    bool isCurrentPage = pageNumber == _currentPage;
                    
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => _changePage(pageNumber),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isCurrentPage ? Colors.purple : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrentPage ? Colors.purple : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            '$pageNumber',
                            style: TextStyle(
                              color: isCurrentPage ? Colors.white : Colors.grey[600],
                              fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // Next button
                  IconButton(
                    onPressed: _currentPage < _totalPages
                        ? () => _changePage(_currentPage + 1)
                        : null,
                    icon: Icon(Icons.chevron_right),
                    color: _currentPage < _totalPages ? Colors.purple : Colors.grey,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    if (_images.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Không có hình ảnh nào',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.purple));
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final image = _images[index];
        return _buildImageCard(image, index);
      },
    );
  }

  Widget _buildImageCard(Map<String, dynamic> image, int index) {
    return GestureDetector(
      onTap: () => _showImageGallery(index),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: image['url'] ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.purple),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Không thể tải hình ảnh',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
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
            if (image['description'] != null && image['description'].isNotEmpty)
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      image['description'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Nhấn để xem toàn màn hình',
                      style: TextStyle(fontSize: 10, color: Colors.purple[400]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList() {
    if (_videos.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Không có video nào',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.purple));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return _buildVideoCard(video);
      },
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    String videoId = video['artifactMediaId'].toString();
    VideoPlayerController? controller = _videoControllers[videoId];

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: controller != null
                  ? FutureBuilder(
                      future: controller.initialize(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return VideoPlayer(controller);
                        } else {
                          return Container(
                            color: Colors.black,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.purple,
                              ),
                            ),
                          );
                        }
                      },
                    )
                  : Container(
                      color: Colors.black,
                      child: Center(
                        child: Icon(Icons.error, color: Colors.red, size: 48),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (video['description'] != null &&
                    video['description'].isNotEmpty)
                  Text(
                    video['description'],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _playVideo(controller),
                        icon: Icon(Icons.play_arrow),
                        label: Text('Phát video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showVideoFullscreen(controller),
                      icon: Icon(Icons.fullscreen),
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text('${initialIndex + 1} / ${_images.length}'),
            actions: [
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () => _showImageInfo(_images[initialIndex]),
              ),
            ],
          ),
          body: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(
                  _images[index]['url'] ?? '',
                ),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: _images[index]['artifactMediaId'],
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
              );
            },
            itemCount: _images.length,
            loadingBuilder: (context, event) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.purple),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải hình ảnh...',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            backgroundDecoration: BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: initialIndex),
            onPageChanged: (index) {
              // Có thể thêm logic khi chuyển trang
            },
          ),
        ),
      ),
    );
  }

  void _showImageInfo(Map<String, dynamic> image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thông tin hình ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image['description'] != null && image['description'].isNotEmpty)
              Text(
                'Mô tả:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            if (image['description'] != null && image['description'].isNotEmpty)
              Text(image['description']),
            SizedBox(height: 8),
            Text(
              'ID: ${image['artifactMediaId']}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              'Loại: ${image['type']}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
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

  void _playVideo(VideoPlayerController? controller) {
    if (controller != null && controller.value.isInitialized) {
      setState(() {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      });
    }
  }

  void _showVideoFullscreen(VideoPlayerController? controller) {
    if (controller != null && controller.value.isInitialized) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _playVideo(controller),
              child: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              backgroundColor: Colors.purple,
            ),
          ),
        ),
      );
    }
  }
}
