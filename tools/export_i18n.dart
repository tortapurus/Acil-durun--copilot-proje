import 'dart:convert';
import 'dart:io';

// Simple i18n exporter: reads assets/lang/*.json and writes tools/i18n_export.csv
// Usage: dart run tools/export_i18n.dart

void main() async {
  final dir = Directory('assets/lang');
  if (!await dir.exists()) {
    stderr.writeln('assets/lang directory not found');
    exit(2);
  }

  final files = await dir
      .list()
      .where((f) => f is File && f.path.toLowerCase().endsWith('.json'))
      .map((f) => f as File)
      .toList();

  if (files.isEmpty) {
    stderr.writeln('No json files found in assets/lang');
    exit(0);
  }

  // map lang code -> map(key->value)
  final Map<String, Map<String, String>> locales = {};
  final Set<String> allKeys = {};

  for (final file in files) {
    final filename = file.uri.pathSegments.last;
    final lang = filename.split('.').first; // tr.json -> tr
    try {
      final content = await file.readAsString();
      final Map<String, dynamic> jsonMap = json.decode(content);
      final map = jsonMap.map((k, v) => MapEntry(k.toString(), v.toString()));
      locales[lang] = map;
      allKeys.addAll(map.keys);
      stdout.writeln('Loaded $filename (${map.length} keys)');
    } catch (e) {
      stderr.writeln('Failed to parse $filename: $e');
    }
  }

  // Prepare CSV
  final langs = locales.keys.toList()..sort();
  final csvFile = File('tools/i18n_export.csv');
  final sink = csvFile.openWrite();

  // Header
  sink.write('key');
  for (final l in langs) sink.write(',"$l"');
  sink.writeln();

  final sortedKeys = allKeys.toList()..sort();
  for (final key in sortedKeys) {
    // escape quotes
    String escape(String? v) {
      if (v == null) return '';
      return '"' + v.replaceAll('"', '""') + '"';
    }

    final row = StringBuffer();
    row.write(key);
    for (final l in langs) {
      final v = locales[l]?[key];
      row.write(',');
      row.write(escape(v));
    }
    sink.writeln(row.toString());
  }

  await sink.flush();
  await sink.close();
  stdout.writeln('Exported ${sortedKeys.length} keys for ${langs.length} locales to ${csvFile.path}');
}
