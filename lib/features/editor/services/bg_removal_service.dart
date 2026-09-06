import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class BgRemovalService {
  /// Automatic Background Removal (Direct)
  static Future<String?> removeAutoBg({
    required String inputPath,
    required String outputPath,
    Function(double progress)? onProgress,
  }) async {
    try {
      // ২ সেকেন্ডের লোডিং ডিলে
      await Future.delayed(const Duration(seconds: 2));

      final mediaInformation = await FFmpegKitConfig.getMediaInformation(inputPath);
      final durationStr = mediaInformation.getMediaInformation()?.getDuration();
      double totalDuration = double.tryParse(durationStr ?? '0') ?? 0.0;

      // আলফা ফিল্টার ও ক্রোমা কি অটো কম্যান্ড
      final command =
          '-i "$inputPath" -vf "colorkey=0x00FF00:0.3:0.15,format=yuva420p" -c:v libx264 -preset ultrafast -pix_fmt yuv420p -c:a copy "$outputPath" -y';

      final session = await FFmpegKit.executeAsync(
        command,
        (session) async {},
        (log) {},
        (statistics) {
          if (totalDuration > 0 && onProgress != null) {
            double timeInMilliseconds = statistics.getTime();
            double progress = (timeInMilliseconds / (totalDuration * 1000)).clamp(0.0, 1.0);
            onProgress(progress);
          }
        },
      );

      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        if (onProgress != null) onProgress(1.0);
        return outputPath;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Advanced Chroma Key Adjustment (Manual Sliders)
  static Future<String?> applyChromaKeyWithSliders({
    required String inputPath,
    required String outputPath,
    required double similarity,
    required double blend,
    required double brightness,
    Function(double progress)? onProgress,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final mediaInformation = await FFmpegKitConfig.getMediaInformation(inputPath);
      final durationStr = mediaInformation.getMediaInformation()?.getDuration();
      double totalDuration = double.tryParse(durationStr ?? '0') ?? 0.0;

      // কাস্টম স্লাইডার ভ্যালু দিয়ে ক্রোমা কি ফিল্টার
      final command =
          '-i "$inputPath" -vf "colorkey=0x00FF00:$similarity:$blend,eq=brightness=$brightness" -c:v libx264 -preset ultrafast -pix_fmt yuv420p -c:a copy "$outputPath" -y';

      final session = await FFmpegKit.executeAsync(
        command,
        (session) async {},
        (log) {},
        (statistics) {
          if (totalDuration > 0 && onProgress != null) {
            double timeInMilliseconds = statistics.getTime();
            double progress = (timeInMilliseconds / (totalDuration * 1000)).clamp(0.0, 1.0);
            onProgress(progress);
          }
        },
      );

      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        if (onProgress != null) onProgress(1.0);
        return outputPath;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
