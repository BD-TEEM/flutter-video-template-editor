import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class BgRemovalService {
  /// Green/Single Color background removal using FFmpeg Chromakey
  static Future<String?> removeChromaKeyBg({
    required String inputPath,
    required String outputPath,
    String colorHex = "0x00FF00", // Default Green
    double similarity = 0.3,
    double blend = 0.1,
  }) async {
    // FFmpeg chromakey filter
    final command =
        '-i "$inputPath" -vf "colorkey=$colorHex:$similarity:$blend" -c:a copy "$outputPath" -y';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    } else {
      return null;
    }
  }

  /// Fast AI Masking Method (MediaPipe / Custom Overlay Command)
  static Future<String?> applyOverlayMask({
    required String videoPath,
    required String maskPath,
    required String outputPath,
  }) async {
    final command =
        '-i "$videoPath" -i "$maskPath" -filter_complex "[0:v][1:v]alphamerge" -c:a copy "$outputPath" -y';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    } else {
      return null;
    }
  }
}
