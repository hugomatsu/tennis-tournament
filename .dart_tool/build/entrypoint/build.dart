// @dart=3.6
// ignore_for_file: directives_ordering
// build_runner >=2.4.16
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner/src/build_plan/builder_factories.dart' as _i1;
import 'package:freezed/builder.dart' as _i2;
import 'package:json_serializable/builder.dart' as _i3;
import 'package:mockito/src/builder.dart' as _i4;
import 'package:riverpod_generator/builder.dart' as _i5;
import 'package:source_gen/builder.dart' as _i6;
import 'dart:io' as _i7;
import 'package:build_runner/src/bootstrap/processes.dart' as _i8;

final _builderFactories = _i1.BuilderFactories(
  builderFactories: {
    'freezed:freezed': [_i2.freezed],
    'json_serializable:json_serializable': [_i3.jsonSerializable],
    'mockito:mockBuilder': [_i4.buildMocks],
    'riverpod_generator:riverpod_generator': [_i5.riverpodBuilder],
    'source_gen:combining_builder': [_i6.combiningBuilder],
  },
  postProcessBuilderFactories: {'source_gen:part_cleanup': _i6.partCleanup},
);
void main(List<String> args) async {
  _i7.exitCode = await _i8.ChildProcess.run(
    args,
    _builderFactories,
  )!;
}
