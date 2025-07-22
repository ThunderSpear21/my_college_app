import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/view_profile/view_profile_bloc.dart';
import 'package:frontend/blocs/view_profile/view_profile_event.dart';
import 'package:frontend/blocs/view_profile/view_profile_state.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  bool _isEditing = false;
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    context.read<ViewProfileBloc>().add(ProfileLoadRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getUserRole(Map<String, dynamic>? user) {
    if (user == null) return 'N/A';
    if (user['isSuperAdmin'] == true) return 'Super Admin';
    if (user['isAdmin'] == true) return 'Admin';
    return 'Student';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<ViewProfileBloc, ViewProfileState>(
        listenWhen: (previous, current) {
          final bool updateSuccess =
              previous.status == ProfileStatus.updating &&
              current.status == ProfileStatus.success;
          final bool anyFailure = current.status == ProfileStatus.failure;
          return updateSuccess || anyFailure;
        },
        listener: (context, state) {
          if (state.status == ProfileStatus.failure) {
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
          }
          if (state.status == ProfileStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
          }
        },
        child: BlocBuilder<ViewProfileBloc, ViewProfileState>(
          builder: (context, state) {
            if (state.user != null &&
                _nameController.text != state.user!['name']) {
              _nameController.text = state.user!['name'];
            }

            if (state.status == ProfileStatus.loading ||
                state.status == ProfileStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.user != null) {
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildProfileHeaderCard(context, state),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Secondary Details",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.school_outlined,
                          label: 'Year of Admission',
                          value:
                              state.user?['yearOfAdmission']?.toString() ??
                              'N/A',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.admin_panel_settings_outlined,
                          label: 'Role',
                          value: _getUserRole(state.user),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const Center(
              child: Text('Something went wrong. Please try again.'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(BuildContext context, ViewProfileState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (Theme.of(context).brightness == Brightness.dark)
                ? Colors.blue.shade500
                : Colors.lightBlue.shade200,
            (Theme.of(context).brightness == Brightness.dark)
                ? Colors.purple
                : Colors.purple.shade200,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor:
                  (Theme.of(context).brightness == Brightness.dark)
                      ? Colors.blue.shade200
                      : Colors.indigo.shade600,
              child: Text(
                state.user?['name']?[0].toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color:
                      (Theme.of(context).brightness == Brightness.light)
                          ? Colors.white
                          : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isEditing
                          ? TextFormField(
                            controller: _nameController,
                            style: Theme.of(context).textTheme.titleLarge,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Full Name',
                              isDense: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name cannot be empty';
                              }
                              return null;
                            },
                          )
                          : Text(
                            state.user?['name'] ?? 'User Name',
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                      const SizedBox(height: 4),
                      Text(
                        state.user?['email'] ?? 'email@example.com',
                        style: Theme.of(context).textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_isEditing) {
                      // Save action
                      if (_formKey.currentState!.validate()) {
                        context.read<ViewProfileBloc>().add(
                          ProfileUpdateSubmitted(
                            newName: _nameController.text.trim(),
                          ),
                        );
                        setState(() => _isEditing = false);
                      }
                    } else {
                      // Edit action
                      setState(() => _isEditing = true);
                    }
                  },
                  child:
                      state.status == ProfileStatus.updating
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(_isEditing ? 'SAVE' : 'EDIT', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}
