import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_ml_image_transformation/flutter_ml_image_transformation.dart';
import 'package:try_flutter_camera/utils/file_utils.dart';
import 'package:try_flutter_camera/utils/image_processor.dart';

class PhotoPreview extends StatelessWidget {

  final String _imagePath;

  const PhotoPreview(
    this._imagePath,
    { Key? key }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color(0xffc2c5aa),
          ),
          elevation: 0,
        )
      ),
      backgroundColor: const Color(0xffc2c5aa),
      body: _Content(_imagePath)
    );
  }
}

class _Content extends StatefulWidget {
  final String imagePath;

  const _Content(
    this.imagePath,
    { Key? key }
  ) : super(key: key);

  @override
  __ContentState createState() => __ContentState();
}

class __ContentState extends State<_Content> {
  late File _imgFile = File(widget.imagePath);
  bool _isModelset = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      final config = _MLConfig();
      final modelPath = 
          await FileUtils.copyAssetToAppDir(config.assetModelPath, config.appDirModelPath);
      final result = await MLImageTransformer.setModel(modelPath: modelPath);
      if (result != null) throw Exception(result);
      setState(() {
        _isModelset = true;
      });
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> transformImage() async {
    try {
      final outputPath = await FileUtils.joinPathToCache(_Const.outputName);
      final result = await MLImageTransformer.transformImage(
        imagePath: widget.imagePath, outputPath: outputPath
      );
      if (result == null) {
        final outputFile = File(outputPath);
        if (!mounted) return;
        setState(() {
          _imgFile = outputFile;
        });
      } else {
        throw Exception(result);
      }
    }on Exception catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.file(_imgFile),
        Text(_imgFile.path),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () async {
            final stopwatch = Stopwatch()..start();
            final processedImg = 
                await ImageProcessor.resizeCropSquare(_imgFile, 256, 'testimg.jpg');
            print('exec time: ${stopwatch.elapsedMilliseconds}');
            if (processedImg != null) {
              setState(() {
                _imgFile = processedImg;
              });
              print(_imgFile.path);
            }
          },
          child: const Text('crop square'),
        ),
        ElevatedButton(
          onPressed:_isModelset ? () async {
            final stopwatch = Stopwatch()..start();
            await transformImage();
            print('exec time: ${stopwatch.elapsedMilliseconds}');
          } : null,
          child: const Text('transform image'),
        )
      ],
    );
  }
}

class _Const {
  static const outputName = 'output.jpg';
}

class _MLConfig {
  final String assetModelPath;
  final String appDirModelPath;

  // private constructor
  const _MLConfig._(
    this.assetModelPath,
    this.appDirModelPath
  );

  factory _MLConfig() {
    final _MLConfig instance;
    if (Platform.isAndroid) {
      instance = const _MLConfig._android();
    } else if (Platform.isIOS) {
      instance = const _MLConfig._ios();
    } else {
      throw Exception("the platform not supported; supporting ios or android");
    }
    return instance;
  }

  const _MLConfig._android(): this._(
    'assets/pytorch_model/GANModelFloat32.ptl',
    'GANModel.ptl'
  );

  const _MLConfig._ios(): this._(
    'assets/coreml_model/GANModelFloat16.mlmodel',
    'GANModel.mlmodel'
  );
}
