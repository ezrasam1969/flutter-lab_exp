// pubspec.yaml -> dependencies:  firebase_core: ^3.6.0   cloud_firestore: ^5.4.4
// Uses the 'employees' collection created in Experiment 7
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SearchApp());
}

class SearchApp extends StatelessWidget {
  const SearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Search',
      theme: ThemeData(colorSchemeSeed: Colors.pink, useMaterial3: true),
      home: const SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchCtrl = TextEditingController();
  String _searchBy = 'Name';
  List<Map<String, dynamic>> _results = [];
  bool _loading = false, _searched = false;

  Future<void> _search() async {
    final text = _searchCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a value to search')));
      return;
    }
    setState(() => _loading = true);
    final col = FirebaseFirestore.instance.collection('employees');
    late Query<Map<String, dynamic>> query;

    if (_searchBy == 'Name') {
      // Prefix search: names starting with the typed text
      final s = text.toLowerCase();
      query = col.orderBy('nameLower').startAt([s]).endAt(['$s']);
    } else if (_searchBy == 'ID') {
      query = col.where('empId', isEqualTo: text.toUpperCase());
    } else {
      query = col.where('department', isEqualTo: text);
    }

    try {
      final snapshot = await query.get();
      setState(() => _results = snapshot.docs.map((d) => d.data()).toList());
    } catch (e) {
      setState(() => _results = []);
    } finally {
      setState(() {
        _loading = false;
        _searched = true;
      });
    }
  }

  Widget _info(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(text),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Search'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'Name', label: Text('Name'), icon: Icon(Icons.person)),
                ButtonSegment(
                    value: 'ID', label: Text('Emp ID'), icon: Icon(Icons.badge)),
                ButtonSegment(
                    value: 'Dept', label: Text('Dept'), icon: Icon(Icons.apartment)),
              ],
              selected: {_searchBy},
              onSelectionChanged: (s) => setState(() => _searchBy = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search by $_searchBy',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward), onPressed: _search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            if (_searched && !_loading)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('${_results.length} record(s) found',
                    style: const TextStyle(color: Colors.grey)),
              ),
            Expanded(
              child: _searched && _results.isEmpty && !_loading
                  ? const Center(child: Text('No matching employee in Firestore'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, i) {
                        final e = _results[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: Text(e['name'],
                                        style: const TextStyle(
                                            fontSize: 17, fontWeight: FontWeight.bold)),
                                  ),
                                  Chip(label: Text(e['empId'])),
                                ]),
                                _info(Icons.work_outline, e['designation']),
                                _info(Icons.apartment, e['department']),
                                _info(Icons.email_outlined, e['email']),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
