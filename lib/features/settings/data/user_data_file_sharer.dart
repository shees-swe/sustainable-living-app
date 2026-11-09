import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class UserDataFileSharer {
  const UserDataFileSharer();

  Future<ShareResult> shareExport(Map<String, Object?> export) async {
    final temporaryDirectory = await getTemporaryDirectory();
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      RegExp(r'[:.]'),
      '-',
    );
    final file = File(
      p.join(
        temporaryDirectory.path,
        'sustainable-living-export-$timestamp.json',
      ),
    );
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(export),
      flush: true,
    );
    try {
      return await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Sustainable Living Guide data export',
        ),
      );
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
