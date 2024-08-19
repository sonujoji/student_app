class StudentModel {
  int? id;
  String? name;
  String? age;
  String? place;
  String? mobile;
  String? imageurl;
  // String? parent;

  StudentModel({
    this.id,
    required this.name,
    required this.age,
    required this.place,
    required this.mobile,
    required this.imageurl,
    // required this.parent,
  });

  // static StudentModel fromMap(Map<String, Object?> student) {
  //   return StudentModel(
  //     id: student['id'] as int,
  //     name: student['name'] as String,
  //     age: student['age'] as String,
  //     place: student['place'] as String,
  //     mobile: student['mobile'] as String,
  //     imageurl: student['image'] as String,
  //     // parent: student['parent'] as String,
  //   );
  // }
}
