import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/blocs/auth/auth_state.dart';
import 'package:frontend/blocs/connect/connect_bloc.dart';
import 'package:frontend/blocs/connect/connect_event.dart';
import 'package:frontend/blocs/connect/connect_state.dart';
import 'package:frontend/models/connect_model.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConnectBloc>().add(ConnectDataLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Connect"),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            indicatorColor:
                (Theme.of(context).brightness == Brightness.dark)
                    ? Colors.blue
                    : Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: Colors.grey,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
            padding: EdgeInsets.all(12),
            tabs: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("My Mentor", style: TextStyle(fontSize: 20)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("My Mentees", style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
        body: BlocListener<ConnectBloc, ConnectState>(
          listener: (context, state) {
            if (state.status == ConnectStatus.failure ||
                state.status == ConnectStatus.requestFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage ?? 'An unknown error occurred.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
            } else if (state.status == ConnectStatus.requestSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Mentor request sent successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
            }
          },
          child: const TabBarView(children: [_MyMentorTab(), _MyMenteesTab()]),
        ),
      ),
    );
  }
}

class _MyMentorTab extends StatelessWidget {
  const _MyMentorTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectBloc, ConnectState>(
      builder: (context, state) {
        if (state.status == ConnectStatus.loading ||
            state.status == ConnectStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ConnectStatus.success ||
            state.status == ConnectStatus.sendingRequest) {
          if (state.hasMentor == true && state.myMentor != null) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: _MentorCard(mentor: state.myMentor!, isConnected: true),
            );
          } else {
            if (state.availableMentors.isEmpty) {
              return const Center(
                child: Text('No available mentors at the moment.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.availableMentors.length,
              itemBuilder: (context, index) {
                final mentor = state.availableMentors[index];
                return _MentorCard(mentor: mentor, isConnected: false);
              },
            );
          }
        }
        return const Center(child: Text('Could not load mentor data.'));
      },
    );
  }
}

class _MyMenteesTab extends StatelessWidget {
  const _MyMenteesTab();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    return BlocBuilder<ConnectBloc, ConnectState>(
      builder: (context, state) {
        if (state.status == ConnectStatus.loading ||
            state.status == ConnectStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ConnectStatus.success) {
          if (authState is Authenticated &&
              authState.user['isMentorEligible'] == true) {
            if (state.myMentees.isEmpty) {
              return const Center(child: Text('You have no mentees yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.myMentees.length,
              itemBuilder: (context, index) {
                final mentee = state.myMentees[index];
                return _MenteeCard(mentee: mentee);
              },
            );
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'You are not eligible to be a mentor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
        }
        return const Center(child: Text('Could not load mentee data.'));
      },
    );
  }
}

class _MentorCard extends StatelessWidget {
  final PublicProfile mentor;
  final bool isConnected;

  const _MentorCard({required this.mentor, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mentor.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(mentor.email, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            if (!isConnected)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ConnectBloc>().add(
                      MentorRequestSent(mentor.id),
                    );
                  },
                  child: const Text('Connect'),
                ),
              )
            else
              const Align(
                alignment: Alignment.centerRight,
                child: Chip(
                  label: Text('Connected'),
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenteeCard extends StatelessWidget {
  final PublicProfile mentee;
  const _MenteeCard({required this.mentee});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          mentee.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(mentee.email),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to chat screen with mentee.id
        },
      ),
    );
  }
}
