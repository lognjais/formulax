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

  /// Returns the RAW encrypted bytes for each data file. Decryption is done in
  /// the parse isolate (see FormulaProvider) so ~2MB of AES never blocks the UI
  /// thread at startup.
  Future<List<Uint8List>> loadData() async {
    final dir = await getApplicationDocumentsDirectory();
    final prefs = await SharedPreferences.getInstance();

    String? localVersion = prefs.getString(_currentVersionKey);
    bool hasLocalUpdate = localVersion != null;

    List<Uint8List> encrypted = [];

    if (hasLocalUpdate) {
      try {
        debugPrint("📂 Loading Data from Local Storage ($localVersion)...");
        for (String file in _files) {
          final filePtr = File('${dir.path}/$file.enc');
          if (await filePtr.exists()) {
            encrypted.add(await filePtr.readAsBytes());
          } else {
            throw Exception("Missing file: $file.enc");
          }
        }
      } catch (e) {
        debugPrint(
            "⚠️ Local data corrupted/missing ($e). Reverting to assets.");
        encrypted.clear();
      }
    }

    if (encrypted.isEmpty) {
      debugPrint("📦 Loading Data from Bundled Assets (Default)...");
      encrypted = await Future.wait(_files.map((f) async {
        final bd = await rootBundle.load('assets/data/$f.enc');
        return bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
      }));
    }

    _checkForUpdates(localVersion);

    return encrypted;
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

      // Collect the expected encrypted files from the archive.
      final pending = <String, Uint8List>{};
      for (final file in archive) {
        if (file.isFile && _files.any((base) => file.name == '$base.enc')) {
          pending[file.name] = Uint8List.fromList(file.content as List<int>);
        }
      }
      if (pending.length != _files.length) {
        debugPrint(
            "⚠️ Update incomplete (${pending.length}/${_files.length} files). Aborting; keeping current data.");
        return;
      }

      // VALIDATE before committing: every file must decrypt + parse as a
      // non-empty JSON list. Prevents a bad release from corrupting the cache.
      for (final entry in pending.entries) {
        try {
          final decoded = json.decode(DataCrypto.decryptBytes(entry.value));
          if (decoded is! List || decoded.isEmpty) {
            throw Exception("not a formula list");
          }
        } catch (e) {
          debugPrint(
              "❌ Update validation failed for ${entry.key} ($e). Aborting; keeping current data.");
          return;
        }
      }

      // All valid — now write atomically-ish and only then bump the version tag.
      final dir = await getApplicationDocumentsDirectory();
      for (final entry in pending.entries) {
        final outFile = File('${dir.path}/${entry.key}');
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(entry.value);
        debugPrint("📝 Updated: ${entry.key}");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentVersionKey, newVersion);

      debugPrint("🎉 Update installed successfully! Restart app to apply.");
    } catch (e) {
      debugPrint("❌ Failed to install update: $e");
    }
  }
}
