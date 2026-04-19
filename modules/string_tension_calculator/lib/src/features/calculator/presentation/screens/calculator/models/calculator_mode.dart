enum CalculatorMode { guitar, bass, myGuitars }

extension CalculatorModeX on CalculatorMode {
  bool get isManual => this != CalculatorMode.myGuitars;

  String get titleRu => switch (this) {
    CalculatorMode.guitar => 'Гитара',
    CalculatorMode.bass => 'Бас',
    CalculatorMode.myGuitars => 'Мои гитары',
  };
}
