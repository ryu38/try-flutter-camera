import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:try_flutter_camera/main.dart';
import 'package:try_flutter_camera/ui/photo_preview.dart';
import 'package:try_flutter_camera/utils/file_utils.dart';

class CameraView extends ConsumerWidget {
  CameraView({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final _camera = ref.read(cameraProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color(0xffc2c5aa)
          ),
          elevation: 0,
          backgroundColor: const Color(0xffc2c5aa),
        )
      ),
      backgroundColor: const Color(0xffc2c5aa),
      body: _camera != null 
          ? _Content(_camera) 
          : const Center(
            child: Text('No cameras are available'),
          )
    );
  }
}

class _Content extends StatelessWidget {
  final CameraDescription _camera;
  late final _controller = CameraController(
    _camera, ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.jpeg
  );

  _Content(
    this._camera,
    { Key? key }
  ) : super(key: key);

  Future<void> initializeCamera() async {
    await _controller.initialize();
    await _controller.lockCaptureOrientation();
  }

  Future<void> takePhoto(BuildContext context) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final imageXFile = await _controller.takePicture();

      await FlutterExifRotation.rotateAndSaveImage(path: imageXFile.path);

      // final image = img.decodeImage(await imageXFile.readAsBytes());
      // if (image == null) throw Exception('could not decode captured image');
      // final fixedImg = img.bakeOrientation(image);
      // final inputPath = await FileUtils.joinPathToCache(_Const.inputName);
      // await File(inputPath).writeAsBytes(img.encodeJpg(fixedImg));

      print('prepare captured image: ${stopwatch.elapsedMilliseconds}');
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PhotoPreview(imageXFile.path)
        )
      );
    // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _controller.initialize(),
      builder: (context, snapshot) => 
          snapshot.connectionState == ConnectionState.done
          ? Column(
            children: [
              RotatedBox(
                quarterTurns: 0,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: CameraPreview(_controller)
                ),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () => takePhoto(context),
                  child: const Text(''),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(_Const.buttonSize / 2),
                    elevation: 0,
                    primary: const Color(0xff5f5539)
                  ),
                ),
              ),
              const Spacer(),
            ],
          )
          : const Center(child: CircularProgressIndicator())
    );
  }
}

class _Const {
  static const buttonSize = 80;

  static const inputName = 'input.jpg';
}
