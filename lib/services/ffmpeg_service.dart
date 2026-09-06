import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

const uuid = Uuid();
final logger = Logger();

class FFmpegService {
  static final FFmpegService _instance = FFmpegService._internal();

  factory FFmpegService() {
    return _instance;
  }

  FFmpegService._internal();

  final StreamController<double> _progressController = StreamController<double>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();

  Stream<double> get progressStream => _progressController.stream;
  Stream<String> get statusStream => _statusController.stream;

  /// Main Generation Function for News Editor Screen
  Future<String?> generateVideo({
    required String inputMedia,
    required String resolution,
    required String textOverlay,
    Function(double)? onProgress,
  }) async {
    try {
      _statusController.add('Preparing video processing...');
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/news_export_${uuid.v4()}.mp4';

      final isImage = !_isVideo(inputMedia);
      
      // Calculate Total Duration for Progress Bar
      double totalDurationMs = 5000.0; // Default for Images (5 Seconds)
      if (!isImage) {
        final mediaInfo = await FFmpegKitConfig.getMediaInformation(inputMedia);
        final durationStr = mediaInfo.getMediaInformation()?.getDuration();
        final parsedSec = double.tryParse(durationStr ?? '0') ?? 0.0;
        if (parsedSec > 0) {
          totalDurationMs = parsedSec * 1000;
        }
      }

      List<String> command;

      // Resolution Filter (e.g., "1920x1080" or "1080x1920")
      String resFilter = 'scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2';
      if (resolution.contains('x')) {
        final resParts = resolution.split('x');
        if (resParts.length == 2) {
          final w = resParts[0];
          final h = resParts[1];
          resFilter = 'scale=$w:$h:force_original_aspect_ratio=decrease,pad=$w:$h:(ow-iw)/2:(oh-ih)/2';
        }
      }

      // Handle Text Overlay Filter
      String videoFilter = resFilter;
      if (textOverlay.isNotEmpty) {
        final escapedText = textOverlay.replaceAll("'", "\\'").replaceAll(":", "\\:");
        videoFilter += ",drawtext=text='$escapedText':fontsize=36:fontcolor=white:box=1:boxcolor=red@0.8:boxborderw=10:x=(w-tw)/2:y=h-th-40";
      }

      if (isImage) {
        // Image to 5-second News Video
        command = [
          '-loop', '1',
          '-i', inputMedia,
          '-vf', videoFilter,
          '-c:v', 'libx264',
          '-t', '5',
          '-pix_fmt', 'yuv420p',
          '-y',
          outputPath
        ];
      } else {
        // Video Processing
        command = [
          '-i', inputMedia,
          '-vf', videoFilter,
          '-c:v', 'libx264',
          '-preset', 'fast',
          '-c:a', 'aac',
          '-y',
          outputPath
        ];
      }

      final session = await FFmpegSession.create(
        command,
        null,
        null,
        (Statistics stats) {
          final timeInMs = stats.getTime();
          double progress = (timeInMs / totalDurationMs).clamp(0.0, 1.0);
          _progressController.add(progress);
          if (onProgress != null) {
            onProgress(progress);
          }
        },
      );

      await FFmpegKitConfig.asyncFFmpegExecute(session);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Video exported successfully!');
        if (onProgress != null) onProgress(1.0);
        logger.i('Exported: $outputPath');
        return outputPath;
      } else {
        _statusController.add('Export failed');
        final logs = await session.getLogsAsString();
        logger.e('FFmpeg Fail Log: $logs');
        return null;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      logger.e('Generate Video Error: $e');
      return null;
    }
  }

  /// 1. Automatic Background Removal
  Future<String?> removeAutoBg({
    required String inputPath,
    required String outputPath,
    Function(double)? onProgress,
  }) async {
    try {
      _statusController.add('Removing background automatically...');

      final mediaInfo = await FFmpegKitConfig.getMediaInformation(inputPath);
      final durationStr = mediaInfo.getMediaInformation()?.getDuration();
      double totalDurationMs = (double.tryParse(durationStr ?? '0') ?? 5.0) * 1000;

      final command = [
        '-i', inputPath,
        '-vf', 'colorkey=0x00FF00:0.3:0.15,format=yuva420p',
        '-c:v', 'libx264',
        '-preset', 'ultrafast',
        '-pix_fmt', 'yuv420p',
        '-c:a', 'copy',
        '-y', outputPath
      ];

      final session = await FFmpegSession.create(
        command,
        null,
        null,
        (Statistics stats) {
          final timeInMs = stats.getTime();
          double progress = (timeInMs / totalDurationMs).clamp(0.0, 1.0);
          _progressController.add(progress);
          if (onProgress != null) onProgress(progress);
        },
      );

      await FFmpegKitConfig.asyncFFmpegExecute(session);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Background removed successfully');
        if (onProgress != null) onProgress(1.0);
        return outputPath;
      } else {
        _statusController.add('Background removal failed');
        return null;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      return null;
    }
  }

