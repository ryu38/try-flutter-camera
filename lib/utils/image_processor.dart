import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

class ImageProcessor {
  
  static Future<File?> resizeCropSquare(File file, int size, String path) async {
    try {
      final image = await compute(
          _ResizeCropSquare.compute, _ResizeCropSquare(file, size));
      final basePath = await getApplicationDocumentsDirectory();
      return await File('${basePath.path}/$path').writeAsBytes(encodeJpg(image!));
    } on Exception catch (e) { 
      print(e);
      return null; 
    }
  }
}

class _ResizeCropSquare {
  final File file;
  final int size;

  _ResizeCropSquare(
    this.file, this.size
  );

  static Image? compute(_ResizeCropSquare param) {
    try {
      final image = decodeImage(param.file.readAsBytesSync())!;
      return copyResizeCropSquare(image, param.size);
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }
}