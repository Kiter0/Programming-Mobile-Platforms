import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/app_state.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatelessWidget {
  final AppState appState;

  const ProductsScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    final products = [
      const Product(
        id: 1,
        name: 'Навушники',
        description: 'Бездротові навушники з якісним звуком',
        price: 59.99,
        imageUrl:
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
      ),
      const Product(
        id: 2,
        name: 'Смарт-годинник',
        description: 'Сучасний годинник для щоденного використання',
        price: 129.99,
        imageUrl:
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
      ),
      const Product(
        id: 3,
        name: 'Ноутбук',
        description: 'Потужний ноутбук для роботи та навчання',
        price: 899.99,
        imageUrl:
            'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, child) {
          return Column(
            children: [
              _buildUserPanel(),
              _buildStatePanel(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ProductCard(
                        product: products[index],
                        appState: appState,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserPanel() {
    final user = appState.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatePanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade100,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStateItem(
            icon: Icons.favorite,
            title: 'Обране',
            value: appState.favorites.length.toString(),
          ),
          _buildStateItem(
            icon: Icons.shopping_cart,
            title: 'Кошик',
            value: appState.cartCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStateItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 28),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}