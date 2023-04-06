import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gatevision/repo/db.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import 'licenseviewer.dart';
import 'main.dart';

class OcrView extends HookConsumerWidget {
  const OcrView({Key? key, required this.xfilepath}) : super(key: key);
  final XFile xfilepath;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController();

    useEffect(() {
      if (ref.watch(currentStateProvider) != 'Starting....') {
        // animate
        animationController.stop();
      }
      return null;
    }, [ref.watch(currentStateProvider)]);
    useAnimation(animationController);
    return ref.watch(_runOcr(xfilepath)).when(data: (String data) {
      var datas = cleanedText(data);
      return LicenseView(extractedText: datas);
    }, error: (Object error, StackTrace stackTrace) {
      debugPrint(stackTrace.toString());
      return Scaffold(
          appBar: AppBar(), body: const Center(child: Text("Failed to run")));
    }, loading: () {
      return Scaffold(
        body: SafeArea(
            child: Center(
          child: Lottie.asset('animations/car.json',
              controller: animationController, onLoaded: (composition) {
            animationController
              ..duration = composition.duration
              ..forward()
              ..repeat();
          }),
        )),
      );
    });
  }

  cleanedText(String text) {
    debugPrint('before cleaning up text: $text');
    String removedItems =
        (((text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').replaceAll('\n', ''))
                .replaceAll(' ', ''))
            .replaceAll('-', ''));
    for (var state in states) {
      removedItems = removedItems.replaceAll(state.toLowerCase(), '');
    }
    for (var slogan in slogans) {
      removedItems = removedItems.replaceAll(
          slogan.toLowerCase().replaceAll(RegExp(r' '), ''), '');
    }
    removedItems.replaceAll('federal', '');
    removedItems.replaceAll('republic', '');
    removedItems.replaceAll('of', '');
    removedItems.replaceAll('nigeria', '');
    debugPrint('After cleaning up text: $removedItems');

    return removedItems;
  }
}

final _runOcr = FutureProvider.family<String, XFile>((ref, xfile) async {
  Future.delayed(
    const Duration(seconds: 3),
  );
  var text = await getIt<DatabaseHandler>().runOCR(xfile.path);
  ref.watch(currentStateProvider.notifier).setState('done');
  return text;
  // return Future.delayed(const Duration(seconds: 1), () => 'STAFF');
  // var url = await getIt<APIHandler>().saveImgToBucket(xfile);

  // return await getIt<APIHandler>().getTextsFromImage(url);
});

class CurrentState extends StateNotifier<String> {
  CurrentState() : super('Starting....');
  setState(String newState) {
    state = newState;
  }
}

final currentStateProvider =
    StateNotifierProvider<CurrentState, String>((ref) => CurrentState());

class LoadingState extends StateNotifier<bool> {
  LoadingState() : super(true);
  setState(bool newState) {
    state = newState;
  }
}

final loadingstateProvider =
    StateNotifierProvider<LoadingState, bool>((ref) => LoadingState());
