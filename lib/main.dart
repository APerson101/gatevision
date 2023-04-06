import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gatevision/models/usermodel.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'adminview.dart';
import 'firebase_options.dart';
import 'homeview.dart';
import 'loginview.dart';
import 'models/attendance.dart';
import 'models/staffmodel.dart';
import 'repo/db.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  getIt.registerSingleton<DatabaseHandler>(DatabaseHandler(
      textRecognizer: TextRecognizer(script: TextRecognitionScript.latin),
      isar: await Isar.open(
          [AttendanceSchema, StaffModelSchema, UserModelSchema])));

  getIt.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  getIt.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance());

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var type = ref.watch(authenticationStatus);
    var activeuser = getIt<SharedPreferences>().getString('activeuser');
    return ref.watch(setActiveUser(activeuser)).maybeWhen(
        data: (_) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData()
                  .copyWith(textTheme: GoogleFonts.alegreyaSansTextTheme()),
              home: type == 'user'
                  ? HomeView()
                  : type == 'admin'
                      ? const AdminView()
                      : LoginView(),
            ),
        orElse: () => Container());
  }
}

// 1= visitor
// 0= staff

final authenticationStatus = StateProvider<String>((ref) {
  return getIt<SharedPreferences>().getString('signedin') ?? 'none';
});

final setActiveUser =
    FutureProvider.family.autoDispose<void, String?>((ref, user) async {
  if (user != 'none') {
    var activeuser = await getIt<DatabaseHandler>()
        .users
        ?.filter()
        .emailEqualTo(user)
        .findFirst();
    activeuser != null
        ? getIt<DatabaseHandler>().setActiveUser(activeuser)
        : null;
  }
});
