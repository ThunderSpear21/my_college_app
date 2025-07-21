import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/blocs/auth/auth_event.dart';
import 'package:frontend/blocs/auth/auth_state.dart';
import 'package:frontend/blocs/theme/theme_bloc.dart';
import 'package:frontend/blocs/theme/theme_event.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/view_profile_screen.dart';
import 'package:frontend/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final data = await UserService.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildAppDrawer(context, isDarkMode),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    height: size.height * 0.3,
                    width: size.width * 0.9,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (Theme.of(context).brightness == Brightness.light)
                              ? Colors.lightBlue.shade200
                              : Colors.blue.shade500,
                          (Theme.of(context).brightness == Brightness.light)
                              ? Colors.purple.shade200
                              : Colors.purple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Welcome Back,\n${currentUser?['data']['user']['name'] ?? 'User'}!",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color:
                                  (Theme.of(context).brightness ==
                                          Brightness.dark)
                                      ? Colors.white
                                      : Colors.black,
                              width: 3,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            icon: Icon(Icons.person_2, size: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 25,
                    crossAxisSpacing: 25,
                    padding: EdgeInsets.all(12),
                    children: [
                      buildNavigationCard(
                        icon: Icons.school,
                        text: "Course Structure",
                        colour: Colors.blue,
                        onTap: () {},
                      ),
                      buildNavigationCard(
                        icon: Icons.text_snippet,
                        text: "Notes",
                        colour: Colors.green,
                        onTap: () {},
                      ),
                      buildNavigationCard(
                        icon: Icons.people,
                        text: "Connect",
                        colour: Colors.purpleAccent,
                        onTap: () {},
                      ),
                      buildNavigationCard(
                        icon: Icons.checklist_rtl,
                        text: "Attendance",
                        colour: Colors.deepOrange,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  if (currentUser?['data']?['user']?['isAdmin'] == true)
                    adminDashboard(context, size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Drawer buildAppDrawer(BuildContext context, bool isDarkMode) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDarkMode ? Colors.blue.shade500 : Colors.lightBlue.shade200,
                  isDarkMode ? Colors.purple : Colors.purple.shade200,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  currentUser?['data']['user']['name'] ?? 'User',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  currentUser?['data']['user']['email'] ?? 'user@email.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('View Profile'),
            onTap: () {
              Navigator.pop(context);
              Future.microtask(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewProfileScreen()),
                ).then((wasProfileUpdated) {
                  if (wasProfileUpdated == true) {
                    loadUserData();
                  }
                });
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Toggle Theme'),
            onTap: () {
              context.read<ThemeBloc>().add(ThemeToggled());
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              context.read<AuthBloc>().add(LoggedOut());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget buildNavigationCard({
    required IconData icon,
    required String text,
    required Color colour,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow:
                Theme.of(context).brightness == Brightness.light
                    ? [
                      // Apply a shadow only in light mode
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colour, size: 50),
              SizedBox(height: 10),
              Text(
                text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget adminDashboard(context, size) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: size.height * 0.07,
        width: size.width * 0.7,
        decoration: BoxDecoration(
          color:
              (Theme.of(context).brightness == Brightness.light)
                  ? Colors.white
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color:
                (Theme.of(context).brightness == Brightness.dark)
                    ? Colors.white
                    : Colors.black,
            width: 3,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 40),
            Text(
              "Admin Dashboard",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
