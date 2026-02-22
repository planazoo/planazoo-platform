import 'dart:convert';
import 'dart:io';

import 'package:unp_calendario/testing/login_logic.dart';

/// Simple test runner for logical scenarios (starting with auth/login).
///
/// Usage:
///   dart run bin/run_tests.dart
///
/// It reads JSON test cases from `tests/login_cases.json` and writes
/// a structured report to `reports/login_report.json`.
Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final commitSha = await _getGitCommitSha();
  final casesFile = File('tests/login_cases.json');

  if (!await casesFile.exists()) {
    stderr.writeln('ERROR: tests/login_cases.json not found.');
    exitCode = 1;
    return;
  }

  final raw = await casesFile.readAsString();
  final List<dynamic> parsed;
  try {
    parsed = jsonDecode(raw) as List<dynamic>;
  } catch (e) {
    stderr.writeln('ERROR: Failed to parse tests/login_cases.json: $e');
    exitCode = 1;
    return;
  }

  int passed = 0;
  int failed = 0;
  int errors = 0;

  final List<Map<String, dynamic>> caseResults = [];

  for (final dynamic entry in parsed) {
    if (entry is! Map<String, dynamic>) continue;
    final caseId = entry['id']?.toString() ?? 'unknown';
    final target = (entry['target'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final input = (entry['input'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final expected = (entry['expected'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    final caseStopwatch = Stopwatch()..start();
    try {
      final actual = await _evaluateCase(target, input);
      final comparison = _compareOutputs(expected, actual);

      if (comparison == null) {
        passed++;
        caseResults.add({
          'id': caseId,
          'target': target,
          'status': 'passed',
          'duration_ms': caseStopwatch.elapsedMilliseconds,
        });
      } else {
        failed++;
        caseResults.add({
          'id': caseId,
          'target': target,
          'status': 'failed',
          'input': input,
          'expected': expected,
          'actual': actual,
          'diff': comparison,
          'duration_ms': caseStopwatch.elapsedMilliseconds,
        });
      }
    } catch (e, st) {
      errors++;
      caseResults.add({
        'id': caseId,
        'target': target,
        'status': 'error',
        'input': input,
        'error_message': e.toString(),
        'stack_excerpt': _stackExcerpt(st.toString()),
        'duration_ms': caseStopwatch.elapsedMilliseconds,
      });
    }
  }

  final report = <String, dynamic>{
    'metadata': {
      'language': 'dart',
      'execution_time': DateTime.now().toUtc().toIso8601String(),
      'commit': commitSha,
      'environment': 'local',
    },
    'summary': {
      'total': passed + failed + errors,
      'passed': passed,
      'failed': failed,
      'errors': errors,
      'duration_ms': stopwatch.elapsedMilliseconds,
    },
    'cases': caseResults,
  };

  final reportsDir = Directory('reports');
  if (!await reportsDir.exists()) {
    await reportsDir.create(recursive: true);
  }

  final reportFile = File('reports/login_report.json');
  await reportFile.writeAsString(const JsonEncoder.withIndent('  ').convert(report));

  stdout.writeln('Test report written to ${reportFile.path}');
  stdout.writeln('Summary: passed=$passed failed=$failed errors=$errors');
}

/// Dispatches to the appropriate logical evaluator based on target.
Future<Map<String, dynamic>> _evaluateCase(
  Map<String, dynamic> target,
  Map<String, dynamic> input,
) async {
  final module = target['module']?.toString();
  final scenario = target['scenario']?.toString();

  if (module == 'auth' && scenario == 'login') {
    return evaluateAuthLogin(input);
  }

  // Unknown target: treat as error.
  throw UnsupportedError('Unsupported target: module=$module scenario=$scenario');
}

/// Returns `null` if [expected] and [actual] are considered equal, otherwise
/// a short human-readable diff description.
String? _compareOutputs(Map<String, dynamic> expected, Map<String, dynamic> actual) {
  return compareOutputs(expected, actual);
}

/// Try to obtain the current git commit SHA. Returns 'unknown' on failure.
Future<String> _getGitCommitSha() async {
  try {
    final result = await Process.run('git', ['rev-parse', 'HEAD']);
    if (result.exitCode == 0) {
      return (result.stdout as String).trim();
    }
  } catch (_) {
    // Ignore and fall through.
  }
  return 'unknown';
}

String _stackExcerpt(String fullStack) {
  final lines = const LineSplitter().convert(fullStack);
  const maxLines = 8;
  if (lines.length <= maxLines) {
    return fullStack;
  }
  return lines.take(maxLines).join('\n');
}

