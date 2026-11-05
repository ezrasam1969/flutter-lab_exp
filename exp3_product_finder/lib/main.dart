import 'package:flutter/material.dart';

void main() => runApp(const SearchApp());

class SearchApp extends StatelessWidget {
  const SearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Finder',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const ProductSearchPage(),
    );
  }
}

class Item {
  final String name, category;
  final int price;
  const Item(this.name, this.category, this.price);
}

const List<Item> allItems = [
  Item('Cotton T-Shirt', 'Clothing', 499),
  Item('Denim Jeans', 'Clothing', 1299),
  Item('Running Shoes', 'Footwear', 2199),
  Item('Leather Sandals', 'Footwear', 899),
  Item('Wireless Earbuds', 'Electronics', 1999),
  Item('Power Bank', 'Electronics', 1099),
  Item('Smart Band', 'Electronics', 2499),
  Item('Flutter in Action', 'Books', 650),
  Item('Clean Code', 'Books', 720),
  Item('Water Bottle', 'Home', 349),
];

const List<String> filters = [
  'All', 'Clothing', 'Footwear', 'Electronics', 'Books', 'Home'
];

const Map<String, IconData> categoryIcons = {
  'Clothing': Icons.checkroom,
  'Footwear': Icons.directions_run,
  'Electronics': Icons.devices,
  'Books': Icons.menu_book,
  'Home': Icons.home_outlined,
};

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  // Apply both the search text and the category chip
  List<Item> get _filteredItems {
    return allItems.where((item) {
      final matchesText =
          item.name.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesText && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredItems;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Finder'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: filters.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = category),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${results.length} product(s) found',
                  style: const TextStyle(color: Colors.grey)),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No matching products'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final item = results[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(categoryIcons[item.category]),
                          ),
                          title: Text(item.name),
                          subtitle: Text(item.category),
                          trailing: Text('₹${item.price}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
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
