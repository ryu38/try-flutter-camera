import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:try_flutter_camera/ui/camera_view.dart';

late CameraDescription? camera;
final cameraProvider = Provider((ref) => camera);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  camera = cameras.isNotEmpty ? cameras[1] : null;

  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Color(0xfffafafa), // status bar color
  // ));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(ProviderScope(
    child: MyApp()
  ));
}

class MyApp extends StatelessWidget {

  const MyApp({ Key? key }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xfffafafa),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white)
      ),
      home: CameraView(),
    );
  }
}
