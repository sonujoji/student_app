import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
  late List<Map<String, dynamic>> _studentData = [];
  late List<Map<String, dynamic>> _filteredStudents = [];

  TextEditingController searchController = TextEditingController();
  File? _selectedImage;
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

  void filterStudents(String value) {
    if (_filteredStudents.isEmpty) {
      _filteredStudents = _studentData;
    } else {
      _filteredStudents = _studentData
          .where((student) =>
              student['name'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    }
    setState(() {});
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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 70,
              // color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
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
                        // final studentId = student['id'];
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
                                                      child: studentImg == null
                                                          ? Icon(Icons.person)
                                                          : null,
                                                    ),
                                                    SizedBox(
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
                                                  Center(child:  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Close')))
                                                  
                                                ],
                                              ));
                                    },
                                    child: CircleAvatar(
                                      backgroundImage: studentImg != null
                                          ? FileImage(File(studentImg))
                                          : null,
                                      child: studentImg == null
                                          ? Icon(Icons.person)
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
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                      content: Text(
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
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  content: Text(
                                                                      'Student details deleted'),
                                                                  // behavior:
                                                                  //     SnackBarBehavior
                                                                  //         .floating,
                                                                ),
                                                              );
                                                            },
                                                            child: Text('yes')),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text('no'))
                                                      ]));
                                        },
                                        icon: Icon(
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
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddStudentScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey[100],
      ),
    );
  }

  Future<void> showEditDialogue(
      BuildContext context, Map<String, dynamic> student) async {
    final TextEditingController nameController =
        TextEditingController(text: student['name'].toString());
    final TextEditingController ageController =
        TextEditingController(text: student['age'].toString());
    final TextEditingController placeController =
        TextEditingController(text: student['place'].toString());
    final TextEditingController mobileController =
        TextEditingController(text: student['mobile'].toString());

    File? selectedImage;
    if (student['imageurl'] is String && student['imageurl'].isNotEmpty) {
      selectedImage = File(student['imageurl']);
    }

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Edit Student Details'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          final pickedImage = await _pickImageFromGallery();
                          if (pickedImage != null) {
                            selectedImage = pickedImage;
                            setState(() {});
                          }
                        },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : null,
                          child: selectedImage == null
                              ? Icon(Icons.add_a_photo)
                              : null,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: nameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('Name')),
                          validator: (value) => value!.isEmpty || value == null 
                              ? 'Name is empty'
                              : null),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
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
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), label: Text('Age')),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Place is empty';
                          } else {
                            return null;
                          }
                        },
                        controller: placeController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), label: Text('Place')),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Mobile number is empty';
                          } else {
                            return null;
                          }
                        },
                        controller: mobileController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Mobile Number')),
                      ),
                      SizedBox(
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
                    },
                    child: Text('Cancel')),
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
                            imageurl: selectedImage != null
                                ? selectedImage!.path
                                : student['imageurl'],
                          ),
                        );
                        await _fetchStudentsData();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Student details edited succesfully'),
                          backgroundColor: Colors.orange[800],
                        ));
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Save'))
              ],
            ));
  }

  Future<File?> _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      return File(pickedImage.path);
    }
    return null;
  }
}
