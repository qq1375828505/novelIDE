import 'dart:convert';

/// 写作技能模型
class WritingSkill {
  final String id;
  String name;
  String category;
  String description;
  String content; // 技能详细内容/prompt
  bool isEnabled;
  bool isBuiltIn; // 是否为内置技能
  final DateTime createdAt;
  final DateTime updatedAt;

  WritingSkill({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.content,
    this.isEnabled = true,
    this.isBuiltIn = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory WritingSkill.fromJson(Map<String, dynamic> json) {
    return WritingSkill(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? '通用',
      description: json['description'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? true,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'content': content,
      'isEnabled': isEnabled,
      'isBuiltIn': isBuiltIn,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 获取所有内置技能
  static List<WritingSkill> get builtInSkills => [
    WritingSkill(
      id: 'builtin_hook_design',
      name: '伏笔设计',
      category: '剧情技巧',
      description: '如何设计引人入胜的伏笔，包括埋设时机、回收节奏、多层伏笔嵌套',
      isBuiltIn: true,
      content: '''【伏笔设计技巧】

1. 埋设原则：
- 伏笔要自然融入剧情，不能刻意
- 读者第一遍读时不应察觉，回看时恍然大悟
- 重要的伏笔至少提前3-5章埋设

2. 回收节奏：
- 短期伏笔：3-5章内回收，制造即时爽感
- 中期伏笔：10-20章回收，推动剧情转折
- 长期伏笔：贯穿整卷甚至全书，作为大高潮引爆点

3. 嵌套技巧：
- 明线伏笔 + 暗线伏笔双重布局
- 用看似无关的细节掩盖关键伏笔
- 同一伏笔在不同阶段揭示不同层面

4. 注意事项：
- 记录每个伏笔的埋设位置和预计回收位置
- 避免伏笔过多导致读者遗忘
- 闲置超过10章的伏笔应尽快安排回收''',
    ),
    WritingSkill(
      id: 'builtin_pacing',
      name: '节奏把控',
      category: '结构技巧',
      description: '网文节奏控制方法，包括张弛有度、高潮设置、低谷过渡',
      isBuiltIn: true,
      content: '''【节奏把控技巧】

1. 基本节奏模式：
- 紧张→释放→铺垫→高潮→余韵（五段式循环）
- 每3-5章一个小高潮，每15-20章一个大高潮
- 高潮之后必须有1-2章的缓冲/日常过渡

2. 章节节奏：
- 开头200字：承接上章悬念或制造新冲突
- 中段：推进主线+支线穿插
- 结尾：留下悬念或反转，吸引读者点下一章

3. 张弛有度：
- 连续高潮不超过3章，读者会疲劳
- 日常/轻松章节穿插在紧张剧情中
- 战斗/冲突后安排角色互动放松

4. 节奏信号：
- 加速：短句、快节奏对话、多场景切换
- 减速：长句、环境描写、内心独白
- 停顿：章节末尾留白、时间跳跃''',
    ),
    WritingSkill(
      id: 'builtin_dialogue',
      name: '对话写作',
      category: '文笔技巧',
      description: '写出有个性、推动剧情的对话，避免千篇一律',
      isBuiltIn: true,
      content: '''【对话写作技巧】

1. 角色个性化：
- 每个角色有独特的说话方式（口头禅、用词习惯、语气）
- 身份地位影响措辞（皇帝用朕、武将直爽、文人文雅）
- 情绪变化时说话方式也要变化

2. 对话推动剧情：
- 对话中传递信息，避免"为说而说"
- 通过对话揭示角色关系和冲突
- 对话中设置悬念和伏笔

3. 技巧：
- 少用"说道"，多用动作/表情代替提示语
- 对话要留白，不要把话说尽
- 适当加入沉默、停顿、动作描写

4. 格式：
- 一段对话不宜超过3-4轮
- 穿插动作描写和内心活动
- 重要对话单独成段，增强感染力''',
    ),
    WritingSkill(
      id: 'builtin_description',
      name: '场景描写',
      category: '文笔技巧',
      description: '写出有画面感的场景描写，调动读者五感',
      isBuiltIn: true,
      content: '''【场景描写技巧】

1. 五感描写法：
- 视觉：色彩、光影、动态
- 听觉：环境音、对话声、战斗声
- 嗅觉：气味（花香、血腥、药香）
- 触觉：温度、质感、疼痛
- 味道：食物、毒药、灵气

2. 描写原则：
- 不要流水账式罗列，选择最有特征的2-3个细节
- 动静结合，静态场景加入动态元素
- 以角色感受为视角，不要上帝视角

3. 场景切换：
- 用感官变化过渡（温度骤降→进入秘境）
- 用角色反应带出新环境
- 重要场景首次出现时详细描写，后续简略

4. 战斗场景：
- 快节奏短句，突出力量感和速度感
- 招式描写不宜过长，重点写效果和反应
- 穿插角色心理活动增加深度''',
    ),
    WritingSkill(
      id: 'builtin_suspense',
      name: '悬念设置',
      category: '剧情技巧',
      description: '制造悬念吸引读者持续阅读，包括章末钩子、反转设计',
      isBuiltIn: true,
      content: '''【悬念设置技巧】

1. 章末钩子类型：
- 危机型：主角陷入绝境
- 转折型：意外信息出现
- 悬念型：即将揭晓的秘密
- 冲突型：矛盾激化到临界点

2. 反转设计：
- 铺垫要充分，反转才有说服力
- 最好的反转是回看有迹可循
- 避免为反转而反转，要服务于剧情

3. 信息差悬念：
- 读者知道角色不知道→紧张感
- 角色知道读者不知道→好奇心
- 双方都不知道→探索欲

4. 注意事项：
- 每章结尾必须有钩子
- 不要每章都用同类型钩子
- 大悬念下设置小悬念，层层递进''',
    ),
    WritingSkill(
      id: 'builtin_character_design',
      name: '角色塑造',
      category: '角色技巧',
      description: '塑造立体丰满的角色，包括性格、成长弧线、记忆点',
      isBuiltIn: true,
      content: '''【角色塑造技巧】

1. 角色立体化：
- 优点+缺点并存，避免完美或纯粹反派
- 给每个角色一个核心动机
- 过去经历影响当前行为

2. 成长弧线：
- 主角要有明确的成长轨迹
- 成长不是突变，要有铺垫和触发事件
- 偶尔倒退和迷茫让角色更真实

3. 角色记忆点：
- 外貌特征（标志性发型/服饰/伤疤）
- 口头禅或习惯动作
- 独特的价值观或信条

4. 角色关系：
- 角色之间要有化学反应
- 配角也要有自己的故事线
- 对手/反派的动机要合理''',
    ),
  ];
}
