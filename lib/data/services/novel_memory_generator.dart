import 'package:novel_ide/data/datasources/database_helper.dart';
import 'package:novel_ide/data/repositories/material_repository.dart';
import 'package:novel_ide/data/repositories/chapter_repository.dart';
import 'package:novel_ide/data/repositories/volume_repository.dart';

/// Generates a structured "novel memory" file that any AI can read
/// to understand the current state of a novel project.
class NovelMemoryGenerator {
  /// Generate the memory file content.
  static Future<String> generate(String novelId, String novelTitle) async {
    final buf = StringBuffer();
    final db = await DatabaseHelper().database;
    final chapterRepo = ChapterRepository();
    final volumeRepo = VolumeRepository();
    final matRepo = MaterialRepository();

    buf.writeln('╔══════════════════════════════════════════╗');
    buf.writeln('║        小说记忆文件 (Novel Memory)        ║');
    buf.writeln('╚══════════════════════════════════════════╝');
    buf.writeln();

    // --- 1. Novel info ---
    buf.writeln('═══ 1. 作品信息 ═══');
    final novels = await db.query('novels', where: 'id = ?', whereArgs: [novelId]);
    if (novels.isNotEmpty) {
      final novel = novels.first;
      buf.writeln('书名: $novelTitle');
      buf.writeln('分类: ${novel['category'] ?? "未分类"}');
      buf.writeln('总字数: ${novel['total_word_count'] ?? 0}');
      buf.writeln('总章数: ${novel['chapter_count'] ?? 0}');
      final desc = novel['description'] as String?;
      if (desc != null && desc.isNotEmpty) {
        buf.writeln('主线大纲: $desc');
      }
    }
    buf.writeln();

    // --- 2. Volume structure ---
    buf.writeln('═══ 2. 卷章结构 ═══');
    final volumes = await volumeRepo.getVolumesByNovel(novelId);
    final chapters = await chapterRepo.getChaptersByNovel(novelId);

    if (volumes.isNotEmpty) {
      for (final vol in volumes) {
        buf.writeln('【${vol.title}】');
        if (vol.summary != null && vol.summary!.isNotEmpty) {
          buf.writeln('  卷纲要: ${vol.summary}');
        }
        final volChapters = chapters.where((c) => c.volumeId == vol.id).toList();
        for (final ch in volChapters) {
          buf.writeln('  ${ch.orderIndex}. ${ch.title} (${ch.wordCount}字) [${ch.status}]');
        }
        buf.writeln();
      }
    } else {
      buf.writeln('（未分卷，共${chapters.length}章）');
      for (final ch in chapters) {
        buf.writeln('  ${ch.orderIndex}. ${ch.title} (${ch.wordCount}字) [${ch.status}]');
      }
      buf.writeln();
    }

    // --- 3. Latest chapter summary ---
    buf.writeln('═══ 3. 最近章节摘要 ═══');
    final recentChapters = chapters.take(5).toList();
    for (final ch in recentChapters) {
      buf.writeln('【${ch.title}】');
      if (ch.summary != null && ch.summary!.isNotEmpty) {
        buf.writeln('  ${ch.summary}');
      } else {
        buf.writeln('  （无摘要）');
      }
    }
    buf.writeln();

    // --- 4. Characters ---
    buf.writeln('═══ 4. 角色状态 ═══');
    final characters = await matRepo.getCharacters(novelId);
    if (characters.isNotEmpty) {
      for (final c in characters) {
        buf.writeln('【${c.name}】${c.role != null ? " (${c.role})" : ""}');
        if (c.description != null && c.description!.isNotEmpty) {
          buf.writeln('  简介: ${c.description}');
        }
        if (c.personality != null && c.personality!.isNotEmpty) {
          buf.writeln('  性格: ${c.personality}');
        }
        if (c.background != null && c.background!.isNotEmpty) {
          buf.writeln('  背景: ${c.background}');
        }
        if (c.tags.isNotEmpty) {
          buf.writeln('  标签: ${c.tags.map((t) => "${t.key}=${t.value}").join(", ")}');
        }
      }
    } else {
      buf.writeln('（暂无角色卡）');
    }
    buf.writeln();

    // --- 5. Settings / World building ---
    buf.writeln('═══ 5. 设定状态 ═══');
    final settings = await matRepo.getSettingCards(novelId);
    if (settings.isNotEmpty) {
      for (final s in settings) {
        buf.writeln('【${s.name}】${s.category != null ? " (${s.category})" : ""}');
        if (s.description != null && s.description!.isNotEmpty) {
          buf.writeln('  ${s.description}');
        }
        if (s.tags.isNotEmpty) {
          buf.writeln('  属性: ${s.tags.map((t) => "${t.key}=${t.value}").join(", ")}');
        }
      }
    } else {
      buf.writeln('（暂无设定卡）');
    }
    buf.writeln();

    // --- 6. Locations ---
    buf.writeln('═══ 6. 地点 ═══');
    final locations = await matRepo.getLocations(novelId);
    if (locations.isNotEmpty) {
      for (final l in locations) {
        buf.writeln('【${l.name}】${l.category != null ? " (${l.category})" : ""}');
        if (l.description != null && l.description!.isNotEmpty) buf.writeln('  ${l.description}');
        if (l.rules != null && l.rules!.isNotEmpty) buf.writeln('  规则: ${l.rules}');
      }
    } else {
      buf.writeln('（暂无地点）');
    }
    buf.writeln();

    // --- 7. Factions ---
    buf.writeln('═══ 7. 势力 ═══');
    final factions = await matRepo.getFactions(novelId);
    if (factions.isNotEmpty) {
      for (final f in factions) {
        buf.writeln('【${f.name}】${f.category != null ? " (${f.category})" : ""}');
        if (f.description != null && f.description!.isNotEmpty) buf.writeln('  ${f.description}');
        if (f.leader != null) buf.writeln('  首领: ${f.leader}');
        if (f.members.isNotEmpty) buf.writeln('  成员: ${f.members.join("、")}');
      }
    } else {
      buf.writeln('（暂无势力）');
    }
    buf.writeln();

    // --- 8. Items ---
    buf.writeln('═══ 8. 重要道具 ═══');
    final items = await matRepo.getItems(novelId);
    if (items.isNotEmpty) {
      for (final i in items) {
        final marker = i.isKeyItem ? " ⭐" : "";
        buf.writeln('【${i.name}】${i.category != null ? " (${i.category})" : ""}$marker');
        if (i.description != null && i.description!.isNotEmpty) buf.writeln('  ${i.description}');
        if (i.powerLevel != null) buf.writeln('  品阶: ${i.powerLevel}');
        if (i.owner != null) buf.writeln('  持有者: ${i.owner}');
      }
    } else {
      buf.writeln('（暂无道具）');
    }
    buf.writeln();

    // --- 9. Hooks (Foreshadowing) ---
    buf.writeln('═══ 9. 伏笔追踪 ═══');
    final hooks = await matRepo.getPlotHooks(novelId);
    if (hooks.isNotEmpty) {
      final unresolved = hooks.where((h) => !h.isRevealed).toList();
      final resolved = hooks.where((h) => h.isRevealed).toList();
      buf.writeln('【未回收伏笔】(${unresolved.length}条)');
      for (final h in unresolved) {
        final warning = h.idleChapters > 10 ? ' ⚠️闲置${h.idleChapters}章' : '';
        buf.writeln('  · ${h.title}$warning');
        if (h.description != null && h.description!.isNotEmpty) {
          buf.writeln('    ${h.description}');
        }
      }
      buf.writeln('【已回收伏笔】(${resolved.length}条)');
      for (final h in resolved) {
        buf.writeln('  ✓ ${h.title}');
      }
    } else {
      buf.writeln('（暂无伏笔）');
    }
    buf.writeln();

    // --- 10. References ---
    buf.writeln('═══ 10. 参考资料 ═══');
    final refs = await matRepo.getReferences(novelId);
    if (refs.isNotEmpty) {
      for (final r in refs) {
        buf.writeln('· ${r.title}');
        if (r.source != null) buf.writeln('  来源: ${r.source}');
      }
    } else {
      buf.writeln('（暂无参考资料）');
    }
    buf.writeln();

    buf.writeln('═══════════════════════════════════════════');
    buf.writeln('记忆文件生成时间: ${DateTime.now().toString().substring(0, 19)}');
    buf.writeln('═══════════════════════════════════════════');

    return buf.toString();
  }
}
