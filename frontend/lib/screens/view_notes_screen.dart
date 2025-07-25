import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/course/course_bloc.dart';
import 'package:frontend/blocs/course/course_event.dart';
import 'package:frontend/blocs/course/course_state.dart';
import 'package:frontend/blocs/notes/notes_bloc.dart';
import 'package:frontend/blocs/notes/notes_event.dart';
import 'package:frontend/blocs/notes/notes_state.dart';
import 'package:frontend/models/course_model.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:frontend/models/notes_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ViewNotesScreen extends StatelessWidget {
  const ViewNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double dropdownWidth = MediaQuery.of(context).size.width - 48.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Notes"),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state.status == NotesStatus.failure) {
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
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSemesterDropdown(context, dropdownWidth),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, courseState) {
                  return _buildCoursesDropdown(
                    context,
                    courseState,
                    dropdownWidth,
                  );
                },
              ),
              const SizedBox(height: 24),
              const Divider(),
              Expanded(
                child: BlocBuilder<NoteBloc, NoteState>(
                  builder: (context, state) {
                    if (state.status == NotesStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.filteredNotes.isEmpty &&
                        state.status == NotesStatus.success) {
                      return const Center(
                        child: Text('No notes found for this selection.'),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: state.filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = state.filteredNotes[index];
                        return _NoteCard(note: note);
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterDropdown(BuildContext context, double width) {
    return DropdownMenu<int>(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).cardColor),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        fixedSize: WidgetStatePropertyAll(Size.fromWidth(width)),
      ),
      expandedInsets: EdgeInsets.zero,
      label: const Text('Select Semester'),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dropdownMenuEntries: List.generate(10, (index) {
        final semester = index + 1;
        return DropdownMenuEntry<int>(
          value: semester,
          label: 'Semester $semester',
        );
      }),
      onSelected: (int? semester) {
        if (semester != null) {
          // Dispatch events to both blocs
          context.read<CourseBloc>().add(SemesterSelected(semester));
          context.read<NoteBloc>().add(NotesSemesterSelected(semester));
        }
      },
    );
  }

  Widget _buildCoursesDropdown(
    BuildContext context,
    CourseState courseState,
    double width,
  ) {
    final TextEditingController courseController = TextEditingController();

    return DropdownMenu<Course>(
      controller: courseController,
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).cardColor),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        fixedSize: WidgetStatePropertyAll(Size.fromWidth(width)),
      ),
      enabled: courseState.courses.isNotEmpty,
      expandedInsets: EdgeInsets.zero,
      label: const Text('Filter by Course'),
      hintText:
          courseState.selectedSemester == null
              ? 'Select a semester first'
              : 'All Courses',
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dropdownMenuEntries: [
        //const DropdownMenuEntry<Course>(value: null, label: 'All Courses'),
        ...courseState.courses.map((course) {
          return DropdownMenuEntry<Course>(
            value: course,
            label: '${course.courseId} - ${course.courseName}',
          );
        }),
      ],
      onSelected: (Course? course) {
        context.read<NoteBloc>().add(NotesCourseFiltered(course));
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  const _NoteCard({required this.note});

  bool _isImageUrl(String url) {
    final lowercasedUrl = url.toLowerCase();
    return lowercasedUrl.endsWith('.png') ||
        lowercasedUrl.endsWith('.jpg') ||
        lowercasedUrl.endsWith('.jpeg') ||
        lowercasedUrl.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => FileViewerScreen(url: note.url, fileName: note.title),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                _isImageUrl(note.url)
                    ? Icons.image_outlined
                    : Icons.picture_as_pdf_outlined,
                color:
                    (Theme.of(context).brightness == Brightness.dark)
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'By: ${note.uploadedBy.name}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FileViewerScreen extends StatefulWidget {
  final String url;
  final String fileName;

  const FileViewerScreen({
    super.key,
    required this.url,
    required this.fileName,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  String? localPdfPath;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (!_isImageUrl(widget.url)) {
      _loadPdf();
    } else {
      _isLoading = false;
    }
  }

  bool _isImageUrl(String url) {
    final lowercasedUrl = url.toLowerCase();
    return lowercasedUrl.endsWith('.png') ||
        lowercasedUrl.endsWith('.jpg') ||
        lowercasedUrl.endsWith('.jpeg') ||
        lowercasedUrl.endsWith('.gif');
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${widget.fileName}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          setState(() {
            localPdfPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        throw Exception(
          'Failed to load PDF. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading PDF: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.fileName), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_errorMessage!, textAlign: TextAlign.center),
                ),
              )
              : _isImageUrl(widget.url)
              ? Center(
                child: InteractiveViewer(child: Image.network(widget.url)),
              )
              : localPdfPath != null
              ? PDFView(filePath: localPdfPath)
              : const Center(child: Text('Could not display PDF.')),
    );
  }
}
