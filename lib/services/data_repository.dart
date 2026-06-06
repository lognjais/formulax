import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive.dart';
import '../core/app_config.dart';
import '../core/crypto.dart';

class DataRepository {
  static const String _currentVersionKey = "data_version_tag";

  final List<String> _files = [
    'physics.json',
    'chemistry.json',
    'math.json',
    'biology.json'
  ];

  Future<Map<String, List<String>>> loadSynonyms() async {
    try {
      final raw = await rootBundle.loadString('assets/data/synonyms.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, (v as List).cast<String>()),
      );
    } catch (e) {
      debugPrint("⚠️ Failed to load synonyms: $e");
      return const {};
    }
  }

  Future<List<String>> loadData() async {
    final dir = await getApplicationDocumentsDirectory();
    final prefs = await SharedPreferences.getInstance();

    String? localVersion = prefs.getString(_currentVersionKey);
    bool hasLocalUpdate = localVersion != null;

    List<String> jsonStrings = [];

    if (hasLocalUpdate) {
      try {
        debugPrint("📂 Loading Data from Local Storage ($localVersion)...");
        for (String file in _files) {
          final filePtr = File('${dir.path}/$file.enc');
          if (await filePtr.exists()) {
            jsonStrings.add(DataCrypto.decryptBytes(await filePtr.readAsBytes()));
          } else {
            throw Exception("Missing file: $file.enc");
          }
        }
      } catch (e) {
        debugPrint(
            "⚠️ Local data corrupted/missing ($e). Reverting to assets.");

        jsonStrings.clear();
      }
    }

    if (jsonStrings.isEmpty) {
      debugPrint("📦 Loading Data from Bundled Assets (Default)...");
      jsonStrings = await Future.wait(_files.map((f) async {
        final bd = await rootBundle.load('assets/data/$f.enc');
        return DataCrypto.decryptBytes(
            bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes));
      }));
    }

    _checkForUpdates(localVersion);

    return jsonStrings;
  }

  Future<void> _checkForUpdates(String? currentVersion) async {
    try {
      final url = Uri.parse(
          "https://api.github.com/repos/${AppConfig.dataRepoOwner}/${AppConfig.dataRepoName}/releases/latest");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final releaseData = json.decode(response.body);
        final String latestTag = releaseData['tag_name'];

        if (currentVersion == null || latestTag != currentVersion) {
          debugPrint(
              "🚀 New Data Update Found: $latestTag (Current: $currentVersion)");
          await _downloadAndInstallUpdate(releaseData['assets'], latestTag);
        } else {
          debugPrint("✅ Data is up to date ($latestTag).");
        }
      }
    } catch (e) {
      debugPrint("❌ Update check failed: $e");
    }
  }

  Future<void> _downloadAndInstallUpdate(
      List<dynamic> assets, String newVersion) async {
    try {
      final asset = assets.firstWhere(
        (a) => a['name'] == 'data.zip',
        orElse: () => null,
      );

      if (asset == null) {
        debugPrint("⚠️ 'data.zip' not found in release assets.");
        return;
      }

      final downloadUrl = asset['browser_download_url'];
      debugPrint("⬇️ Downloading update from: $downloadUrl");

      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode != 200) throw Exception("Download failed");

      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      final dir = await getApplicationDocumentsDirectory();

      for (final file in archive) {
        if (file.isFile) {
          if (_files.any((base) => file.name == '$base.enc')) {
            final outFile = File('${dir.path}/${file.name}');

            await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content as List<int>);
            debugPrint("📝 Updated: ${file.name}");
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentVersionKey, newVersion);

      debugPrint("🎉 Update installed successfully! Restart app to apply.");
    } catch (e) {
      debugPrint("❌ Failed to install update: $e");
    }
  }
}
