import 'package:flutter/material.dart';

import '../models/user.dart';
import '../widgets/custom_button.dart';
import '../widgets/profile_widget.dart';
import '../widgets/animated_counter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const user = User(
      name: 'Олексій Руденко',
      email: 'oleksii.rudenko@example.com',
      avatarUrl: 'https://i.pravatar.cc/300?img=12',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Widgets'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Custom Widgets',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Практична робота №5',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            const Text(
              'Expanded Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ProfileWidget(
              user: user,
              onEditPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Редагування профілю'),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Compact Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ProfileWidget(
              user: user,
              isCompact: true,
              onEditPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Редагування профілю'),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Button Components',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            CustomButton(
              text: 'Primary Button',
              style: CustomButtonStyle.primary,
              icon: const Icon(Icons.check),
              onPressed: () {},
            ),

            const SizedBox(height: 12),

            CustomButton(
              text: 'Secondary Button',
              style: CustomButtonStyle.secondary,
              icon: const Icon(Icons.star),
              onPressed: () {},
            ),

            const SizedBox(height: 12),

            CustomButton(
              text: 'Danger Button',
              style: CustomButtonStyle.danger,
              icon: const Icon(Icons.delete),
              onPressed: () {},
            ),

            const SizedBox(height: 12),

            CustomButton(
              text: 'Outline Button',
              style: CustomButtonStyle.outline,
              icon: const Icon(Icons.info),
              onPressed: () {},
            ),

            const SizedBox(height: 12),

            const CustomButton(
              text: 'Loading...',
              isLoading: true,
            ),
            
            const SizedBox(height: 24),

            const Text(
              'Stateful Widget',
               style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const AnimatedCounter(
               initialValue: 0,
               maxValue: 10,
               animationDuration: Duration(milliseconds: 500),
               primaryColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}