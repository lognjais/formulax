import 'dart:io';
import 'package:archive/archive.dart';
import 'package:formulax/core/crypto.dart';

/// Build-time encryptor. Reads plaintext subject JSON (source of truth in the
/// repo), writes AES-encrypted `*.json.enc` (bundled into the app) and an
/// encrypted `build/data.zip` (uploaded as the OTA release asset).
///
/// Run: `dart run tool/encrypt_assets.dart`
void main() {
  const files = ['physics', 'chemistry', 'math', 'biology'];
  final archive = Archive();
  for (final f in files) {
    final plain = File('assets/data/$f.json').readAsStringSync();
    final bytes = DataCrypto.encryptString(plain);
    File('assets/data/$f.json.enc').writeAsBytesSync(bytes);
    // Round-trip self-check: decrypt what we just wrote and compare.
    final back = DataCrypto.decryptBytes(
        File('assets/data/$f.json.enc').readAsBytesSync());
    if (back != plain) {
      stderr.writeln('ROUND-TRIP FAILED for $f');
      exit(1);
    }
    archive.addFile(ArchiveFile('$f.json.enc', bytes.length, bytes));
    stdout.writeln('encrypted $f.json -> $f.json.enc (${bytes.length} bytes, round-trip OK)');
  }
  Directory('build').createSync(recursive: true);
  final zip = ZipEncoder().encode(archive);
  if (zip == null) {
    stderr.writeln('zip encode failed');
    exit(1);
  }
  File('build/data.zip').writeAsBytesSync(zip);
  stdout.writeln('wrote encrypted build/data.zip (${zip.length} bytes)');
}
