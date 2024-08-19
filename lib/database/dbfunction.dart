import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:student_app/model/student_model.dart';

// ValueNotifier<List<StudentModel>> studentListNotifier = ValueNotifier([]);

late Database _db;

Future<void> initializeDatabase() async {
  // try {
  _db = await openDatabase(
    'student.db',
    version: 2,
    onCreate: (db, version) async {
      db.execute(
        'CREATE TABLE student (id INTEGER PRIMARY KEY,name TEXT,age INTEGER,place TEXT,mobile INTEGER,imageurl TEXT)',
      );
    },
  );
  log('database initialised');
  //   log('database initialised succesfully');

  // } catch (e) {
  //   log('error initializing database $e');
  // }
  await getAllStudents();
}

Future<void> addStudent(StudentModel value) async {
  await _db.rawInsert(
      'INSERT INTO student (id,name,age,place,mobile,imageurl) VALUES (?,?,?,?,?,?)',
      [
        value.id,
        value.name,
        // value.parent,
        value.age,
        value.place,
        value.mobile,
        value.imageurl,
      ]);
  log('student details added');
}

Future<List<Map<String, dynamic>>> getAllStudents() async {
  final values = await _db.rawQuery('SELECT * FROM student');
  log('$values');
  return values;
}

Future<void> deleteStudent(int id) async {
  await _db.rawDelete('DELETE FROM student WHERE id = ?', [id]);
  log('student data deleted');
  // getAllStudents();
}

Future<void> updateStudent(StudentModel updateStudent) async {
  await _db.rawUpdate(
    'UPDATE student SET name = ?,age = ?,place = ?,mobile = ?,imageurl = ? WHERE id = ?',
    [
      updateStudent.name,
      updateStudent.age,
      updateStudent.place,
      updateStudent.mobile,
      updateStudent.imageurl,
      updateStudent.id,
    ],
  );

  // getAllStudents();
  log('student details updated');
}



 // await _db.update(
  //   'student',
  //   {
  //     'imageurl': updateStudent.imageurl,
  //     'name': updateStudent.name,
  //     'age': updateStudent.age,
  //     'place': updateStudent.place,
  //     'mobile': updateStudent.mobile,
  //   },
  //   where: 'id = ?',
  //   whereArgs: [updateStudent.id],
  // );

  //  onUpgrade: (db, oldVersion, newVersion) async {
  //     if (oldVersion < 2) {
  //       await _db.execute('ALTER TABLE student ADD COLUMN country TEXT');
  //     }
  //   },