import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/blocs/auth/auth_event.dart';
import 'package:frontend/blocs/auth/auth_state.dart';
import 'package:frontend/blocs/theme/theme_bloc.dart';
import 'package:frontend/blocs/theme/theme_event.dart';
import 'package:frontend/screens/admin_screen.dart';
import 'package:frontend/screens/connect_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/view_course_screen.dart';
import 'package:frontend/screens/view_notes_screen.dart';
import 'package:frontend/screens/view_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    Size size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: scaffoldKey,
      drawer: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return buildAppDrawer(context, isDarkMode, state.user);
          }
          return const Drawer();
        },
      ),
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
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is! Authenticated) {
                return const Center(child: CircularProgressIndicator());
              }
              final user = state.user;
              return Padding(
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
                              isDarkMode
                                  ? Colors.blue.shade500
                                  : Colors.lightBlue.shade200,
                              isDarkMode
                                  ? Colors.purple
                                  : Colors.purple.shade200,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const SizedBox(width: 10,),
                            Expanded(
                              child: Text(
                                "Welcome Back,\n${user['name'] ?? 'User'}!",
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  width: 3,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  scaffoldKey.currentState?.openDrawer();
                                },
                                icon: const Icon(Icons.person_2, size: 40),
                              ),
                            ),
                            const SizedBox(width: 10,)
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
                        padding: const EdgeInsets.all(12),
                        children: [
                          buildNavigationCard(
                            icon: Icons.school,
                            text: "Course Structure",
                            colour: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ViewCourseScreen(),
                                ),
                              );
                            },
                          ),
                          buildNavigationCard(
                            icon: Icons.text_snippet,
                            text: "Notes",
                            colour: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ViewNotesScreen(),
                                ),
                              );
                            },
                          ),
                          buildNavigationCard(
                            icon: Icons.people,
                            text: "Connect",
                            colour: Colors.purpleAccent,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ConnectScreen(),
                                ),
                              );
                            },
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
                      if (user['isAdmin'] == true)
                        adminDashboard(context, size),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Drawer buildAppDrawer(
    BuildContext context,
    bool isDarkMode,
    Map<String, dynamic> user,
  ) {
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
                  user['name'] ?? 'User',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    overflow: TextOverflow.ellipsis
                  ),
                  maxLines: 2,
                ),
                Text(
                  user['email'] ?? 'user@email.com',
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewProfileScreen()),
              );
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
    return Builder(
      builder: (context) {
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
                          BoxShadow(
                            // ignore: deprecated_member_use
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
                  const SizedBox(height: 10),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget adminDashboard(BuildContext context, Size size) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      },
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
          children: const [
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
