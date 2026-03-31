import 'package:flutter/material.dart';

enum HomeDestinationTone { blue, red, dark }

enum HomeDestination { tickets, blitz, topics, marathon, errors, favorites }

extension HomeDestinationX on HomeDestination {
  String get title {
    switch (this) {
      case HomeDestination.tickets:
        return 'Билеты';
      case HomeDestination.blitz:
        return 'Блиц';
      case HomeDestination.topics:
        return 'Темы';
      case HomeDestination.marathon:
        return 'Марафон';
      case HomeDestination.errors:
        return 'Ошибки';
      case HomeDestination.favorites:
        return 'Избранное';
    }
  }

  IconData get icon {
    switch (this) {
      case HomeDestination.tickets:
        return Icons.confirmation_number_rounded;
      case HomeDestination.blitz:
        return Icons.bolt_rounded;
      case HomeDestination.topics:
        return Icons.menu_book_rounded;
      case HomeDestination.marathon:
        return Icons.timer_rounded;
      case HomeDestination.errors:
        return Icons.warning_amber_rounded;
      case HomeDestination.favorites:
        return Icons.star_rounded;
    }
  }

  HomeDestinationTone get tone {
    switch (this) {
      case HomeDestination.tickets:
        return HomeDestinationTone.blue;
      case HomeDestination.blitz:
        return HomeDestinationTone.red;
      case HomeDestination.topics:
      case HomeDestination.marathon:
      case HomeDestination.errors:
      case HomeDestination.favorites:
        return HomeDestinationTone.dark;
    }
  }
}
