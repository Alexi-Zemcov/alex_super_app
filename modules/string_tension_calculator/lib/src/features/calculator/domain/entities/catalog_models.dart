import 'package:equatable/equatable.dart';

enum InstrumentType {
  guitar,
  bass;

  String get titleRu => switch (this) {
    InstrumentType.guitar => 'Гитара',
    InstrumentType.bass => 'Бас',
  };
}

enum StringSetId { dxl, k1 }

enum WoundType {
  plain,
  wound;

  String get shortLabel => switch (this) {
    WoundType.plain => 'p',
    WoundType.wound => 'w',
  };
}

class PhysicalString extends Equatable {
  const PhysicalString({
    required this.id,
    required this.gaugeInches,
    required this.unitWeight,
    required this.woundType,
  });

  final int id;
  final double gaugeInches;
  final double unitWeight;
  final WoundType woundType;

  @override
  List<Object?> get props => [id, gaugeInches, unitWeight, woundType];
}

class StringSet extends Equatable {
  const StringSet({
    required this.id,
    required this.displayName,
    required this.instrumentTypes,
    required this.strings,
  });

  final StringSetId id;
  final String displayName;
  final List<InstrumentType> instrumentTypes;
  final List<PhysicalString> strings;

  @override
  List<Object?> get props => [id, displayName, instrumentTypes, strings];
}

enum ScalePresetKind { single, multiscale }

class ScalePreset extends Equatable {
  const ScalePreset.single(this.singleScaleInches)
    : kind = ScalePresetKind.single,
      multiscaleRange = null;

  const ScalePreset.multiscale(double fromInches, double toInches)
    : kind = ScalePresetKind.multiscale,
      singleScaleInches = null,
      multiscaleRange = (fromInches, toInches);

  final ScalePresetKind kind;
  final double? singleScaleInches;
  final (double fromInches, double toInches)? multiscaleRange;

  bool get isSingleScale => kind == ScalePresetKind.single;

  List<double> buildScales(int stringCount) {
    if (kind == ScalePresetKind.single) {
      final scale = singleScaleInches!;
      return List<double>.filled(stringCount, scale, growable: false);
    }

    final range = multiscaleRange!;
    final step = (range.$2 - range.$1) / (stringCount - 1);
    return List<double>.generate(
      stringCount,
      (index) => roundToDecimals(range.$1 + (step * index), 2),
      growable: false,
    );
  }

  String toLabelRu() {
    return switch (kind) {
      ScalePresetKind.single =>
        'Обычная мензура: ${formatDecimal(singleScaleInches!)}"',
      ScalePresetKind.multiscale =>
        'Мультимензура: ${formatDecimal(multiscaleRange!.$1)}" - ${formatDecimal(multiscaleRange!.$2)}"',
    };
  }

  @override
  List<Object?> get props => [kind, singleScaleInches, multiscaleRange];
}

double roundToDecimals(double value, int decimals) {
  final scale = _pow10(decimals);
  return (value * scale).round() / scale;
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

String formatDecimal(double value) {
  final fixed = value.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

String formatGauge(double value) {
  final tenThousandths = (value * 10000).round();
  final decimals = tenThousandths % 10 == 0 ? 3 : 4;
  return value.toStringAsFixed(decimals);
}
