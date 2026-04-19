import 'package:flutter/material.dart';

class MyInstrumentsEmptyState extends StatelessWidget {
  const MyInstrumentsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('my-instruments-empty-state'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF292B33)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Мои гитары пока пусты',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Настройте инструмент во вкладках "Гитара" или "Бас" и сохраните его кнопкой "Сохранить в мои гитары".',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}
