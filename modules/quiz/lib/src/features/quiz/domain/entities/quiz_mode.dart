enum QuizMode { ticket, blitz, topic, marathon, errors, favorites }

extension QuizModeX on QuizMode {
  String get storageValue {
    switch (this) {
      case QuizMode.ticket:
        return 'ticket';
      case QuizMode.blitz:
        return 'blitz';
      case QuizMode.topic:
        return 'topic';
      case QuizMode.marathon:
        return 'marathon';
      case QuizMode.errors:
        return 'errors';
      case QuizMode.favorites:
        return 'favorites';
    }
  }

  String get title {
    switch (this) {
      case QuizMode.ticket:
        return 'Билет';
      case QuizMode.blitz:
        return 'Блиц';
      case QuizMode.topic:
        return 'Тема';
      case QuizMode.marathon:
        return 'Марафон';
      case QuizMode.errors:
        return 'Ошибки';
      case QuizMode.favorites:
        return 'Избранное';
    }
  }
}

QuizMode? parseQuizMode(String? rawValue) {
  switch (rawValue) {
    case 'ticket':
      return QuizMode.ticket;
    case 'blitz':
      return QuizMode.blitz;
    case 'topic':
      return QuizMode.topic;
    case 'marathon':
      return QuizMode.marathon;
    case 'errors':
      return QuizMode.errors;
    case 'favorites':
      return QuizMode.favorites;
    default:
      return null;
  }
}
