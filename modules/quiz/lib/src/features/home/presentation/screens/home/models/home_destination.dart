import 'package:flutter/material.dart';
import 'package:quiz/src/features/home/presentation/screens/home/models/home_destination_tone.dart';
import 'package:quiz/src/navigation/quiz_flow_route_args.dart';
import 'package:quiz/src/navigation/quiz_route_names.dart';

enum HomeDestination {
  tickets,
  blitz,
  topics,
  marathon,
  errors,
  favorites;

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

extension HomeDestinationNavigationX on HomeDestination {
  String get routeName {
    switch (this) {
      case HomeDestination.tickets:
        return QuizRouteNames.tickets;
      case HomeDestination.blitz:
        return QuizRouteNames.quizFlow;
      case HomeDestination.topics:
        return QuizRouteNames.topics;
      case HomeDestination.marathon:
        return QuizRouteNames.marathon;
      case HomeDestination.errors:
        return QuizRouteNames.errors;
      case HomeDestination.favorites:
        return QuizRouteNames.favorites;
    }
  }

  Object? get routeArguments {
    switch (this) {
      case HomeDestination.blitz:
        return const QuizFlowRouteArgs.blitz();
      case HomeDestination.tickets:
      case HomeDestination.topics:
      case HomeDestination.marathon:
      case HomeDestination.errors:
      case HomeDestination.favorites:
        return null;
    }
  }
}
