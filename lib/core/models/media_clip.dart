class MediaClip {
  final String id;
  final String path;
  final double startTime;
  final double endTime;
  final bool isBgRemoved;
  final double cropX;
  final double cropY;
  final double cropWidth;
  final double cropHeight;

  MediaClip({
    required this.id,
    required this.path,
    required this.startTime,
    required this.endTime,
    this.isBgRemoved = false,
    this.cropX = 0.0,
    this.cropY = 0.0,
    this.cropWidth = 1.0,
    this.cropHeight = 1.0,
  });

  MediaClip copyWith({
    String? id,
    String? path,
    double? startTime,
    double? endTime,
    bool? isBgRemoved,
    double? cropX,
    double? cropY,
    double? cropWidth,
    double? cropHeight,
  }) {
    return MediaClip(
      id: id ?? this.id,
      path: path ?? this.path,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBgRemoved: isBgRemoved ?? this.isBgRemoved,
      cropX: cropX ?? this.cropX,
      cropY: cropY ?? this.cropY,
      cropWidth: cropWidth ?? this.cropWidth,
      cropHeight: cropHeight ?? this.cropHeight,
    );
  }
}
