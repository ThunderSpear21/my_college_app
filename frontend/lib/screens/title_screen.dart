import 'package:flutter/material.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: height * 0.65,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/title-image1.jpg', fit: BoxFit.fill),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  SizedBox(height: 20),
                  Text(
                    "My-College-App",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Initializing app....',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/auth/auth_bloc.dart';
// import '../../blocs/auth/auth_state.dart';
// import 'home_screen.dart';
// import 'login_screen.dart';

// class TitleScreen extends StatelessWidget {
//   const TitleScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is Authenticated) {
//             debugPrint("Listened to Authenticated");
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//             );
//           } else if (state is Unauthenticated) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const LoginScreen()),
//             );
//           }
//         },
//         child: BlocBuilder<AuthBloc, AuthState>(
//           builder: (context, state) {
//             if (state is AuthLoading || state is AuthInitial) {
//               return const _TitleScreenContent();
//             }
//             return const SizedBox.shrink();
//           },
//         ),
//       ),
//     );
//   }
// }

// class _TitleScreenContent extends StatelessWidget {
//   const _TitleScreenContent();

//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;

//     return Column(
//       children: [
//         Container(
//           height: height * 0.65,
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(10),
//               bottomRight: Radius.circular(10),
//             ),
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: Image.asset('assets/title-image1.jpg', fit: BoxFit.fill),
//         ),
//         Expanded(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: const [
//                 SizedBox(height: 20),
//                 Text(
//                   "My-College-App",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 20),
//                 CircularProgressIndicator(color: Colors.grey),
//                 SizedBox(height: 20),
//                 Text(
//                   'Initializing app....',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
//                 ),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
