// pubspec.yaml -> dependencies:  firebase_core: ^3.6.0   cloud_firestore: ^5.4.4
// Updates records in the 'employees' collection created in Experiment 7
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const UpdateApp());
}

class UpdateApp extends StatelessWidget {
  const UpdateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Update Employee',
      theme: ThemeData(colorSchemeSeed: Colors.blueGrey, useMaterial3: true),
      home: const UpdatePage(),
    );
  }
}

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _department = 'Development';
  DocumentReference<Map<String, dynamic>>? _docRef;
  Map<String, dynamic>? _updated;

  void _showMessage(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // Step 1: find the record by Employee ID and fill the form
  Future<void> _fetch() async {
    final snap = await FirebaseFirestore.instance
        .collection('employees')
        .where('empId', isEqualTo: _idCtrl.text.trim().toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      setState(() => _docRef = null);
      return _showMessage('No employee found with this ID');
    }
    final data = snap.docs.first.data();
    setState(() {
      _docRef = snap.docs.first.reference;
      _updated = null;
      _nameCtrl.text = data['name'];
      _roleCtrl.text = data['designation'];
      _emailCtrl.text = data['email'];
      _department = data['department'];
    });
  }

  // Step 2: write the edited values back to the same document
  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    await _docRef!.update({
      'name': _nameCtrl.text.trim(),
      'nameLower': _nameCtrl.text.trim().toLowerCase(),
      'designation': _roleCtrl.text.trim(),
      'department': _department,
      'email': _emailCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final fresh = await _docRef!.get(); // read back the updated record
    setState(() => _updated = fresh.data());
    _showMessage('Record updated successfully');
  }

  Widget _field(TextEditingController c, String label, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder()),
          validator: (v) => v!.trim().isEmpty ? '$label is required' : null,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Employee Record'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _idCtrl,
                decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _fetch, child: const Text('Fetch')),
          ]),
          const SizedBox(height: 16),
          if (_docRef != null)
            Form(
              key: _formKey,
              child: Column(children: [
                _field(_nameCtrl, 'Name', Icons.person),
                _field(_roleCtrl, 'Designation', Icons.work_outline),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    value: _department,
                    decoration: const InputDecoration(
                        labelText: 'Department',
                        prefixIcon: Icon(Icons.apartment),
                        border: OutlineInputBorder()),
                    items: ['Development', 'Testing', 'Design', 'HR', 'Marketing']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setState(() => _department = v!),
                  ),
                ),
                _field(_emailCtrl, 'Email', Icons.email_outlined),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _update,
                    icon: const Icon(Icons.update),
                    label: const Text('Update Record'),
                  ),
                ),
              ]),
            ),
          if (_updated != null)
            Card(
              margin: const EdgeInsets.only(top: 16),
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                title: Text('${_updated!['name']}  (${_updated!['empId']})'),
                subtitle: Text('${_updated!['designation']}\n'
                    '${_updated!['department']}  •  ${_updated!['email']}'),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }
}
