import 'package:flutter/material.dart';

void main() => runApp(const FruitApp());

class FruitApp extends StatelessWidget {
  const FruitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fruit Basket',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const FruitListPage(),
    );
  }
}

// Model class for a fruit item
class Fruit {
  final String name, emoji, origin;
  final double price;
  final Color color;
  const Fruit(this.name, this.emoji, this.origin, this.price, this.color);
}

const List<Fruit> fruits = [
  Fruit('Mango', '🥭', 'Salem, Tamil Nadu', 120, Color(0xFFFFB300)),
  Fruit('Banana', '🍌', 'Theni, Tamil Nadu', 50, Color(0xFFFDD835)),
  Fruit('Apple', '🍎', 'Shimla, Himachal', 180, Color(0xFFE53935)),
  Fruit('Grapes', '🍇', 'Nashik, Maharashtra', 90, Color(0xFF8E24AA)),
  Fruit('Orange', '🍊', 'Nagpur, Maharashtra', 80, Color(0xFFFB8C00)),
  Fruit('Watermelon', '🍉', 'Dindigul, Tamil Nadu', 40, Color(0xFF43A047)),
  Fruit('Pineapple', '🍍', 'Thrissur, Kerala', 70, Color(0xFFC0CA33)),
];

class FruitListPage extends StatelessWidget {
  const FruitListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruit Basket'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          HeaderBanner(count: fruits.length),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: fruits.length,
              itemBuilder: (context, index) => FruitCard(fruit: fruits[index]),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable widget 1: banner at the top of the screen
class HeaderBanner extends StatelessWidget {
  final int count;
  const HeaderBanner({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_basket, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fresh Fruits',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('$count items available today',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable widget 2: card that displays one fruit
class FruitCard extends StatelessWidget {
  final Fruit fruit;
  const FruitCard({super.key, required this.fruit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fruit.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Text(fruit.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fruit.name,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(fruit.origin,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${fruit.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32))),
                const Text('per kg',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
