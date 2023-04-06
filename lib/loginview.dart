import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gatevision/main.dart';
import 'package:gatevision/repo/db.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends HookConsumerWidget {
  LoginView({Key? key}) : super(key: key);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController();

    useEffect(() {
      ref.watch(loginState) == LoadingStates.loading
          ? {animationController.repeat()}
          : {animationController.reset(), animationController.stop()};
      return null;
    }, [ref.watch(loginState)]);

    useAnimation(animationController);
    return Scaffold(
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: ref.watch(loginState) == LoadingStates.loading,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Lottie.asset('animations/loading.json',
                        width: 300,
                        height: 300,
                        controller: animationController,
                        onLoaded: (composition) {
                      animationController.duration = composition.duration;
                    }),
                    const SizedBox(height: 10),
                    const Text(
                      "Bingham Vistor management System",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(),
                        ),
                        Text(
                          'Please enter the details below to continue',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Expanded(
                          child: Divider(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                        controller: emailController,
                        scrollPadding: const EdgeInsets.only(bottom: 40),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) {
                          return email != null
                              ? EmailValidator.validate(email)
                                  ? null
                                  : 'Enter valid Email'
                              : null;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
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
                            prefixIcon: const Align(
                                widthFactor: 1,
                                heightFactor: 1,
                                child: Icon(Icons.email)),
                            labelText: 'Enter Email')),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: passwordController,
                      obscureText: ref.watch(_passwordView),
                      scrollPadding: const EdgeInsets.only(bottom: 40),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (password) {
                        if (password == null) {
                          return null;
                        } else {
                          if (password.isEmpty) {
                            return 'Enter a password';
                          } else {
                            return null;
                          }
                        }
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          suffixIcon: Align(
                            widthFactor: 1,
                            heightFactor: 1,
                            child: IconButton(
                                onPressed: () {
                                  // toggle password visibility
                                  ref.watch(_passwordView.notifier).state =
                                      !ref.watch(_passwordView);
                                },
                                icon: FaIcon(ref.watch(_passwordView) == false
                                    ? FontAwesomeIcons.eyeSlash
                                    : FontAwesomeIcons.eye)),
                          ),
                          labelText: 'Enter password',
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
                          prefixIcon: const Align(
                            widthFactor: 1,
                            heightFactor: 1,
                            child: Icon(Icons.lock),
                          )),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      backgroundColor: Colors.red,
                                      closeIconColor: Colors.white,
                                      showCloseIcon: true,
                                      content: ListTile(
                                        title: Center(
                                          child: Text(
                                            "Contact admin to recover password",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                        trailing: Align(
                                            widthFactor: 1,
                                            heightFactor: 1,
                                            child: FaIcon(
                                                FontAwesomeIcons.faceSadCry,
                                                color: Colors.white)),
                                      )));
                            },
                            child: const Text('Forgot Password?',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                )))
                      ],
                    ),
                    GestureDetector(
                        onTap: () async {
                          if (EmailValidator.validate(emailController.text)) {
                            var current = ref.watch(loginState);
                            ref.watch(loginState.notifier).state =
                                current == LoadingStates.loading
                                    ? LoadingStates.idle
                                    : LoadingStates.loading;
                            String type = '';
                            if (passwordController.text == 'admin' &&
                                emailController.text == 'admin@bingham.com') {
                              type = 'admin';
                            } else {
                              var user = await GetIt.I<DatabaseHandler>()
                                  .getspecificUser(emailController.text,
                                      passwordController.text);

                              if (user == null && context.mounted) {
                                ref.watch(loginState.notifier).state =
                                    LoadingStates.idle;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        closeIconColor: Colors.white,
                                        backgroundColor: Colors.red,
                                        content: Center(
                                          child: Text(
                                            "No such user",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        )));
                              } else {
                                // set user property
                                type = 'user';
                                GetIt.I<SharedPreferences>().setString(
                                    'activeuser', emailController.text);

                                GetIt.I<DatabaseHandler>().setActiveUser(user!);
                              }
                            }

                            ref.watch(_login(type));
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    closeIconColor: Colors.white,
                                    backgroundColor: Colors.red,
                                    content: Center(
                                      child: Text(
                                        "Check credentials!",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )));
                          }
                        },
                        child: InkWell(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DecoratedBox(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.deepPurpleAccent.shade700),
                                  child: const Center(
                                      child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "LOGIN",
                                      style: TextStyle(
                                          fontSize: 23,
                                          letterSpacing: 3,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )))),
                        )),
                    const SizedBox(
                      height: 60,
                    ),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Text(
                          "Emmanuel Bingham",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(child: Divider())
                      ],
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

final loginState = StateProvider.autoDispose((ref) => LoadingStates.idle);
final _login =
    FutureProvider.autoDispose.family<void, String>((ref, type) async {
  // get email and password and go to appropriate page

  await Future.delayed(const Duration(seconds: 2));
  await GetIt.I<SharedPreferences>().setString('signedin', type);
  ref.watch(authenticationStatus.notifier).state = type;
});
final _passwordView = StateProvider.autoDispose((ref) => true);

enum LoadingStates { loading, idle }
