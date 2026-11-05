import 'package:flutter/material.dart';

void main() => runApp(const CatalogApp());

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopEase Catalog',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const CatalogPage(),
    );
  }
}

class Product {
  final String name, category;
  final double price, rating;
  final IconData icon;
  final Color color;
  const Product(this.name, this.category, this.price, this.rating, this.icon,
      this.color);
}

const List<Product> products = [
  Product('Wireless Headphones', 'Audio', 2499, 4.5, Icons.headphones, Colors.indigo),
  Product('Smart Watch', 'Wearables', 3999, 4.2, Icons.watch, Colors.teal),
  Product('Bluetooth Speaker', 'Audio', 1799, 4.4, Icons.speaker, Colors.deepOrange),
  Product('Android Phone', 'Mobiles', 15999, 4.6, Icons.phone_android, Colors.blue),
  Product('Laptop', 'Computers', 54999, 4.7, Icons.laptop_mac, Colors.blueGrey),
  Product('DSLR Camera', 'Cameras', 42999, 4.8, Icons.camera_alt, Colors.brown),
  Product('Keyboard', 'Accessories', 1299, 4.1, Icons.keyboard, Colors.purple),
  Product('Gaming Mouse', 'Accessories', 899, 4.3, Icons.mouse, Colors.red),
];

const List<String> categories = [
  'All', 'Audio', 'Mobiles', 'Computers', 'Wearables', 'Cameras', 'Accessories'
];

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  // Decide number of grid columns from the available width
  int _columnsFor(double width) {
    if (width < 600) return 2; // mobile
    if (width < 1000) return 3; // tablet
    return 4; // desktop / web
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopEase Catalog'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 16),
          Icon(Icons.shopping_cart_outlined),
          SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final grid = GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columnsFor(width),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: products.length,
            itemBuilder: (context, i) => ProductCard(product: products[i]),
          );

          // Wide screens get a category side panel beside the grid
          if (width >= 1000) {
            return Row(
              children: [
                const SizedBox(width: 220, child: CategoryPanel()),
                const VerticalDivider(width: 1),
                Expanded(child: grid),
              ],
            );
          }
          return grid;
        },
      ),
    );
  }
}

// Reusable side panel (shown only on large screens)
class CategoryPanel extends StatelessWidget {
  const CategoryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        for (final c in categories)
          ListTile(
            dense: true,
            selected: c == 'All',
            leading: const Icon(Icons.label_outline),
            title: Text(c),
          ),
      ],
    );
  }
}

// Reusable product card
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: product.color.withOpacity(0.12),
              child: Icon(product.icon, size: 64, color: product.color),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(product.category,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' ${product.rating}',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo)),
                    const Icon(Icons.add_shopping_cart,
                        size: 20, color: Colors.indigo),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
