import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gatevision/dashboardview.dart';
import 'package:gatevision/historyview.dart';
import 'package:gatevision/peopleview.dart';
import 'package:gatevision/settingsview.dart';

class HomeView extends ConsumerWidget {
  HomeView({Key? key}) : super(key: key);

  final PageController pageController = PageController();
  final SideMenuController sidemenuController = SideMenuController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var width = MediaQuery.of(context).size.width;
    sidemenuController.addListener((po) {
      pageController.jumpToPage(po);
      ref.watch(_currentPage.notifier).state = po;
    });
    return Scaffold(
      bottomNavigationBar: width >= 500
          ? null
          : BottomNavigationBar(
              selectedItemColor: Colors.deepPurpleAccent,
              unselectedItemColor: Colors.grey,
              currentIndex: ref.watch(_currentPage),
              onTap: (selected) {
                pageController.jumpToPage(selected);
                ref.watch(_currentPage.notifier).state = selected;
              },
              items: _BottomBar.values.map((e) {
                Icon icon = const Icon(Icons.dashboard);
                String label = 'Dashboard';
                switch (e) {
                  case _BottomBar.dashboard:
                    break;
                  case _BottomBar.history:
                    icon = const Icon(Icons.history);
                    label = 'History';
                    break;
                  case _BottomBar.staff:
                    icon = const Icon(Icons.people);
                    label = 'Staff';
                    break;
                  case _BottomBar.settings:
                    icon = const Icon(Icons.settings);
                    label = 'Settings';
                    break;
                }
                return BottomNavigationBarItem(
                  icon: icon,
                  label: label,
                );
              }).toList()),
      body: Row(children: [
        width >= 500
            ? SideMenu(
                title: SizedBox(
                    width: 120,
                    height: 120,
                    child: Image.asset('images/binghamlogo.png')),
                footer: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Emmanuel ',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                items: [
                  SideMenuItem(
                    priority: 0,
                    title: 'Dashboard',
                    icon: const Icon(Icons.dashboard),
                    onTap: (page, _) {
                      sidemenuController.changePage(page);
                    },
                  ),
                  SideMenuItem(
                    priority: 1,
                    title: 'History',
                    icon: const Icon(Icons.history),
                    onTap: (page, _) {
                      sidemenuController.changePage(page);
                    },
                  ),
                  SideMenuItem(
                    priority: 2,
                    title: 'People',
                    icon: const Icon(Icons.people),
                    onTap: (page, _) {
                      sidemenuController.changePage(page);
                    },
                  ),
                  SideMenuItem(
                    priority: 3,
                    title: 'Settings',
                    icon: const Icon(Icons.settings),
                    onTap: (page, _) {
                      sidemenuController.changePage(page);
                    },
                  )
                ],
                controller: sidemenuController,
                style: SideMenuStyle(
                  displayMode: SideMenuDisplayMode.auto,
                  hoverColor: Colors.blue[100],
                  selectedColor: Colors.blue[600],
                  selectedTitleTextStyle: const TextStyle(color: Colors.white),
                  selectedIconColor: Colors.white,
                  unselectedIconColor: Colors.white70,
                  unselectedTitleTextStyle:
                      const TextStyle(color: Colors.white70),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 79, 117, 134),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ]),
                  backgroundColor: const Color.fromARGB(255, 79, 117, 134),
                ),
              )
            : Container(),
        Expanded(
            child: PageView(
          controller: pageController,
          children: [
            const DashboardView(),
            HistoryView(),
            SafeArea(child: PeopleView()),
            const SettingsView()
          ],
        ))
      ]),
    );
  }
}

enum _BottomBar { dashboard, history, staff, settings }

final _currentPage = StateProvider.autoDispose((ref) => 0);
