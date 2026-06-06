import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:formulax/core/crypto.dart';

/// Verifies the on-device load path: each bundled `*.json.enc` decrypts to JSON
/// that parses and matches the plaintext source 1:1. Guards against a key/format
/// drift between the build-time encryptor and the runtime loader.
void main() {
  const files = ['physics', 'chemistry', 'math', 'biology'];

  test('encrypted assets decrypt + parse and match plaintext', () {
    for (final f in files) {
      final enc = File('assets/data/$f.json.enc');
      expect(enc.existsSync(), isTrue, reason: '$f.json.enc must be built');
      final decrypted = DataCrypto.decryptBytes(enc.readAsBytesSync());
      final list = json.decode(decrypted) as List<dynamic>;
      final plain =
          json.decode(File('assets/data/$f.json').readAsStringSync()) as List<dynamic>;
      expect(list.length, plain.length, reason: '$f count mismatch after decrypt');
      expect(decrypted, File('assets/data/$f.json').readAsStringSync(),
          reason: '$f decrypted bytes must equal source exactly');
    }
  });

  test('crypto round-trips arbitrary content', () {
    const sample = r'{"x":"E=mc^2 \\frac{a}{b} ünïçødé 🚀"}';
    expect(DataCrypto.decryptBytes(DataCrypto.encryptString(sample)), sample);
  });
}
