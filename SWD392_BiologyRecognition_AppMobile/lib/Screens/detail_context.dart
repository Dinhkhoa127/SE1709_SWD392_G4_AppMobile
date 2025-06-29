import 'package:flutter/material.dart';

class TextContentDetailScreen extends StatelessWidget {
  final String contentType; // 'topic' hoặc 'article'
  final List<dynamic> contentList;
  final String searchQuery;

  const TextContentDetailScreen({
    Key? key,
    required this.contentType,
    required this.contentList,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          contentType == 'topic' ? 'Bài học trong sách' : 'Bài viết tham khảo',
        ),
        backgroundColor: contentType == 'topic' ? Colors.green : Colors.orange,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: contentList.length,
        itemBuilder: (context, index) {
          final item = contentList[index];

          if (contentType == 'topic') {
            return _buildTopicCard(item);
          } else {
            return _buildArticleCard(item);
          }
        },
      ),
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
}
