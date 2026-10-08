
import 'package:flutter/material.dart';

import '../utils/app_state.dart';
import '../utils/constants.dart';
import '../widgets/animated_counter.dart';
import '../widgets/custom_button.dart';
import '../widgets/profile_widget.dart';

class HomeScreen extends StatelessWidget {
  final AppState appState;

  const HomeScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.homeTitle),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Товари',
            icon: const Icon(Icons.shopping_bag),
            onPressed: () {
              Navigator.pushNamed(context, '/products');
            },
          ),
          IconButton(
            tooltip: 'Профіль',
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, child) {
          final user = appState.currentUser;

          if (user == null) {
            return const Center(
              child: Text('Користувача не знайдено'),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Custom Widgets',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
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
                        Navigator.pushNamed(context, '/profile');
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
                        Navigator.pushNamed(context, '/profile');
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Primary Button натиснуто'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    CustomButton(
                      text: 'Secondary Button',
                      style: CustomButtonStyle.secondary,
                      icon: const Icon(Icons.star),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Secondary Button натиснуто'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    CustomButton(
                      text: 'Danger Button',
                      style: CustomButtonStyle.danger,
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Danger Button натиснуто'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    CustomButton(
                      text: 'Outline Button',
                      style: CustomButtonStyle.outline,
                      icon: const Icon(Icons.info),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Outline Button натиснуто'),
                          ),
                        );
                      },
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
            ),
          );
        },
      ),
    );
  }
}