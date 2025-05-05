// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;

  File? _logFile;
  IOSink? _logSink;
  final Logger _logger = Logger('AppLogger');
  bool _isInitialized = false;
  String? _lastStateLog;
  DateTime? _lastStateLogTime;

  AppLogger._internal() {
    // Configure logging levels
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen(_handleLogRecord);
  }

  // Getter for the current log file path
  String get logFilePath => _logFile?.path ?? 'No log file';

  // Maximum number of log files to keep (adjust as needed)
  static const int _maxLogFiles = 5;
  
  Future<void> initialize({String? absoluteLogPath}) async {
    if (_isInitialized) {
      return;
    }

    try {
      // Close existing sink if any
      await _logSink?.flush();
      await _logSink?.close();
      _logSink = null;

      Directory logDirectory;

      // Try to use the specified absolute path first
      if (absoluteLogPath != null) {
        logDirectory = Directory(absoluteLogPath);
        try {
          final testFile = File('${logDirectory.path}/write_test.tmp');
          await testFile.create(recursive: true);
          await testFile.delete();
        } catch (e) {
          print('Cannot write to specified log path: $absoluteLogPath');
          // Fallback to application documents directory
          logDirectory = await getApplicationDocumentsDirectory();
        }
      } else {
        // If no path specified, use application documents directory
        logDirectory = await getApplicationDocumentsDirectory();
      }

      // Ensure log directory exists
      final logsSubDir = Directory('${logDirectory.path}/logs');
      await logsSubDir.create(recursive: true);

      // Create log file with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      _logFile = File('${logsSubDir.path}/app_log_$timestamp.txt');

      // Open file in write mode (not append)
      _logSink = _logFile?.openWrite(mode: FileMode.write);
      
      // Clean up old log files
      _cleanupOldLogFiles(logsSubDir);

      print('Logging to: ${_logFile?.path}');
      _isInitialized = true;
    } catch (e, stackTrace) {
      print('Critical error initializing log file: $e');
      print('Stacktrace: $stackTrace');
    }
  }

  void _handleLogRecord(LogRecord record) {
    if (_logSink == null) return;

    // Skip redundant initialization and loading logs
    if (record.level == Level.FINE &&
        (record.message.contains('MainScreen: Initializing') ||
            record.message.contains('HomeTab: Initializing') ||
            record.message.contains('LoginScreen: Initializing') ||
            record.message.contains('Total products retrieved:') ||
            record.message.contains('GetProductsUseCase: Got') ||
            record.message.contains('Store Response Details:') ||
            record.message.contains('Total stores in raw response:') ||
            record.message.contains('Current Log File Path:') ||
            record.message.contains('Successfully opened') ||
            record.message.contains('Checking for existing'))) {
      return;
    }

    // Deduplicate state change logs with time-based threshold
    if (record.message.contains('State')) {
      final now = DateTime.now();
      if (record.message == _lastStateLog &&
          _lastStateLogTime != null &&
          now.difference(_lastStateLogTime!).inMilliseconds < 500) {
        return;
      }
      _lastStateLog = record.message;
      _lastStateLogTime = now;
    }

    // Format timestamp and level prefix
    final prefix = '[${record.time}] ${record.level.name}: ';

    // Build the log message with consistent formatting
    String logMessage = prefix + record.message;

    // Format error with the same prefix style
    if (record.error != null) {
      // Instead of adding on a new line, include it in the same formatted line
      logMessage = '$prefix${record.message} - ${record.error}';
    }

    // Only add stacktrace on a new line if present
    if (record.stackTrace != null) {
      logMessage += '\nStacktrace: ${record.stackTrace}';
    }

    // Write to file if possible
    try {
      _logSink?.write('$logMessage\n---\n');
    } catch (e) {
      if (kDebugMode) {
        print('Error writing to log file: $e');
      }
    }

    // Print to console in debug mode with selective filtering
    if (kDebugMode) {
      // Show INFO and above, plus important FINE logs
      if (record.level.value >= Level.INFO.value ||
          (record.level == Level.FINE &&
              !record.message.contains('Converting') &&
              !record.message.contains('Retrieved') &&
              !record.message.contains('Successfully') &&
              !record.message.contains('Attempting to') &&
              !record.message.contains('Current Log'))) {
        debugPrint(logMessage);
      }
    }
  }

  // Public logging methods
  void debug(String message, [Map<String, String>? contextMap]) {
    _logger.fine(message);
  }

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.info(message, error, stackTrace);
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.warning(message, error, stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.severe(message, error, stackTrace);
  }

  // Copy log file to a specified directory
  Future<String?> copyLogToDownloads({
    Directory? customDestination,
  }) async {
    try {
      if (_logFile == null) {
        print('🚨 No log file to copy');
        return null;
      }

      // Default: use app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final destinationDir = Directory('${appDocDir.path}/logs');

      // Ensure destination directory exists
      await destinationDir.create(recursive: true);

      // Create a unique filename
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final newLogFile = File('${destinationDir.path}/app_log_$timestamp.txt');

      // Copy the log file
      await _logFile!.copy(newLogFile.path);

      print('✅ Log copied to: ${newLogFile.path}');
      return newLogFile.path;
    } catch (e) {
      print('❌ Error copying log file: $e');
      return null;
    }
  }

  // Share the current log file
  Future<void> shareLogFile() async {
    try {
      final copiedLogPath = await copyLogToDownloads();

      if (copiedLogPath == null) {
        print('Failed to copy log file');
        return;
      }

      await Share.shareXFiles(
        [XFile(copiedLogPath)],
        text: 'SEMO App Logs',
        subject: 'Application Logs',
      );
    } catch (e) {
      print('Error sharing log file: $e');
    }
  }

  // Print entire log file contents to terminal
  Future<void> printLogContents() async {
    try {
      if (_logFile == null) {
        print('🚨 No log file to print');
        return;
      }

      final logContents = await _logFile!.readAsString();

      print('📋 Log File Contents START ===========================');
      print(logContents);
      print('📋 Log File Contents END   ===========================');
    } catch (e) {
      print('❌ Error reading log file: $e');
    }
  }
  
  // Clean up old log files, keeping only the most recent ones
  Future<void> _cleanupOldLogFiles(Directory logDirectory) async {
    try {
      // List all log files
      final logFiles = await logDirectory
          .list()
          .where((entity) => 
              entity is File && 
              entity.path.contains('app_log_') && 
              entity.path.endsWith('.txt'))
          .toList();
      
      // Sort by modification time (newest first)
      logFiles.sort((a, b) {
        return (b as File).lastModifiedSync()
            .compareTo((a as File).lastModifiedSync());
      });
      
      // Delete old files, keeping only _maxLogFiles most recent ones
      if (logFiles.length > _maxLogFiles) {
        for (var i = _maxLogFiles; i < logFiles.length; i++) {
          try {
            await (logFiles[i] as File).delete();
            print('Deleted old log file: ${logFiles[i].path}');
          } catch (e) {
            print('Error deleting old log file: $e');
          }
        }
      }
    } catch (e) {
      print('Error during log cleanup: $e');
    }
  }
  
  // Manually trigger log cleanup
  Future<void> cleanupLogs() async {
    if (_logFile != null) {
      final logDirectory = Directory(_logFile!.parent.path);
      await _cleanupOldLogFiles(logDirectory);
    }
  }

  Future<void> dispose() async {
    try {
      await _logSink?.flush();
      await _logSink?.close();
      _logSink = null;
      _isInitialized = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing logger: $e');
      }
    }
  }

  Future<void> close() async {
    await dispose();
  }
}
