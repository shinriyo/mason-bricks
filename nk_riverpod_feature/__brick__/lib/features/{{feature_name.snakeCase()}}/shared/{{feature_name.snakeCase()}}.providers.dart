import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data.dart';
import '../domain.dart';
import '../presentation.dart';

/// {{feature_name.pascalCase()}} Feature Providers
class {{feature_name.pascalCase()}}Providers {
  
  // Data
  {{#fake_datasource}}
  /// Fake Datasource
  static final Provider<{{feature_name.pascalCase()}}Datasource> {{feature_name.camelCase()}}FakeDatasource =
      Provider((ref) => {{feature_name.pascalCase()}}FakeDatasource());
  {{/fake_datasource}}
  {{#local_datasource}}
  /// Local Datasource
  static final Provider<{{feature_name.pascalCase()}}Datasource> {{feature_name.camelCase()}}LocalDatasource =
      Provider((ref) => {{feature_name.pascalCase()}}LocalDatasource());
  {{/local_datasource}}
  /// Remote Datasource
  static final Provider<{{feature_name.pascalCase()}}Datasource> {{feature_name.camelCase()}}RemoteDatasource =
      Provider((ref) => {{feature_name.pascalCase()}}RemoteDatasource());

  // Domain
  /// Repository
  static final Provider<{{feature_name.pascalCase()}}Repository> {{feature_name.camelCase()}}Repository =
      Provider((ref) => {{feature_name.pascalCase()}}RepositoryImpl());

  // Presentation
  /// Controller
  static final Provider<{{feature_name.pascalCase()}}Controller> {{feature_name.camelCase()}}Controller =
      Provider((ref) => {{feature_name.pascalCase()}}Controller());

  // l10n
  /// {{feature_name.camelCase()}} Localization Provider
  static final Provider<{{feature_name.pascalCase()}}Localizations> {{feature_name.camelCase()}}LocalizationsProvider =
    Provider<{{feature_name.pascalCase()}}Localizations>(
    (ref) {
      final locale = PlatformDispatcher.instance.locale;
      ref.state = lookup{{feature_name.pascalCase()}}Localizations(locale);
      final observer = LocaleObserver((_) {
      ref.state = lookupAppLocalizations(locale);
      });
      final binding = WidgetsBinding.instance..addObserver(observer);
      ref.onDispose(() => binding.removeObserver(observer));
      return ref.state;
    },
  );

}
