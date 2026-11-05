import 'package:flutter/material.dart';

void main() => runApp(const MileageApp());

class MileageApp extends StatelessWidget {
  const MileageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mileage Calculator',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const MileagePage(),
    );
  }
}

class MileagePage extends StatefulWidget {
  const MileagePage({super.key});

  @override
  State<MileagePage> createState() => _MileagePageState();
}

class _MileagePageState extends State<MileagePage> {
  final _formKey = GlobalKey<FormState>();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _fuelCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _fuelType = 'Petrol';

  double? _distance, _mileage, _costPerKm;

  // Common validator: required, numeric and positive
  String? _validateNumber(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final number = double.tryParse(value);
    if (number == null) return 'Enter a valid number';
    if (number <= 0) return '$field must be greater than 0';
    return null;
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final start = double.parse(_startCtrl.text);
    final end = double.parse(_endCtrl.text);
    final fuel = double.parse(_fuelCtrl.text);
    final price = double.parse(_priceCtrl.text);
    setState(() {
      _distance = end - start;
      _mileage = _distance! / fuel;
      _costPerKm = (fuel * price) / _distance!;
    });
  }

  void _reset() {
    _formKey.currentState!.reset();
    for (final c in [_startCtrl, _endCtrl, _fuelCtrl, _priceCtrl]) {
      c.clear();
    }
    setState(() => _distance = _mileage = _costPerKm = null);
  }

  String get _rating {
    if (_mileage! >= 20) return 'Excellent';
    if (_mileage! >= 15) return 'Good';
    if (_mileage! >= 10) return 'Average';
    return 'Poor';
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? (v) => _validateNumber(v, label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Mileage Calculator'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _fuelType,
                decoration: const InputDecoration(
                  labelText: 'Fuel Type',
                  prefixIcon: Icon(Icons.local_gas_station),
                  border: OutlineInputBorder(),
                ),
                items: ['Petrol', 'Diesel', 'CNG']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => _fuelType = v!),
              ),
              const SizedBox(height: 12),
              _field(_startCtrl, 'Start Odometer (km)', Icons.speed),
              _field(_endCtrl, 'End Odometer (km)', Icons.speed,
                  validator: (v) {
                final error = _validateNumber(v, 'End reading');
                if (error != null) return error;
                final start = double.tryParse(_startCtrl.text) ?? 0;
                if (double.parse(v!) <= start) {
                  return 'Must be greater than start reading';
                }
                return null;
              }),
              _field(_fuelCtrl, 'Fuel Consumed (litres)', Icons.water_drop),
              _field(_priceCtrl, 'Fuel Price (₹/litre)', Icons.currency_rupee),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_mileage != null)
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('${_mileage!.toStringAsFixed(2)} km/l',
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold)),
                        Text('$_fuelType mileage  •  $_rating',
                            style: const TextStyle(fontSize: 16)),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _stat('Distance',
                                '${_distance!.toStringAsFixed(0)} km'),
                            _stat('Cost / km',
                                '₹${_costPerKm!.toStringAsFixed(2)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      );
}
