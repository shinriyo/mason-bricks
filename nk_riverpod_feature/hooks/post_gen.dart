import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  // final progress = context.logger.progress('Installing packages');
  //
  // // context.vars.entries.forEach(
  // //     (entry) => context.logger.info('vars... ${entry.key}: ${entry.value}'));
  // // Run `flutter packages get` after generation.
  // await Process.run('flutter', ['packages', 'get']);
  // progress.complete();

  final featureName = context.vars['feature_name'];
  final makefileService = _MakefileService();
  await makefileService.ensureMakefile();
  await makefileService.addLocalization(featureName);

  final makeProgress =
      context.logger.progress('Generate Locale for Feature $featureName');
  await Process.run('make', ['l10n-gen']);
  makeProgress.complete();
}

class _MakefileService {
  final String _l10 = '''
l10n:
	flutter gen-l10n --arb-dir lib/features/\$(feature)/l10n/arb --template-arb-file \$(feature)_de.arb \\
		--output-dir lib/features/\$(feature)/l10n --output-localization-file \$(feature)_localization.dart \\
		--no-synthetic-package --no-nullable-getter --format --no-suppress-warnings --output-class \$(classname) \\
		--required-resource-attributes --untranslated-messages-file=lib/features/\$(feature)/l10n/\$(feature)_l10n_untranslated.txt
ifneq (\$(ci), yes)
	git add **/\$(feature)_localization*.dart
endif

#Example
#l10n-gen:
#	make l10n feature=auth classname=AuthLocalizations
#	make l10n feature=core classname=CoreLocalizations
  ''';

  Future<void> ensureMakefile() async {
    final l10genFile = 'makefiles/l10n-makefile';
    final globalMakefile = 'Makefile';

    final l10n_exists = await File(l10genFile).exists();

    if (!l10n_exists) {
      await File(l10genFile).create(recursive: true);

      var file = File(l10genFile);
      var sink = file.openWrite();
      sink.write(_l10);
      await sink.flush();

      // Close the IOSink to free system resources.
      await sink.close();
    }

    final globalMakefileExists = await File(globalMakefile).exists();

    if (!globalMakefileExists) {
      final file = File(globalMakefile);
      await file.create();
      final sink = file.openWrite();
      sink.writeln('include ./makefiles/l10n-makefile');
      sink.write('l10n-gen:');
      await sink.flush();
      await sink.close();
    }
  }

  Future<void> addLocalization(String featureName) async {
    final globalMakefile = 'Makefile';

    final content = await File(globalMakefile).readAsLines();
    final genCommand =
        '\tmake l10n feature=${featureName} classname=${featureName.pascalCase}Localizations';

    final includeCommand = 'include ./makefiles/l10n-makefile';

    if (!content.contains(genCommand)) {
      final l10ngenIndex = content.indexOf('l10n-gen:');
      content.insert(l10ngenIndex + 1, genCommand);
    }

    if (!content.contains(includeCommand)) {
      content.insert(0, includeCommand);
    }

    final file = File(globalMakefile);
    final sink = file.openWrite(mode: FileMode.write);
    content.forEach(sink.writeln);
    await sink.flush();
    sink.close();
  }
}
