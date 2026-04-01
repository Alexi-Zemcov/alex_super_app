import 'package:flutter/material.dart';

import 'package:quiz/src/features/home/presentation/screens/home/home_destination.dart';

class HomeDestinationPlaceholderScreen extends StatelessWidget {
  const HomeDestinationPlaceholderScreen({
    required this.destination,
    super.key,
  });

  final HomeDestination destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(destination.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(destination.icon, size: 56),
              const SizedBox(height: 16),
              Text(
                destination.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Этот экран подключим следующим шагом.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
