import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
// import 'package:image_picker/image_picker.dart';

import 'cameraview.dart';
import 'dashboard_stats.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var width = MediaQuery.of(context).size.width;
    return ref.watch(camerasProvider).when(
        data: (List<CameraDescription> data) {
      return width >= 500
          ? Row(
              children: [
                const Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: DashboardStats(),
                )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CameraApp(
                      cameras: data,
                    ),
                  ),
                ),
              ],
            )
          : SafeArea(
              child: Column(
                children: [
                  const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: DashboardStats(),
                      )),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CameraApp(
                        cameras: data,
                      ),
                    ),
                  ),
                ],
              ),
            );
    }, error: (Object error, StackTrace stackTrace) {
      return const Text("ERROR");
    }, loading: () {
      return const CircularProgressIndicator.adaptive();
    });
  }
}

final initializeCamera =
    FutureProvider.family<void, CameraController>((ref, controller) async {
  await controller.initialize();
});

final camerasProvider = FutureProvider<List<CameraDescription>>(
    (ref) async => await availableCameras());
