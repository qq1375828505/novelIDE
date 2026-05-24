import 'package:flutter/material.dart';

/// 水文检测报告页
class WaterReportPage extends StatelessWidget {
  final String chapterContent;
  final String aiResponse;

  const WaterReportPage({
    super.key,
    required this.chapterContent,
    required this.aiResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('水文检测报告')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Text('AI 检测结果', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  Text(aiResponse, style: const TextStyle(fontSize: 14, height: 1.6)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
