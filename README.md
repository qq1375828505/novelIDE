# 网文写作IDE - Android

> 🚀 完全单机运行的网文写作IDE。双编辑器 · AI写作助手 · 富文本排版 · 8种主题 · 文章校对 · EPUB导出

[![GitHub Release](https://img.shields.io/github/v/release/qq1375828505/DAXIE666)](https://github.com/qq1375828505/DAXIE666/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.29+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📥 下载安装

最新版：**V1.4.0** — [直接下载 APK](https://github.com/qq1375828505/DAXIE666/releases/download/v1.4.0/novel-ide-android-v1.4.0.apk)

> 支持 Android 6.0+（minSdk 23），无需注册，安装即用。完全单机，不联网也能写。

---

## ✨ 功能特色

### 📝 双编辑器 — 随心切换

| | 纯文本编辑器 | WebView 富文本编辑器 |
|---|---|---|
| **定位** | 轻量极速，适合专注码字 | 专业排版，适合发布级作品 |
| **格式** | 纯文本 + Markdown | 加粗、斜体、H1/H2标题、引用块、有序/无序列表 |
| **插入** | 文字输入 | 图片、视频、超链接、@提及角色、#话题标签 |
| **工具栏** | 9按钮可滚动快捷栏 | 格式工具栏（B/I/H1/H2/引用/列表/链接/图片/撤销/重做） |
| **校对** | 文章校对引擎 | 文章校对引擎（共用） |
| **来源** | Flutter 原生 TextField | 复用起点作家 App 的 rich_editor.js（63KB成熟引擎） |

### 🔍 全文搜索与替换

- **跨章节全局搜索** — 输入关键词，扫描全部章节标题和正文，逐章逐行匹配
- **黄色高亮** — 搜索结果中关键词高亮显示
- **逐条替换** — 选中某条结果，点击替换按钮，单条替换
- **全部替换** — 一键替换当前关键词的所有匹配项
- **搜索导航** — 上一条/下一条快速跳转，显示 `当前/总数` 进度

### 📖 文章校对引擎

- **错别字检测** — 60+ 常见同音字/形近字词库，例如：莫明其妙→莫名其妙、迫不急待→迫不及待
- **标点修正** — 重复标点简化（`。。` → `……`）、中英文标点混用检测
- **重复用字** — 正则检测连续重复字（如"的的的"），自动标红
- **分类筛选** — 校对结果按"错别字/标点/建议"三种类型分类，可筛选查看
- **上下文显示** — 每条结果显示"原文→建议"+ 前后各20字上下文

### 🤖 AI 写作助手

**AI 对话**
- 独立 Tab 页面，支持多个对话会话
- 自动上下文压缩（40条消息后自动压缩，避免 token 超限）
- 支持发送图片附件（文件选择器选取）
- 25个番茄风格预设（都市/玄幻/穿越/悬疑/女频），覆盖主流网文风格

**编辑器内 AI 操作**
- 长按选中文字 → 右键菜单 → 润色/扩写/续写/联网查证
- 一键精修 — 8维度审查（语病/节奏/文风/冗余/对话/描写/钩子/战力），逐条审核采纳或跳过
- 全文审查 — 设定冲突检测、战力一致性、伏笔追踪、角色一致性
- 爽点密度报告 / 水文检测报告 / 爆款标题生成

**自定义 Agent**
- Agent 市场 — 内置番茄专区智能体
- 自定义创建 — 设置 Agent 名称、系统提示词、参数模板
- 从 JSON 文件导入已有 Agent

**多模型支持**
- OpenAI 兼容协议（GPT / DeepSeek / 通义千问 / 本地 Ollama 等）
- Anthropic 协议（Claude Sonnet / Opus）
- 每个模型独立配置 API 地址、密钥、模型名
- 一键测试连接 + 获取模型列表
- 模型间自由切换

### 📚 资料管理系统（8种资料类型）

| 类型 | 说明 |
|------|------|
| 角色卡 | 名字、定位、外貌、性格、背景、AI生成头像 |
| 设定卡 | 世界观、魔法体系、科技树、社会规则 |
| 地点 | 城市、宗门、秘境，含分类和特征 |
| 势力 | 门派、国家、组织，含成员列表和实力等级 |
| 道具 | 武器、法宝、丹药，含品阶和持有者 |
| 伏笔 | 伏笔标题、描述、状态（已埋/已回收）、闲置章数 |
| 参考资料 | 搜索结果保存、灵感笔记 |
| AI 记忆文件 | 自动维护的小说上下文状态，AI对话时自动注入 |

### 📦 导入导出

**导出**
- **EPUB 电子书** — 标准 EPUB 3.0 格式，按卷/章组织目录，含 CSS 样式，可用 Kindle / Apple Books / Calibre 打开
- **ZIP 打包** — 选中章节 + 10种资料类型自由勾选，打包为 ZIP 文件
- **保存到本地** — 通过 FilePicker 选择手机存储位置
- **系统分享** — 通过 QQ / 微信 / 蓝牙 等发送

**导入**
- `.novelpack` 完整作品包 — 解压导入，保留全部结构
- `.txt` / `.md` / `.docx` 文本文件 — 自动识别章节分隔符，智能拆章，自动创建新作品

### 🎨 8种主题皮肤

| 主题 | 风格 | 适合场景 |
|------|------|---------|
| 白色 | 纯净简洁，紫蓝主色调 | 日常写作（默认） |
| 黑色 | 深邃护眼，紫光点缀 | 夜间写作 |
| 蓝色护眼 | 柔和蓝色，降低视觉疲劳 | 长时间码字 |
| 黄色暖光 | 温暖惬意的暖黄色调 | 咖啡厅/沙发写作 |
| 绿色清新 | 自然养眼的清新绿 | 办公室/教室 |
| 粉色 | 甜美浪漫的粉色调 | 言情/女频创作 |
| 日系木色 | 素雅淡然的木质色 | 散文/文艺创作 |
| 红色热情 | 热血激情的红色调 | 玄幻/战斗创作 |

每种主题独立定义 primary / secondary / background / surface / text 等13个色值，在设置页网格卡片一键切换，自动持久化。

### 🛠️ 编辑器增强功能

- **快捷操作栏** — 底部可滚动9按钮工具栏（撤销 / 重做 / 查找 / 替换 / AI / 语音 / 快词 / 保存 / 设置）
- **快捷短语面板** — 一键插入常用标点（`……` `——` `「」` `『』` `【】` 等）
- **语音输入** — 中文语音转文字，免打字创作
- **自动保存** — 1.5秒延迟防抖 + 页面退出强制保存，绝不丢稿
- **历史快照** — 每3分钟自动快照，保留最近20个版本，一键恢复任意版本
- **撤销/重做** — 50步操作历史栈
- **查找替换** — 当前章节内查找，支持逐个跳转
- **章节数超限提醒** — 超过10000字黄色警告，超过15000字红色建议拆章
- **设定提醒** — 扫描小说设定，自动检测角色名冲突、时间线矛盾等
- **字数统计** — 实时字数 + 每日写作统计图表（fl_chart柱状图）+ 连续打卡天数 + 每日目标进度条

### 📂 作品与大纲管理

**作品**
- 作品列表 — 展示封面、书名、字数、章节数、更新时间
- 新建 / 重命名 / 删除作品
- 每部作品独立存储为 Markdown 源文件

**大纲**
- 主线大纲编辑区 — 自由撰写故事主线
- 多卷管理 — 新建卷、拖拽排序
- 多章管理 — 新建章节、拖拽排序、状态切换（草稿/进行中/已完成/已定稿）
- 大纲与正文关联 — 章节梗概绑定到具体章节

### 🔒 隐私与安全

- **完全单机** — 所有数据存储在手机本地，不依赖任何后端服务器
- **API Key 加密** — 使用 Android Keystore + flutter_secure_storage 加密存储
- **19项权限声明** — 运行时逐项授权，透明可控
- **离线模式** — 断网时自动切换，AI功能暂停，写作/编辑/保存不受影响

---

## 🏗️ 技术栈

| 技术 | 用途 |
|------|------|
| Flutter 3.29+ / Dart | 跨平台 UI 框架 |
| Riverpod | 状态管理（Provider / StateNotifier） |
| sqflite | 本地数据库（7张表：作品/章节/卷/角色/设定/统计/配置） |
| Hive | 主题皮肤持久化 + 配置存储 |
| webview_flutter | 富文本编辑器（加载起点作家 JS 引擎） |
| flutter_secure_storage | API Key 加密存储 |
| Dio | HTTP 请求（OpenAI / Anthropic 多协议） |
| fl_chart | 写作统计柱状图 |
| archive | ZIP 压缩 + EPUB 生成 |
| file_picker | 文件选择（导入/导出） |
| share_plus | 系统分享 |
| speech_to_text | 语音转文字 |
| permission_handler | 运行时权限管理 |

---

## 📂 项目结构

```
lib/
├── main.dart                          # 入口，初始化 Hive/通知/权限
├── core/
│   ├── constants.dart                 # 颜色常量、字符串常量
│   ├── router.dart                    # 路由表（editor/richEditor/search/agents）
│   └── theme/
│       ├── app_themes.dart            # 8种 SkinTheme 定义 + ThemeData 生成
│       └── skin_provider.dart         # 主题状态（Riverpod + Hive 持久化）
├── data/
│   ├── models/                        # Freezed 数据模型（小说/章节/卷/AI配置/角色等）
│   ├── datasources/                   # DatabaseHelper(SQLite) + LocalFileDataSource + SecureStorage
│   ├── repositories/                  # 数据仓库（小说/章节/卷/素材/统计）
│   ├── presets/                       # 25个番茄风格预设数据
│   └── services/
│       ├── ai_service.dart            # AI 多协议调用（OpenAI兼容 + Anthropic）
│       ├── ai_analysis_service.dart   # AI 全文分析（爽点/水文/冲突检测）
│       ├── proofread_service.dart     # 文章校对引擎（60+错别字 + 标点 + 重复检测）
│       ├── epub_export_service.dart   # EPUB 3.0 电子书导出
│       ├── novel_import_service.dart  # TXT/MD/DOCX 智能拆章导入
│       ├── novel_memory.dart          # 小说记忆文件（自动维护上下文）
│       ├── config_service.dart        # 配置读写
│       ├── connectivity_service.dart  # 网络状态监控
│       └── notification_service.dart  # 本地通知（字数目标/每日提醒）
├── presentation/
│   ├── state/                         # Riverpod Providers（小说/章节/编辑器/AI/统计/设置）
│   └── pages/
│       ├── writing/
│       │   ├── writing_page.dart      # 写作入口
│       │   ├── editor_page.dart       # 纯文本编辑器（9按钮工具栏 + AI抽屉 + 语音）
│       │   ├── rich_editor_page.dart  # WebView 富文本编辑器（格式工具栏 + FlutterBridge）
│       │   ├── global_search_page.dart # 跨章节全局搜索替换
│       │   └── proofread_page.dart    # 文章校对结果展示（分类筛选 + 高亮）
│       ├── works/
│       │   ├── works_page.dart        # 作品列表 + 文件导入
│       │   ├── novel_detail_page.dart # 作品详情（卷管理 + 长按菜单）
│       │   └── export_page.dart       # 导出页（EPUB + ZIP，章节+资料勾选）
│       ├── outline/
│       │   └── outline_page.dart      # 大纲管理（主线编辑 + 卷章拖拽排序）
│       ├── materials/
│       │   └── materials_page.dart    # 资料管理（8个Tab）
│       ├── profile/
│       │   ├── profile_page.dart      # 设置页（8种主题选择器 + AI模型 + 数据管理）
│       │   └── app_config_page.dart   # JSON 配置编辑器
│       ├── ai/
│       │   ├── ai_chat_page.dart      # AI 对话（多会话 + 历史 + 附件）
│       │   ├── ai_drawer.dart         # 编辑器内 AI 操作抽屉
│       │   ├── polish_engine_page.dart # 一键精修（8维度）
│       │   ├── full_text_review_page.dart # 全文审查
│       │   ├── search_drawer.dart     # 联网搜索抽屉
│       │   └── setting_reminder_page.dart # 设定冲突提醒
│       ├── tomato/
│       │   ├── agent_marketplace_page.dart # Agent 市场（内置+自定义）
│       │   ├── style_selector_bar.dart    # 风格预设选择器
│       │   ├── shuangdian_report_page.dart # 爽点密度报告
│       │   ├── water_report_page.dart     # 水文检测报告
│       │   └── title_generator_result_page.dart # 爆款标题生成
│       └── stats/
│           └── stats_page.dart        # 写作统计（日字数/打卡/柱状图/目标进度）
└── assets/
    └── editor/                        # WebView 编辑器资源（9个文件）
        ├── editor.html                # 编辑器 HTML 主页
        ├── rich_editor.js             # 核心编辑器逻辑（63KB，来自起点作家）
        ├── WeReadApi.js               # JS Bridge 通信层
        ├── style.css                  # 编辑器基础样式
        ├── news.css                   # 主题/字号切换样式
        ├── normalize.css              # CSS 重置
        ├── rich_display.js            # 展示模式（书籍卡片/图片点击）
        ├── style_html.js              # HTML 格式化工具（765行）
        └── article_display.js         # 文章展示脚本
```

---

## 🛠️ 开发运行

```bash
# 1. 克隆项目
git clone https://github.com/qq1375828505/DAXIE666.git

# 2. 安装 Flutter SDK (>=3.29.0)

# 3. 安装依赖
flutter pub get

# 4. 生成 Freezed 代码（首次运行必须）
flutter pub run build_runner build --delete-conflicting-outputs

# 5. 运行（开发模式）
flutter run

# 6. 打包 Release APK
flutter build apk --release
```

### 环境要求

| 项目 | 要求 |
|------|------|
| Flutter SDK | >= 3.29.0 |
| Dart SDK | >= 3.0.0 |
| Android minSdk | 23（Android 6.0） |
| Android compileSdk | 36 |

---

## 💾 数据存储

| 数据 | 存储方式 | 路径 |
|------|---------|------|
| 作品正文 | Markdown 文件 | `NovelProjects/{novelId}_{title}/chapters/*.md` |
| 作品索引 | SQLite 数据库 | `novel_ide.db`（7张表） |
| 主题/配置 | Hive | `settings` box（skin_type / font_size / line_height） |
| API Key | Android Keystore | `flutter_secure_storage` 加密 |
| AI 记忆文件 | 文本文件 | `NovelProjects/memories/{novelId}_memory.txt` |
| 导出文件 | ZIP / EPUB | 用户通过 FilePicker 选择保存位置 |

---

## 📜 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| V1.4.0 | 2026-05 | **大版本更新**：8种主题皮肤 · WebView富文本编辑器 · 跨章节全局搜索 · 文章校对引擎(60+词库) · EPUB电子书导出 · 编辑器9按钮快捷操作栏 · 快捷短语面板 · DOCX自动创建作品导入 · withValues兼容性修复 |
| V1.3.5 | 2026-05 | 修复导出保存到本地失败(FilePicker bytes参数)、修复_showImportDialog类作用域错误 |
| V1.3.4 | 2026-05 | 小说文件导入(TXT/MD/DOCX)、AI智能分析填充资料库、导出全选/全不选、界面交互优化 |
| V1.3.3 | 2026-05 | 修复章节内容丢失Bug、导出保存到本地、dispose强制保存 |
| V1.3.2 | 2026-05 | 运行时权限、卷长按菜单、全页面导出、19项权限声明 |
| V1.3.1 | 2026-05 | 多协议支持(OpenAI+Anthropic)、测试连接、JSON配置文件、上下文压缩 |
| V1.3.0 | 2026-05 | AI对话窗口(独立Tab)、导出系统重写、小说记忆系统 |
| V1.2.0 | 2026-05 | 写作统计图表、全文审查、多模型路由、AgentForge |
| V1.1.0 | 2026-05 | 资料管理扩展(8种)、大纲增强、番茄报告UI |
| V1.0.0 | 2026-05 | 基础框架、作品管理、编辑器、AI基础动作 |

---

## 📄 License

MIT
