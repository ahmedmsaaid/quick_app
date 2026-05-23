import 'dart:io';

void main() async {
  print('🔄 Generating AppStrings...\n');

  // 1. Run easy_localization:generate
  print('📦 Running easy_localization:generate...');
  final result = await Process.run('dart', [
    'run',
    'easy_localization:generate',
    '-S',
    'assets/translations',
    '-f',
    'keys',
    '-o',
    'locale_keys.g.dart',
  ]);

  if (result.exitCode != 0) {
    print('❌ Error: ${result.stderr}');
    return;
  }

  print('✅ Generated locale_keys.g.dart\n');

  // 2. Read file
  final file = File('lib/generated/locale_keys.g.dart');
  if (!file.existsSync()) {
    print('❌ Generated file not found');
    return;
  }

  String content = file.readAsStringSync();

  // 3. Show original content
  print('📄 Original content (first lines):');
  final originalLines = content.split('\n').take(10).join('\n');
  print(originalLines);
  print('\n---\n');

  // 4. Replace LocaleKeys with AppStrings
  String updatedContent = content.replaceAll('LocaleKeys', 'AppStrings');

  // 5. Transform const to getters with .tr()
  updatedContent = _transformToGetters(updatedContent);

  // 6. Add easy_localization import if not exists
  if (!updatedContent.contains(
    "import 'package:easy_localization/easy_localization.dart'",
  )) {
    updatedContent = _addImport(updatedContent);
  }

  // 7. Show updated content
  print('📄 Updated content (first lines):');
  final updatedLines = updatedContent.split('\n').take(15).join('\n');
  print(updatedLines);
  print('\n---\n');

  // 8. Save to new location
  final outputFile = File('lib/core/localizations/app_strings.g.dart');
  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(updatedContent);

  print('✅ Created: lib/core/localizations/app_strings.g.dart');
  print('📊 Keys transformed: ${_countTransformations(content)}');
  print('✨ Added .tr() extensions and import');
}

String _transformToGetters(String content) {
  final lines = content.split('\n');
  final transformedLines = <String>[];

  for (var line in lines) {
    // Match: static const variableName = 'value';
    final match = RegExp(
      r"^\s*static const (\w+) = '([^']+)';",
    ).firstMatch(line);

    if (match != null) {
      final variableName = match.group(1);
      final value = match.group(2);
      // Transform to: static String get variableName => 'value'.tr();
      transformedLines.add(
        "  static String get $variableName => '$value'.tr();",
      );
    } else {
      transformedLines.add(line);
    }
  }

  return transformedLines.join('\n');
}

String _addImport(String content) {
  final lines = content.split('\n');

  // Find the position after the first comment block and before class declaration
  int insertPosition = 0;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('abstract class') || lines[i].contains('class ')) {
      insertPosition = i;
      break;
    }
  }

  // Insert import before the class
  lines.insert(insertPosition, '');
  lines.insert(
    insertPosition,
    "import 'package:easy_localization/easy_localization.dart';",
  );

  return lines.join('\n');
}

int _countTransformations(String content) {
  return RegExp(r"static const \w+ = '[^']+';").allMatches(content).length;
}
