import 'package:flutter/material.dart';
import 'package:novel_ide/presentation/pages/main_shell.dart';
import 'package:novel_ide/presentation/pages/writing/editor_page.dart';
import 'package:novel_ide/presentation/pages/writing/rich_editor_page.dart';
import 'package:novel_ide/presentation/pages/writing/global_search_page.dart';
import 'package:novel_ide/presentation/pages/writing/proofread_page.dart';
import 'package:novel_ide/presentation/pages/outline/outline_page.dart';
import 'package:novel_ide/presentation/pages/ai/full_text_review_page.dart';
import 'package:novel_ide/presentation/pages/tomato/agent_marketplace_page.dart';
import 'package:novel_ide/presentation/pages/works/export_page.dart';
import 'package:novel_ide/presentation/pages/materials/materials_tree_page.dart';
import 'package:novel_ide/presentation/pages/stats/stats_page.dart';
import 'package:novel_ide/presentation/pages/profile/profile_page.dart';

class AppRouter {
  static const String home = '/';
  static const String editor = '/editor';
  static const String richEditor = '/rich-editor';
  static const String agents = '/agents';
  static const String globalSearch = '/global-search';
  static const String outline = '/outline';
  static const String proofread = '/proofread';
  static const String fullTextReview = '/full-text-review';
  static const String export = '/export';
  static const String materials = '/materials';
  static const String stats = '/stats';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainShell());
      case editor:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditorPage(
            novelId: args?['novelId'] ?? '',
            chapterId: args?['chapterId'] ?? '',
          ),
        );
      case richEditor:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RichEditorPage(
            novelId: args?['novelId'] ?? '',
            chapterId: args?['chapterId'] ?? '',
            initialTitle: args?['title'] ?? '',
            initialContent: args?['content'] ?? '',
          ),
        );
      case agents:
        return MaterialPageRoute(builder: (_) => const AgentMarketplacePage());
      case globalSearch:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => GlobalSearchPage(
            novelId: args?['novelId'] ?? '',
            novelTitle: args?['novelTitle'] ?? '',
          ),
        );
      case outline:
        return MaterialPageRoute(builder: (_) => const OutlinePage());
      case proofread:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProofreadPage(
            novelId: args?['novelId'] ?? '',
          ),
        );
      case fullTextReview:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => FullTextReviewPage(
            novelId: args?['novelId'] ?? '',
            novelTitle: args?['novelTitle'] ?? '',
          ),
        );
      case export:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExportPage(
            novelId: args?['novelId'] ?? '',
            novelTitle: args?['novelTitle'] ?? '',
          ),
        );
      case materials:
        return MaterialPageRoute(builder: (_) => const MaterialsTreePage());
      case stats:
        return MaterialPageRoute(builder: (_) => const StatsPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(builder: (_) => const MainShell());
    }
  }
}
