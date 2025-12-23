import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

class BackupService {
  static Future<File> exportZip() async {
    final dir = await getApplicationDocumentsDirectory();
    final zipPath = '${dir.path}/backup.zip';
    final encoder = ZipFileEncoder()..create(zipPath);
    encoder.addDirectory(dir);
    encoder.close();
    return File(zipPath);
  }
}
