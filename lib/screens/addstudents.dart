import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_app/database/dbfunction.dart';
import 'package:student_app/model/student_model.dart';
import 'package:student_app/screens/home.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key, this.model});
  final StudentModel? model;

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _nameController = TextEditingController();

  final _ageController = TextEditingController();

  final _placeController = TextEditingController();

  final _mobilenumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;

  void setImage(File image) {
    setState(() {
      _selectedImage = image;
    });
  }

  @override
  void initState() {
    // showData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text(
          'Add Student',
          style: TextStyle(color: Colors.white, fontFamily: 'PlaywriteHR'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Center(
              child: CircleAvatar(
                radius: 60,
                child: GestureDetector(
                    onTap: () async {
                      File? pickedImage = await _pickImageFromGallery();
                      if (pickedImage != null) {
                        setImage(pickedImage);
                      }
                    },
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              height: 140,
                              width: 140,
                            ),
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            size: 30,
                          )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _nameController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                      ],
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Name',
                          hintStyle: TextStyle(color: Colors.grey)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Name is empty';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Age',
                          hintStyle: TextStyle(color: Colors.grey)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Age is empty';
                        } else if (value.length > 2) {
                          return 'Enter correct age';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                      ],
                      controller: _placeController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Place',
                          hintStyle: TextStyle(color: Colors.grey)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Place is empty';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLength: 10,
                      controller: _mobilenumberController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Mobile Number',
                          hintStyle: TextStyle(color: Colors.grey)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Mobile number is empty';
                        } else if (value.length > 10) {
                          return 'Invalid number';
                        } else if (value.length < 10) {
                          return 'Invalid number';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          onAddStudentButtonClicked(context);
                        }
                      },
                      style: const ButtonStyle(
                        minimumSize: WidgetStatePropertyAll(Size(0, 45)),
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blueGrey),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      child: const Text('Add Student'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File?> _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      return File(pickedImage.path);
    }
    return null;
  }

  void onAddStudentButtonClicked(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Image not selected',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }

      final student = StudentModel(
        name: _nameController.text,
        age: _ageController.text,
        place: _placeController.text,
        mobile: _mobilenumberController.text,
        imageurl: _selectedImage != null ? _selectedImage!.path : null,
      );

      if (widget.model == null) {
        await addStudent(student);
      } else {
        student.id = widget.model!.id;
        await updateStudent(student);
      }
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (Route<dynamic> route) => false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.lightGreen,
            content: Text(
              'Student details added succesfully',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  // void showData() {
  //   if (widget.model != null) {
  //     _nameController.text = widget.model!.name!;
  //     _ageController.text = widget.model!.age!;
  //     _placeController.text = widget.model!.age!;
  //     _mobilenumberController.text = widget.model!.mobile!;

  //     if (widget.model!.imageurl != null) {
  //       _selectedImage = File(
  //         widget.model!.imageurl!,
  //       );
  //     }
  //   }
  // }
}
