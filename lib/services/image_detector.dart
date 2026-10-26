import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

const String _kModelAsset = 'assets/image_model/model.onnx';
const int _kSize = 224;
const List<double> _kMean = [0.5, 0.5, 0.5];
const List<double> _kStd = [0.5, 0.5, 0.5];
const int _kAiIndex = 0; // index of the "AI" class in the model's id2label

class DetectionResult {
  final double aiProbability;
  final double realProbability;
  const DetectionResult(this.aiProbability, this.realProbability);

  String get aiPercent => '${(aiProbability * 100).round()}%';
  String get realPercent => '${(realProbability * 100).round()}%';
}

Float32List _preprocess(String path) {
  final bytes = File(path).readAsBytesSync();
  var image = img.decodeImage(bytes);
  if (image == null) {
    throw Exception('Could not decode image');
  }
  image = img.bakeOrientation(image); 
  image = img.copyResize(
    image,
    width: _kSize,
    height: _kSize,
    interpolation: img.Interpolation.linear,
  );

  final plane = _kSize * _kSize;
  final data = Float32List(3 * plane);
  for (var y = 0; y < _kSize; y++) {
    for (var x = 0; x < _kSize; x++) {
      final p = image.getPixel(x, y);
      final i = y * _kSize + x;
      data[i] = (p.r / 255.0 - _kMean[0]) / _kStd[0];
      data[plane + i] = (p.g / 255.0 - _kMean[1]) / _kStd[1];
      data[2 * plane + i] = (p.b / 255.0 - _kMean[2]) / _kStd[2];
    }
  }
  return data;
}

class ImageDetector {
  ImageDetector._();
  static final ImageDetector instance = ImageDetector._();

  OrtSession? _session;
  Future<void>? _initFuture;

  Future<void> initialize() {
    return _initFuture ??= _load().catchError((e) {
      _initFuture = null;
      throw e;
    });
  }

  Future<void> _load() async {
    final ort = OnnxRuntime();
    _session = await ort.createSessionFromAsset(_kModelAsset);
  }

  Future<DetectionResult> detect(String imagePath) async {
    await initialize();
    final session = _session!;

    final pixels = await compute(_preprocess, imagePath);
    final input = await OrtValue.fromList(pixels, [1, 3, _kSize, _kSize]);

    final outputs = await session.run({session.inputNames.first: input});
    final out = outputs[session.outputNames.first]!;
    final raw = await out.asFlattenedList();
    final logits = raw.map((e) => (e as num).toDouble()).toList();

    await input.dispose();
    for (final v in outputs.values) {
      await v.dispose();
    }

    // Softmax over the two logits
    final maxLogit = logits.reduce(math.max);
    final exps = logits.map((l) => math.exp(l - maxLogit)).toList();
    final sum = exps.reduce((a, b) => a + b);
    final probs = exps.map((e) => e / sum).toList();

    final ai = probs[_kAiIndex];
    return DetectionResult(ai, 1.0 - ai);
  }

  Future<void> dispose() async {
    await _session?.close();
    _session = null;
    _initFuture = null;
  }
}