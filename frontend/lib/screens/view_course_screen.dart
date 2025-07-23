import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/course/course_bloc.dart';
import 'package:frontend/blocs/course/course_event.dart';
import 'package:frontend/blocs/course/course_state.dart';
import 'package:frontend/models/course_model.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ViewCourseScreen extends StatelessWidget {
  const ViewCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double dropdownWidth = MediaQuery.of(context).size.width - 48.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Course Structure"),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state.status == CourseStatus.failure) {
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
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // --- Semester Dropdown ---
                _buildSemesterDropdown(context, dropdownWidth),
                const SizedBox(height: 24),

                // --- Courses Dropdown ---
                BlocBuilder<CourseBloc, CourseState>(
                  builder: (context, state) {
                    if (state.status == CourseStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildCoursesDropdown(context, state,dropdownWidth);
                  },
                ),
                const SizedBox(height: 32),

                BlocBuilder<CourseBloc, CourseState>(
                  builder: (context, state) {
                    if (state.selectedCourse != null) {
                      return _SyllabusPreviewCard(
                        course: state.selectedCourse!,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
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
        fixedSize: WidgetStatePropertyAll(Size.fromWidth(width))
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
          context.read<CourseBloc>().add(SemesterSelected(semester));
        }
      },
    );
  }

  Widget _buildCoursesDropdown(BuildContext context, CourseState state, double width) {
    final TextEditingController courseController = TextEditingController();

    return DropdownMenu<Course>(
      controller: courseController,
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).cardColor),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        fixedSize: WidgetStatePropertyAll(Size.fromWidth(width))
      ),
      enabled: state.courses.isNotEmpty,
      expandedInsets: EdgeInsets.zero,
      label: const Text('Select Course'),
      hintText:
          state.selectedSemester == null
              ? 'Please select a semester first'
              : 'No courses found',
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      dropdownMenuEntries:
          state.courses.map((course) {
            return DropdownMenuEntry<Course>(
              value: course,
              label: '${course.courseId} - ${course.courseName}',
            );
          }).toList(),

      onSelected: (Course? course) {
        context.read<CourseBloc>().add(CourseSelected(course));
      },
    );
  }
}

class _SyllabusPreviewCard extends StatelessWidget {
  final Course course;
  const _SyllabusPreviewCard({required this.course});

  bool _isImageUrl(String url) {
    final lowercasedUrl = url.toLowerCase();
    return lowercasedUrl.endsWith('.png') ||
        lowercasedUrl.endsWith('.jpg') ||
        lowercasedUrl.endsWith('.jpeg') ||
        lowercasedUrl.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tap to FullScreen',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => FileViewerScreen(
                          url: course.url,
                          fileName: course.courseName,
                        ),
                  ),
                );
              },
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child:
                    _isImageUrl(course.url)
                        ? Image.network(
                          course.url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            return progress == null
                                ? child
                                : const Center(
                                  child: CircularProgressIndicator(),
                                );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.error_outline, size: 40),
                            );
                          },
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 60,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 16),
                            const Text('Tap to view PDF'),
                          ],
                        ),
              ),
            ),
          ),
        ],
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
              ? Center(child: Image.network(widget.url))
              : localPdfPath != null
              ? PDFView(filePath: localPdfPath)
              : const Center(child: Text('Could not display PDF.')),
    );
  }
}
