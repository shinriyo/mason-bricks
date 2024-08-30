import 'dart:io';

import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';

Future<void> run(HookContext context) async {
  final progress = context.logger.progress('Installing packages if needed...');
  final yamlContent = await File('pubspec.yaml').readAsString();
  final projectYaml = loadYamlDocument(yamlContent);
  final dependencies = projectYaml.contents.value['dependencies'] as YamlMap;
  final requiredDependencies = {
    'flutter_riverpod': '>=2.5.1 <3.0.0',
    'flutter_localizations': '{"sdk":"flutter"}',
    'intl': '^0.19.0',
    'go_router': '>=14.2.7 <15.0.0',
  };
  final missingDependencies = List<String>.empty(growable: true);

  requiredDependencies.entries.forEach((entry) {
    if (!dependencies.containsKey(entry.key)) {
      missingDependencies.add('${entry.key}:${entry.value}');
    }
  });

  if (missingDependencies.isNotEmpty) {
    await Process.run('flutter', ['pub', 'add', ...missingDependencies]);
  }

  progress.complete();
}
