class VideoProject {
  final String id;
  final String title;
  final String description;
  final String templateType;
  final String resolution;
  final int durationInSeconds;
  final List<String> mediaFilePaths;
  final List<AudioTrack> audioTracks;
  final TextOverlay? textOverlay;
  final Watermark? watermark;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? lastModified;
  final String? videoOutputPath;
  final double? renderProgress;

  VideoProject({
    required this.id,
    required this.title,
    required this.description,
    required this.templateType,
    required this.resolution,
    required this.durationInSeconds,
    required this.mediaFilePaths,
    required this.audioTracks,
    this.textOverlay,
    this.watermark,
    this.isFavorite = false,
    required this.createdAt,
    this.lastModified,
    this.videoOutputPath,
    this.renderProgress = 0.0,
  });

  VideoProject copyWith({
    String? title,
    String? description,
    List<String>? mediaFilePaths,
    List<AudioTrack>? audioTracks,
    TextOverlay? textOverlay,
    Watermark? watermark,
    bool? isFavorite,
    String? videoOutputPath,
    double? renderProgress,
  }) {
    return VideoProject(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      templateType: templateType,
      resolution: resolution,
      durationInSeconds: durationInSeconds,
      mediaFilePaths: mediaFilePaths ?? this.mediaFilePaths,
      audioTracks: audioTracks ?? this.audioTracks,
      textOverlay: textOverlay ?? this.textOverlay,
      watermark: watermark ?? this.watermark,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      lastModified: DateTime.now(),
      videoOutputPath: videoOutputPath ?? this.videoOutputPath,
      renderProgress: renderProgress ?? this.renderProgress,
    );
  }
}

class AudioTrack {
  final String id;
  final String filePath;
  final String trackType; // 'bgm', 'voiceover', 'sfx'
  final double volume;
  final double pitch;
  final int startTimeMs;
  final int durationMs;
  final bool isMuted;

  AudioTrack({
    required this.id,
    required this.filePath,
    required this.trackType,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.startTimeMs = 0,
    this.durationMs = 0,
    this.isMuted = false,
  });
}

class TextOverlay {
  final String id;
  final String text;
  final String fontFamily;
  final double fontSize;
  final String hexColor;
  final double xPosition;
  final double yPosition;
  final double width;
  final double height;
  final int startTimeMs;
  final int durationMs;
  final bool isBold;
  final bool isItalic;

  TextOverlay({
    required this.id,
    required this.text,
    this.fontFamily = 'Poppins',
    this.fontSize = 24,
    this.hexColor = '#FFFFFF',
    this.xPosition = 0,
    this.yPosition = 0,
    this.width = 1080,
    this.height = 100,
    this.startTimeMs = 0,
    this.durationMs = 0,
    this.isBold = false,
    this.isItalic = false,
  });
}

class Watermark {
  final String id;
  final String imagePath;
  final double xPosition;
  final double yPosition;
  final double width;
  final double height;
  final double opacity;

  Watermark({
    required this.id,
    required this.imagePath,
    this.xPosition = 10,
    this.yPosition = 10,
    this.width = 150,
    this.height = 50,
    this.opacity = 0.8,
  });
}
