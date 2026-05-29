import 'package:flutter/material.dart';

/// 爽点检查报告页 - 显示AI分析结果
class ShuangdianReportPage extends StatelessWidget {
  final String chapterContent;
  final String aiResponse;

  const ShuangdianReportPage({
    super.key,
    required this.chapterContent,
    required this.aiResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('爽点密度报告')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AI 分析结果
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      const Text('AI 分析结果', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  Text(
                    aiResponse,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 章节内容摘要
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('章节内容（前500字）', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    chapterContent.length > 500
                        ? '${chapterContent.substring(0, 500)}...'
                        : chapterContent,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
