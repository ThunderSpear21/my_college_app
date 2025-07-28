import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/admin/admin_bloc.dart';
import 'package:frontend/blocs/admin/admin_event.dart';
import 'package:frontend/blocs/admin/admin_state.dart';
import 'package:frontend/models/course_model.dart';
import 'package:frontend/models/notes_model.dart';
import 'package:frontend/services/course_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people_outline), text: 'Users'),
              Tab(icon: Icon(Icons.folder_open_outlined), text: 'Content'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_UserManagementTab(), _ContentManagementTab()],
        ),
      ),
    );
  }
}

// --- User Management Tab ---
class _UserManagementTab extends StatelessWidget {
  const _UserManagementTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader(
          context,
          'Manage Admin Status',
          'Promote or demote your immediate juniors.',
        ),
        _buildManagementButton(
          context: context,
          title: 'Show Junior List',
          icon: Icons.arrow_forward_ios,
          onPressed: () {
            context.read<AdminBloc>().add(AdminJuniorsFetched());
            _showUserListDialog(
              context: context,
              title: 'Juniors',
              userListBuilder:
                  (context) => BlocBuilder<AdminBloc, AdminState>(
                    builder: (context, state) {
                      if (state.status == AdminStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.juniors.isEmpty) {
                        return const Center(child: Text('No juniors found.'));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.juniors.length,
                        itemBuilder: (context, index) {
                          final junior = state.juniors[index];
                          return _buildUserCard(
                            context,
                            name: junior.name,
                            email: junior.email,
                            actionTitle: 'Toggle Admin',
                            isActive: junior.isAdmin,
                            onAction: () {
                              context.read<AdminBloc>().add(
                                AdminStatusToggled(junior.id),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
            );
          },
        ),
        const Divider(height: 32),
        _buildSectionHeader(
          context,
          'Manage Mentor Eligibility',
          'Toggle mentor status for your peers (same year).',
        ),
        _buildManagementButton(
          context: context,
          title: 'Show Peer List',
          icon: Icons.arrow_forward_ios,
          onPressed: () {
            context.read<AdminBloc>().add(AdminPeersFetched());
            _showUserListDialog(
              context: context,
              title: 'Peers',
              userListBuilder:
                  (context) => BlocBuilder<AdminBloc, AdminState>(
                    builder: (context, state) {
                      if (state.status == AdminStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.peers.isEmpty) {
                        return const Center(child: Text('No peers found.'));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.peers.length,
                        itemBuilder: (context, index) {
                          final peer = state.peers[index];
                          return _buildUserCard(
                            context,
                            name: peer.name,
                            email: peer.email,
                            actionTitle: 'Toggle Mentor',
                            isActive: peer.isMentorEligible,
                            onAction: () {
                              context.read<AdminBloc>().add(
                                AdminMentorStatusToggled(peer.id),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
            );
          },
        ),
      ],
    );
  }
}

// --- Content Management Tab ---
class _ContentManagementTab extends StatelessWidget {
  const _ContentManagementTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader(
          context,
          'Course Structures',
          'Upload or delete course structure PDFs.',
        ),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: 'Upload',
                icon: Icons.upload,
                context: context,
                color:
                    (Theme.of(context).brightness == Brightness.light)
                        ? Colors.green
                        : ThemeData.dark().scaffoldBackgroundColor,
                outlineColor: Colors.green,
                onPressed: () {
                  _showUploadCourseDialog(context);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                title: 'Delete',
                icon: Icons.delete_outline,
                color:
                    (Theme.of(context).brightness == Brightness.light)
                        ? Colors.red
                        : ThemeData.dark().scaffoldBackgroundColor,
                outlineColor: Colors.red,
                context: context,
                onPressed: () {
                  _showDeleteDialog(
                    context: context,
                    title: 'Delete Course Structure',
                    fetchEventBuilder:
                        (semester) => AdminCoursesFetched(semester),
                    deleteCardBuilder: (item, semester) {
                      // Pass semester
                      final course = item as Course;
                      return _buildContentCard(
                        context,
                        title: '${course.courseId} - ${course.courseName}',
                        onDelete: () {
                          _showConfirmationDialog(
                            context: context,
                            title: 'Delete Course?',
                            content:
                                'Are you sure you want to delete ${course.courseName}?',
                            onConfirm: () {
                              context.read<AdminBloc>().add(
                                AdminCourseDeleted(course.id),
                              );
                              Navigator.of(context).pop(); // Close confirmation
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        const Divider(height: 32),
        _buildSectionHeader(context, 'Notes', 'Upload or delete course notes.'),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: 'Upload',
                icon: Icons.upload,
                color:
                    (Theme.of(context).brightness == Brightness.light)
                        ? Colors.green
                        : ThemeData.dark().scaffoldBackgroundColor,
                outlineColor: Colors.green,
                context: context,
                onPressed: () {
                  _showUploadNoteDialog(context);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                title: 'Delete',
                icon: Icons.delete_outline,
                color:
                    (Theme.of(context).brightness == Brightness.light)
                        ? Colors.red
                        : ThemeData.dark().scaffoldBackgroundColor,
                outlineColor: Colors.red,
                context: context,
                onPressed: () {
                  _showDeleteDialog(
                    context: context,
                    title: 'Delete Note',
                    fetchEventBuilder:
                        (semester) => AdminNotesFetched(semester),
                    deleteCardBuilder: (item, semester) {
                      final note = item as Note;
                      return _buildContentCard(
                        context,
                        title: note.title,
                        onDelete: () {
                          _showConfirmationDialog(
                            context: context,
                            title: 'Delete Note?',
                            content:
                                'Are you sure you want to delete ${note.title}?',
                            onConfirm: () {
                              context.read<AdminBloc>().add(
                                AdminNoteDeleted(note.id),
                              );
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- Helper Widgets ---

void _showUserListDialog({
  required BuildContext context,
  required String title,
  required WidgetBuilder userListBuilder,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, textAlign: TextAlign.center),
        content: SizedBox(
          width: double.maxFinite,
          child: userListBuilder(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

Widget _buildSectionHeader(
  BuildContext context,
  String title,
  String subtitle,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

Widget _buildManagementButton({
  required BuildContext context,
  required String title,
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return Card(
    shape: RoundedRectangleBorder( borderRadius: BorderRadiusGeometry.circular(16),side: BorderSide(color: Colors.white24)),
    child: ListTile(
      title: Text(title),
      trailing: Icon(icon, size: 16),
      onTap: onPressed,
    ),
  );
}

Widget _buildActionButton({
  required String title,
  required IconData icon,
  required VoidCallback onPressed,
  required Color color,
  required Color outlineColor,
  required BuildContext context,
}) {
  return ElevatedButton.icon(
    icon: Icon(icon),
    label: Text(title),
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(
        color:
            (Theme.of(context).brightness == Brightness.dark)
                ? outlineColor
                : Colors.transparent,
        width: 1.5,
      ),
    ),
  );
}

Widget _buildUserCard(
  BuildContext context, {
  required String name,
  required String email,
  required String actionTitle,
  required bool isActive,
  required VoidCallback onAction,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color:
        isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(email, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionTitle, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    ),
  );
}

void _showUploadCourseDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      // We pass the main screen's context to the form so it can read the AdminBloc.
      return _UploadCourseForm(parentContext: context);
    },
  );
}

// A new StatefulWidget to manage the state of the form inside the dialog.
class _UploadCourseForm extends StatefulWidget {
  final BuildContext parentContext;
  const _UploadCourseForm({required this.parentContext});

  @override
  State<_UploadCourseForm> createState() => _UploadCourseFormState();
}

class _UploadCourseFormState extends State<_UploadCourseForm> {
  final _formKey = GlobalKey<FormState>();
  final _courseIdController = TextEditingController();
  final _courseNameController = TextEditingController();
  int? _selectedSemester;
  File? _selectedFile;

  @override
  void dispose() {
    _courseIdController.dispose();
    _courseNameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Course Structure'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _courseIdController,
                decoration: const InputDecoration(
                  labelText: 'Course ID (e.g., CS201)',
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<int>(
                items: List.generate(
                  10,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('Semester ${i + 1}'),
                  ),
                ),
                onChanged: (value) => _selectedSemester = value,
                decoration: const InputDecoration(labelText: 'Semester'),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // Conditionally show the button or the selected file info.
              if (_selectedFile == null)
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Select File'),
                )
              else
                Card(
                  elevation: 0,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(
                      _selectedFile!.path
                          .split('/')
                          .last, // Show only the file name
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Also validate that a file has been selected.
            if (_formKey.currentState!.validate() && _selectedFile != null) {
              // Use the parentContext to read the AdminBloc
              widget.parentContext.read<AdminBloc>().add(
                AdminCourseUploaded(
                  file: _selectedFile!,
                  courseId: _courseIdController.text,
                  courseName: _courseNameController.text,
                  semester: _selectedSemester!,
                ),
              );
              Navigator.pop(context);
            } else if (_selectedFile == null) {
              // Show an error if no file is selected
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a file to upload.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Upload'),
        ),
      ],
    );
  }
}

void _showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
  );
}

Widget _buildContentCard(
  BuildContext context, {
  required String title,
  required VoidCallback onDelete,
}) {
  return Card(
    child: ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text(title, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
    ),
  );
}

class _DeleteContentDialog extends StatefulWidget {
  final String title;
  final AdminEvent Function(int semester) fetchEventBuilder;
  final Widget Function(dynamic item, int semester) deleteCardBuilder;

  const _DeleteContentDialog({
    required this.title,
    required this.fetchEventBuilder,
    required this.deleteCardBuilder,
  });

  @override
  State<_DeleteContentDialog> createState() => _DeleteContentDialogState();
}

class _DeleteContentDialogState extends State<_DeleteContentDialog> {
  int? _selectedSemester;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, textAlign: TextAlign.center),

      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              items: List.generate(
                10,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('Semester ${i + 1}'),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSemester = value;
                  });
                  context.read<AdminBloc>().add(
                    widget.fetchEventBuilder(value),
                  );
                }
              },
              decoration: const InputDecoration(
                labelText: 'Select Semester',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (_selectedSemester == null) {
                    return const Center(
                      child: Text('Please select a semester.'),
                    );
                  }
                  if (state.status == AdminStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list =
                      widget.title.contains('Course')
                          ? state.courses
                          : state.notes;
                  if (list.isEmpty) {
                    return const Center(child: Text('No items found.'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder:
                        (context, index) => widget.deleteCardBuilder(
                          list[index],
                          _selectedSemester!,
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

void _showDeleteDialog({
  required BuildContext context,
  required String title,
  required AdminEvent Function(int semester) fetchEventBuilder,
  required Widget Function(dynamic item, int semester) deleteCardBuilder,
}) {
  showDialog(
    context: context,
    builder:
        (dialogContext) => _DeleteContentDialog(
          title: title,
          fetchEventBuilder: fetchEventBuilder,
          deleteCardBuilder: deleteCardBuilder,
        ),
  );
}

void _showUploadNoteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return _UploadNoteForm(parentContext: context);
    },
  );
}

// A new StatefulWidget to manage the state of the form inside the dialog.
class _UploadNoteForm extends StatefulWidget {
  final BuildContext parentContext;
  const _UploadNoteForm({required this.parentContext});

  @override
  State<_UploadNoteForm> createState() => _UploadNoteFormState();
}

class _UploadNoteFormState extends State<_UploadNoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  // Local state for the dialog
  int? _selectedSemester;
  Course? _selectedCourse;
  File? _selectedFile;

  List<Course> _coursesForSemester = [];
  bool _isLoadingCourses = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _fetchCourses(int semester) async {
    setState(() {
      _isLoadingCourses = true;
      _coursesForSemester = [];
      _selectedCourse = null; // Reset course selection
    });
    try {
      // Assuming you have a CourseService similar to what we built before
      final courses = await CourseService.getCoursesBySemester(semester);
      setState(() {
        _coursesForSemester = courses;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch courses: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingCourses = false;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Note'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Semester Dropdown
              DropdownButtonFormField<int>(
                items: List.generate(
                  10,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('Semester ${i + 1}'),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSemester = value;
                    });
                    _fetchCourses(value);
                  }
                },
                decoration: const InputDecoration(labelText: 'Semester'),
                validator: (value) => value == null ? 'Required' : null,
              ),

              // 2. Course Dropdown (dynamic)
              if (_isLoadingCourses)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              else if (_selectedSemester != null)
                DropdownButtonFormField<Course>(
                  items:
                      _coursesForSemester
                          .map(
                            (course) => DropdownMenuItem(
                              value: course,
                              child: Text(
                                course.courseName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _selectedCourse = value),
                  decoration: InputDecoration(
                    labelText: 'Course',
                    hintText:
                        _coursesForSemester.isEmpty
                            ? 'No courses found'
                            : 'Select a course',
                  ),
                  validator: (value) => value == null ? 'Required' : null,
                ),

              // 3. Title TextField
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Note Title'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // 4. File Picker
              if (_selectedFile == null)
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Select File'),
                )
              else
                Card(
                  elevation: 0,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(
                      _selectedFile!.path.split('/').last,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _selectedFile = null),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() &&
                _selectedFile != null &&
                _selectedCourse != null) {
              widget.parentContext.read<AdminBloc>().add(
                AdminNoteUploaded(
                  file: _selectedFile!,
                  title: _titleController.text.trim(),
                  courseId: _selectedCourse!.id,
                ),
              );
              Navigator.pop(context);
            } else if (_selectedFile == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a file to upload.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