  /// 2. Advanced Chroma Key Control with Sliders
  Future<String?> applyChromaKeyWithSliders({
    required String inputPath,
    required String outputPath,
    required double similarity,
    required double blend,
    required double brightness,
    Function(double)? onProgress,
  }) async {
    try {
      _statusController.add('Applying customized Chroma Key...');

      final mediaInfo = await FFmpegKitConfig.getMediaInformation(inputPath);
      final durationStr = mediaInfo.getMediaInformation()?.getDuration();
      double totalDurationMs = (double.tryParse(durationStr ?? '0') ?? 5.0) * 1000;

      final filterStr = 'colorkey=0x00FF00:$similarity:$blend,eq=brightness=$brightness';

      final command = [
        '-i', inputPath,
        '-vf', filterStr,
        '-c:v', 'libx264',
        '-preset', 'ultrafast',
        '-pix_fmt', 'yuv420p',
        '-c:a', 'copy',
        '-y', outputPath
      ];

      final session = await FFmpegSession.create(
        command,
        null,
        null,
        (Statistics stats) {
          final timeInMs = stats.getTime();
          double progress = (timeInMs / totalDurationMs).clamp(0.0, 1.0);
          _progressController.add(progress);
          if (onProgress != null) onProgress(progress);
        },
      );

      await FFmpegKitConfig.asyncFFmpegExecute(session);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Chroma Key applied successfully');
        if (onProgress != null) onProgress(1.0);
        return outputPath;
      } else {
        _statusController.add('Chroma Key application failed');
        return null;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      return null;
    }
  }

  /// Trim video clip
  Future<bool> trimVideo({
    required String inputPath,
    required String outputPath,
    required int startMs,
    required int durationMs,
  }) async {
    try {
      _statusController.add('Trimming video...');
      
      final startSeconds = startMs / 1000;
      final durationSeconds = durationMs / 1000;

      final command = [
        '-ss', startSeconds.toStringAsFixed(2),
        '-i', inputPath,
        '-t', durationSeconds.toStringAsFixed(2),
        '-c:v', 'libx264',
        '-preset', 'fast',
        '-c:a', 'aac',
        '-y', outputPath,
      ];

      final session = await FFmpegSession.create(
        command,
        null,
        null,
        (Statistics stats) {
          final progress = (stats.getTime() / (durationMs)).clamp(0.0, 1.0);
          _progressController.add(progress);
        },
      );

      await FFmpegKitConfig.asyncFFmpegExecute(session);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Video trimmed successfully');
        logger.i('Video trimmed: $outputPath');
        return true;
      } else {
        final failStackTrace = await session.getLogsAsString();
        _statusController.add('Trim failed');
        logger.e('Trim failed: $failStackTrace');
        return false;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      logger.e('Trim error: $e');
      return false;
    }
  }

