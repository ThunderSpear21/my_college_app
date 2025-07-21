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
  bool _didUpdate = false;
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    // Dispatch the event to load data when the screen is initialized.
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
    // WillPopScope handles the Android hardware back button and passes back our result.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _didUpdate);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // The custom back button ensures our result is passed back on tap.
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context, _didUpdate);
            },
          ),
          title: const Text('My Profile'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocListener<ViewProfileBloc, ViewProfileState>(
          listener: (context, state) {
            // Show a snackbar on failure
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
              context.read<ViewProfileBloc>();
              if (_didUpdate == false) {
              }
            }
          },
          child: BlocBuilder<ViewProfileBloc, ViewProfileState>(
            builder: (context, state) {
              // Sync the controller when the user data is available.
              if (state.user != null &&
                  _nameController.text != state.user!['name'] &&
                  !_isEditing) {
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
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              state.user?['name']?[0].toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            readOnly: !_isEditing,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isEditing ? Icons.close : Icons.edit,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                    if (!_isEditing) {
                                      _nameController.text =
                                          state.user!['name'];
                                    }
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Other read-only fields
                          _buildReadOnlyTextField(
                            label: 'Email',
                            value: state.user?['email'] ?? 'N/A',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildReadOnlyTextField(
                            label: 'Year of Admission',
                            value:
                                state.user?['yearOfAdmission']?.toString() ??
                                'N/A',
                            icon: Icons.calendar_today_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildReadOnlyTextField(
                            label: 'Role',
                            value: _getUserRole(state.user),
                            icon: Icons.verified_user_outlined,
                          ),
                          const SizedBox(height: 32),
                          if (_isEditing)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    state.status == ProfileStatus.updating
                                        ? null
                                        : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            // Set the update flag to true before dispatching
                                            setState(() {
                                              _didUpdate = true;
                                            });
                                            context.read<ViewProfileBloc>().add(
                                              ProfileUpdateSubmitted(
                                                newName:
                                                    _nameController.text.trim(),
                                              ),
                                            );
                                            setState(() {
                                              _isEditing = false;
                                            });
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    state.status == ProfileStatus.updating
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Text(
                                          'Update Profile',
                                          style: TextStyle(fontSize: 16),
                                        ),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildReadOnlyTextField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
      ),
    );
  }
}
