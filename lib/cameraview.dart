import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_photo_editor/flutter_photo_editor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gatevision/ocrview.dart';
import 'package:image_picker/image_picker.dart';

class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({Key? key, required this.cameras}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  State<CameraApp> createState() => _CameraAppState(cameras);
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  final List<CameraDescription> cameras;

  _CameraAppState(this.cameras);

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 10, child: CameraPreview(controller)),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          flex: 1,
          child: ButtonBar(alignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 150),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () async {
                  var picketImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (picketImage != null && context.mounted) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return OcrView(
                        xfilepath: picketImage,
                      );
                    }));
                  }
                },
                child: const Text(
                  "Gallery",
                  style: TextStyle(fontSize: 16),
                )),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 150),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () async {
                  controller.takePicture().then((picFile) async {
                    await FlutterPhotoEditor().editImage(picFile.path);

                    if (context.mounted) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return OcrView(
                          xfilepath: picFile,
                        );
                      }));
                      return;
                    }
                  });
                },
                child: const Text(
                  "Capture",
                  style: TextStyle(fontSize: 16),
                )),
          ]),
        ),
      ],
    );
  }
}

final pictaken =
    FutureProvider.family<XFile, CameraController>((ref, controller) async {
  return controller.takePicture();
});

final selectedPic = StateProvider<XFile?>((ref) => null);
