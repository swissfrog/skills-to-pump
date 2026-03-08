import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const categories = [
    {'name': 'Housing', 'icon': Icons.home, 'color': Colors.blue},
    {'name': 'Career', 'icon': Icons.work, 'color': Colors.purple},
    {'name': 'Finance', 'icon': Icons.account_balance, 'color': Colors.green},
    {'name': 'Mobil', 'icon': Icons.directions_car, 'color': Colors.orange},
    {'name': 'Health', 'icon': Icons.favorite, 'color': Colors.red},
    {'name': 'Documents', 'icon': Icons.description, 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          return Card(
            color: (cat['color'] as Color).withOpacity(0.1),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'] as IconData, size: 40, color: cat['color'] as Color),
                  const SizedBox(height: 8),
                  Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}