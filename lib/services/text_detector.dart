import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dart_bert_tokenizer/dart_bert_tokenizer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:path_provider/path_provider.dart';

class DetectionResult {
  final double aiProbability;
  final double humanProbability;

  const DetectionResult({
    required this.aiProbability,
    required this.humanProbability,
  });
}

class AiDetector {
  final OnnxRuntime _ort = OnnxRuntime();

  OrtSession? _session;
  WordPieceTokenizer? _tokenizer;

  String? _modelDirectory;

  Future<void> initialize() async {
    print('AI DETECTOR: starting initialization');

    try {
      print('AI DETECTOR: loading model.onnx...');

      final modelData = await rootBundle.load('assets/text_model/model.onnx');

      print(
        'AI DETECTOR: model.onnx loaded: '
        '${modelData.lengthInBytes} bytes',
      );

      print('AI DETECTOR: loading model.onnx.data...');

      final externalData = await rootBundle.load(
        'assets/text_model/model.onnx.data',
      );

      print(
        'AI DETECTOR: model.onnx.data loaded: '
        '${externalData.lengthInBytes} bytes',
      );


      final tempDirectory = await getTemporaryDirectory();

      final modelDirectory = Directory(
        '${tempDirectory.path}/ai_detector_model',
      );

      if (!await modelDirectory.exists()) {
        await modelDirectory.create(recursive: true);
      }

      _modelDirectory = modelDirectory.path;

      print(
        'AI DETECTOR: model directory = '
        '${modelDirectory.path}',
      );

      final modelFile = File('${modelDirectory.path}/model.onnx');

      await modelFile.writeAsBytes(
        modelData.buffer.asUint8List(
          modelData.offsetInBytes,
          modelData.lengthInBytes,
        ),
        flush: true,
      );

      print('AI DETECTOR: model.onnx written to disk');


      final externalDataFile = File('${modelDirectory.path}/model.onnx.data');

      await externalDataFile.writeAsBytes(
        externalData.buffer.asUint8List(
          externalData.offsetInBytes,
          externalData.lengthInBytes,
        ),
        flush: true,
      );

      print('AI DETECTOR: model.onnx.data written to disk');

      // ============================================================
      // 5. VERIFY BOTH FILES EXIST
      // ============================================================

      final modelExists = await modelFile.exists();
      final dataExists = await externalDataFile.exists();

      print('AI DETECTOR: model file exists = $modelExists');

      print('AI DETECTOR: external data exists = $dataExists');

      if (!modelExists) {
        throw StateError('model.onnx was not successfully written.');
      }

      if (!dataExists) {
        throw StateError('model.onnx.data was not successfully written.');
      }

      // ============================================================
      // 6. CREATE ONNX SESSION
      //
      // createSession takes a FILE PATH, not Uint8List.
      // ============================================================

      print('AI DETECTOR: creating ONNX session...');

      _session = await _ort.createSession(modelFile.path);

      print('AI DETECTOR: ONNX session created!');

      print(
        'AI DETECTOR: model inputs = '
        '${_session!.inputNames}',
      );

      print(
        'AI DETECTOR: model outputs = '
        '${_session!.outputNames}',
      );

      // ============================================================
      // 7. LOAD TOKENIZER
      // ============================================================

      print('AI DETECTOR: loading tokenizer...');

      final tokenizerJson = await rootBundle.loadString(
        'assets/text_model/tokenizer.json',
      );

      _tokenizer = WordPieceTokenizer.fromTokenizerJsonString(tokenizerJson);

      print('AI DETECTOR: tokenizer loaded!');

      // ============================================================
      // 8. FINAL CHECK
      // ============================================================

      if (_session == null) {
        throw StateError('ONNX session was not created.');
      }

      if (_tokenizer == null) {
        throw StateError('Tokenizer was not created.');
      }

      print('AI DETECTOR: initialization complete!');
    } catch (e, stackTrace) {
      print('AI DETECTOR INITIALIZATION ERROR: $e');

      print(stackTrace);

      await _session?.close();

      _session = null;
      _tokenizer = null;

      rethrow;
    }
  }

  Future<DetectionResult> detect(String text) async {
    print('AI DETECTOR: starting detection');

    // ============================================================
    // CHECK INITIALIZATION
    // ============================================================

    if (_session == null || _tokenizer == null) {
      throw StateError('AiDetector has not been initialized.');
    }

    if (text.trim().isEmpty) {
      throw ArgumentError('Text cannot be empty.');
    }

    // ============================================================
    // TOKENIZE
    // ============================================================

    print('AI DETECTOR: tokenizing text...');

    final encoding = _tokenizer!.encode(text);

    final inputIds = Int64List.fromList(encoding.ids);

    final attentionMask = Int64List.fromList(encoding.attentionMask);

    final sequenceLength = inputIds.length;

    print(
      'AI DETECTOR: token count = '
      '$sequenceLength',
    );

    if (sequenceLength == 0) {
      throw StateError('Tokenizer returned zero tokens.');
    }

    // ============================================================
    // CREATE INPUT TENSORS
    // ============================================================

    final inputIdsValue = await OrtValue.fromList(inputIds, [
      1,
      sequenceLength,
    ]);

    final attentionMaskValue = await OrtValue.fromList(attentionMask, [
      1,
      sequenceLength,
    ]);

    try {
      // ============================================================
      // RUN MODEL
      // ============================================================

      print('AI DETECTOR: running ONNX model...');

      final outputs = await _session!.run({
        'input_ids': inputIdsValue,
        'attention_mask': attentionMaskValue,
      });

      print('AI DETECTOR: model finished!');

      print('AI DETECTOR: outputs = ${outputs.keys}');

      // ============================================================
      // GET LOGITS
      // ============================================================

      final logitsOutput = outputs['logits'];

      if (logitsOutput == null) {
        throw StateError(
          'The model did not return "logits". '
          'Available outputs: ${outputs.keys}',
        );
      }

      final logits = await logitsOutput.asFlattenedList();

      print('AI DETECTOR: logits = $logits');

      if (logits.length < 2) {
        throw StateError(
          'Expected at least 2 logits, '
          'but received ${logits.length}.',
        );
      }

      // ============================================================
      // CONVERT LOGITS TO PROBABILITIES
      // ============================================================

      final humanLogit = (logits[0] as num).toDouble();

      final aiLogit = (logits[1] as num).toDouble();

      final maxLogit = math.max(humanLogit, aiLogit);

      final humanExp = math.exp(humanLogit - maxLogit);

      final aiExp = math.exp(aiLogit - maxLogit);

      final total = humanExp + aiExp;

      final humanProbability = humanExp / total;

      final aiProbability = aiExp / total;

      print(
        'AI DETECTOR: human probability = '
        '$humanProbability',
      );

      print(
        'AI DETECTOR: AI probability = '
        '$aiProbability',
      );

      return DetectionResult(
        aiProbability: aiProbability,
        humanProbability: humanProbability,
      );
    } finally {
      await inputIdsValue.dispose();
      await attentionMaskValue.dispose();
    }
  }

  Future<void> dispose() async {
    print('AI DETECTOR: disposing...');

    await _session?.close();

    _session = null;
    _tokenizer = null;

    // Clean up our copied model files.
    if (_modelDirectory != null) {
      try {
        final directory = Directory(_modelDirectory!);

        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      } catch (e) {
        print(
          'AI DETECTOR: could not clean up '
          'temporary model files: $e',
        );
      }
    }

    _modelDirectory = null;
  }
}
