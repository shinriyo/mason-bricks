import 'dart:io';

import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';

Future<void> run(HookContext context) async {
  final progress = context.logger.progress('Installing packages');

  final yamlContent = await File('pubspec.yaml').readAsString();
  final projectYaml = loadYamlDocument(yamlContent);

  final dependencies = projectYaml.contents.value['dependencies'] as YamlMap;
  context.logger.info(dependencies.toString());

  final missingDependencies = List<String>.empty(growable: true);

  context.logger.info(dependencies.toString());
  if (!dependencies.containsKey('flutter_riverpod')) {
    context.logger.info('add flutter_riverpod');
    missingDependencies.add('flutter_riverpod');
  }

  if (!dependencies.containsKey('intl')) {
    context.logger.info('add intl');
    missingDependencies.add('intl');
  }

  if (!dependencies.containsKey('flutter_localizations')) {
    context.logger.info('add flutter_localizations');
    missingDependencies.add('flutter_localizations:{"sdk":"flutter"}');
  }

  if (missingDependencies.isNotEmpty) {
    await Process.run('flutter', ['pub', 'add', ...missingDependencies]);
  }

  progress.complete();
}
