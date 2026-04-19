import 'package:equatable/equatable.dart';

enum SavedInstrumentKind { guitar, bass }

extension SavedInstrumentKindX on SavedInstrumentKind {
  static SavedInstrumentKind fromStorageValue(String value) {
    return switch (value) {
      'guitar' => SavedInstrumentKind.guitar,
      'bass' => SavedInstrumentKind.bass,
      _ => throw FormatException('Unsupported instrument kind: $value'),
    };
  }

  String get storageValue => name;
}

enum SavedStringSetId { dxl, k1 }

extension SavedStringSetIdX on SavedStringSetId {
  static SavedStringSetId fromStorageValue(String value) {
    return switch (value) {
      'dxl' => SavedStringSetId.dxl,
      'k1' => SavedStringSetId.k1,
      _ => throw FormatException('Unsupported string set id: $value'),
    };
  }

  String get storageValue => name;
}

class SavedInstrumentString extends Equatable {
  const SavedInstrumentString({
    required this.noteLabel,
    required this.scaleLengthInches,
    required this.physicalStringId,
    required this.gaugeInches,
  });

  factory SavedInstrumentString.fromJson(Map<String, dynamic> json) {
    return SavedInstrumentString(
      noteLabel: json['noteLabel'] as String,
      scaleLengthInches: (json['scaleLengthInches'] as num).toDouble(),
      physicalStringId: json['physicalStringId'] as int,
      gaugeInches: (json['gaugeInches'] as num).toDouble(),
    );
  }

  final String noteLabel;
  final double scaleLengthInches;
  final int physicalStringId;
  final double gaugeInches;

  Map<String, dynamic> toJson() {
    return {
      'noteLabel': noteLabel,
      'scaleLengthInches': scaleLengthInches,
      'physicalStringId': physicalStringId,
      'gaugeInches': gaugeInches,
    };
  }

  @override
  List<Object?> get props => [
    noteLabel,
    scaleLengthInches,
    physicalStringId,
    gaugeInches,
  ];
}

class SavedInstrumentRecord extends Equatable {
  SavedInstrumentRecord({
    required this.id,
    required this.name,
    required this.kind,
    required this.stringSetId,
    required List<SavedInstrumentString> strings,
    required this.createdAt,
    required this.updatedAt,
  }) : strings = List.unmodifiable(strings);

  factory SavedInstrumentRecord.fromJson(Map<String, dynamic> json) {
    final rawStrings = json['strings'] as List<dynamic>? ?? const [];
    return SavedInstrumentRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: SavedInstrumentKindX.fromStorageValue(json['kind'] as String),
      stringSetId: SavedStringSetIdX.fromStorageValue(
        json['stringSetId'] as String,
      ),
      strings: rawStrings
          .map(
            (item) => SavedInstrumentString.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String name;
  final SavedInstrumentKind kind;
  final SavedStringSetId stringSetId;
  final List<SavedInstrumentString> strings;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedInstrumentRecord copyWith({
    String? id,
    String? name,
    SavedInstrumentKind? kind,
    SavedStringSetId? stringSetId,
    List<SavedInstrumentString>? strings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedInstrumentRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      stringSetId: stringSetId ?? this.stringSetId,
      strings: strings ?? this.strings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kind': kind.storageValue,
      'stringSetId': stringSetId.storageValue,
      'strings': strings.map((item) => item.toJson()).toList(growable: false),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    kind,
    stringSetId,
    strings,
    createdAt,
    updatedAt,
  ];
}
