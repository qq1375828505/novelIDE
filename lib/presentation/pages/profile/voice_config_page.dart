import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_ide/core/constants.dart';
import 'package:novel_ide/data/models/ai_config_model.dart';
import 'package:novel_ide/presentation/state/app_providers.dart';
import 'package:novel_ide/data/services/config_service.dart';

/// 语音模型配置页面
/// 选择用于语音通话的AI模型（可与文字对话模型不同）
class VoiceConfigPage extends ConsumerWidget {
  const VoiceConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(aiConfigsProvider);
    final currentVoiceId = ConfigService.voiceConfigId;

    return Scaffold(
      appBar: AppBar(title: const Text('语音模型配置')),
      body: Column(
        children: [
          // 说明
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text('语音通话模型', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700])),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '选择用于AI语音通话的模型。建议选择响应速度快的模型以获得更好的通话体验。\n\n'
                  '当前通话方式：语音识别 → AI回复 → 语音合成',
                  style: TextStyle(fontSize: 13, color: Colors.blue[600]),
                ),
              ],
            ),
          ),

          // 模型列表
          Expanded(
            child: configs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.smart_toy_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('未配置AI模型', style: TextStyle(color: Colors.grey[500])),
                        const SizedBox(height: 8),
                        Text('请先在「我的 → AI模型配置」添加模型', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: configs.length,
                    itemBuilder: (context, index) {
                      final config = configs[index];
                      final isSelected = config.id == currentVoiceId;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected
                              ? BorderSide(color: AppColors.primary, width: 2)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? AppColors.primary : Colors.grey[200],
                            child: Icon(
                              Icons.record_voice_over,
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                          ),
                          title: Text(config.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          subtitle: Text('${config.modelName} · ${config.protocol == ApiProtocol.openaiCompatible ? "OpenAI" : "Anthropic"}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: AppColors.primary)
                              : Icon(Icons.chevron_right, color: Colors.grey[400]),
                          onTap: () {
                            ConfigService.voiceConfigId = config.id;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('已切换语音模型为「${config.name}」')),
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
          ),

          // 恢复默认
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ConfigService.voiceConfigId = '';
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已恢复为使用默认模型')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('恢复默认（使用对话模型）'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
