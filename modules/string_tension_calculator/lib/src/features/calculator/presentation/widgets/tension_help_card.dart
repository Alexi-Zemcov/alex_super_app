import 'package:flutter/material.dart';

class TensionHelpCard extends StatelessWidget {
  const TensionHelpCard({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF8D8D9D);

    return Container(
      key: const Key('calculator-help-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A33),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const Text(
            'Натяжение струн',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Цвет цифры натяжения струны показывает, насколько слабо или сильно натянута струна. '
            'Жёлтый означает более мягкое натяжение, красный — более тугое.',
            style: TextStyle(color: textColor, height: 1.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Обычные значения для гитар:',
            style: TextStyle(color: textColor, height: 1.4),
          ),
          const SizedBox(height: 8),
          const _HelpList(
            items: [
              '13 lbs. — лёгкое натяжение',
              '18 lbs. — обычное натяжение',
              '22 lbs. — сильное натяжение',
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Для басов:',
            style: TextStyle(color: textColor, height: 1.4),
          ),
          const SizedBox(height: 8),
          const _HelpList(
            items: [
              '31 lbs. — лёгкое натяжение',
              '40 lbs. — обычное натяжение',
              '49 lbs. — сильное натяжение',
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Значения ориентировочные и могут заметно отличаться в зависимости от инструмента и конструкции струны.',
            style: TextStyle(color: textColor, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFF00), Colors.white, Color(0xFFFF0000)],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ЛЕГЧЕ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'СИЛЬНЕЕ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpList extends StatelessWidget {
  const _HelpList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $item',
              style: const TextStyle(color: Color(0xFF8D8D9D), height: 1.4),
            ),
          ),
      ],
    );
  }
}
