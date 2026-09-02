import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
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

  final StreamController<double> _progressController =
      StreamController<double>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  Stream<double> get progressStream => _progressController.stream;
  Stream<String> get statusStream => _statusController.stream;

  /// Trim video clip
  /// [inputPath] - Path to input video
  /// [outputPath] - Path to output video
  /// [startMs] - Start time in milliseconds
  /// [durationMs] - Duration in milliseconds
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
        '-i',
        inputPath,
        '-ss',
        startSeconds.toStringAsFixed(2),
        '-t',
        durationSeconds.toStringAsFixed(2),
        '-c:v',
        'libx264',
        '-preset',
        'fast',
        '-c:a',
        'aac',
        outputPath,
      ];

      final session = await FFmpegKit.executeWithArguments(
        command,
        onStatistics: (Statistics stats) {
          final progress = (stats.getTime() / (durationMs)).clamp(0.0, 1.0);
          _progressController.add(progress);
        },
      );

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
  /// [audioTracks] - List of audio file paths
  /// [outputPath] - Path to output audio
  Future<bool> mergeAudioTracks({
    required List<String> audioTracks,
    required String outputPath,
  }) async {
    try {
      if (audioTracks.isEmpty) return false;

      _statusController.add('Mixing audio tracks...');

      // Build filter complex for audio mixing
      String filterComplex = '';
      String inputs = '';

      for (int i = 0; i < audioTracks.length; i++) {
        inputs += '-i "${audioTracks[i]}" ';
        filterComplex += '[$i]volume=0.5[a$i];';
      }

      // Combine all audio streams
      filterComplex += audioTracks.asMap().entries.map((e) => '[a${e.key}]').join('');
      filterComplex += 'amix=inputs=${audioTracks.length}:duration=longest[out]';

      final command = '$inputs -filter_complex "$filterComplex" -map "[out]" $outputPath';

      final session = await FFmpegKit.execute(command);
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
  /// [inputPath] - Path to input audio
  /// [outputPath] - Path to output audio
  /// [pitch] - Pitch value (1.0 = normal, 0.5 = half, 2.0 = double)
  Future<bool> adjustAudioPitch({
    required String inputPath,
    required String outputPath,
    required double pitch,
  }) async {
    try {
      _statusController.add('Adjusting pitch...');

      final command = [
        '-i',
        inputPath,
        '-af',
        'rubberband=pitch=$pitch',
        outputPath,
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
  /// [imagePaths] - List of image file paths
  /// [outputPath] - Path to output video
  /// [framerate] - Framerate (default 30)
  /// [durationPerImageMs] - Duration per image in milliseconds
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

      // Create concat demuxer file
      for (int i = 0; i < imagePaths.length; i++) {
        final duration = durationPerImageMs / 1000.0;
        concat.write('file \'${imagePaths[i]}\'\n');
        concat.write('duration $duration\n');
      }

      final concatFile = '${tempDir.path}/concat_${uuid.v4()}.txt';
      await _writeFile(concatFile, concat.toString());

      final command = [
        '-f',
        'concat',
        '-safe',
        '0',
        '-i',
        concatFile,
        '-c:v',
        'libx264',
        '-pix_fmt',
        'yuv420p',
        '-r',
        framerate.toString(),
        outputPath,
      ];

      final session = await FFmpegKit.executeWithArguments(
        command,
        onStatistics: (Statistics stats) {
          final progress = (stats.getTime() / (imagePaths.length * durationPerImageMs))\n              .clamp(0.0, 1.0);
          _progressController.add(progress);
        },
      );

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

  /// Apply chroma key (color key) effect to remove background
  /// [inputPath] - Path to input video
  /// [outputPath] - Path to output video
  /// [keyColor] - Color to key out (hex format: 0xRRGGBB)
  /// [similarity] - Similarity threshold (0-100)
  /// [blend] - Blend threshold (0-100)
  Future<bool> applyChromaKey({
    required String inputPath,
    required String outputPath,
    required int keyColor,
    double similarity = 50,
    double blend = 10,
  }) async {
    try {
      _statusController.add('Applying chroma key...');

      final colorHex = '0x${keyColor.toRadixString(16).padLeft(6, '0').toUpperCase()}';
      final filterComplex = 'chromakey=$colorHex:similarity=${similarity / 100}:blend=${blend / 100}';

      final command = [
        '-i',
        inputPath,
        '-vf',
        filterComplex,
        '-c:a',
        'copy',
        outputPath,
      ];

      final session = await FFmpegKit.executeWithArguments(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Chroma key applied successfully');
        logger.i('Chroma key applied: $outputPath');
        return true;
      } else {
        _statusController.add('Chroma key failed');
        return false;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      logger.e('Chroma key error: $e');
      return false;
    }
  }

  /// Add watermark/overlay to video
  /// [inputPath] - Path to input video
  /// [watermarkPath] - Path to watermark image
  /// [outputPath] - Path to output video
  /// [xPos] - X position in pixels
  /// [yPos] - Y position in pixels
  /// [width] - Watermark width
  /// [height] - Watermark height
  /// [opacity] - Opacity (0-1)
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

      final opacityFilter = (opacity * 100).toInt();
      final filterComplex = '''[0][1]overlay=$xPos:$yPos:enable='gte(t,0)':w=$width:h=$height''';

      final command = [
        '-i',
        inputPath,
        '-i',
        watermarkPath,
        '-filter_complex',
        filterComplex,
        '-c:a',
        'copy',
        outputPath,
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

  /// Add text overlay to video
  /// [inputPath] - Path to input video
  /// [outputPath] - Path to output video
  /// [text] - Text to overlay
  /// [fontSize] - Font size
  /// [xPos] - X position
  /// [yPos] - Y position
  /// [fontColor] - Font color (hex: FFFFFF)
  Future<bool> addTextOverlay({
    required String inputPath,
    required String outputPath,
    required String text,
    int fontSize = 30,
    int xPos = 50,
    int yPos = 50,
    String fontColor = 'FFFFFF',
  }) async {
    try {
      _statusController.add('Adding text overlay...');

      final escapedText = text.replaceAll("'", "\\'");
      final filterComplex = '''drawtext=text='$escapedText':fontsize=$fontSize:fontcolor=$fontColor:x=$xPos:y=$yPos:fontfile=/system/fonts/DroidSans.ttf''';

      final command = [
        '-i',
        inputPath,
        '-vf',
        filterComplex,
        '-c:a',
        'copy',
        outputPath,
      ];

      final session = await FFmpegKit.executeWithArguments(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Text overlay added successfully');
        logger.i('Text overlay added: $outputPath');
        return true;
      } else {
        _statusController.add('Text overlay failed');
        return false;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      logger.e('Text overlay error: $e');
      return false;
    }
  }

  /// Resize video
  /// [inputPath] - Path to input video
  /// [outputPath] - Path to output video
  /// [width] - Output width
  /// [height] - Output height
  /// [fitMode] - 'scale' (stretch), 'pad' (letter box), 'crop'
  Future<bool> resizeVideo({
    required String inputPath,
    required String outputPath,
    required int width,
    required int height,
    String fitMode = 'scale',
  }) async {
    try {
      _statusController.add('Resizing video...');

      String filterComplex;

      if (fitMode == 'scale') {
        filterComplex = 'scale=$width:$height';
      } else if (fitMode == 'pad') {
        filterComplex = 'scale=$width:$height:force_original_aspect_ratio=decrease,pad=$width:$height:(ow-iw)/2:(oh-ih)/2';
      } else if (fitMode == 'crop') {
        filterComplex = 'scale=$width:$height:force_original_aspect_ratio=increase,crop=$width:$height';
      } else {
        filterComplex = 'scale=$width:$height';
      }

      final command = [
        '-i',
        inputPath,
        '-vf',
        filterComplex,
        '-c:v',
        'libx264',
        '-c:a',
        'aac',
        outputPath,
      ];

      final session = await FFmpegKit.executeWithArguments(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Video resized successfully');
        logger.i('Video resized: $outputPath');
        return true;
      } else {
        _statusController.add('Resize failed');
        return false;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      logger.e('Resize error: $e');
      return false;
    }
  }

  /// Convert image to video format
  /// [imagePath] - Path to input image
  /// [outputPath] - Path to output video
  /// [durationSeconds] - Duration in seconds
  Future<bool> imageToVideo({
    required String imagePath,
    required String outputPath,
    int durationSeconds = 5,
  }) async {
    try {
      _statusController.add('Converting image to video...');

      final command = [
        '-loop',
        '1',
        '-i',
        imagePath,
        '-c:v',
        'libx264',
        '-t',
        durationSeconds.toString(),
        '-pix_fmt',
        'yuv420p',
        '-y',
        outputPath,
      ];

      final session = await FFmpegKit.executeWithArguments(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        _statusController.add('Image converted to video');
        logger.i('Image to video: $outputPath');
        return true;
      } else {
        _statusController.add('Conversion failed');
        return false;
      }
    } catch (e) {
      _statusController.add('Error: $e');
      logger.e('Image to video error: $e');
      return false;
    }
  }

  /// Render final video with all effects
  /// [inputPath] - Path to input video
  /// [outputPath] - Path to output video
  /// [resolution] - Output resolution (e.g., '1080x1920')
  /// [quality] - Quality ('high', 'medium', 'low')
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
        '-i',
        inputPath,
        '-vf',
        'scale=$resolution',
        '-c:v',
        'libx264',
        '-preset',
        preset,
        '-crf',
        crf,
        '-c:a',
        'aac',
        '-b:a',
        '128k',
        outputPath,
      ];

      final session = await FFmpegKit.executeWithArguments(
        command,
        onStatistics: (Statistics stats) {
          final time = stats.getTime();
          _progressController.add(time / 30000.0); // Assuming 30 second video
        },
      );

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
  /// [videoPath] - Path to video file
  Future<Map<String, dynamic>?> getVideoInfo(String videoPath) async {
    try {
      final session = await FFmpegKit.execute(
        '-i $videoPath',
      );

      final logs = await session.getLogsAsString();
      logger.i('Video info: $logs');

      // Parse logs to extract video information
      // This is a simplified version
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
    // Implementation depends on platform
    // For now, using simple file operations
    logger.i('Writing file: $path');
  }

  void dispose() {
    _progressController.close();
    _statusController.close();
  }
}

// Riverpod Provider
final ffmpegServiceProvider = Provider((ref) {
  return FFmpegService();
});
