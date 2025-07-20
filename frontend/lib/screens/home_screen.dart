import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
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
                        "Welcome Back, \nUser !",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border: BoxBorder.all(
                            color:
                                (Theme.of(context).brightness ==
                                        Brightness.dark)
                                    ? Colors.white
                                    : Colors.black,
                            width: 3,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {},
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
                InkWell(
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNavigationCard({
    required IconData icon,
    required String text,
    required Color colour,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: BoxDecoration(
          //color: Colors.grey.shade800,
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow:
              Theme.of(context).brightness == Brightness.light
                  ? [
                    // Apply a shadow only in light mode
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
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
    );
  }
}
