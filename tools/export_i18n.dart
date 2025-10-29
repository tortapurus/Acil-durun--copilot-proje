import 'dart:convert';
import 'dart:io';

// Simple i18n exporter: reads assets/lang/*.json and writes tools/i18n_export.csv
// Usage: dart run tools/export_i18n.dart

void main(List<String> args) async {
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
  // If called with --import <csvfile>, update JSON files from CSV
  if (args.length >= 2 && args[0] == '--import') {
    final csvPath = args[1];
    final csvFile = File(csvPath);
    if (!await csvFile.exists()) {
      stderr.writeln('CSV file not found: $csvPath');
      exit(2);
    }

    final lines = await csvFile.readAsLines();
    if (lines.isEmpty) {
      stderr.writeln('CSV is empty');
      exit(0);
    }

    List<String> parseCsvLine(String line) {
      final List<String> cols = [];
      final sb = StringBuffer();
      bool inQuotes = false;
      for (int i = 0; i < line.length; i++) {
        final ch = line[i];
        if (ch == '"') {
          // lookahead for escaped quote
          if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
            sb.write('"');
            i++;
            continue;
          }
          inQuotes = !inQuotes;
          continue;
        }
        if (ch == ',' && !inQuotes) {
          cols.add(sb.toString());
          sb.clear();
          continue;
        }
        sb.write(ch);
      }
      cols.add(sb.toString());
      return cols;
    }

    final header = parseCsvLine(lines.first);
    if (header.isEmpty || header[0] != 'key') {
      stderr.writeln('CSV header must start with "key"');
      exit(2);
    }

    final csvLangs = header.sublist(1);
    // build map lang->map
    final Map<String, Map<String, String>> csvLocales = {};
    for (final l in csvLangs) csvLocales[l] = {};

    for (int i = 1; i < lines.length; i++) {
      final cols = parseCsvLine(lines[i]);
      if (cols.isEmpty) continue;
      final key = cols[0];
      for (int j = 1; j < cols.length; j++) {
        final lang = csvLangs[j - 1];
        final val = cols[j];
        if (val.isNotEmpty) csvLocales[lang]?[key] = val;
      }
    }

    // Merge and write back to assets/lang/<lang>.json
    for (final entry in locales.entries) {
      final lang = entry.key;
      final map = Map<String, String>.from(entry.value);
      final updates = csvLocales[lang];
      if (updates != null) {
        map.addAll(updates);
        // backup existing file
        final file = File('assets/lang/$lang.json');
        final backup = File('assets/lang/$lang.json.bak');
        if (await file.exists()) {
          await file.copy(backup.path);
        }
        final encoder = const JsonEncoder.withIndent('  ');
        await file.writeAsString(encoder.convert(map));
        stdout.writeln('Updated assets/lang/$lang.json (${updates.length} keys updated)');
      }
    }

    stdout.writeln('Import complete');
    return;
  }

  // Prepare CSV (export)
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
