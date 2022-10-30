import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pitoco Screen Capture and Share',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Screenshot(
        controller: screenshotController,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Pitoco Screen Capture and Share'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Tu album mas escuchado en Estupify de 2022 es:"),
                  const SizedBox(height: 20),
                  const PitocoImage(),
                  const SizedBox(height: 20),
                  const Text(
                      "¡Compartíle a tus seres queridos para que sepan la clase de enfermo que sos!"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await shareImage(
                        useWidget: false,
                        controller: screenshotController,
                      ); // save image to gallery
                    },
                    child: const Text(
                        'Capturame esta, y compartí TODA LA PANTALLA'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await shareImage(
                          useWidget: true,
                          controller: screenshotController,
                          widget: const PitocoImage()); // save image to gallery
                    },
                    child: const Text(
                        'Capturame esta, y compartí UN WIDGET ESPECIFICO'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> shareImage(
      {bool? useWidget,
      Widget? widget,
      required ScreenshotController controller}) async {
    if (useWidget == true) {
      final status = await Permission.storage
          .request(); // this is for getting the permission to save the image to gallery
      final appDir =
          await getApplicationDocumentsDirectory(); // this is for getting the path to the app directory
      // final extDir = await getExternalStorageDirectory(); // this is for getting the external storage directory
      if (status.isGranted) {
        final bytes = await controller.captureFromWidget(
          widget!,
          pixelRatio: 3.0,
          delay: const Duration(milliseconds: 500),
        );

        // final pickedImage = await ImageGallerySaver.saveImage(
        //   bytes,
        //   quality: 60,
        //   name: 'pitocoxd.jpg',
        // );

        final xf = XFile.fromData(bytes);

        final fileName =
            DateTime.now().toString().replaceAll('.', '_').replaceAll(':', '_');

        await xf.saveTo('${appDir.path}/$fileName.jpg');

        await Share.shareFiles(['${appDir.path}/$fileName.jpg'],
            text: 'Pitoco Screen Capture and Share');
      }
    } else {
      final status = await Permission.storage.request();
      List<String> files = [];

      if (status.isGranted) {
        final appDir = await getApplicationDocumentsDirectory();
        final time = DateTime.now()
            .toString()
            .replaceAll('.', '_')
            .replaceAll(':', '_'); // this is for getting the current time
        String? filePath = await controller.captureAndSave(
          appDir.path,
          fileName: 'pitoco_$time.jpg',
          delay: const Duration(
            milliseconds: 200,
          ),
        );

        if (filePath != null) {
          files.add(filePath);
        }
      }

      await Share.shareFiles(files, text: 'Pitoco Screen Capture and Share');
    }
  }
}

class PitocoImage extends StatelessWidget {
  const PitocoImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Image(
        image: AssetImage('assets/images/imagen_magica.jpeg'),
      ),
    );
  }
}
