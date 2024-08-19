import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_app/model/student_model.dart';
import 'package:student_app/screens/addstudents.dart';
import 'package:student_app/database/dbfunction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _selectedImage;

  FocusNode searchFocusNode = FocusNode();

  late List<Map<String, dynamic>> _studentData = [];
  late List<Map<String, dynamic>> _filteredStudents = [];

  TextEditingController searchController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  String query = '';

  @override
  void initState() {
    super.initState();
    _fetchStudentsData();
  }

  Future<void> _fetchStudentsData() async {
    List<Map<String, dynamic>>? students = await getAllStudents();

    setState(() {
      _studentData = students;
      _filteredStudents = students;
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  void filterStudents(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredStudents = _studentData;
      } else {
        _filteredStudents = _studentData
            .where((student) =>
                student['name'].toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
      if (_filteredStudents.isEmpty) {
        _filteredStudents = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: const Text(
            'Students Details',
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontFamily: 'PlaywriteHR'),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    focusNode: searchFocusNode,
                    controller: searchController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onChanged: (value) {
                      filterStudents(value);
                    },
                  ),
                ),
              ),
              Expanded(
                child: _filteredStudents.isEmpty
                    ? Center(child: Text('No students found'))
                    : ListView.builder(
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          final studentImg = student['imageurl'];
                          return SizedBox(
                              height: 80,
                              child: Card(
                                elevation: 2,
                                child: ListTile(
                                    title: Text(student['name']),
                                    subtitle: Text(student['place']),
                                    leading: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 60,
                                                        backgroundImage:
                                                            studentImg != null
                                                                ? FileImage(File(
                                                                    studentImg))
                                                                : null,
                                                        child: studentImg ==
                                                                null
                                                            ? Icon(Icons.person)
                                                            : null,
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        'Name: ${student['name']}',
                                                      ),
                                                      Text(
                                                        'Age:${student['age']}',
                                                      ),
                                                      Text(
                                                        'Place:${student['place']}',
                                                      ),
                                                      Text(
                                                        'Mobile:${student['mobile']}',
                                                      )
                                                    ],
                                                  ),
                                                  actions: [
                                                    Center(
                                                        child: TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              FocusScope.of(
                                                                      context)
                                                                  .unfocus();
                                                            },
                                                            child: const Text(
                                                                'Close')))
                                                  ],
                                                ));
                                      },
                                      child: CircleAvatar(
                                        backgroundImage: studentImg != null
                                            ? FileImage(File(studentImg))
                                            : null,
                                        child: studentImg == null
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                    ),
                                    trailing: Wrap(children: [
                                      IconButton(
                                        onPressed: () {
                                          showEditDialogue(context, student);
                                        },
                                        icon: const Icon(Icons.edit),
                                      ),
                                      IconButton(
                                          onPressed: () async {
                                            await showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
                                                    AlertDialog(
                                                        content: const Text(
                                                            'Do you want to delete'),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                deleteStudent(
                                                                    student[
                                                                        'id']);
                                                                setState(() {
                                                                  _fetchStudentsData();
                                                                });

                                                                Navigator.pop(
                                                                    context);
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                    content: Text(
                                                                        'Student details deleted'),
                                                                  ),
                                                                );
                                                              },
                                                              child: const Text(
                                                                  'yes')),
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                              },
                                                              child: const Text(
                                                                  'no'))
                                                        ]));
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                          ))
                                    ])),
                              ));
                        },
                        itemCount: _filteredStudents.length),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          FocusScope.of(context).unfocus();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddStudentScreen(),
            ),
          );
        },
        backgroundColor: Colors.blueGrey[100],
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showEditDialogue(
      BuildContext context, Map<String, dynamic> student) async {
    // FocusScope.of(context).unfocus();
    final TextEditingController nameController =
        TextEditingController(text: student['name'].toString());
    final TextEditingController ageController =
        TextEditingController(text: student['age'].toString());
    final TextEditingController placeController =
        TextEditingController(text: student['place'].toString());
    final TextEditingController mobileController =
        TextEditingController(text: student['mobile'].toString());

    _selectedImage =
        student['imageurl'] is String && student['imageurl'].isNotEmpty
            ? XFile(student['imageurl'])
            : null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          Future<void> _pickImageFromGallery() async {
            final pickedImage =
                await ImagePicker().pickImage(source: ImageSource.gallery);

            if (pickedImage != null) {
              setState(() {
                _selectedImage = XFile(pickedImage.path);
              });
            }
            return;
          }

          return AlertDialog(
            title: const Text('Edit Student Details'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        _pickImageFromGallery();
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _selectedImage != null
                            ? FileImage(File(_selectedImage!.path))
                            : null,
                        child: _selectedImage == null
                            ? const Icon(Icons.add_a_photo)
                            : null,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z]')),
                        ],
                        controller: nameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), label: Text('Name')),
                        validator: (value) =>
                            value!.isEmpty ? 'Name is empty' : null),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Age is empty';
                        } else if (value.length > 2) {
                          return 'Age is incorrect';
                        } else {
                          return null;
                        }
                      },
                      controller: ageController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), label: Text('Age')),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Place is empty';
                        } else {
                          return null;
                        }
                      },
                      controller: placeController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), label: Text('Place')),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Mobile number is empty';
                        } else if (value.length < 10) {
                          return 'Invalid mobile number';
                        } else {
                          return null;
                        }
                      },
                      controller: mobileController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Mobile Number')),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    FocusScope.of(context).unfocus();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await updateStudent(
                        StudentModel(
                          id: student['id'],
                          name: nameController.text,
                          age: ageController.text,
                          place: placeController.text,
                          mobile: mobileController.text,
                          imageurl: _selectedImage != null
                              ? _selectedImage!.path
                              : student['imageurl'],
                        ),
                      );
                      await _fetchStudentsData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Student details edited succesfully'),
                        backgroundColor: Colors.lightGreen,
                      ));
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();
                    }
                  },
                  child: const Text('Save'))
            ],
          );
        });
      },
    );
  }
}
