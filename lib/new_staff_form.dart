import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gatevision/models/staffmodel.dart';
import 'package:gatevision/repo/db.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class NewStaffFormView extends ConsumerWidget {
  NewStaffFormView({Key? key}) : super(key: key);
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final imgeProvider = FutureProvider((ref) async =>
      await ImagePicker().pickImage(source: ImageSource.gallery));
  final imageController = StateProvider<XFile?>((ref) => null);
  final GlobalKey<FormState> _key = GlobalKey();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("New Staff Form"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Form(
                key: _key,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StaffFormField(
                      controller: firstnameController,
                      labelText: 'Enter first name',
                      prefixIcon: const Icon(Icons.abc),
                    ),
                    const SizedBox(height: 25),
                    _StaffFormField(
                      controller: lastnameController,
                      labelText: 'Enter last name',
                      prefixIcon: const Icon(Icons.abc),
                    ),
                    const SizedBox(height: 25),
                    _StaffFormField(
                      controller: idController,
                      labelText: 'Enter Staff ID',
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                    const SizedBox(height: 25),
                    _StaffFormField(
                      controller: licenseController,
                      labelText: 'Enter License number without - and spaces',
                      prefixIcon: const Icon(Icons.car_rental_rounded),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          child: const Text("select image"),
                          onPressed: () async {
                            var data = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            debugPrint('image not null');

                            ref.watch(imageController.notifier).state = data;
                          },
                        ),
                        ref.watch(imageController) == null
                            ? const SizedBox()
                            : SizedBox(
                                width: 100,
                                height: 100,
                                child: Image.file(
                                    File(ref.watch(imageController)!.path)))
                      ],
                    ),
                    const SizedBox(height: 200),
                    ElevatedButton(
                        onPressed: () async {
                          var validated = _key.currentState?.validate();

                          if (validated == true) {
                            var img = ref.watch(imageController) != null
                                ? await ref
                                    .watch(imageController)!
                                    .readAsBytes()
                                : null;
                            if (context.mounted) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return StaffSavingView(
                                    newStaff: StaffModel()
                                      ..firstname = firstnameController.text
                                      ..lastname = lastnameController.text
                                      ..staffID = idController.text
                                      ..licenseNumber = licenseController.text
                                      ..image = img);
                              }));
                            }
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      "Check form",
                                      style: TextStyle(color: Colors.white),
                                    )));
                          }
                        },
                        child: const Text("Save new Staff"))
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class StaffSavingView extends HookConsumerWidget {
  const StaffSavingView({super.key, required this.newStaff});
  final StaffModel newStaff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationContoller = useAnimationController();

    useEffect(() {
      ref.watch(_savingStatus) == 1
          ? {animationContoller.reset(), animationContoller.stop()}
          : null;
      return null;
    }, [ref.watch(_savingStatus)]);
    useAnimation(animationContoller);
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Lottie.asset('animations/integration.json',
                controller: animationContoller, onLoaded: (composition) {
              animationContoller
                ..duration = composition.duration
                ..forward()
                ..repeat();
            }),
            const SizedBox(height: 10),
            ref.watch(saveToDB(newStaff)).when(
                data: (data) {
                  return SizedBox(
                    height: 150,
                    child: Column(
                      children: [
                        const Text("SUCCESS!!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 27,
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                              ..pop()
                              ..pop();
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 75)),
                          child: const Text(
                            "Back",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                error: (er, st) => const Text("Failed to save"),
                loading: () => const Text(
                      "SAVING...",
                      style: TextStyle(fontSize: 20),
                    ))
          ],
        ),
      )),
    );
  }
}

final _savingStatus = StateProvider((ref) => 0);

final saveToDB =
    FutureProvider.autoDispose.family<bool, StaffModel>((ref, newStaff) async {
  final getIt = GetIt.instance;
  ref.watch(_savingStatus.notifier).state = 0;
  await Future.delayed(const Duration(seconds: 4));

  await getIt<DatabaseHandler>().addUpdateNewStaff(newStaff);
  ref.watch(_savingStatus.notifier).state = 1;

  return true;
});

class _StaffFormField extends ConsumerWidget {
  const _StaffFormField(
      {required this.controller,
      required this.labelText,
      required this.prefixIcon});
  final TextEditingController controller;
  final String labelText;
  final Widget prefixIcon;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (name) {
        return name != null
            ? name.isEmpty
                ? 'field cannot be empty'
                : null
            : null;
      },
      scrollPadding: const EdgeInsets.only(bottom: 40),
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          helperStyle: const TextStyle(
            fontSize: 16,
          ),
          hintStyle: const TextStyle(
            fontSize: 16,
          ),
          errorStyle: const TextStyle(
            fontSize: 16,
          ),
          labelStyle: const TextStyle(
            fontSize: 16,
          ),
          prefixIcon: Align(widthFactor: 1, heightFactor: 1, child: prefixIcon),
          labelText: labelText),
      controller: controller,
    );
  }
}
