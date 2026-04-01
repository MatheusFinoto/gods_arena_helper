import 'dart:convert';
import 'dart:io';

abstract class PyCommandService {
  Future<Map<String, dynamic>> runPythonCommand({
    required String method,
    required List<String> arguments,
  });

  Future<PyCommandSession> startPythonCommand({
    required String method,
    required List<String> arguments,
  });
}

abstract class PyCommandSession {
  Stream<String> get stdoutLines;
  Stream<String> get stderrLines;
  Future<int> get exitCode;
  Future<void> kill();
}

PyCommandService newPyCommandService() => _PyCommandService();

class _PyCommandService implements PyCommandService {
  static const _pythonWorkingDirectory =
      r'C:\Users\mathe\Desktop\dev\gods_arena_helper\helper_service\src';

  @override
  Future<Map<String, dynamic>> runPythonCommand({
    required String method,
    required List<String> arguments,
  }) async {
    final scriptPath = File('..\\helper_service\\src\\main.py').absolute.path;

    final result = await Process.run('python', [
      scriptPath,
      method,
      ...arguments,
    ], workingDirectory: _pythonWorkingDirectory);

    final stdoutText = result.stdout.toString().trim();
    final stderrText = result.stderr.toString().trim();

    if (result.exitCode != 0) {
      throw Exception(
        stderrText.isNotEmpty
            ? 'Python script failed: $stderrText'
            : 'Python script failed with exit code ${result.exitCode}.',
      );
    }

    if (stdoutText.isEmpty) {
      throw const FormatException('Python script returned empty stdout.');
    }

    final payload = jsonDecode(stdoutText);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException(
        'Python script returned invalid JSON payload.',
      );
    }

    if (payload['ok'] != true) {
      throw Exception(
        payload['error'] ?? 'Python script returned an unknown error.',
      );
    }

    return payload;
  }

  @override
  Future<PyCommandSession> startPythonCommand({
    required String method,
    required List<String> arguments,
  }) async {
    final scriptPath = File('..\\helper_service\\src\\main.py').absolute.path;

    final process = await Process.start('python', [
      scriptPath,
      method,
      ...arguments,
    ], workingDirectory: _pythonWorkingDirectory);

    return _ProcessPyCommandSession(process);
  }
}

class _ProcessPyCommandSession implements PyCommandSession {
  final Process process;

  _ProcessPyCommandSession(this.process);

  @override
  Stream<String> get stdoutLines =>
      process.stdout.transform(utf8.decoder).transform(const LineSplitter());

  @override
  Stream<String> get stderrLines =>
      process.stderr.transform(utf8.decoder).transform(const LineSplitter());

  @override
  Future<int> get exitCode => process.exitCode;

  @override
  Future<void> kill() async {
    process.kill();
    await process.exitCode;
  }
}
