import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:novel_ide/data/datasources/local_file_datasource.dart';

/// 备份服务 - 打包所有数据生成压缩包
class BackupService {
  /// 执行备份，返回备份文件路径
  static Future<String?> backup() async {
    try {
      // 让用户选择保存位置
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择备份保存位置',
      );
      if (result == null) return null;

      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final backupFileName = 'NovelIDE_备份_$timestamp.zip';
      final backupPath = p.join(result, backupFileName);

      // 获取项目目录
      final fs = LocalFileDataSource();
      final baseDir = await fs.getBaseDir();

      final projectDir = Directory(p.join(baseDir.path, 'NovelProjects'));
      if (!await projectDir.exists()) return null;

      // 创建压缩包
      final archive = Archive();

      // 遍历所有文件
      await for (final entity in projectDir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = p.relative(entity.path, from: projectDir.path);
          final bytes = await entity.readAsBytes();
          final file = ArchiveFile(relativePath, bytes.length, bytes);
          archive.addFile(file);
        }
      }

      // 同时备份数据库（使用 sqflite 的 getDatabasesPath）
      final dbDir = await getDatabasesPath();
      final dbPath = p.join(dbDir, 'novel_ide.db');
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        final dbBytes = await dbFile.readAsBytes();
        archive.addFile(ArchiveFile('database/novel_ide.db', dbBytes.length, dbBytes));
      }

      // 编码为ZIP
      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) return null;

      // 写入文件
      final zipFile = File(backupPath);
      await zipFile.writeAsBytes(zipData);

      return backupPath;
    } catch (e) {
      return null;
    }
  }
}
