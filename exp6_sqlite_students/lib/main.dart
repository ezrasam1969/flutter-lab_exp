// pubspec.yaml -> dependencies:  sqflite: ^2.3.3   path: ^1.9.0
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() => runApp(const StudentApp());

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Records',
      theme: ThemeData(colorSchemeSeed: Colors.cyan, useMaterial3: true),
      home: const StudentPage(),
    );
  }
}

// Model class with conversion to and from a database row
class Student {
  final int? id;
  final String name, regNo, department;
  final double cgpa;
  Student({this.id, required this.name, required this.regNo,
      required this.department, required this.cgpa});

  Map<String, dynamic> toMap() =>
      {'id': id, 'name': name, 'regNo': regNo, 'department': department, 'cgpa': cgpa};

  factory Student.fromMap(Map<String, dynamic> m) => Student(
        id: m['id'] as int,
        name: m['name'] as String,
        regNo: m['regNo'] as String,
        department: m['department'] as String,
        cgpa: (m['cgpa'] as num).toDouble(),
      );
}

// Opens the database and performs Create and Read operations
class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await openDatabase(
      p.join(await getDatabasesPath(), 'students.db'),
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE students(id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'name TEXT NOT NULL, regNo TEXT UNIQUE NOT NULL, '
        'department TEXT NOT NULL, cgpa REAL NOT NULL)',
      ),
    );
    return _db!;
  }

  // CREATE
  static Future<int> insertStudent(Student s) async =>
      (await database).insert('students', s.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);

  // READ
  static Future<List<Student>> getStudents() async {
    final rows = await (await database).query('students', orderBy: 'id DESC');
    return rows.map(Student.fromMap).toList();
  }
}

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _regCtrl = TextEditingController();
  final _cgpaCtrl = TextEditingController();
  String _department = 'CSE';
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final data = await DatabaseHelper.getStudents();
    setState(() => _students = data);
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await DatabaseHelper.insertStudent(Student(
        name: _nameCtrl.text.trim(),
        regNo: _regCtrl.text.trim().toUpperCase(),
        department: _department,
        cgpa: double.parse(_cgpaCtrl.text),
      ));
      _formKey.currentState!.reset();
      _nameCtrl.clear();
      _regCtrl.clear();
      _cgpaCtrl.clear();
      _showMessage('Student saved successfully');
      _loadStudents();
    } on DatabaseException {
      _showMessage('Register number already exists');
    }
  }

  void _showMessage(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  InputDecoration _decor(String label, IconData icon) => InputDecoration(
      labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Records (SQLite)'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _decor('Student Name', Icons.person),
                    validator: (v) => v!.trim().isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _regCtrl,
                    decoration: _decor('Register Number', Icons.badge),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Enter register number' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _department,
                          decoration: _decor('Department', Icons.school),
                          items: ['CSE', 'AI&ML', 'ECE', 'EEE', 'MECH']
                              .map((d) =>
                                  DropdownMenuItem(value: d, child: Text(d)))
                              .toList(),
                          onChanged: (v) => setState(() => _department = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cgpaCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _decor('CGPA', Icons.grade),
                          validator: (v) {
                            final g = double.tryParse(v ?? '');
                            if (g == null || g < 0 || g > 10) return '0 – 10 only';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saveStudent,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Student'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Saved Records (${_students.length})',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _students.length,
              itemBuilder: (context, i) {
                final s = _students[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(s.name[0])),
                    title: Text(s.name),
                    subtitle: Text('${s.regNo}  •  ${s.department}'),
                    trailing: Text('CGPA ${s.cgpa.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