  /// Merge multiple audio tracks
  Future<bool> mergeAudioTracks({
    required List<String> audioTracks,
    required String outputPath,
  }) async {
    try {
      if (audioTracks.isEmpty) return false;

      _statusController.add('Mixing audio tracks...');

      final List<String> command = [];
      for (var path in audioTracks) {
        command.addAll(['-i', path]);
      }

      String filterComplex = '';
      for (int i = 0; i < audioTracks.length; i++) {
        filterComplex += '[$i]volume=0.5[a$i];';
      }
      filterComplex += audioTracks.asMap().entries.map((e) => '[a${e.key}]').join('');
      filterComplex += 'amix=inputs=${audioTracks.length}:duration=longest[out]';

      command.addAll([
        '-filter_complex', filterComplex,
        '-map', '[out]',
        '-y', outputPath
      ]);

      final session = await FFmpegKit.executeWithArguments(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Audio mixed successfully');
        logger.i('Audio mixed: $outputPath');
        return true;
      } else {
        _statusController.add('Audio mix failed');
        logger.e('Audio mix failed');
        return false;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      logger.e('Audio mix error: $e');
      return false;
    }
  }

  /// Adjust audio pitch
  Future<bool> adjustAudioPitch({
    required String inputPath,
    required String outputPath,
    required double pitch,
  }) async {
    try {
      _statusController.add('Adjusting pitch...');

      final command = [
        '-i', inputPath,
        '-af', 'rubberband=pitch=$pitch',
        '-y', outputPath,
      ];

      final session = await FFmpegKit.executeWithArguments(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Pitch adjusted successfully');
        logger.i('Pitch adjusted: $outputPath');
        return true;
      } else {
        _statusController.add('Pitch adjustment failed');
        return false;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      logger.e('Pitch adjustment error: $e');
      return false;
    }
  }

  /// Generate video from images with effects
  Future<bool> generateVideoFromImages({
    required List<String> imagePaths,
    required String outputPath,
    int framerate = 30,
    int durationPerImageMs = 1000,
  }) async {
    try {
      if (imagePaths.isEmpty) return false;

      _statusController.add('Generating video from images...');

      final tempDir = await getTemporaryDirectory();
      final concat = StringBuffer();

      for (int i = 0; i < imagePaths.length; i++) {
        final duration = durationPerImageMs / 1000.0;
        concat.write("file '${imagePaths[i]}'\n");
        concat.write("duration $duration\n");
      }

      final concatFile = '${tempDir.path}/concat_${uuid.v4()}.txt';
      await _writeFile(concatFile, concat.toString());

      final command = [
        '-f', 'concat',
        '-safe', '0',
        '-i', concatFile,
        '-c:v', 'libx264',
        '-pix_fmt', 'yuv420p',
        '-r', framerate.toString(),
        '-y', outputPath,
      ];

      final session = await FFmpegSession.create(
        command,
        null,
        null,
        (Statistics stats) {
          final progress = (stats.getTime() / (imagePaths.length * durationPerImageMs))
              .clamp(0.0, 1.0);
          _progressController.add(progress);
        },
      );

      await FFmpegKitConfig.asyncFFmpegExecute(session);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Video generated successfully');
        logger.i('Video generated: $outputPath');
        return true;
      } else {
        _statusController.add('Video generation failed');
        return false;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      logger.e('Video generation error: $e');
      return false;
    }
  }

  /// Add watermark to video
  Future<bool> addWatermark({
    required String inputPath,
    required String watermarkPath,
    required String outputPath,
    int xPos = 10,
    int yPos = 10,
    int width = 150,
    int height = 50,
    double opacity = 0.8,
  }) async {
    try {
      _statusController.add('Adding watermark...');

      final filterComplex = '[1:v]scale=$width:$height[wm];[0:v][wm]overlay=$xPos:$yPos';

      final command = [
        '-i', inputPath,
        '-i', watermarkPath,
        '-filter_complex', filterComplex,
        '-c:a', 'copy',
        '-y', outputPath,
      ];

      final session = await FFmpegKit.executeWithArguments(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Watermark added successfully');
        logger.i('Watermark added: $outputPath');
        return true;
      } else {
        _statusController.add('Watermark addition failed');
        return false;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      logger.e('Watermark error: $e');
      return false;
    }
  }

  /// Render final video
  Future<bool> renderVideo({
    required String inputPath,
    required String outputPath,
    required String resolution,
    String quality = 'high',
  }) async {
    try {
      _statusController.add('Rendering video...');

      final preset = quality == 'high'
          ? 'slow'
          : quality == 'medium'
              ? 'medium'
              : 'fast';

      final crf = quality == 'high'
          ? '18'
          : quality == 'medium'
              ? '23'
              : '28';

      final command = [
        '-i', inputPath,
        '-vf', 'scale=$resolution',
        '-c:v', 'libx264',
        '-preset', preset,
        '-crf', crf,
        '-c:a', 'aac',
        '-b:a', '128k',
        '-y', outputPath,
      ];

      final session = await FFmpegSession.create(
        command,
        null,
        null,
        (Statistics stats) {
          final time = stats.getTime();
          _progressController.add((time / 30000.0).clamp(0.0, 1.0));
        },
      );

      await FFmpegKitConfig.asyncFFmpegExecute(session);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Video rendered successfully');
        _progressController.add(1.0);
        logger.i('Video rendered: $outputPath');
        return true;
      } else {
        _statusController.add('Render failed');
        return false;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      logger.e('Render error: $e');
      return false;
    }
  }

  /// Get video information
  Future<Map<String, dynamic>?> getVideoInfo(String videoPath) async {
    try {
      final session = await FFmpegKit.execute('-i "$videoPath"');
      final logs = await session.getLogsAsString();
      logger.i('Video info: $logs');

      return {
        'duration': _extractDuration(logs),
        'width': _extractWidth(logs),
        'height': _extractHeight(logs),
      };
    } catch (e) {
      logger.e('Error getting video info: $e');
      return null;
    }
  }

  bool _isVideo(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi') || lower.endsWith('.mkv');
  }

  String _extractDuration(String logs) {
    final regex = RegExp(r'Duration: (\d{2}):(\d{2}):(\d{2})');
    final match = regex.firstMatch(logs);
    return match?.group(0) ?? 'Unknown';
  }

  int _extractWidth(String logs) {
    final regex = RegExp(r'(\d{3,4})x(\d{3,4})');
    final match = regex.firstMatch(logs);
    return int.tryParse(match?.group(1) ?? '0') ?? 0;
  }

  int _extractHeight(String logs) {
    final regex = RegExp(r'(\d{3,4})x(\d{3,4})');
    final match = regex.firstMatch(logs);
    return int.tryParse(match?.group(2) ?? '0') ?? 0;
  }

  Future<void> _writeFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
    logger.i('File written successfully: $path');
  }

  void dispose() {
    _progressController.close();
    _statusController.close();
  }
}

final ffmpegServiceProvider = Provider((ref) {
  return FFmpegService();
});
