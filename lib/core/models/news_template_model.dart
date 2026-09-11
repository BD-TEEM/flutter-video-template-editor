import 'package:flutter/material.dart';

class TemplateModel {
  final String id;
  final String baseUrl;
  final double width;
  final double height;
  final String imgPath;
  final String overlayVideoPath;
  final String hasAudio;
  final int videoTime;
  final List<TemplateInput> inputs;

  TemplateModel({
    required this.id,
    required this.baseUrl,
    required this.width,
    required this.height,
    required this.imgPath,
    required this.overlayVideoPath,
    required this.hasAudio,
    required this.videoTime,
    required this.inputs,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> rawJson) {
    final jsonData = rawJson['json'];
    final inputList = jsonData['input'] as List;

    return TemplateModel(
      id: rawJson['id'] ?? '',
      baseUrl: rawJson['base_url'] ?? '',
      width: double.tryParse(jsonData['width'].toString()) ?? 1280.0,
      height: double.tryParse(jsonData['height'].toString()) ?? 720.0,
      imgPath: (rawJson['base_url'] ?? '') + (jsonData['img'] ?? ''),
      overlayVideoPath: (rawJson['base_url'] ?? '') + (jsonData['path'] ?? ''),
      hasAudio: jsonData['audio'] ?? 'no',
      videoTime: jsonData['wipeinfo']?['videotime'] ?? 10,
      inputs: inputList.map((e) => TemplateInput.fromJson(e)).toList(),
    );
  }
}

class TemplateInput {
  final String type; // textinput or video
  final String displayName;
  final String textType; // single or multiline
  final PositionConfig position;
  final Color backgroundColor;
  final Color textColor;
  final int inTime;
  final int stayTime;

  TemplateInput({
    required this.type,
    required this.displayName,
    required this.textType,
    required this.position,
    required this.backgroundColor,
    required this.textColor,
    required this.inTime,
    required this.stayTime,
  });

  factory TemplateInput.fromJson(Map<String, dynamic> json) {
    return TemplateInput(
      type: json['type'] ?? 'textinput',
      displayName: json['diplayname'] ?? '',
      textType: json['texttype'] ?? 'single',
      position: PositionConfig.fromJson(json['postions']),
      backgroundColor: _parseColor(json['backcolor']),
      textColor: _parseColor(json['textcolor']),
      inTime: json['texttime']?['intime'] ?? 0,
      stayTime: json['texttime']?['staytime'] ?? 0,
    );
  }

  static Color _parseColor(String colorStr) {
    if (colorStr.isEmpty || colorStr == '#0000') return Colors.transparent;
    if (colorStr == 'red') return Colors.red;
    if (colorStr.startsWith('rgb')) {
      final match = RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)').firstMatch(colorStr);
      if (match != null) {
        return Color.fromRGBO(
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
          double.parse(match.group(4) ?? '1.0'),
        );
      }
    }
    return Colors.transparent;
  }
}

class PositionConfig {
  final double x, y, w, h;
  PositionConfig({required this.x, required this.y, required this.w, required this.h});

  factory PositionConfig.fromJson(Map<String, dynamic> json) {
    return PositionConfig(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      w: (json['w'] as num).toDouble(),
      h: (json['h'] as num).toDouble(),
    );
  }
}
